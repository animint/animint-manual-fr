# Traduction avec Babeldown

# Réglage de l'environnement de travail

path_local_animint2_fr <- "/home/anton/projetR/animint-manual-fr"

path_github_animint2 <- "https://raw.githubusercontent.com/animint/animint2/master"

path_github_animint_book <- "https://raw.githubusercontent.com/tdhock/animint-book/master"

path_tree_github_animint_book <- "https://github.com/tdhock/animint-book/tree/master"



# Installation du package babeldown

# Vérifie et installe si nécessaire, puis charge
for (pkg in c("babeldown", "aeolus")) {
  if (!require(pkg, character.only = TRUE)) {
    repos <- if (pkg == "babeldown") {
      c("https://ropensci.r-universe.dev", "https://cloud.r-project.org")
    } else {
      c("https://packages.ropensci.org", "https://cloud.r-project.org")
    }
    install.packages(pkg, repos = repos)
    library(pkg, character.only = TRUE)
  }
}


# Clé API de Jeremi pour DEEPL

Sys.setenv(DEEPL_API_URL = "https://api.deepl.com")
deepl_key <- Sys.setenv(DEEPL_API_KEY = "KEY")
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
      
      
    # Retire les espaces superflues  
      content <- trimws(content)
      combined_md <- sub("\\s+$", "", combined_md)
      combined_md <- paste0(combined_md, " ", content) # OG
      combined_md <- gsub("`\\s+([,.])", "`\\1", combined_md)
      
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




# Copie et modification du fichier de base 

ConvertRmd_comments <- function(file_name = "README",
                                file_extension = ".md",
                                source_filepath = path_github_animint2,
                                dest_filepath = path_local_animint2_fr,
                                #UpdateDoc = FALSE, # maj du doc traduit ou creation dun nouveau doc traduit
                                ajoutFR = TRUE,
                                TestFile = TRUE,
                                github_tree_filepath = path_tree_github_animint_book,
                                Chx = "Ch05-") {
  
  # Traduction utilisant babeldown et le glossaire maison  
  output_path <- paste0(dest_filepath,
                        "/",file_name,ifelse(TestFile,"_Test",""),file_extension)
  
  
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
  
  # Find all PNG files that start with "Chx"
  png_files <- list.files("animint-book", pattern = paste0("^", Chx, ".*\\.png$"), 
                          recursive = TRUE, full.names = TRUE)
  
  file.copy(png_files, dest_filepath,overwrite = TRUE)
  
  adapted_unleash(temp_file,temp_file)
  
  file.copy(temp_file, output_path, overwrite = TRUE)
  
  # Lire le fichier traduit
  translated_text <- readLines(output_path, encoding = "UTF-8")
  translated_text <- gsub("\\\\_", "_", translated_text)
  
  # Détecter les lignes de formatage YAML (triple tiret "---")
  yaml_end <- which(translated_text == "---")[2]  # Trouver la fin du YAML (deuxième occurrence)
  
  
  # Ajouter le header personnalisé
  #  header <- c("",ifelse(file_name == "README", "# animint-manual-fr", ""), "", "ConvertRmd_comments /n Traduction de [English](https://github.com/tdhock/animint-book/)",paste0("[",file_name,"]","(",source_filepath,"/",file_name,file_extension,")"),"")
  
  # Assembler le nouveau contenu
  #  updated_text <- c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)])
  
  #full_text <- paste(c(translated_text[1:yaml_end], header, translated_text[(yaml_end + 1):length(translated_text)]), collapse = "\n")
  
  full_text <- paste(c(translated_text[1:yaml_end],translated_text[(yaml_end + 1):length(translated_text)]), collapse = "\n")
  
  
  # Ajouter un commentaire HTML entre chaque paragraphe
  # 1. Séparation entre les phrases
  
  # updated_with_comments <- gsub("\n\n","\n\n<!-- comment -->\n\n",x = full_text)
  
  updated_with_comments<- gsub(
    "(\\n{2,})(?!<!--)",
    "\\1<!-- paragraph -->\\1",
    full_text,
    perl = TRUE
  )
  library(stringr)

text_with_phrase_comments <-str_replace_all(
  updated_with_comments,
  regex("(?<!\\b(ex|etc|e\\.g|i\\.e|Dr|Mr|Mme|M|e\\.g\\.|\\(e\\.g))(?<=[\\.\\!\\?]|\\])\\s+(?!<!-- paragraph -->)(?!\\n{1,2}<!-- paragraph -->)",
        ignore_case = TRUE, 
        multiline = TRUE)
  , 
  replacement = " "
)
#  text_with_phrase_comments <- gsub(
#    "(?<!\\b(ex|etc|e\\.g|i\\.e|Dr|Mr|Mme|M|e\\.g\\.|\\(e\\.g))(?<=[\\.\\!\\?]|\\])\\s+(?!<!-- paragraph -->)(?!\\n{1,2}<!-- paragraph -->)",
#    "\n<!-- comment -->\n",
#    updated_with_comments, 
#    perl = TRUE
#  )
  
  
  # Écrire le contenu modifié dans le fichier
  writeLines(text_with_phrase_comments, output_path, useBytes = TRUE)
  
  # Supprimer le fichier temporaire
  #unlink(temp_file)
  
}

#################################

# Fonction de la traduction FR <- EN utilisant babeldown

Translate_FR_EN <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint2,
                            dest_filepath = path_local_animint2_fr,
                            ajoutFR = TRUE) {
  
  library(stringr)
  
  # Chemins d'accès
  output_path <- paste0(dest_filepath, "/", file_name, ifelse(ajoutFR, "_FR", ""), file_extension)
  Rmd_OG_path <- paste0(dest_filepath, "/", file_name, file_extension)
  
  # Traduction via babeldown
  if (file_extension == ".qmd") {
    babeldown::deepl_translate_quarto(
      path = Rmd_OG_path,
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
      glossary_name = "animint-manual-glossaire-fr-en"
    )
  }
  
  # Lire le fichier traduit
  translated_text <- readLines(output_path, encoding = "UTF-8")
  
  # Restaurer les balises modifiées par DeepL
  translated_text <- str_replace_all(translated_text, "<!-- commentaire -->", "<!-- comment -->")
  translated_text <- str_replace_all(translated_text, "<!-- paragraphe -->", "<!-- paragraph -->")
  translated_text <- str_replace_all(translated_text, "<!--comment-->", "<!-- comment -->")
  
  # Nettoyage du format selon le type de balise
  cleaned_lines <- c()
  i <- 1
  while (i <= length(translated_text)) {
    line <- translated_text[i]
    #print(line)
    
    if (str_trim(line) == "<!-- comment -->") {
      # Supprimer ligne vide avant
      if (length(cleaned_lines) > 0 && str_trim(cleaned_lines[length(cleaned_lines)]) == "") {
        cleaned_lines <- cleaned_lines[-length(cleaned_lines)]
      }
      cleaned_lines <- c(cleaned_lines, line)
      # Supprimer ligne vide après
      j <- i + 1
      while (j <= length(translated_text) && str_trim(translated_text[j]) == "") {
        i <- i + 1  # sauter les lignes vides
        j <- j + 1
      }
    } else if (str_trim(line) == "<!-- paragraph -->") {
      # Ajouter ligne vide avant (si absente)
      if (length(cleaned_lines) == 0 || str_trim(cleaned_lines[length(cleaned_lines)]) != "") {
        cleaned_lines <- c(cleaned_lines, "")
      }
      cleaned_lines <- c(cleaned_lines, line)
      # Ajouter ligne vide après (si absente)
      if (i < length(translated_text) && str_trim(translated_text[i + 1]) != "") {
        cleaned_lines <- c(cleaned_lines, "")
      }
    } else {
      cleaned_lines <- c(cleaned_lines, line)
    }
    i <- i + 1
  }
  
  # Conversion finale des paragraphes en commentaires
 # cleaned_lines <- str_replace_all(cleaned_lines, "<!-- paragraph -->", "<!-- comment -->")
  
  
  # Injection du header personnalisé
  yaml_end <- which(cleaned_lines == "---")[2]
  header <- c(
    "",
    ifelse(file_name == "README", "# animint-manual-fr", ""),
    "",
    "Traduction de [English](https://github.com/tdhock/animint-book/)",
    paste0("[", file_name, "](", source_filepath, "/", file_name, file_extension, ")"),
    ""
  )
  #print(cleaned_lines)
  final_lines <- c(
    cleaned_lines[1:yaml_end],
    header,
    cleaned_lines[(yaml_end + 1):length(cleaned_lines)]
  )
  
  # Écriture du fichier final
  writeLines(final_lines, output_path, useBytes = TRUE)
}

# Traduction du README avec la fonction Translate_FR_EN



# Traduction Chapitre 03 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch03-showSelected",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch03-"
)

Translate_FR_EN(file_name = "Ch03-showSelected",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)


quarto::quarto_render(input = "Chapitres/Ch03/Ch03-showSelected_ConvertRmd_comments.Rmd")


##### Chapitre 04 ####


# Traduction Chapitre 04 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch04-clickSelects",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch04"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch04-"
)

Translate_FR_EN(file_name = "Ch04-clickSelects",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch04"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)


##### Chapitre 05 ######

# Traduction Chapitre 05 par Anna Artiges

ConvertRmd_comments(file_name = "Ch05-sharing",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch05"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch05-"
)

Translate_FR_EN(file_name = "Ch05-sharing",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch05"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)


##### Chapitre 06 ######

# Traduction Chapitre 06 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch06-other",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch06"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch06-"
)

Translate_FR_EN(file_name = "Ch06-other",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch06"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)


##### Chapitre 07 ######

# Traduction Chapitre 06 par Anna Artiges

ConvertRmd_comments(file_name = "Ch07-limitations",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch07"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch07-"
)

Translate_FR_EN(file_name = "Ch07-limitations",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch07"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)



##### Chapitre 08 ######

# Traduction Chapitre 08 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch08-WorldBank-facets",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch08"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch08-"
)

Translate_FR_EN(file_name = "Ch08-WorldBank-facets",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch08"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)


# Traduction Chapitre 09 par Anna Artiges

ConvertRmd_comments(file_name = "Ch09-Montreal-bikes",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch09"),
                    github_tree_filepath = path_tree_github_animint_book,
                    #UpdateDoc = TRUE,
                    ajoutFR = FALSE,
                    TestFile = FALSE,
                    Chx = "Ch09-"
)

Translate_FR_EN(file_name = "Ch09-Montreal-bikes",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch09"),
                #UpdateDoc = TRUE,
                ajoutFR = FALSE
)
