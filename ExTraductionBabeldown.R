# Traduction avec Babeldown

# Réglage de l'environnement de travail

path_local_animint2_fr <- "C:/Users/lepj1/OneDrive/Desktop/animint-manual-fr"

path_github_animint2 <- "https://raw.githubusercontent.com/animint/animint2/master"

# Installation du package babeldown

install.packages('babeldown',
                 repos = c('https://ropensci.r-universe.dev',
                           'https://cloud.r-project.org'))

# Clé API de Jeremi pour DEEPL

Sys.setenv(DEEPL_API_KEY = "3be8c59d-9e13-4022-a7d8-30cd5bf3a9b6:fx")

# MAJ du glossaire

if (FALSE) { # \dontrun{
  babeldown::deepl_upsert_glossary(
    filename = "animint-manual-glossaire-fr-en.csv",
    target_lang = "FR",
    source_lang = "EN"
  )
} # }

# Fonction de la traduction FR <- EN utilisant babeldown

Translate_FR_EN <- function(file_name = "README", file_extension = ".md") {
    
  # Création d'un fichier temporaire
    temp_file <- tempfile(pattern = paste0(file_name,"_Temp"),
                          fileext = file_extension)
    
  # Téléchargement du fichier
    download.file(url = paste0(path_github_animint2,"/",file_name,file_extension),
                  destfile = temp_file,
                  mode = "wb")
    
  # Traduction utilisant babeldown et le glossaire maison  
    output_path <- paste0(path_local_animint2_fr,
                          "/",file_name,"_FR",file_extension)
    
    babeldown::deepl_translate(path = temp_file,
                               source_lang = "EN",
                               target_lang = "FR",
                               out_path = output_path,
                               glossary_name = "animint-manual-glossaire-fr-en")
    
  # Lire le fichier traduit
    translated_text <- readLines(output_path, encoding = "UTF-8")
    
  # Ajouter le header personnalisé
    header <- c("# animint-manual-fr", "", "Traduction de [English](https://github.com/tdhock/animint-book/)", "")
    updated_text <- c(header, translated_text)
    
  # Écrire le contenu modifié dans le fichier
    writeLines(updated_text, output_path, useBytes = TRUE)
    
  # Supprimer le fichier temporaire
    unlink(temp_file)
    

  }

# Traduction du README avec la fonction Translate_FR_EN

Translate_FR_EN(file_name = "README", file_extension = ".md")


