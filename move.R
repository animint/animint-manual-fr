qmd <- Sys.glob("chapitres/*/*source.qmd")
to <- sub("Ch.*", "index.qmd", qmd)
for(cmd in paste("git mv", qmd, to))system(cmd)

cap <- Sys.glob("chapitres/*/Ch*.*")
for(cmd in paste("git mv", cap, sub("Ch", "ch", cap)))system(cmd)
