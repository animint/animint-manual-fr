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
  quote.lines <- grep('".*?"', not.angle, value=TRUE, perl=TRUE)
  if(length(quote.lines)){
    violations[[qmd]] <- quote.lines
  }
}
print(violations)

q(status=length(violations))
