bad.regex <- paste(c(
  "idiom", # technique ou méthode
  "'", # ’ et non '
  "[^ ]:", # espace insécable avant deux points
  "«[^ ]", # espace fine insécable après guillemets ouvrants
  "[^ ][»?!;]"), # espace fine insécable avant »?!;
  collapse="|")
get_bad <- function(...){
  grep(bad.regex, c(...), value=TRUE)
}
good.vec <- c("C’est", "comme :")
bad.vec <- c("C'est", "comme :", "comme:")
(bad.computed <- get_bad(good.vec, bad.vec))
stopifnot(identical(bad.computed, bad.vec))
qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/*qmd"))
violations <- list()
for(qmd in qmd.files){
  qmd.lines <- readLines(qmd)
  is.fence <- grepl("```", qmd.lines)
  is.text <- (cumsum(is.fence) %% 2)==0
  qmd.text <- qmd.lines[is.text]
  no.comments <- grep("<!--", qmd.text, invert=TRUE, value=TRUE)
  bad.lines <- get_bad(no.comments)
  if(length(bad.lines)){
    violations[[qmd]] <- bad.lines
  }
}
print(violations)

q(status=length(violations))
