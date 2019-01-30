#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# general stuff needed outside of app -------------------------------------

library(shiny)
library(tidyverse)
library(htmltools)

set.seed(1834)

shinyServer(function(input, output, session){
  my_data <- reactive({
    ability_mu<- 100
    ability_sigma <- 15
    
    sigma_g <- input$grade_noise
    sigma_s <- input$sat_noise
    
    n <- input$n_samples
    
    minority_perc <- input$minority_perc/100
    
    dist_of_groups <- c(minority_perc, 1-minority_perc)
    
    number_groups <- c(1,2)
    
    group_1_sat_taken <- input$group_1_taken
    group_2_sat_taken <- input$group_2_taken
    
    
    initial_data <-data_frame(ability = rnorm(n, ability_mu, ability_sigma)) %>% 
      mutate(student = paste0("student_", row_number()),
             group_membership = sample(number_groups, n, prob = dist_of_groups, T))
    grades <- rnorm(n, initial_data$ability, sigma_g)
    
    initial_data <- initial_data %>% add_column(grades = grades)
    
    # Group 1 Test Takers
    group_1 <- filter(initial_data, group_membership == 1)
    
    group_1_sat_matrix <- matrix(
      data = rnorm(group_1_sat_taken*nrow(group_1), mean = group_1$ability, sd =sigma_s),
      nrow = nrow(group_1),
      ncol = group_1_sat_taken,
      byrow = F)
    
    group_1_sat_matrix = cbind(group_1_sat_matrix, 
                               max_score = apply(group_1_sat_matrix, MARGIN = 1, max))
    
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
                               max_score = apply(group_2_sat_matrix, MARGIN = 1, max))
    
    group_2 <- group_2 %>% 
      bind_cols(as_data_frame(group_2_sat_matrix))
    
    # Bring the Two Groups Together
    
    combined_student_data <- bind_rows(group_1, group_2)
    
    print(head(combined_student_data)) 
    
    out <- combined_student_data
  })
  
  model_fits <- reactive({
    if(input$mod_group){
      my_data() %>% 
        group_by(group_membership) %>% 
        nest() %>% 
        mutate(fit = map(data, ~broom::augment(lm(ability ~ grades + max_score, data = .))[".fitted"])) %>% 
        unnest() %>% 
        mutate(admitted = ifelse(.fitted >= input$intelligence_cut, 1, 0))
    } else{
      my_data()  %>% 
        add_column(.fitted = broom::augment(lm(ability ~ grades + max_score, 
                                               data = my_data()))[[".fitted"]]) %>% 
        mutate(admitted = ifelse(.fitted >= input$intelligence_cut, 1, 0))
    }
  })
  
  
  make_first_plot <- function(){
    if(input$mod_group){
    model_fits() %>% 
    ggplot(aes(grades, max_score, color = as.factor(group_membership)))+
      geom_point(alpha = .5)+
      labs(
        title = "Distribution of Scores",
        subtitle = "Line Represents Cutoff Threshold for Admission",
        color = "Group",
        x = "Grade Score",
        y= "Test Score (max)"
      )+
      theme_minimal()+
      geom_smooth(method = "lm", se = FALSE)
    } else{
      model_fits() %>% 
        ggplot()+
        geom_point(aes(grades, max_score, color = as.factor(group_membership)),alpha = .5)+
        labs(
          title = "Distribution of Scores",
          subtitle = "Line Represents Cutoff Threshold for Admission",
          color = "Group",
          x = "Grade Score",
          y= "Test Score (max)"
        )+
        theme_minimal()+
        geom_smooth(aes(grades, max_score), method = "lm", se = FALSE)
    }
  }
  
  make_summary_statz <- function(){
    dat <-model_fits() %>% 
      group_by(group_membership) %>% 
      summarise(total_students = n(),
                avg_true_ability = mean(ability),
                  avg_grade = mean(grades),
                avg_sat = mean(max_score),
                admit = mean(admitted)*100) %>% 
      mutate_if(is.numeric, round, 2) %>% 
      set_names(c("Group", "#", "Avg True Ability", "Avg Grades", "Avg SAT", "% Admit"))
  }
  
  output$initial_plot <- renderPlot({make_first_plot()})
  output$initial_statz <- renderDataTable({make_summary_statz()})
})