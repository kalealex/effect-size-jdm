library(readr)
library(tidyverse)
library(RColorBrewer)
library(rstan)
library(modelr)
library(tidybayes)
library(brms)
library(ggpubr)

##Loading data and models

# read in data 
model_df <- read_csv("../analysis/model-data.csv")

# preprocessing
model_df <- model_df %>% 
  mutate(
    # factors for modeling
    means = as.factor(means),
    start_means = as.factor(start_means),
    sd_diff = as.factor(sd_diff),
    # evidence scale for decision model
    p_diff = p_award_with - (p_award_without + (1 / award_value)),
    evidence = qlogis(p_award_with) - qlogis(p_award_without + (1 / award_value))
  )

# p superiority model
m.p_sup <- brm(data = model_df, family = "gaussian",
               formula = bf(lo_p_sup ~  (1 + lo_ground_truth*trial + means*sd_diff|worker_id) + lo_ground_truth*means*sd_diff*condition*start_means + lo_ground_truth*condition*trial,
                            sigma ~ (1 + lo_ground_truth + trial|worker_id) + lo_ground_truth*condition*trial + means*start_means),
               prior = c(prior(normal(1, 0.5), class = b),
                         prior(normal(1.3, 1), class = Intercept),
                         prior(normal(0, 0.15), class = sd, group = worker_id),
                         prior(normal(0, 0.3), class = b, dpar = sigma),
                         prior(normal(0, 0.15), class = sd, dpar = sigma),
                         prior(lkj(4), class = cor)),
               iter = 12000, warmup = 2000, chains = 2, cores = 2, thin = 2,
               control = list(adapt_delta = 0.99, max_treedepth = 12),
               file = "../analysis/model-fits/llo_mdl-min-r_means_sd_trial_block_sigma_gt_trial_means_block")

# intervention decision model
m.decisions <- brm(
  data = model_df, family = bernoulli(link = "logit"),
  formula = bf(intervene ~ (1 + evidence*means*sd_diff + evidence*trial|worker_id) + evidence*means*sd_diff*condition*start_means + evidence*trial),
  prior = c(prior(normal(0, 1), class = Intercept),
            prior(normal(1, 1), class = b, coef = evidence),
            prior(normal(0, 0.5), class = b),
            prior(normal(0, 0.5), class = sd),
            prior(lkj(4), class = cor)),
  iter = 8000, warmup = 2000, chains = 2, cores = 2, thin = 2,
  file = "../analysis/model-fits/logistic_mdl-min_order-r_means_sd_trial-long_chains")


##LLO explainer

# generate fake LLO model parameters to show a gradient of slops
fake_llo_df <- data.frame(
    "intercept" = 0,
    "slope" = seq(0.35, 1.65, length.out = 7)
  ) %>%
  mutate(ground_truth = list(seq(0.01, 0.99, length.out = 101))) %>%
  unnest(cols = c("ground_truth")) %>%
  mutate(
    lo_ground_truth = qlogis(ground_truth),
    lo_response = intercept + slope * lo_ground_truth,
    response = plogis(lo_response),
    slope = as.ordered(slope)
  )

# mean slope and intercept in each condition fake LLO model parameters to show a gradient of slops
vis_fits_df <- data.frame(
  "intercept" = c(0.003426065, -0.009079539, 0.006064548, 0.007080837),
  "slope" = c(0.4338522, 0.3938609, 0.3506741, 0.5656542),
  "Condition" = c("Densities", "HOPs", "Intervals", "Quantile Dotplots")
) %>%
  mutate(ground_truth = list(seq(0.01, 0.99, length.out = 101))) %>%
  unnest(cols = c("ground_truth")) %>%
  mutate(
    lo_ground_truth = qlogis(ground_truth),
    lo_response = intercept + slope * lo_ground_truth,
    response = plogis(lo_response),
    slope = as.ordered(slope)
  )

# fit for one worker
wrkr_df <- model_df %>%
  filter(worker_id == "fd3bea1b")
wrkr_fit_df <- wrkr_df %>%
  group_by(worker_id, means, sd_diff, condition, trial, start_means) %>%
  data_grid(lo_ground_truth = seq(-3, 3, length.out = 51)) %>%
  add_predicted_draws(model = m.p_sup, n = 500, seed = 1234) %>%
  rename(lo_prediction = .prediction) %>%  # predictions are in log odss units
  mutate(
    ground_truth = plogis(lo_ground_truth),
    prediction = plogis(lo_prediction)
  )

# generate plots
# vis conditions vs range of possibilities
lo_plt1 <- fake_llo_df %>%
  ggplot(aes(x = lo_ground_truth, y = lo_response, group = slope)) +
  geom_line(alpha = 0.25, show.legend = FALSE) +
  geom_line(data = vis_fits_df, mapping = aes(color = Condition), show.legend = FALSE) +
  scale_colour_brewer(type = "qual", palette = 2) +
  coord_cartesian(
    xlim = c(-3, 3),
    ylim = c(-3, 3)
  ) + 
  theme_minimal() +
  theme(panel.grid.minor = element_blank())
p_plt1 <- fake_llo_df %>%
  ggplot(aes(x = ground_truth, y = response, group = slope)) +
  geom_line(alpha = 0.25, show.legend = FALSE) +
  geom_line(data = vis_fits_df, mapping = aes(color = Condition), show.legend = FALSE) +
  scale_colour_brewer(type = "qual", palette = 2) +
  coord_cartesian(
    xlim = c(0.0474, 0.9526),
    ylim = c(0.0474, 0.9526)
  ) + 
  theme_minimal() +
  theme(panel.grid.minor = element_blank())
# fit for individual worker
lo_plt2 <- wrkr_fit_df %>%
  ggplot(aes(x = lo_ground_truth, y = lo_prediction)) +
  geom_abline(intercept = 0, slope = 1, size = 1, alpha = .25, linetype = "dashed") + # ground truth
  stat_lineribbon(.width = c(.95, .80, .50), fill = "gray", alpha = .25) +
  geom_point(data = wrkr_df, aes(y = lo_p_sup)) +
  coord_cartesian(
    xlim = c(-3, 3),
    ylim = c(-3, 3)
  ) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())
p_plt2 <- wrkr_fit_df %>%
  ggplot(aes(x = ground_truth, y = prediction)) +
  geom_abline(intercept = 0, slope = 1, size = 1, alpha = .25, linetype = "dashed") + # ground truth
  stat_lineribbon(.width = c(.95, .80, .50), fill = "gray", alpha = .25) +
  geom_point(data = wrkr_df, aes(y = p_superiority / 100)) +
  coord_cartesian(
    xlim = c(0.0474, 0.9526),
    ylim = c(0.0474, 0.9526)
  ) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

# compose image
llo_explainer <- ggarrange(lo_plt1, p_plt1, lo_plt2, p_plt2, ncol = 2, nrow = 2)
ggsave(file = "components/llo_explainer.svg", plot = llo_explainer, width=10, height=8)


##Results: LLO Slopes

# get expected slopes
llo_slopes_df <- model_df %>%
  group_by(means, sd_diff, condition, trial, start_means) %>%
  data_grid(lo_ground_truth = c(0, 1)) %>%                      # get fitted draws (in log odds units) only for ground truth of 0 and 1
  add_fitted_draws(m.p_sup, re_formula = NA) %>%
  compare_levels(.value, by = lo_ground_truth) %>%              # calculate the difference between fits at 1 and 0 (i.e., slope)
  rename(slope = .value)

# interaction effect
llo_interaction_plt <- llo_slopes_df %>%
  group_by(means, sd_diff, condition, .draw) %>%   # group by predictors to keep
  summarise(slope = weighted.mean(slope)) %>%      # marginalize out other predictors by taking a weighted average
  ggplot(aes(x = slope, y = condition, group = means, fill = means)) +
  stat_slabh(alpha = 0.35) +
  labs(
    x = "Slope",
    y = "Visualization",
    fill = "Means Added"
  ) +
  theme_minimal() +
  facet_grid(. ~ sd_diff)
# save
ggsave(file = "components/llo_slopes-interaction.svg", plot = llo_interaction_plt, width=5, height=1.33)

# marginal effect of visualization
llo_vis_plt <- llo_slopes_df %>%
  group_by(condition, .draw) %>%                    # group by predictors to keep
  summarise(slope = weighted.mean(slope)) %>%       # marginalize out means present/absent by taking a weighted average
  ggplot(aes(x = slope, y = condition, fill = condition)) +
  stat_slabh(alpha = 0.35) +
  scale_fill_brewer(type = "qual", palette = 2) +
  theme_minimal() +
  theme(legend.position = "none")
# save
ggsave(file = "components/llo_slopes-vis_conditions.svg", plot = llo_vis_plt, width=2.5, height=1.33)

##Results: PSE

# calculate PSE from slopes and intercepts of logisitic model
slopes_df <- model_df %>%
  group_by(means, sd_diff, condition, trial, start_means) %>%
  data_grid(evidence = c(0, 1)) %>%
  add_fitted_draws(m.decisions, re_formula = NA, scale = "linear", seed = 1234) %>%
  compare_levels(.value, by = evidence) %>%
  rename(slope = .value)
intercepts_df <- model_df %>%
  group_by(means, sd_diff, condition, trial, start_means) %>%
  data_grid(evidence = 0) %>%
  add_fitted_draws(m.decisions, re_formula = NA, scale = "linear", seed = 1234) %>%
  rename(intercept = .value) 
pse_df <- slopes_df %>% 
  full_join(intercepts_df, by = c("means", "sd_diff", "condition", "trial", "start_means", ".draw")) %>%
  mutate(pse = -intercept / slope)

# interaction effect
pse_interaction_plt <- pse_df %>%
  group_by(means, sd_diff, condition, .draw) %>%          # maginalize out other manipulations
  summarise(pse = mean(pse)) %>%
  ggplot(aes(x = pse, y = condition, group = means, fill = means)) +
  stat_slabh(alpha = 0.35) +
  coord_cartesian(xlim = c(-1, 1)) +
  theme_minimal() +
  facet_grid(. ~ sd_diff)
# save
ggsave(file = "components/pse-interaction.svg", plot = pse_interaction_plt, width=5, height=1.33)

# marginal effect of visualization
pse_vis_plt <- pse_df %>%
  group_by(condition, .draw) %>%          # maginalize out other manipulations
  summarise(pse = mean(pse)) %>%
  ggplot(aes(x = pse, y = condition, fill = condition)) +
  stat_slabh(alpha = 0.35) +
  scale_fill_brewer(type = "qual", palette = 2) + 
  theme_minimal() +
  theme(legend.position = "none")
# save
ggsave(file = "components/pse-vis_conditions.svg", plot = pse_vis_plt, width=2.5, height=1.33)

# marginal effect of means at each level of variance
pse_means.sd_plt <- pse_df %>%
  group_by(means, sd_diff, .draw) %>%          # maginalize out other manipulations
  summarise(pse = mean(pse)) %>%
  ggplot(aes(x = pse, y = "Overall", group = means, fill = means)) +
  stat_slabh(alpha = 0.35) +
  coord_cartesian(xlim = c(-1, 1)) +
  theme_minimal() +
  facet_grid(. ~ sd_diff)
# save
ggsave(file = "components/pse-means_sd.svg", plot = pse_means.sd_plt, width=5, height=0.4)


##Other figures generated from images saved in StimuliGeneration.Rmd
