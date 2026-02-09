qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/*qmd"))
violations <- list()
for(qmd in qmd.files){
  qmd.lines <- readLines(qmd)
  is.fence <- grepl("```", qmd.lines)
  is.text <- (cumsum(is.fence) %% 2)==0
  qmd.text <- qmd.lines[is.text]
  not.backticks <- gsub("`.*?`", "", qmd.text)
  not.angle <- gsub("<.*?>", "", not.backticks)
  not.curly <- gsub("[{].*?[}]", "", not.angle)
  quote.lines <- grep('".*?"', not.curly, value=TRUE, perl=TRUE)
  if(length(quote.lines)){
    violations[[qmd]] <- quote.lines
  }
}
print(violations)

q(status=length(violations))
