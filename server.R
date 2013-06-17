library(datasets)
library(ggplot2)
library(scales)
library(plyr)

# Define server logic required to plot various variables
# options(shiny.maxRequestSize, 30*1024^2)

# default play table

shinyServer(function(input, output) {
  newTable <- reactive(function(){
    
    # input$file1 will be NULL initially. After the user selects and uploads a 
    # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
    # columns. The 'datapath' column will contain the local filenames where the 
    # data can be found.

    inFile <- input$file1
    if (is.null(inFile)){
      df <- read.table('schema_big.tsv',header=TRUE,sep =",")
      df$non_segmented = 1
      return(df)
    }
    df <- read.table(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
    df$non_segmented = 1
    df
  })

  # Generate x-axis dropdown dynamically
  output$dropdown <- renderUI({
    newTable()
    dropdown_items <- c("None")
    dropdown_items <- append(dropdown_items,names(newTable()))
    dropdown_items <- dropdown_items[dropdown_items!="id"]
    dropdown_items <- dropdown_items[dropdown_items!="user_id"]
    dropdown_items <- dropdown_items[dropdown_items!="non_segmented"]
    dropdown_items <- dropdown_items
    selectInput("variable","",choices=dropdown_items)
  })

  # Data sample
  output$view <- renderTable({
    df <- newTable()
    head(df[,!(names(df) == 'non_segmented')], n = 3)
  })
  
  # Compute the variable text in a reactive function
  varText <- reactive(function() {
    if(is.null(input$variable))
      return("None")
    input$variable

  })

  # Return the constraint for filter
  filterCriteria <- reactive(function() {
    if(input$filter_criteria == "")
      return("1==1")
    input$filter_criteria
  })
  
  # Return the constraint for evaluation
  evalCriteria <- reactive(function() {
    input$eval_function
  })

  # Return the formula text for printing as a caption
  output$caption <- renderText(function() {
    if(input$eval_percent == TRUE)
      return(paste("% of users where: ", evalCriteria(), sep=""))
    else
      return(paste("Plot: ", evalCriteria(), sep=""))
  })

  
  # Generate a plot of the requested variable
  # ggplot version
  output$userPlot <- renderPlot(function() {

    newTable()
    variable2 = varText()

    if(variable2 == "None")
      variable2 = "non_segmented"

    eval(parse(
      text = paste("newTable_f <- subset(newTable(),", filterCriteria(),")",sep="")
    ))
    
    output$nrows <- renderText(function() {
      paste("Total users profiled = ", as.character(format(nrow(newTable_f),big.mark=',')))
    })

    dataprep = ""
    if(input$eval_percent == TRUE){
      dataprep = paste("data_plot<- ddply(newTable_f, '",variable2,"', summarise, statistic=length(non_segmented[",evalCriteria(),"])/length(non_segmented))",sep="")
      eval(parse(text = dataprep))
    }
    else{
      eval_var = evalCriteria()
      if(eval_var == "")
        eval_var = "length(non_segmented)"

      dataprep = paste("data_plot<- ddply(newTable_f, '",variable2,"', summarise, statistic=",eval_var,")",sep="")
      eval(parse(text = dataprep))     
    }
    
    p <- ggplot(data_plot, aes_string(x=variable2, y="statistic")) + 
    geom_bar(stat="identity", fill="#0072B2",color="black") 
    
    if(input$eval_percent == TRUE){
      p <- p + scale_y_continuous(labels = percent_format()) + ylab("Percent")
    }
    else{
      p <- p + ylab("")
    }

    print(p)
  })
})

