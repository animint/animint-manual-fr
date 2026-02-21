qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/index.qmd"))
library(data.table)
violations <- list()
for(qmd in qmd.files){
  link_dt <- nc::capture_all_str(
    qmd,
    "\\]\\(",
    url="http.*?",
    "\\)")
  if(nrow(link_dt)){
    violations[[qmd]] <- link_dt$url
  }
}
print(violations)

q(status=length(violations))
