png_vec <- Sys.glob("Chapitres/*/*png")
library(data.table)
out.list <- list()
for(png in png_vec){
  png_data <- magick::image_read(png)
  png_at <- magick::image_attributes(png_data)
  png_dt <- data.table(png_at, key="property")
  int <- list("[0-9]+", as.integer)
  wh_string <- png_dt["png:IHDR.width,height", value]
  wh_dt <- nc::capture_first_vec(
    wh_string, width=int, ", ", height=int)
  out.list[[png]] <- data.table(png, wh_dt)
}
(out <- rbindlist(out.list))
