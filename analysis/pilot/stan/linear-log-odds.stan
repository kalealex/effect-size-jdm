/*
* Linear regression of cles judgments in linear log odds units
*/

data {
  int n; // total observations
  int n_condition;
  int n_worker_id;
  vector[n] cles; // the response
  vector[n] ground_truth; // predictors
  int condition[n];
  int worker_id[n];  
}
transformed data {
  vector[n] lo_cles; // cles and ground_truth in log odds units
  vector[n] lo_ground_truth;
  lo_cles = logit(cles / 100);
  lo_ground_truth = logit(ground_truth);
}
parameters {
  vector[n_condition] alpha; // intercept (crossover point)
  vector[n_condition] beta; // coefficients for vis conds (slopes in LLO space)
  real<lower=0> sigma; // residual error
}
model {  
  // priors
  alpha ~ normal(1, 2); // center prior for crossover point on logit(0.5)
  beta ~ normal(0, 2);
  sigma ~ cauchy(0, 2);
  
  // likelihood
  for (i in 1:n) {
    lo_cles[i] ~ normal(beta[condition[i]] * lo_ground_truth[i] + alpha[condition[i]], sigma);
  }
}
