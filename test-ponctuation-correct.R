library(data.table)
fr <- function(FIND, REP){
  data.table(FIND, REP)
}
find.rep.dt <- rbind(
  fr("[']", "’"),
  fr("[  ]:"," :"),
  fr("([^ ]):","\\1 :"),
  fr("«[^ ]","« "),
  fr("[  ]([»?!;])"," \\1"),
  fr("([^ ])([»?!;])","\\1 \\2"),
  fr(" +$", "")
)
correct <- function(chr_vec){
  for(row.i in 1:nrow(find.rep.dt)){
    chr_vec <- find.rep.dt[row.i, gsub(FIND, REP, chr_vec)]
  }
  chr_vec
}
before <- c(
  "C’est", "C'est", 
  "comme : ", "comme :", "comme:",
  "ça?", "ça ?", "ça ?")
once <- correct(before)
twice <- correct(once)
t(data.table(before, once, twice))

qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/*qmd"))
for(qmd in qmd.files){
  qmd.lines <- readLines(qmd)
  is.fence <- grepl("```", qmd.lines)
  is.text <- (cumsum(is.fence) %% 2)==0
  is.comment <- grepl("<!--|http|::", qmd.lines)
  can.rep <- is.text & !is.comment
  qmd.lines[can.rep] <- correct(qmd.lines[can.rep])
  writeLines(qmd.lines, qmd)
}


find.rep.dt <- rbind(
  fr("viz", "vis")
)
qmd.files <- c(
  Sys.glob("chapitres/*qmd"),
  Sys.glob("chapitres/*/*qmd"))
for(qmd in qmd.files){
  qmd.lines <- readLines(qmd)
  is.comment <- grepl("png", qmd.lines)
  can.rep <- !is.comment
  qmd.lines[can.rep] <- correct(qmd.lines[can.rep])
  writeLines(qmd.lines, qmd)
}
