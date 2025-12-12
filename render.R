pkgs <- c("penaltyLearning","future.apply","maps","lars","LambertW","kernlab","data.table","quarto","chromote","magick","mlr3torch","glmnet","kknn","mlr3learners","mlr3tuning","WeightedROC","remotes","nc")
ins.mat <- installed.packages()
missing.pkgs <- setdiff(pkgs, rownames(ins.mat))
install.packages(missing.pkgs)
remotes::install_github("animint/animint2", dep=TRUE)
remotes::install_github(c("animint/animint2data","animint/animint2fr"))
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
file.copy("Chapitres/_source.qmd", "Chapitres/index.qmd", overwrite = TRUE)
quarto::quarto_render("Chapitres")

animint_js_vec <- Sys.glob("Chapitres/*/*/animint.js")
from_dir_vec <- dirname(animint_js_vec)
to_dir_vec <- dirname(sub("/", "/_book/", from_dir_vec))
from_to_list <- split(from_dir_vec, to_dir_vec)
for(to_dir in names(from_to_list)){
  from_dir <- from_to_list[[to_dir]]
  file.copy(from_dir, to_dir, recursive=TRUE)
}
viz_html_vec <- Sys.glob("Chapitres/_book/*/*-viz.html")
for(viz_html in viz_html_vec){
  base_html <- basename(viz_html)
  base_qmd <- sub("html", "qmd", base_html)
  source_qmd <- sub("-viz", "_source", base_qmd)
  sys::exec_wait("sed", c(
    "-i",
    sprintf("s/%s/%s/g", base_qmd, source_qmd),
    viz_html))
}
##grep  -nH --null 'Ch[0-9]*-viz.qmd' Chapitres/_book/*/*-viz.html
sys::exec_wait("grep", c("Ch[0-9]*-viz.qmd", "Chapitres/_book/*/*-viz.html"))
if(interactive())servr::httd("Chapitres/_book/")
