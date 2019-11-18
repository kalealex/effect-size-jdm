library(tidyverse)
library(digest)

# function to anonymize worker ids
anonymize <- function(x, algo="crc32"){
  unq_hashes <- vapply(unique(x), function(object) digest(object, algo=algo), FUN.VALUE="", USE.NAMES=TRUE)
  unname(unq_hashes[x])
}

# load raw data
raw_df <- read_csv("raw-data/experiment.csv")

# anonymize worker ids
anonymous_df <- raw_df %>%
  mutate(workerId=anonymize(workerId))

# save file
write.csv(anonymous_df, file = "experiment-anonymous.csv", row.names=FALSE)