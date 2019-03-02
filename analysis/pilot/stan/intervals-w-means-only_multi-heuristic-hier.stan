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
  // relative mean difference heuristic
  real relative_mean_difference(real mean_diff, real max_abs_mean_diff) {
    return(est_in_bounds(0.5 - 0.5 * mean_diff / max_abs_mean_diff));
  }
  // mean difference relative to axis range
  real mean_difference_vs_axis(real mean_diff, real axis_range) {
    return(est_in_bounds(0.5 - 0.5 * mean_diff / axis_range));
  }
  // mean difference / interval length heuristic
  real means_first_then_uncertainty_intervals(real mean_diff, real sd_team) {
    real interval_length = inv_Phi(0.975) * sd_team - inv_Phi(0.025) * sd_team; // assuming that the two intervals are the same length, so we don't need to take their average
    // scaling factor for uncertainty information (Change this to a parameter?)
    real scale_uncertainty = 0.5;
    return(est_in_bounds(0.5 - 0.5 * mean_diff / (scale_uncertainty * interval_length)));
  }
  // interval overlap relative to interval length
  real interval_overlap_vs_length(real mean_diff, real sd_team) {
    real interval_length = inv_Phi(0.975) * sd_team - inv_Phi(0.025) * sd_team; // assuming that the two intervals are the same length, so we don't need to take their average
    real mean_teamA = - mean_diff / 2; // team means relative to center
    real mean_teamB = mean_diff / 2;
    // heuristic estimate depends on which mean is larger
    if(mean_teamA > mean_teamB) {
      real interval_overlap = (mean_teamB + interval_length / 2) - (mean_teamA - interval_length / 2); // upper bound of lower dist minus lower bound of higher dist
      return(est_in_bounds(1.0 - 0.5 * interval_overlap / interval_length));
    } else { // mean_teamA < mean_teamB
      real interval_overlap = (mean_teamA + interval_length / 2) - (mean_teamB - interval_length / 2); // upper bound of lower dist minus lower bound of higher dist
      return(est_in_bounds(0.5 * interval_overlap / interval_length));
    }
  }
  // interval overlap relative to axis range
  real interval_overlap_vs_axis(real mean_diff, real sd_team, real axis_range) {
    real interval_length = inv_Phi(0.975) * sd_team - inv_Phi(0.025) * sd_team; // assuming that the two intervals are the same length, so we don't need to take their average
    real mean_teamA = - mean_diff / 2; // team means relative to center
    real mean_teamB = mean_diff / 2;
    // heuristic estimate depends on which mean is larger
    if(mean_teamA > mean_teamB) {
      real interval_overlap = (mean_teamB + interval_length / 2) - (mean_teamA - interval_length / 2); // upper bound of lower dist minus lower bound of higher dist
      return(est_in_bounds(1.0 - 0.5 * interval_overlap / axis_range));
    } else { // mean_teamA < mean_teamB
      real interval_overlap = (mean_teamA + interval_length / 2) - (mean_teamB - interval_length / 2); // upper bound of lower dist minus lower bound of higher dist
      return(est_in_bounds(0.5 * interval_overlap / axis_range));
    }
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
  vector[n] mean_diff;           // mean difference on each trial
  real max_abs_mean_diff;        // the maximum absolute mean difference shown across all trial
  real axis_range;               // the range of the x-axis for all trials
  vector[n] sd_team;             // the sd of the distribution of scores for each team on each trial
}
transformed data {
  vector[n] lo_cles = logit(cles / 100); // cles in log odds units
}
parameters {
  vector<lower=0>[n_heuristic] sigma_scale;             // scaling factor for non-centered parameterization of multivariate normal
  real<lower=0> sigma_err;                              // residual error
  // hyperparameters
  vector[n_heuristic] mu_lo_heuristic;                  // population mean of log odds for each heuristic
  corr_matrix[n_heuristic] Omega;                       // correlation maxtrix for the log odds of each heuristic (p_heuristic is a set of correlated values)
  vector<lower=0>[n_heuristic] sigma_lo_heuristic;      // population sd of log odds for each heuristic
}
transformed parameters {
  cov_matrix[n_heuristic] Sigma = quad_form_diag(Omega, sigma_lo_heuristic); // covariance matrix for log odds of each heuristic
  matrix[n_heuristic, n_heuristic] L = cholesky_decompose(Sigma);            // Cholesky factorization of the covariance matrix (for non-centered parameterization)
  simplex[n_heuristic] p_heuristic[n_worker];                                // multinomial probabilities for each heuristic, per worker
  for (i in 1:n_worker) {
    vector[n_heuristic] lo_heuristic_worker; // mean log odds of each heuristic (for current worker)
    lo_heuristic_worker = mu_lo_heuristic + L * sigma_scale; // implies: lo_heuristic_worker ~ multi_normal(mu_lo_heuristic, Sigma)
    p_heuristic[i, :] = softmax(lo_heuristic_worker);
  }
}
model {
  // log probabilities for each trial
  vector[n] lp_trial;
  // priors (log odds units)
  sigma_scale ~ std_normal(); // => half-normal 
  sigma_err ~ std_normal();   // => half-normal 
  // hyperpriors (log odds units)
  mu_lo_heuristic ~ std_normal();     // => normal
  Omega ~ lkj_corr(1);                // LKJ correlation matrix
  sigma_lo_heuristic ~ std_normal();  // => half-normal 
  
  // for each trial, marginalize across heuristic predictions to find joint density of parameters given the data (prior * likelihood)
  for (i in 1:n) {
    // prior * likelihood (averaging across possible heuristics)
    lp_trial[i] = log(p_heuristic[worker[i], 1]) + normal_lpdf(lo_cles[i] | logit(ground_truth[i]), sigma_err);                                                   // ground truth
    lp_trial[i] += log(p_heuristic[worker[i], 2]) + normal_lpdf(lo_cles[i] | logit(relative_mean_difference(mean_diff[i], max_abs_mean_diff)), sigma_err);        // relative mean difference
    lp_trial[i] += log(p_heuristic[worker[i], 3]) + normal_lpdf(lo_cles[i] | logit(mean_difference_vs_axis(mean_diff[i], axis_range)), sigma_err);                // mean difference vs axis range
    lp_trial[i] += log(p_heuristic[worker[i], 4]) + normal_lpdf(lo_cles[i] | logit(means_first_then_uncertainty_intervals(mean_diff[i], sd_team[i])), sigma_err); // mean difference / interval length
    lp_trial[i] += log(p_heuristic[worker[i], 5]) + normal_lpdf(lo_cles[i] | logit(interval_overlap_vs_length(mean_diff[i], sd_team[i])), sigma_err);             // interval overlap relative to interval length
    lp_trial[i] += log(p_heuristic[worker[i], 6]) + normal_lpdf(lo_cles[i] | logit(interval_overlap_vs_axis(mean_diff[i], sd_team[i], axis_range)), sigma_err);   // interval overlap relative to axis range
  }
  target += log_sum_exp(lp_trial);
}
generated quantities {
  simplex[n_heuristic] p_heuristic_hat = softmax(mu_lo_heuristic + L * sigma_scale); // posterior predictions for probabilities of each heuristic
}
