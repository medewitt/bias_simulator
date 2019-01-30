
library(tidyverse)



ability_mu<- 100
ability_sigma <- 15

sigma_g <- 15
sigma_s <- 15

n <- 10000

minority_perc <- .2

dist_of_groups <- c(minority_perc, 1-minority_perc)

number_groups <- c(1,2)

group_1_sat_taken <- 2
group_2_sat_taken <- 1


initial_data <-data_frame(ability = rnorm(n, ability_mu, ability_sigma)) %>% 
  mutate(student = paste0("student_", row_number()),
         group_membership = sample(number_groups, n, prob = dist_of_groups, T))
grades <- rnorm(n, ability, sigma_g)
initial_data <- initial_data %>% add_column(grades)

# Group 1 Test Takers
group_1 <- filter(initial_data, group_membership == 1)

group_1_sat_matrix <- matrix(
  data = rnorm(group_1_sat_taken*nrow(group_1), mean = group_1$ability, sd =sigma_s),
  nrow = nrow(group_1),
  ncol = group_1_sat_taken,
  byrow = F)

group_1_sat_matrix = cbind(group_1_sat_matrix, 
                           max = apply(group_1_sat_matrix, MARGIN = 1, max))

group_1 <- group_1 %>% 
  bind_cols(as_data_frame(group_1_sat_matrix))

# Group 2 data prep

group_2 <- filter(initial_data, group_membership == 2)

group_2_sat_matrix <- matrix(
  data = rnorm(group_2_sat_taken*nrow(group_2), mean = group_2$ability, sd =sigma_s),
  nrow = nrow(group_2),
  ncol = group_2_sat_taken,
  byrow = F)

group_2_sat_matrix = cbind(group_2_sat_matrix, 
                           max = apply(group_2_sat_matrix, MARGIN = 1, max))

group_2 <- group_2 %>% 
  bind_cols(as_data_frame(group_2_sat_matrix))

# Bring the Two Groups Together

combined_student_data <- bind_rows(group_1, group_2)


combined_student_data %>% 
    group_by(group_membership) %>% 
  nest() %>% 
  mutate(fit = map(data, ~broom::augment(lm(ability ~ grades + max, data = .))[".fitted"])) %>% 
  unnest()
combined_student_data %>% add_column(.fitted = 
  broom::augment(lm(ability ~ grades + max, data = combined_student_data))[[".fitted"]])
  