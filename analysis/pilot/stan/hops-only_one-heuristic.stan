/*
* Non-hierarchical model of the probabilities for outcome proportion heuristic vs ground truth in the HOPs condition.
*/

functions {
  // outcome proportion heuristic
  real outcome_proportion(real[] draws) {
    // loop over draws because Stan does not allow vector argumentes to <
    vector[size(draws)] draws_less_than_zero;
    for (i in 1:size(draws)) {
      real curr_draw = draws[i]; // hack to cast vector[i] as a real
      draws_less_than_zero[i] = curr_draw < 0;
    }
    // find proportion of draws where the the difference B - A is less than zero (i.e., past games when team A won)
    return sum(draws_less_than_zero) / size(draws);
  }
}
data {
  int n;                    // total observations (i.e., trials)
  vector<lower=0, upper=100>[n] cles;           // the worker's response on each trial
  vector<lower=0, upper=1>[n] ground_truth;   // the ground truth cles value on each trial
  int n_draws;              // number of draws displayed in the HOPs per trial
  real draws[n, n_draws];   // multidimensional array of the difference between draws B - A shown in HOPs trials * draws
}
transformed data {
  vector[n] lo_cles = logit(cles / 100); // cles in log odds units
}
parameters {
  real<lower=0, upper=1> p_heuristic; // probability of outcome proportion heuristic, as opposed to ground truth
  real<lower=0> sigma;                // residual error
}
model {
  // log probabilities for each trial
  vector[n] lp_trial;
  // priors
  p_heuristic ~ beta(2, 2);   // => symmetric beta centered on 0.5: probability of outcome proportion heuristic, as opposed to ground truth
  sigma ~ normal(0, 1);       // => half-normal: residual error
  
  // for each trial, marginalize across heuristic predictions to find joint density of parameters given the data (prior * likelihood)
  for (i in 1:n) {
    // prior * likelihood (averaging across possible heuristics)
    lp_trial[i] = log(1 - p_heuristic) + normal_lpdf(lo_cles[i] | logit(ground_truth[i]), sigma);           // ground truth
    lp_trial[i] += log(p_heuristic) + normal_lpdf(lo_cles[i] | logit(outcome_proportion(draws[i])), sigma); // outcome proportion heuristic
  }
  target += log_sum_exp(lp_trial);
}
// generated quantities {
//   vector[n] heuristic_est[2]; // estimates for each heuristic on each trial
//   for (i in 1:n) {
//     // calculate heuristic estimates
//     heuristic_est[1, i] = ground_truth[i];
//     heuristic_est[2, i] = outcome_proportion(draws[i]);
//   }
// }
