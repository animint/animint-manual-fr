out <- readLines("index_quarto_render.log")
(WARNING <- grep("WARNING", out, value=TRUE))
q(status=length(WARNING))

