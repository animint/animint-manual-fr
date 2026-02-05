qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/*qmd"))
violations <- list()
for(qmd in qmd.files){
  qmd.lines <- readLines(qmd)
  is.fence <- grepl("```", qmd.lines)
  is.text <- (cumsum(is.fence) %% 2)==0
  qmd.text <- qmd.lines[is.text]
  geom.lines <- grep("geom_", qmd.text, value=TRUE, perl=TRUE)
  if(FALSE){
    geom.lines <- c("`geom_text`","geom_text","geom_text()","`geom_text()`")
  }
  bad.lines <- c(
    grep("[^-#`](?:clickSelects|showSelected)", qmd.text, value=TRUE),
    grep("geom_[^(]+\\(\\)`", geom.lines, value=TRUE, perl=TRUE, invert=TRUE))
  if(length(bad.lines)){
    violations[[qmd]] <- bad.lines
  }
}
print(violations)

q(status=length(violations))
