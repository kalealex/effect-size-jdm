/*
* Non-hierarchical model of the probabilities for each heuristic in the HOPs condition.
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
  int n;                    // total observations (i.e., trials)
  vector[n] cles;           // the worker's response on each trial
  vector[n] ground_truth;   // the ground truth cles value on each trial
  int n_heuristic;          // number of alternative heuristics in the model
  int n_draws;              // number of draws displayed in the HOPs per trial
  real draws[n, n_draws];   // multidimensional array of the difference between draws B - A shown in HOPs trials * draws
}
transformed data {
  vector[n] lo_cles;        // cles in log odds units
  lo_cles = logit(cles / 100);
}
parameters {
  vector[n_heuristic] mu_lo_heuristic;  // mean log odds of each heuristic (to be transformed into probabilities)
  real<lower=0> sigma;                  // residual error
}
transformed parameters {
  simplex[n_heuristic] p_heuristic = softmax(mu_lo_heuristic);  // multinomial probabilities for each heuristic
}
model {
  // log probabilities for each trial
  vector[n] lp_trial;
  // priors
  mu_lo_heuristic ~ normal(0, 1); // => normal (log odds units)
  sigma ~ normal(0, 1);           // => half-normal
  
  // for each trial, marginalize across heuristic predictions to find joint density of parameters given the data (prior * likelihood)
  for (i in 1:n) {
    // prior * likelihood (averaging across possible heuristics)
    lp_trial[i] = log(p_heuristic[1]) + normal_lpdf(lo_cles[i] | logit(ground_truth[i]), sigma);                              // ground truth
    lp_trial[i] += log(p_heuristic[2]) + normal_lpdf(lo_cles[i] | logit(outcome_proportion(draws[i])), sigma);                // outcome proportion heuristic
    lp_trial[i] += log(p_heuristic[3]) + normal_lpdf(lo_cles[i] | logit(outcome_proportion(draws[i, :10])), sigma);           // outcome proportion heuristic for first ten draws (maybe learn first n as a parameter)
    lp_trial[i] += log(p_heuristic[4]) + normal_lpdf(lo_cles[i] | logit(means_first_then_uncertainty_hops(draws[i])), sigma); // ensemble mean / spread
  }
  target += log_sum_exp(lp_trial);
}
