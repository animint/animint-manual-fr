# Traduction avec Babeldown

```{r Traduction Babeldown}
# Installation du package babeldown

install.packages('babeldown', repos = c('https://ropensci.r-universe.dev', 'https://cloud.r-project.org'))


Sys.setenv(DEEPL_API_KEY = "3be8c59d-9e13-4022-a7d8-30cd5bf3a9b6:fx")

babeldown::deepl_translate("C:/Users/lepj1/Downloads/README (1).md", source_lang = "EN", target_lang = "FR",out_path = "C:/Users/lepj1/Downloads/README_translated.md")

```