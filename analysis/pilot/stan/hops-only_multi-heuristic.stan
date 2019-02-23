/*
* Non-hierarchical model of the probabilities for each heuristic in the HOPs condition.
*/

functions {
  // outcome proportion heuristic
  real outcome_proportion(vector draws) {
    return sum(draws < 0) / size(draws);
  }
  // # means to inform reliability, sd for baseline heuristic (both mean and sd inferred from draws through ensemble processing)
  real means_first_then_uncertainty_hops(vector draws) {
    // ensemble statistics from draws
    vector[size(draws)] mean_diff;
    vector[size(draws)] outcome_diff_span;
    vector[size(draws)] outcome_span;
    mean_diff = mean(draws);
    outcome_diff_span = max(draws) - min(draws);
    outcome_span = sqrt((outcome_diff_span ^ 2) / 2); // avg span of outcomes for each team (what workers actually see)
    // scaling factor for uncertainty information (change this to a parameter?)
    real scale_uncertainty;
    scale_uncertainty = 0.5; // rationale: how does mean_diff compare to the maximum distance of from any draw to the mean?
    return 0.5 - 0.5 * mean_diff / (scale_uncertainty * outcome_span);
  }
}
data {
  int n;                    // total observations (i.e., trials)
  vector[n] cles;           // the worker's response on each trial
  vector[n] ground_truth;   // the ground truth cles value on each trial
  int n_heuristic;          // number of alternative heuristics in the model
  int n_draws;              // number of draws displayed in the HOPs per trial
  vector[n_draws] draws[n]; // an array of vectors of draws with one index per trial (more efficient than a matrix according to https://mc-stan.org/docs/2_18/stan-users-guide/indexing-efficiency-section.html)
}
transformed data {
  vector[n] lo_cles; // cles in log odds units
  lo_cles = logit(cles / 100);
}
parameters {
  vector<lower=0, upper=1>[n_heuristic] p_heuristic; // probabilities of each heuristic
  real<lower=0> sigma;                               // residual error
}
model {
  // priors
  // need a prior for p_heuristic //
  sigma ~ normal(0, 1);   // => half-normal
  
  // 1) assign heuristic predictions and 2) likelihood of joint distribution of parameters given the data, both for each trial
  vector[n_heuristic] mu_heuristic[n];      // array of heuristic predictions (means) on each trial
  for (i in 1:n) {
    // heuristic submodels (run on predictors for the current trial)
    mu_heuristic[i, 1] = ground_truth[i];
    mu_heuristic[i, 2] = outcome_proportion(draws[i]);
    mu_heuristic[i, 3] = outcome_proportion(draws[i, :10]); // first ten draws only (maybe learn first n as a parameter)
    mu_heuristic[i, 4] = means_first_then_uncertainty_hops(draws[i]);
    // transform heuristic predictions to log odds units
    mu_heuristic = logit(mu_heuristic);
    // likelihood (averaging across possible heuristics)
    for (j in 1:n_heuristic) {
      target += lp_heuristic[i, j] + normal_lpdf(lo_cles[i] | mu_heuristic[i, j], sigma);
    }
  }
}
