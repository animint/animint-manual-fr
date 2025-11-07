qmd.files <- c(
  Sys.glob("Chapitres/*qmd"),
  Sys.glob("Chapitres/*/*qmd"))
library(data.table)
violations <- list()
for(qmd in qmd.files){
  link_dt <- nc::capture_all_str(
    qmd,
    "!\\[",
    caption=".*?",
    "\\]\\(",
    file=".*?",
    "\\)")
  long_dt <- rbind(
    data.table(file="ignored", type=c("exists","link")),
    data.table(
      file=dir(dirname(qmd), pattern="png$"),
      type="exists"),
    link_dt[, .(file, type="link")])
  wide_dt <- dcast(long_dt, file ~ type, length)
  problem_dt <- wide_dt[exists+link<2]
  if(nrow(problem_dt)){
    violations[[qmd]] <- problem_dt
  }
}
print(violations)
q(status=length(violations))
