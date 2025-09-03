options(repos="http://cloud.r-project.org")
for(p in c("nc","quarto","animint2"))if(!requireNamespace(p))install.packages(p)
remotes::install_github("animint/animint2")
if(!requireNamespace("animint2fr"))remotes::install_github("animint/animint2fr")
qmd_vec <- Sys.glob("Chapitres/Ch*/Ch*_source.qmd")
for(qmd_i in seq_along(qmd_vec)){
  qmd_in <- qmd_vec[[qmd_i]]
  qmd_out <- sub("_source", "-viz", qmd_in)
  name_dt <- nc::capture_all_str(
    qmd_in,
    "\n```{r ",
    name="[^ ,}]+")
  pattern <- paste0("^", sub(".qmd", "", basename(qmd_out)))
  bad_dt <- name_dt[!grepl(pattern, name)]
  if(nrow(bad_dt)){
    cat(qmd_in, "-----BAD chunk names\n")
    print(bad_dt)
  }
  dup_dt <- name_dt[, .(count=.N), by=name][count>1]
  if(nrow(dup_dt)){
    cat(qmd_in, "-----DUPLICATE chunk names\n")
    print(dup_dt)
  }
  sys::exec_wait("grep", c("-v", "'<!--'", qmd_in), std_out=qmd_out)
}
if(FALSE){
  # On Ubuntu xelatex is required for quarto book pdf.
  system("sudo apt install texlive-xetex")
}
quarto::quarto_render("Chapitres")
animint_js_vec <- Sys.glob("Chapitres/*/*/animint.js")
from_dir_vec <- dirname(animint_js_vec)
to_dir_vec <- dirname(sub("/", "/_book/", from_dir_vec))
from_to_list <- split(from_dir_vec, to_dir_vec)
for(to_dir in names(from_to_list)){
  from_dir <- from_to_list[[to_dir]]
  file.copy(from_dir, to_dir, recursive=TRUE)
}
if(interactive())servr::httd("Chapitres/_book/")
