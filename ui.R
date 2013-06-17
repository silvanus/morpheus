library(shiny)

# Define UI
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Morpheus"),

  # Sidebar with controls to select the variable to plot
  sidebarPanel(
    fileInput('file1', 'Use pre-loaded dataset or upload a new CSV file',
              accept=c('text/csv', 'text/comma-separated-values,text/plain')),
    tags$hr(),
    checkboxInput('header', 'Header', TRUE),
    radioButtons('sep', 'Separator',
                c(Comma=',', Semicolon=';', Tab='\t'),
                'Comma'),
    radioButtons('quote', 'Quote',
                 c(None='',
                   'Double quote'='"',
                   'Single quote'="'"),
                 'Double Quote'),
    h3("X-axis"),
    
    uiOutput("dropdown"),

    h3("Constraints"),
    textInput("filter_criteria", "Filter dataset (eg: all_score > 2 & is_paid == 0)", ""),
    tags$style(type='text/css', "#filter_criteria { width: 350px}"),
    h3("Evaluation criteria"),
    textInput("eval_function", "Hint: use 'length(id)' to get count",""),
    tags$style(type='text/css', "#eval_function { width: 350px}"),
    checkboxInput('eval_percent', 'Evaluate as percent. NB: expression must be a constraint (eg. cu_total > 2)', TRUE),
    submitButton("Update")
  ),

  # Show the caption and plot of the requested variable
  mainPanel(
    h3("Data sample"),
    tableOutput("view"),
    h3(textOutput("caption")),
    #tabsetPanel(
    #  tabPanel("% Plot", plotOutput("userPlot")),
    #  tabPanel("Distribution",h3("TBD"))),
    plotOutput("userPlot"),
    h3(textOutput("nrows"))
  )
))