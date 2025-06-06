# Traduction avec Babeldown

# Réglage de l'environnement de travail

path_local_animint2_fr <- "C:/Users/lepj1/OneDrive/Desktop/animint-manual-fr"

path_github_animint2 <- "https://raw.githubusercontent.com/animint/animint2/master"

path_github_animint_book <- "https://raw.githubusercontent.com/tdhock/animint-book/master"

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

Translate_FR_EN <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint2,
                            dest_filepath = path_local_animint2_fr,
                            ajoutFR = TRUE) {
    
  # Création d'un fichier temporaire
    temp_file <- tempfile(pattern = paste0(file_name,"_Temp"),
                          fileext = file_extension)
    
  # Téléchargement du fichier
    download.file(url = paste0(source_filepath,"/",file_name,file_extension),
                  destfile = temp_file,
                  mode = "wb")
    
  # Traduction utilisant babeldown et le glossaire maison  
    output_path <- paste0(dest_filepath,
                          "/",file_name,ifelse(ajoutFR,"_FR",""),file_extension)
    
    if(file_extension == ".qmd"){
      
      babeldown::deepl_translate_quarto(
        path = temp_file,
        source_lang = "EN",
        target_lang = "FR",
        out_path = output_path,
        glossary_name = "animint-manual-glossaire-fr-en"
      )
      
      
    } else {
      
      babeldown::deepl_translate(
        path = temp_file,
        source_lang = "EN",
        target_lang = "FR",
        out_path = output_path,
        glossary_name = "animint-manual-glossaire-fr-en")
    }
    
  # Lire le fichier traduit
    translated_text <- readLines(output_path, encoding = "UTF-8")
    
    
  # Détecter les lignes de formatage YAML (triple tiret "---")
    yaml_end <- which(translated_text == "---")[2]  # Trouver la fin du YAML (deuxième occurrence)
    
    
  # Ajouter le header personnalisé
    header <- c("",ifelse(file_name == "README", "# animint-manual-fr", ""), "", "Traduction de [English](https://github.com/tdhock/animint-book/)",paste0("[",file_name,"]","(",source_filepath,"/",file_name,file_extension,")"),"")
    
  # Assembler le nouveau contenu
    updated_text <- c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)])
    
  # Écrire le contenu modifié dans le fichier
    writeLines(updated_text, output_path, useBytes = TRUE)
    
  # Supprimer le fichier temporaire
    unlink(temp_file)
    

  }

# Traduction du README avec la fonction Translate_FR_EN

Translate_FR_EN(file_name = "README",
                file_extension = ".md",
                source_filepath = path_github_animint2,
                dest_filepath = path_local_animint2_fr,
                ajoutFR = FALSE)


# Traduction Chapitre 03 par Jeremi Lepage

Translate_FR_EN(file_name = "Ch03-showSelected",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                ajoutFR = FALSE)
