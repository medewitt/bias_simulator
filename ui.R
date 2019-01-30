library(shiny) 
library(shinydashboard)
library(tidyverse)
library(plotly)

shinydashboard::dashboardPage(skin = "yellow",
                              
                              #add title
                              dashboardHeader(title = "Algorithmic Fairness (Bias?)", titleWidth = 800),
                              
                              #Add sidebar elements
                              dashboardSidebar(sidebarMenu(
                                menuItem("About", tabName = "about", icon = icon("archive")),
                                menuItem("Simulation", tabName = "simulation", icon = icon("bars"))
                              )),
                              # Add Body Elements
                              
                              dashboardBody(
                                tabItems(
                                  # First Tab
                                  tabItem(tabName = "about",
                                          fluidRow(
                                            withMathJax(),
                                            h1("What this Application Does"),
                                            "The purpose of this app is to explore algorithmic bias. 
                                            Aaron Roth Developed a blog post that went through the basics of algorithmic bias. You can read that", 
                                            a("here", target = "_blank", "http://aaronsadventures.blogspot.com/2019/01/discussion-of-unfairness-in-machine.html?m=1"),
                                            br(),
            
                                            h2("A motivating example"),
                                            "Suppose that a school is looking at admitting different students.
                                            Additionally, the school is looking at admitting the best and the brightest
                                            by some latent factor 'ability'. Suppose that this latent factor is normally distibuted",
                                        
                                            withMathJax("$$Ability \\sim n(100, 15)$$"),
                                            "Now we have noisy measures of this in students' grades and test scores. 
                                            However, some students might have an advantage in wealth meaning that they can take additional prep
                                            classes and perform better on their tests. The school generally takes the maximum score of both and tries to predict a students' 
                                            ability. As you can see if you model these two groups together, just by taking more tests your average score will increase and
                                            your liklihood of admission will increase. However, if you model the two groups separately you can re-balance
                                            admission. But there is a big but; this practice is illegal!"
              
                                          )),

# simulation --------------------------------------------------------------

                                  tabItem(tabName = "simulation",
                                          fluidRow(
                                            h2("Simulator"),
                                            "Use this to simulate different scenarios",
                                            br(),
                                            box(h3("Population Inputs"),
                                                sliderInput("n_samples", "Population Size", min = 1, max = 1e5, value = 1e4),
                                                sliderInput("minority_perc", "% Minority Population", min = 1, max = 100, value = 50),
                                                sliderInput("grade_noise", "Error of Grades", min = 1, max = 25, value = 15),
                                                sliderInput("sat_noise", "Error of SAT", min = 1, max = 25, value = 15),
                                                width = 6),
                                            
                                            box(h3("Advantages"),
                                                sliderInput("group_1_taken", "# Times Group 1 Takes SAT", min = 1, max = 5, value = 1),
                                                sliderInput("group_2_taken", "# Times Group 2 Takes SAT", min = 1, max = 5, value = 1),
                                                sliderInput("intelligence_cut", "Intelligence Cutoff", min = 100, max = 200, value = 115),
                                                h4("Ability Prediction"),
                                                checkboxInput("mod_group", "Model by Group?", value = FALSE),
                                                width = 6),
                                          box(plotOutput("initial_plot"), width = 12),
                                          box(dataTableOutput("initial_statz"), width = 12))
                                          )
                                  )
                                
                      
                                  
                                )
)