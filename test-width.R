qmd.files <- c(
  Sys.glob("Chapitres/*qmd"),
  Sys.glob("Chapitres/*/*.qmd"))
violations <- list()
for(qmd in qmd.files){
  code.R <- knitr::purl(qmd, documentation=0)
  code.lines <- readLines(code.R)
  chars.wide <- nchar(code.lines)
  too.long <- chars.wide>72
  if(any(too.long)){
    violations[[qmd]] <- code.lines[too.long]
  }
  unlink(code.R)
}
print(violations)
q(status=length(violations))
