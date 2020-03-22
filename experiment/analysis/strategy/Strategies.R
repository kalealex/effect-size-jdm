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
    `Mentioned confusion` = tolower(`Mentioned confusion`)
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


## Distance

# proportion who mentioned distance
df %>% 
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# proportion who normalize their interpretation of distance based on variance
df %>% 
  summarize(
    n_distance_variance = sum(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference")),
    n_total = n(),
    proportion_distance_variance = n_distance_variance / n_total
  )


## Variance

# proportion who mentioned using variance in any way
df %>% 
  summarize(
    n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
    n_total = n(),
    proportion_variance = n_variance / n_total
  )

# proportion who prefer low or high variance
df %>% 
  summarize(
    n_low_high_variance = sum(`Mentioned variance` == "low" | `Mentioned variance` == "high"),
    n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
    proportion_low_high_variance = n_low_high_variance / n_variance
  )

# proportion who used variance not in combination with distance
df %>% 
  summarize(
    n_variance_alone = sum((`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high") & !(str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference"))),
    n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
    proportion_variance_alone = n_variance_alone / n_variance
  )


## Area

# proportion who mentioned area
df %>% 
  summarize(
    n_area = sum(`Mentioned area` == "yes"),
    n_total = n(),
    proportion_area = n_area / n_total
  )

# proportion who judge area across threshold
df %>% 
  summarize(
    n_area_threshold = sum(str_detect(`Open codes`, "area across threshold")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_area_threshold = n_area_threshold / n_area 
  )

# proportion who judge area overlap
df %>% 
  summarize(
    n_area_overlap = sum(str_detect(`Open codes`, "distribution overlap")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_area_overlap = n_area_overlap / n_area 
  )


## Frequency

# proportion who mentioned frequency
df %>% 
  summarize(
    n_frequency = sum(`Mentioned frequency` == "yes"),
    n_total = n(),
    proportion_frequency = n_frequency / n_total
  )

# proportion who count marks across threshold
df %>% 
  summarize(
    n_frequency_threshold = sum(str_detect(`Open codes`, "frequency of draws across threshold") | str_detect(`Open codes`, "counting dots across threshold")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency_threshold = n_frequency_threshold / n_frequency
  )

# proportion who judge frequency of draws changing order
df %>% 
  summarize(
    n_frequency_order = sum(str_detect(`Open codes`, "frequency of draws changing order")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency_order = n_frequency_order / n_frequency
  )


## Threshold

# proportion who mentioned threshold
df %>% 
  summarize(
    n_threshold = sum(`Mentioned threshold` == "yes"),
    n_total = n(),
    proportion_threshold = n_threshold / n_total
  )

# proportion who mentioned across threshold
df %>% 
  summarize(
    n_across_threshold = sum(str_detect(`Open codes`, "across threshold")),
    n_threshold = sum(`Mentioned threshold` == "yes"),
    proportion_across_threshold = n_across_threshold / n_threshold
  )

# proportion who mentioned other point thresholds
df %>% 
  summarize(
    n_point_threshold = sum(str_detect(`Open codes`, "point threshold") & !str_detect(`Open codes`, "across threshold") & !str_detect(strategy_with_means, "100") & !str_detect(strategy_without_means, "100") & !str_detect(strategy_with_means, "threshold") & !str_detect(strategy_without_means, "threshold") & !str_detect(strategy_with_means, "threshhold") & !str_detect(strategy_without_means, "threshhold") & !str_detect(strategy_with_means, "dashed") & !str_detect(strategy_without_means, "dashed")),
    n_threshold = sum(`Mentioned threshold` == "yes"),
    proportion_point_threshold = n_point_threshold / n_threshold
  )
# test <- df %>% filter(str_detect(`Open codes`, "point threshold") & !str_detect(`Open codes`, "across threshold") & !str_detect(strategy_with_means, "100") & !str_detect(strategy_without_means, "100") & !str_detect(strategy_with_means, "threshold") & !str_detect(strategy_without_means, "threshold") & !str_detect(strategy_with_means, "threshhold") & !str_detect(strategy_without_means, "threshhold") & !str_detect(strategy_with_means, "dashed") & !str_detect(strategy_without_means, "dashed"))


## Switching

# proportion who switched strategies
df %>% 
  summarize(
    n_switched = sum(`Changed strategy` == "yes"),
    n_total = n(),
    proportion_switched = n_switched / n_total
  )


## Behaviors by Condition

# relying on distance
df %>% 
  group_by(condition) %>%
  summarize(
    n_distance = sum(`Mentioned distance` == "yes"),
    n_total = n(),
    proportion_distance = n_distance / n_total
  )

# relying on distance or means
df %>% 
  group_by(condition) %>%
  summarize(
    n_distance_mean = sum(`Mentioned distance` == "yes" | `Mentioned mean` == "yes"),
    n_total = n(),
    proportion_distance_mean = n_distance_mean / n_total
  )

# relying on variance
df %>%
  group_by(condition) %>%
  summarize(
    n_variance = sum(`Mentioned variance` == "yes" | `Mentioned variance` == "low" | `Mentioned variance` == "high"),
    n_total = n(),
    proportion_variance = n_variance / n_total
  )

# using variance in combination with distance
# df %>% 
#   group_by(condition) %>%
#   summarize(
#     n_variance_distance = sum((`Mentioned variance` == "yes" & (str_detect(`Open codes`, "variance and gist distance") | str_detect(`Open codes`, "variance and mean difference")))),
#     n_total = n(),
#     proportion_variance_distance = n_variance_distance / n_total
#   )

# relying on area
df %>% 
  group_by(condition) %>%
  summarize(
    n_area = sum(`Mentioned area` == "yes"),
    n_total = n(),
    proportion_area = n_area / n_total
  )

# relying on area overlap
df %>% 
  group_by(condition) %>%
  summarize(
    n_area_overlap = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "overlap")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_area_overlap = n_area_overlap / n_area
  )

# relying on area across threshold
df %>% 
  group_by(condition) %>%
  summarize(
    n_area_threshold = sum(`Mentioned area` == "yes" & str_detect(`Open codes`, "across threshold")),
    n_area = sum(`Mentioned area` == "yes"),
    proportion_area_threshold = n_area_threshold / n_area
  )

# relying on frequency
df %>% 
  group_by(condition) %>%
  summarize(
    n_frequency = sum(`Mentioned frequency` == "yes"),
    n_total = n(),
    proportion_frequency = n_frequency / n_total
  )

# making cumulative probability judgments based on frequency
df %>% 
  group_by(condition) %>%
  summarize(
    n_frequency_across_threshold = sum(`Mentioned frequency` == "yes" & str_detect(`Open codes`, "across threshold")),
    n_frequency = sum(`Mentioned frequency` == "yes"),
    proportion_frequency = n_frequency_across_threshold / n_frequency
  )

# relying on thresholds
df %>% 
  group_by(condition) %>%
  summarize(
    n_threshold = sum(`Mentioned threshold` == "yes"),
    n_total = n(),
    proportion_threshold = n_threshold / n_total
  )

# making cumulative probability judgments
df %>% 
  group_by(condition) %>%
  summarize(
    n_across_threshold = sum(str_detect(`Open codes`, "across threshold")),
    n_total = n(),
    proportion_across_threshold = n_across_threshold / n_total
  )

# switching strategies
df %>% 
  group_by(condition) %>%
  summarize(
    n_switched = sum(`Changed strategy` == "yes"),
    n_total = n(),
    proportion_switched = n_switched / n_total
  )

# switching to or from means
df %>% 
  group_by(condition) %>%
  summarize(
    n_switched_to_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    n_switched = sum(`Changed strategy` == "yes"),
    proportion_switched_to_mean = n_switched_to_mean / n_switched
  )

# switching between frequency and means
df %>%
  group_by(condition) %>%
  summarize(
    n_switched_frequency_mean = sum(`Changed strategy` == "yes" & `Mentioned frequency` == "yes" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_frequency_mean = n_switched_frequency_mean / n_switched_mean
  )


## Means

# relying on means 
df %>% 
  summarize(
    n_mean = sum(`Mentioned mean` == "yes"),
    n_total = n(),
    proportion_mean = n_mean / n_total
  )

# switching to means (overall)
df %>% 
  summarize(
    n_switched_to_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes" & !start_means),
    n_total = sum(!start_means),
    proportion_switched_to_mean = n_switched_to_mean / n_total
  )

# switching from means (overall)
df %>% 
  summarize(
    n_switched_from_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes" & start_means),
    n_total = sum(start_means),
    proportion_switched_from_mean = n_switched_from_mean / n_total
  )

# not switching from means (overall)
df %>% 
  summarize(
    n_no_switch_from_mean = sum(`Changed strategy` == "no" & `Mentioned mean` == "yes" & start_means),
    n_total = sum(start_means),
    proportion_no_switch_from_mean = n_no_switch_from_mean / n_total
  )

# switching to or from means (overall)
df %>% 
  summarize(
    n_switched_from_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    n_total = n(),
    proportion_switched_from_mean = n_switched_from_mean / n_total
  )

# switching between distance and means (overall)
df %>% 
  summarize(
    n_switched_distance_mean = sum(`Changed strategy` == "yes" & `Mentioned distance` == "yes" & `Mentioned area` == "no" & `Mentioned frequency` == "no" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_distance_mean = n_switched_distance_mean / n_switched_mean
  )

# switching between distance and means (per condition)
# df %>%
#   group_by(condition) %>%
#   summarize(
#     n_switched_distance_mean = sum(`Changed strategy` == "yes" & `Mentioned distance` == "yes" & `Mentioned area` == "no" & `Mentioned frequency` == "no" & `Mentioned mean` == "yes"),
#     n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
#     proportion_switched_distance_mean = n_switched_distance_mean / n_switched_mean
#   )

# switching between area and means (overall)
df %>%
  summarize(
    n_switched_area_mean = sum(`Changed strategy` == "yes" & `Mentioned area` == "yes" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_area_mean = n_switched_area_mean / n_switched_mean
  )

# switching between area and means (per condition)
# df %>% 
#   group_by(condition) %>%
#   summarize(
#     n_switched_area_mean = sum(`Changed strategy` == "yes" & `Mentioned area` == "yes" & `Mentioned mean` == "yes"),
#     n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
#     proportion_switched_area_mean = n_switched_area_mean / n_switched_mean
#   )

# switching between frequency and means (overall)
df %>% 
  summarize(
    n_switched_frequency_mean = sum(`Changed strategy` == "yes" & `Mentioned frequency` == "yes" & `Mentioned mean` == "yes"),
    n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
    proportion_switched_frequency_mean = n_switched_frequency_mean / n_switched_mean
  )

# switching between frequency and means (per condition)
# df %>% 
#   group_by(condition) %>%
#   summarize(
#     n_switched_frequency_mean = sum(`Changed strategy` == "yes" & `Mentioned frequency` == "yes" & `Mentioned mean` == "yes"),
#     n_switched_mean = sum(`Changed strategy` == "yes" & `Mentioned mean` == "yes"),
#     proportion_switched_frequency_mean = n_switched_frequency_mean / n_switched_mean
#   )


## Distance or Mean Difference (overall)
df %>% 
  summarize(
    n_distance_mean = sum(`Mentioned distance` == "yes" | `Mentioned mean` == "yes"),
    n_total = n(),
    proportion_distance_mean = n_distance_mean / n_total
  )


## Cumulative Probability Judgments (overall)
df %>% 
  summarize(
    n_across_threshold = sum(str_detect(`Open codes`, "across threshold")),
    n_total = n(),
    proportion_across_threshold = n_across_threshold / n_total
  )
