pkgs <- c("penaltyLearning","future.apply","maps","lars","LambertW","kernlab","data.table","quarto","chromote","magick","mlr3torch","glmnet","kknn","mlr3learners","mlr3tuning","WeightedROC","remotes","nc")
ins.mat <- installed.packages()
missing.pkgs <- setdiff(pkgs, rownames(ins.mat))
install.packages(missing.pkgs)
remotes::install_github("animint/animint2", dep=TRUE)
remotes::install_github(c("animint/animint2data","animint/animint2fr"))
chapters <- "chapitres"
quarto::quarto_render(chapters)
## copy data viz to site.
gvec <- file.path(chapters, c("*/animint.js", "ch*/*/animint.js"))
for(glob in gvec){
  animint_js_vec <- Sys.glob(glob)
  from_dir_vec <- dirname(animint_js_vec)
  to_dir_vec <- dirname(sub("/", "/_book/", from_dir_vec))
  from_to_list <- split(from_dir_vec, to_dir_vec)
  for(to_dir in names(from_to_list)){
    from_dir <- from_to_list[[to_dir]]
    print(to_dir)
    file.copy(from_dir, to_dir, recursive=TRUE)
  }
}
## preview site.
if(interactive())servr::httd(file.path(chapters, "_book"))

