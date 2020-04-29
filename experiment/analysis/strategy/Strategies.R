library(readr)
library(tidyverse)


## Load Coded Strategies
full_df <- read_csv("strategies.csv")

# preprocessing
df <- full_df %>% 
  mutate(
    `Open codes` = tolower(`Open Codes`),
    `Answered question` = tolower(`Answered question`),
    `Changed strategy` = tolower(`Changed strategy with vs witout means`),
    `Mentioned distance` = tolower(`Mentioned distance`),
    `Mentioned mean` = tolower(`Mentioned mean`),
    `Mentioned variance` = tolower(`Mentioned variance`),
    `Mentioned threshold` = tolower(`Mentioned threshold`),
    `Mentioned area` = tolower(`Mentioned area of marking`),
    `Mentioned frequency` = tolower(`Mentioned frequency of events/markings`),
    `Mentioned confusion` = tolower(`Mentioned confusion`),
    condition = factor(condition, levels = c("intervals", "HOPs", "densities", "QDPs")) # reorder
  ) %>%
  filter(`Answered question` == "yes")


## Base Rates of Users Who Answered the Question

# proportion who answered the question in each condition
full_count <- full_df %>% group_by(condition) %>% summarize(n_full = n())
answered_count <- df %>% group_by(condition) %>% summarize(n_answered = n())
answered_count %>% 
  full_join(full_count, by = ("condition")) %>%
  mutate(proportion_answered = n_answered / n_full)

# proportion who were confused in each condition
df %>%
  group_by(condition) %>%
  summarize(
    n_confused = sum(`Mentioned confusion` == "yes"),
    n_total = n(),
    proportion_confused = n_confused / n_total
  )


## Only Distance

# proportion who use gist distance or mean difference without normalizing to variance
df %>% 
  summarize(
    n_distance_or_means = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_total = n(),
    proportion_distance_or_means = n_distance_or_means / n_total
  )

# proportion who use gist distance without normalizing to variance
df %>% 
  summarize(
    n_gist_distance = sum(str_detect(`Open codes`, "gist distance") & !str_detect(`Open codes`, "variance and gist distance")),
    n_distance_or_means = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    proportion_gist_distance = n_gist_distance / n_distance_or_means
  )

# proportion who use the mean difference strategy without normalizing to variance
df %>% 
  summarize(
    n_mean_difference = sum(str_detect(`Open codes`, "mean difference") & !str_detect(`Open codes`, "variance and mean difference")),
    n_distance_or_means = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    proportion_mean_difference = n_mean_difference / n_distance_or_means
  )

# proportion who use both gist distance and mean difference strategies without normalizing to variance
df %>% 
  summarize(
    n_both = sum((str_detect(`Open codes`, "gist distance") & str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance_or_means = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    proportion_both = n_both / n_distance_or_means
  )


## Distance Relative to Variance

# proportion who normalize their interpretation of distance based on variance
df %>% 
  summarize(
    n_distance_variance = sum(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference")),
    n_total = n(),
    proportion_distance_variance = n_distance_variance / n_total
  )


## Cumulative Probability

# proportion who rely on distance, area, or frequency across threshold
df %>% 
  summarize(
    n_across_threshold = sum(str_detect(`Open codes`, "across threshold")),
    n_total = n(),
    proportion_across_threshold = n_across_threshold / n_total
  )


## Distribution Overlap

# proportion who use distribution overlap strategy
df %>% 
  summarize(
    n_overlap = sum(str_detect(`Open codes`, "distribution overlap")),
    n_total = n(),
    proportion_overlap = n_overlap / n_total 
  )


## Frequency of Draws Changing Order

# proportion who use frequency of draws changing order strategy
df %>% 
  group_by(condition) %>%
  summarize(
    n_draws_changing_order = sum(str_detect(`Open codes`, "frequency of draws changing order")),
    n_total = n(),
    proportion_draws_changing_order = n_draws_changing_order / n_total 
  )


## Switching

# proportion who switched strategies
df %>% 
  summarize(
    n_switched = sum(`Changed strategy` == "yes"),
    n_total = n(),
    proportion_switched = n_switched / n_total
  )


# ## Relative Position
# 
# # proportion who mentioned using distance
# df %>% 
#   summarize(
#     n_distance = sum(`Mentioned distance` == "yes"),
#     n_total = n(),
#     proportion_variance = n_distance / n_total
#   )
# 
# # proportion who use only distance only strategies
# df %>% 
#   summarize(
#     n_only_distance = sum(`Mentioned distance` == "yes" & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
#     n_distance = sum(`Mentioned distance` == "yes"),
#     proportion_only_distance = n_only_distance / n_distance
#   )
# 
# # proportion who use distance relative to variance strategy
# df %>% 
#   summarize(
#     n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
#     n_distance = sum(`Mentioned distance` == "yes"),
#     proportion_distance_relative = n_distance_relative / n_distance
#   )
# 
# 
# ## Spread
# 
# # proportion who mentioned using variance in any way
# df %>% 
#   summarize(
#     n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
#     n_total = n(),
#     proportion_variance = n_variance / n_total
#   )
# 
# # proportion who use distance relative to variance strategy
# df %>% 
#   summarize(
#     n_distance_relative = sum((`Mentioned variance` == "yes"| `Mentioned variance` == "low" | `Mentioned variance` == "high") & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
#     n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
#     proportion_distance_relative = n_distance_relative / n_variance
#   )
# 
# # proportion who prefer low or high variance
# df %>% 
#   summarize(
#     n_low_high_variance = sum(`Mentioned variance` == "low" | `Mentioned variance` == "high"),
#     n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
#     proportion_low_high_variance = n_low_high_variance / n_variance
#   )
# 
# # proportion who use distribution overlap strategy
# df %>% 
#   summarize(
#     n_overlap = sum((`Mentioned variance` == "yes"| `Mentioned variance` == "low" | `Mentioned variance` == "high") & str_detect(`Open codes`, "distribution overlap")),
#     n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
#     proportion_overlap = n_overlap / n_variance 
#   )
# 
# 
# ## Area
# 
# # proportion who mentioned area
# df %>% 
#   summarize(
#     n_area = sum(`Mentioned area` == "yes"),
#     n_total = n(),
#     proportion_area = n_area / n_total
#   )
# 
# # proportion who use cumulative probability strategy
# df %>% 
#   summarize(
#     n_area_cumulative = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "across threshold")),
#     n_area = sum(`Mentioned area` == "yes"),
#     proportion_area_cumulative = n_area_cumulative / n_area 
#   )
# 
# # proportion who judge area overlap
# df %>% 
#   summarize(
#     n_area_overlap = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "distribution overlap")),
#     n_area = sum(`Mentioned area` == "yes"),
#     proportion_area_overlap = n_area_overlap / n_area 
#   )
# 
# 
# ## Frequency
# 
# # proportion who mentioned frequency
# df %>% 
#   summarize(
#     n_frequency = sum(`Mentioned frequency` == "yes"),
#     n_total = n(),
#     proportion_frequency = n_frequency / n_total
#   )
# 
# # proportion who used cumulative probability
# df %>% 
#   summarize(
#     n_frequency_cumulative = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "across threshold")),
#     n_frequency = sum(`Mentioned frequency` == "yes"),
#     proportion_frequency_cumulative = n_frequency_cumulative / n_frequency
#   )
# 
# # proportion who judge frequency of draws changing order
# df %>% 
#   summarize(
#     n_frequency_order = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "frequency of draws changing order")),
#     n_frequency = sum(`Mentioned frequency` == "yes"),
#     proportion_frequency_order = n_frequency_order / n_frequency
#   )
# 
# 
# ## Reference Lines
# 
# # proportion who mentioned threshold
# df %>% 
#   summarize(
#     n_threshold = sum(`Mentioned threshold` == "yes"),
#     n_total = n(),
#     proportion_threshold = n_threshold / n_total
#   )
# 
# # proportion who used cumulative probability
# df %>% 
#   summarize(
#     n_cumulative = sum(`Mentioned threshold` == "yes" & str_detect(`Open codes`, "across threshold")),
#     n_threshold = sum(`Mentioned threshold` == "yes"),
#     proportion_cumulative = n_cumulative / n_threshold
#   )
# 
# # proportion who mentioned other point thresholds
# df %>% 
#   summarize(
#     n_point_threshold = sum(`Mentioned threshold` == "yes" & str_detect(`Open codes`, "point threshold") & !str_detect(`Open codes`, "across threshold") & !str_detect(strategy_with_means, "100") & !str_detect(strategy_without_means, "100") & !str_detect(strategy_with_means, "threshold") & !str_detect(strategy_without_means, "threshold") & !str_detect(strategy_with_means, "threshhold") & !str_detect(strategy_without_means, "threshhold") & !str_detect(strategy_with_means, "dashed") & !str_detect(strategy_without_means, "dashed")),
#     n_threshold = sum(`Mentioned threshold` == "yes"),
#     proportion_point_threshold = n_point_threshold / n_threshold
#   )
# test <- df %>% filter(str_detect(`Mentioned threshold` == "yes" & `Open codes`, "point threshold") & !str_detect(`Open codes`, "across threshold") & !str_detect(strategy_with_means, "100") & !str_detect(strategy_without_means, "100") & !str_detect(strategy_with_means, "threshold") & !str_detect(strategy_without_means, "threshold") & !str_detect(strategy_with_means, "threshhold") & !str_detect(strategy_without_means, "threshhold") & !str_detect(strategy_with_means, "dashed") & !str_detect(strategy_without_means, "dashed"))


## Intervals

# relying on relative position
df %>% 
  group_by(condition) %>%
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# using only distance strategy if relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "intervals") %>%
  summarize(
    n_only_distance = sum(`Mentioned distance` == "yes" & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_only_distance = n_only_distance / n_distance
  )

# using distance relative to variance strategy if relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "intervals") %>%
  summarize(
    n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_distance_relative = n_distance_relative / n_distance
  )

# using distance relative to variance strategy 
df %>% 
  group_by(condition) %>%
  filter(condition == "intervals") %>%
  summarize(
    n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_total = n(),
    proportion_distance_relative = n_distance_relative / n_total
  )

#  relying on area
df %>% 
  group_by(condition) %>%
  filter(condition == "intervals") %>%
  summarize(
    n_area = sum(`Mentioned area` == "yes"),
    n_total = n(),
    proportion_area = n_area / n_total
  )

# using distribution overlap if relying on area
df %>% 
  group_by(condition) %>%
  filter(condition == "intervals") %>%
  summarize(
    n_overlap = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "overlap")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_overlap = n_overlap / n_area
  )


## HOPs

# relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# using distance relative to variance strategy if relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_distance_relative = n_distance_relative / n_distance
  )

# relying on frequency
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_frequency = sum(`Mentioned frequency` == "yes"),
    n_total = n(),
    proportion_frequency = n_frequency / n_total
  )

# using cumulative probability if relying on frequency
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_frequency_cumulative = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "across threshold")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency_cumulative = n_frequency_cumulative / n_frequency
  )

# using frequency of draws changing order if relying on frequency
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_frequency_order = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "frequency of draws changing order")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency_order = n_frequency_order / n_frequency
  )

# switching strategies
df %>% 
  group_by(condition) %>%
  summarize(
    n_switched = sum(`Changed strategy` == "yes"),
    n_total = n(),
    proportion_switched = n_switched / n_total
  )

# switching to or from means if switching
df %>% 
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_switched_to_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    n_switched = sum(`Changed strategy` == "yes"),
    proportion_switched_to_mean = n_switched_to_mean / n_switched
  )

# switching between relative position and means if relative position
df %>%
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_switched_distance_mean = sum(`Changed strategy` == "yes" & `Mentioned distance` == "yes" & `Mentioned mean` == "yes"),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_switched_distance_mean = n_switched_distance_mean / n_distance
  )

# switching between frequency and means if frequency
df %>%
  group_by(condition) %>%
  filter(condition == "HOPs") %>%
  summarize(
    n_switched_frequency_mean = sum(`Changed strategy` == "yes" & `Mentioned frequency` == "yes" & `Mentioned mean` == "yes"),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_switched_frequency_mean = n_switched_frequency_mean / n_frequency
  )


## Densities

# relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "densities") %>%
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# using distance relative to variance strategy if relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "densities") %>%
  summarize(
    n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_distance_relative = n_distance_relative / n_distance
  )

# relying on area
df %>% 
  group_by(condition) %>%
  filter(condition %in% c("densities", "QDPs")) %>%
  summarize(
    n_area = sum(`Mentioned area` == "yes"),
    n_total = n(),
    proportion_area = n_area / n_total
  )

# using cumulative probability if relying on area
df %>% 
  group_by(condition) %>%
  filter(condition == "densities") %>%
  summarize(
    n_cumulative = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "across threshold")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_cumulative = n_cumulative / n_area
  )

# using overlap if relying on area
df %>% 
  group_by(condition) %>%
  filter(condition == "densities") %>%
  summarize(
    n_overlap = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "overlap")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_overlap = n_overlap / n_area
  )

# relying on spread
df %>% 
  group_by(condition) %>%
  summarize(
    n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
    n_total = n(),
    proportion_variance = n_variance / n_total
  )

# proportion of informative strategy descriptions
answered_count %>% 
  full_join(full_count, by = ("condition")) %>%
  mutate(proportion_answered = n_answered / n_full)


## Quantile Dotplots

# relying on relative position
df %>% 
  group_by(condition) %>%
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# using distance relative to variance strategy if relying on relative position
df %>% 
  group_by(condition) %>%
  filter(condition == "QDPs") %>%
  summarize(
    n_distance_relative = sum(`Mentioned distance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_distance = sum(`Mentioned distance` == "yes"),
    proportion_distance_relative = n_distance_relative / n_distance
  )

# relying on frequency
df %>% 
  group_by(condition) %>%
  filter(condition == "QDPs") %>%
  summarize(
    n_frequency = sum(`Mentioned frequency` == "yes"),
    n_total = n(),
    proportion_frequency = n_frequency / n_total
  )

# using cumulative probability if relying on frequency
df %>% 
  group_by(condition) %>%
  filter(condition == "QDPs") %>%
  summarize(
    n_frequency_cumulative = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "across threshold")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency_cumulative = n_frequency_cumulative / n_frequency
  )


## Adding Means

# relying on means 
df %>% 
  summarize(
    n_mean = sum(`Mentioned mean` == "yes"),
    n_total = n(),
    proportion_mean = n_mean / n_total
  )

# switching to means
df %>% 
  summarize(
    n_switched_to_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes" & !start_means),
    n_total = sum(!start_means),
    proportion_switched_to_mean = n_switched_to_mean / n_total
  )

# switching from means
df %>% 
  summarize(
    n_switched_from_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes" & start_means),
    n_total = sum(start_means),
    proportion_switched_from_mean = n_switched_from_mean / n_total
  )

# sticky means: starting with means and using them
df %>% 
  summarize(
    n_means_from_start = sum(`Mentioned mean` == "yes" & start_means),
    n_total = n(),
    proportion_means_from_start = n_means_from_start / n_total
  )

# sticky means: not switching from means
df %>% 
  summarize(
    n_no_switch_from_mean = sum(`Changed strategy` == "no" & `Mentioned mean` == "yes" & start_means),
    n_means_from_start = sum(`Mentioned mean` == "yes" & start_means),
    proportion_no_switch_from_mean = n_no_switch_from_mean / n_means_from_start
  )

# sticky means: switching from means
df %>% 
  summarize(
    n_switch_from_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes" & start_means),
    n_means_from_start = sum(`Mentioned mean` == "yes" & start_means),
    proportion_switch_from_mean = n_switch_from_mean / n_means_from_start
  )

# relying on means and switching
df %>% 
  summarize(
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    n_total = n(),
    proportion_switched_mean = n_switched_mean / n_total
  )

# switching between relative position only and means
df %>% 
  summarize(
    n_switched_distance_mean = sum(`Changed strategy` == "yes" & `Mentioned distance` == "yes" & `Mentioned area` == "no" & `Mentioned frequency` == "no" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_distance_mean = n_switched_distance_mean / n_switched_mean
  )

# switching between frequency and means 
df %>% 
  summarize(
    n_switched_frequency_mean = sum(`Changed strategy` == "yes" & `Mentioned frequency` == "yes" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_frequency_mean = n_switched_frequency_mean / n_switched_mean
  )

# switching between area and means
df %>%
  summarize(
    n_switched_area_mean = sum(`Changed strategy` == "yes" & `Mentioned area` == "yes" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_area_mean = n_switched_area_mean / n_switched_mean
  )

## Table
table_per_cond <- df %>%
  group_by(condition) %>%
  summarize(
    n_total = n(),
    # only distance
    n_only_distance = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    # proportion_only_distance = n_only_distance / n_total,
    # distance relative to variance
    n_distance_variance = sum(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference")),
    # proportion_distance_variance = n_distance_variance / n_total,
    # cumulative probability
    n_cumulative_p = sum(str_detect(`Open codes`, "across threshold")),
    # proportion_cumulative_p = n_cumulative_p / n_total,
    # distribution overlap
    n_overlap = sum(str_detect(`Open codes`, "distribution overlap")),
    # proportion_overlap = n_overlap / n_total,
    # frequency of draws changing order
    n_draws_changing_order = sum(str_detect(`Open codes`, "frequency of draws changing order")),
    # proportion_draws_changing_order = n_draws_changing_order / n_total,
    # switching
    n_switched = sum(`Changed strategy` == "yes")
    # proportion_switched = n_switched / n_total
  )
table_overall <- df %>%
  mutate(condition = "Overall") %>%
  group_by(condition) %>%
  summarize(
    n_total = n(),
    # only distance
    n_only_distance = sum((str_detect(`Open codes`, "gist distance") | str_detect(`Open codes`, "mean difference")) & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    # proportion_only_distance = n_only_distance / n_total,
    # distance relative to variance
    n_distance_variance = sum(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference")),
    # proportion_distance_variance = n_distance_variance / n_total,
    # cumulative probability
    n_cumulative_p = sum(str_detect(`Open codes`, "across threshold")),
    # proportion_cumulative_p = n_cumulative_p / n_total,
    # distribution overlap
    n_overlap = sum(str_detect(`Open codes`, "distribution overlap")),
    # proportion_overlap = n_overlap / n_total,
    # frequency of draws changing order
    n_draws_changing_order = sum(str_detect(`Open codes`, "frequency of draws changing order")),
    # proportion_draws_changing_order = n_draws_changing_order / n_total,
    # switching
    n_switched = sum(`Changed strategy` == "yes")
    # proportion_switched = n_switched / n_total
  )
table <- rbind(table_per_cond, table_overall)

