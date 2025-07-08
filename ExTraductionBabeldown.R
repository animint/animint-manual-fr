# Traduction avec Babeldown

# Réglage de l'environnement de travail

path_local_animint2_fr <- "C:/Users/lepj1/OneDrive/Desktop/animint-manual-fr"

path_github_animint2 <- "https://raw.githubusercontent.com/animint/animint2/master"

path_github_animint_book <- "https://raw.githubusercontent.com/tdhock/animint-book/master"

path_tree_github_animint_book <- "https://github.com/tdhock/animint-book/tree/master"



# Installation du package babeldown

install.packages('babeldown',
                 repos = c('https://ropensci.r-universe.dev',
                           'https://cloud.r-project.org'))

install.packages("aeolus",
                 repos = c("https://packages.ropensci.org",
                           "https://cloud.r-project.org"))

# Clé API de Jeremi pour DEEPL

Sys.setenv(DEEPL_API_URL = "https://api.deepl.com")
deepl_key <- Sys.getenv("DEEPL_API_KEY")
Sys.setenv(DEEPL_AUTH_KEY = deepl_key)

# MAJ du glossaire

if (FALSE) { # \dontrun{
  babeldown::deepl_upsert_glossary(
    filename = "animint-manual-glossaire-fr-en.csv",
    target_lang = "FR",
    source_lang = "EN"
  )
} # }



adapted_unleash <- function(path,
                            new_path = path,
                            showCombinedText = FALSE) {
  if (!file.exists(path)) {
    cli::cli_abort("Can't find path {path}.")
  }
  
  yarn <- tinkr::yarn$new(path, sourcepos = TRUE)
  
  nodes <- xml2::xml_find_all(
    yarn$body,
    ".//d1:paragraph[not(.//d1:image)]"
  )
  
  purrr::walk(nodes, function(node) {
    children <- xml2::xml_children(node)
    if (length(children) == 0) return()
    
    combined_md <- ""
    
    for (child in children) {
      tag <- xml2::xml_name(child)
      
      if (tag == "link") {
        link_text <- xml2::xml_text(child)
        href <- xml2::xml_attr(child, "destination")
        if (is.na(href) || href == "") {
          href <- xml2::xml_attr(child, "target")
        }
        if (is.na(href) || href == "") {
          href <- xml2::xml_attr(child, "href")
        }
        if (!is.na(href) && href != "") {
          content <- paste0("[", link_text, "](", href, ")")
        } else {
          content <- link_text
        }
      } else if (tag == "code") {
        content <- paste0("`", xml2::xml_text(child), "`")
      } else {
        content <- xml2::xml_text(child)
      }
      
      combined_md <- paste0(combined_md, content, " ")
    }
    
    combined_md <- trimws(combined_md)
    
    if (showCombinedText) {
      message("Paragraph: ", combined_md)
    }
    
    xml2::xml_remove(xml2::xml_children(node))
    xml2::xml_add_child(node, "text", combined_md)
  })
  
  yarn$write(new_path)
  
  # POST-PROCESS output to strip escaping backslashes before [ ] ( ), and also backticks `
  out_lines <- readLines(new_path, encoding = "UTF-8", warn = FALSE)
  out_lines_clean <- gsub("\\\\(\\[|\\]|\\(|\\)|`)", "\\1", out_lines)
  writeLines(out_lines_clean, new_path, useBytes = TRUE)
  
  invisible(new_path)
}




# Fonction de la traduction FR <- EN utilisant babeldown

Translate_FR_EN <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint2,
                            dest_filepath = path_local_animint2_fr,
                            #UpdateDoc = FALSE, # maj du doc traduit ou creation dun nouveau doc traduit
                            ajoutFR = TRUE) {
    

    
  # Traduction utilisant babeldown et le glossaire maison  
    output_path <- paste0(dest_filepath,
                          "/",file_name,ifelse(ajoutFR,"_FR",""),file_extension)
    
    
    # Définition du répertoire temporaire et suppression des anciens fichiers
    temp_dir <- tempdir()
    existing_temp_files <- list.files(temp_dir, pattern = paste0(file_name, "_Temp"), full.names = TRUE)
    
  #  if(UpdateDoc == TRUE) {
  #    
  #    babeldown::deepl_update(
  #      path = existing_temp_files,
  #      source_lang = "EN",
  #      target_lang = "FR",
  #      out_path = output_path,
  #      glossary_name = "animint-manual-glossaire-fr-en")
      
  #  } else {
      
      if (length(existing_temp_files) > 0) {
        file.remove(existing_temp_files)
      }
      
      # Création d'un fichier temporaire
      temp_file <- tempfile(pattern = paste0(file_name,"_Temp"),
                            fileext = file_extension)
      
      # Téléchargement du fichier
      download.file(url = paste0(source_filepath,"/",file_name,file_extension),
                    destfile = temp_file,
                    mode = "wb")
      
      adapted_unleash(temp_file,temp_file)
      #aeolus::unleash(temp_file,temp_file)
    
    if(file_extension == ".qmd") {
      
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
   # }
    
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
    #unlink(temp_file)
    
  }


ConvertRmd_comments <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint2,
                            dest_filepath = path_local_animint2_fr,
                            #UpdateDoc = FALSE, # maj du doc traduit ou creation dun nouveau doc traduit
                            ajoutFR = TRUE,
                            github_tree_filepath = path_tree_github_animint_book,
                            Chx = "Ch03-") {
  
  # Traduction utilisant babeldown et le glossaire maison  
  output_path <- paste0(dest_filepath,
                        "/",file_name,file_extension)
  
  
  # Définition du répertoire temporaire et suppression des anciens fichiers
  temp_dir <- tempdir()
  existing_temp_files <- list.files(temp_dir, pattern = paste0(file_name, "_Temp"), full.names = TRUE)
  
  if (length(existing_temp_files) > 0) {
    file.remove(existing_temp_files)
  }
  
  # Création d'un fichier temporaire
  temp_file <- tempfile(pattern = paste0(file_name,"_Temp"),
                        fileext = file_extension)
  
  # Téléchargement du fichier
  download.file(url = paste0(source_filepath,"/",file_name,file_extension),
                destfile = temp_file,
                mode = "wb")
  
  # et des photos
  
  library(magick)
  
  # Find all PNG files that start with "Ch03-"
  png_files <- list.files("animint-book", pattern = "^Ch03-.*\\.png$", 
                          recursive = TRUE, full.names = TRUE)
  
  file.copy(png_files, dest_filepath,overwrite = TRUE)
  
  adapted_unleash(temp_file,temp_file)
  
  file.copy(temp_file, output_path, overwrite = TRUE)
  
  # Lire le fichier traduit
  translated_text <- readLines(output_path, encoding = "UTF-8")
  
  
  # Détecter les lignes de formatage YAML (triple tiret "---")
  yaml_end <- which(translated_text == "---")[2]  # Trouver la fin du YAML (deuxième occurrence)
  

  # Ajouter le header personnalisé
  header <- c("",ifelse(file_name == "README", "# animint-manual-fr", ""), "", "ConvertRmd_comments /n Traduction de [English](https://github.com/tdhock/animint-book/)",paste0("[",file_name,"]","(",source_filepath,"/",file_name,file_extension,")"),"")
  
  # Assembler le nouveau contenu
 # updated_text <- c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)])
  
  full_text <- paste(c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)]), collapse = "\n")
   
  # Ajouter un commentaire HTML entre chaque paragraphe
  updated_with_comments <- gsub("\n\n","\n\n<!-- paragraphe suivant -->\n\n",x = full_text)
  
  # Écrire le contenu modifié dans le fichier
  writeLines(updated_with_comments, output_path, useBytes = TRUE)
  
  # Supprimer le fichier temporaire
  #unlink(temp_file)
  
}



# Fonction de la traduction FR <- EN utilisant babeldown

Translate_FR_EN <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint2,
                            dest_filepath = path_local_animint2_fr,
                            #UpdateDoc = FALSE, # maj du doc traduit ou creation dun nouveau doc traduit
                            ajoutFR = TRUE) {
  
  # Traduction utilisant babeldown et le glossaire maison  
  output_path <- paste0(dest_filepath,
                        "/",file_name,ifelse(ajoutFR,"_FR",""),file_extension)
  
  Rmd_OG_path <- paste0(dest_filepath,
                        "/",file_name,file_extension)
  
  # Téléchargement du fichier
 # download.file(url = paste0(source_filepath,"/",file_name,file_extension),
 #               destfile = temp_file,
 #               mode = "wb")
  
  if(file_extension == ".qmd") {
    
    babeldown::deepl_translate_quarto(
      path = temp_file,
      source_lang = "EN",
      target_lang = "FR",
      out_path = output_path,
      glossary_name = "animint-manual-glossaire-fr-en"
    )
    
  } else {
    
    babeldown::deepl_translate(
      path = Rmd_OG_path,
      source_lang = "EN",
      target_lang = "FR",
      out_path = output_path,
      glossary_name = "animint-manual-glossaire-fr-en")
  }
  # }
  
  # Lire le fichier traduit
  translated_text <- readLines(output_path, encoding = "UTF-8")
  
  
  # Détecter les lignes de formatage YAML (triple tiret "---")
  yaml_end <- which(translated_text == "---")[2]  # Trouver la fin du YAML (deuxième occurrence)
  
  
  # Ajouter le header personnalisé
  header <- c("",ifelse(file_name == "README", "# animint-manual-fr", ""), "", "Traduction de [English](https://github.com/tdhock/animint-book/)",paste0("[",file_name,"]","(",source_filepath,"/",file_name,file_extension,")"),"")
  
  # Assembler le nouveau contenu
  updated_text <- paste(c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)]), collapse = "\n")
  
  # Écrire le contenu modifié dans le fichier
  writeLines(updated_text, output_path, useBytes = TRUE)
  
  # Supprimer le fichier temporaire
  #unlink(temp_file)
  
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
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
                )

ConvertRmd_comments(file_name = "Ch03-showSelected",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                github_tree_filepath = path_tree_github_animint_book,
                #UpdateDoc = TRUE,
                ajoutFR = FALSE,
                Chx = "Ch03-"
)


quarto::quarto_render(input = "Chapitres/Ch03/Ch03-showSelected_ConvertRmd_comments.Rmd")
