/*
* Hierarchical model of the probabilities for each heuristic in the HOPs condition.
*/

functions {
  // helper function to guarantee that predictions are between 0 and 1
  real est_in_bounds(real est_cles) {
    // catch out-of-bounds probabilities by setting min and max return values
    if (est_cles < 0.0025) {
      return 0.0025;
    } else if (est_cles > 0.9975) {
      return 0.9975;
    }
    // otherwise, return heuristic estimate
    return est_cles;
  }
  // outcome proportion heuristic
  real outcome_proportion(real[] draws) {
    // loop over draws because Stan does not allow vector argumentes to <
    vector[size(draws)] draws_less_than_zero;
    for (i in 1:size(draws)) {
      real curr_draw = draws[i]; // hack to cast vector[i] as a real
      draws_less_than_zero[i] = curr_draw < 0;
    }
    // heursitic estimate: proportion of draws where the the difference B - A is less than zero (i.e., past games when team A won)
    return est_in_bounds(sum(draws_less_than_zero) / size(draws));
  }
  // # means to inform reliability, sd for baseline heuristic (both mean and sd inferred from draws through ensemble processing)
  real means_first_then_uncertainty_hops(real[] draws) {
    // ensemble statistics from draws
    real mean_diff = mean(draws);
    real outcome_span = sqrt(((max(draws) - min(draws)) ^ 2) / 2); // avg span of outcomes for each team (what workers actually see)
    // scaling factor for uncertainty information (Change this to a parameter?)
    real scale_uncertainty = 0.5;
    // heuristic estimate: mean_difference as a portion of average outcome span for the two teams
    return est_in_bounds(0.5 - 0.5 * mean_diff / (scale_uncertainty * outcome_span));
  }
}
data {
  int n;                         // total observations (i.e., trials)
  vector[n] cles;                // the worker's response on each trial
  vector[n] ground_truth;        // the ground truth cles value on each trial
  int n_worker;                  // the number of workers in the sample
  int worker[n];                 // worker index on each trial
  int n_heuristic;               // number of alternative heuristics in the model
  vector[n_heuristic] heuristic; // index for each heuristic (to use with spread_draws)
  int n_draws;                   // number of draws displayed in the HOPs per trial
  real draws[n, n_draws];        // multidimensional array of the difference between draws B - A shown in HOPs trials * draws
}
transformed data {
  vector[n] lo_cles = logit(cles / 100); // cles in log odds units
}
parameters {
  vector<lower=0>[n_heuristic] z[n_worker];             // scaling factor for non-centered parameterization of multivariate normal
  real<lower=0> sigma_err;                              // residual error
  // hyperparameters
  vector[n_heuristic] mu_lo_heuristic;                  // population mean of log odds for each heuristic
  corr_matrix[n_heuristic] Omega;                       // correlation maxtrix for the log odds of each heuristic (p_heuristic is a set of correlated values)
  vector<lower=0>[n_heuristic] sigma_lo_heuristic;      // population sd of log odds for each heuristic
}
transformed parameters {
  cov_matrix[n_heuristic] Sigma = quad_form_diag(Omega, sigma_lo_heuristic); // covariance matrix for log odds of each heuristic
  matrix[n_heuristic, n_heuristic] L = cholesky_decompose(Sigma);            // Cholesky factorization of the covariance matrix (for non-centered parameterization)
  vector[n_heuristic] lo_heuristic_worker[n_worker];                         // mean log odds of each heuristic, per worker
  simplex[n_heuristic] p_heuristic[n_worker];                                // multinomial probabilities for each heuristic, per worker
  for (i in 1:n_worker) {
    lo_heuristic_worker[i, :] = mu_lo_heuristic + L * z[i, :]; // implies: lo_heuristic_worker ~ multi_normal(mu_lo_heuristic, Sigma)
    p_heuristic[i, :] = softmax(lo_heuristic_worker[i, :]);
  }
}
model {
  // log probabilities for each trial
  vector[n] lp_trial;
  // priors (log odds units)
  for (i in 1:n_worker) {
    z[i, :] ~ std_normal();   // => half-normal
  }
  sigma_err ~ std_normal();   // => half-normal 
  // hyperpriors (log odds units)
  mu_lo_heuristic ~ std_normal();     // => normal
  Omega ~ lkj_corr(1);                // LKJ correlation matrix
  sigma_lo_heuristic ~ std_normal();  // => half-normal 
  
  // for each trial, marginalize across heuristic predictions to find joint density of parameters given the data (prior * likelihood)
  for (i in 1:n) {
    // prior * likelihood (averaging across possible heuristics)
    lp_trial[i] = log(p_heuristic[worker[i], 1]) + normal_lpdf(lo_cles[i] | logit(ground_truth[i]), sigma_err);                               // ground truth
    lp_trial[i] += log(p_heuristic[worker[i], 2]) + normal_lpdf(lo_cles[i] | logit(outcome_proportion(draws[i])), sigma_err);                 // outcome proportion heuristic
    lp_trial[i] += log(p_heuristic[worker[i], 3]) + normal_lpdf(lo_cles[i] | logit(outcome_proportion(draws[i, :10])), sigma_err);            // outcome proportion heuristic for first ten draws (maybe learn first n as a parameter)
    lp_trial[i] += log(p_heuristic[worker[i], 4]) + normal_lpdf(lo_cles[i] | logit(means_first_then_uncertainty_hops(draws[i])), sigma_err);  // ensemble mean / spread
  }
  target += log_sum_exp(lp_trial);
}
generated quantities {
  simplex[n_heuristic] mu_p_heuristic = softmax(mu_lo_heuristic); // posterior probilities for each heuristic
  simplex[n_heuristic] p_heuristic_hat[n];                        // posterior predictions for probabilities of each heuristic on each trial
  for (i in 1:n) {
    p_heuristic_hat[i, :] = softmax(mu_lo_heuristic + L * z[worker[i], :]);
  }
}
