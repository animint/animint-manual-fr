# Traduction avec Babeldown

#########################################
################################################################################
################################################################################
# NE PAS TOUCHER À CE SCRIPT DANS LE MAIN
# DO NOT MODIFY THIS SCRIPT IN THE MAIN
################################################################################
################################################################################
#########################################

# Réglage de l'environnement de travail

path_local_animint2_fr <- "C:/Users/lepj1/OneDrive/Desktop/animint-manual-fr"

# mod 30 sep 2025 JL
# path_github_animint_book <- "https://raw.githubusercontent.com/tdhock/animint-book/master"

path_github_animint_book <- "https://raw.githubusercontent.com/animint/animint-manual-en/main/chapters"

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
      
      #combined_md <- paste0(combined_md, content, " ") TEST 12 aout 2025
      combined_md <- paste0(combined_md, content, "")
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



#####################################################################
#######


# Copie et modification du fichier de base 

ConvertRmd_comments <- function(
    file_name = "README",
    file_extension = ".md",
    source_filepath = path_github_animint_book,
    dest_filepath = path_local_animint2_fr,
    TestFile = TRUE,
    chx = "Ch05"
) {
  library(stringr)
  library(magick)
  
  # Define paths
  output_path <- file.path(dest_filepath, paste0(chx, "_source", ifelse(TestFile, "_Test", ""), ".qmd"))
  temp_file <- tempfile(pattern = paste0(chx, "_source_Temp"), fileext = ".qmd")
  
  # Clean up old temp files
  temp_dir <- tempdir()
  old_temp <- list.files(temp_dir, pattern = paste0(chx, "_source_Temp"), full.names = TRUE)
  if (length(old_temp) > 0) file.remove(old_temp)
  
  # Download source file

# mod 30 sep 2025 JL
#  download.file(
#    url = file.path(source_filepath, paste0(file_name, file_extension)),
#    destfile = temp_file,
#    mode = "wb"
#  )
  
  
    # Retry with lowercase chx
    chx_lower <- paste0(tolower(substr(chx, 1, 1)), substr(chx, 2, nchar(chx)))
    
    download.file(
      url = file.path(source_filepath, chx_lower, paste0(file_name, file_extension)),
      destfile = temp_file,
      mode = "wb"
    )
    
    # Copy related images
    
    # mod 30 sep 2025 JL  
    #  png_files <- list.files("animint-book", pattern = paste0("^", chx, ".*\\.png$"), recursive = TRUE, full.names = TRUE)
    
    png_files <- list.files(
      file.path("animint-manual-en","chapters", chx_lower),
      pattern = paste0("^",chx_lower,".*\\.png$"),
      recursive = TRUE,
      full.names = TRUE
    )
    
    file.copy(png_files, dest_filepath, overwrite = TRUE)
    
  
  # Run unleash and copy to output
  
# mod 30 sep 2025 JL  - adding the if .rmd and .qmd
  
  if(file_extension == ".Rmd") {
    
    adapted_unleash(temp_file, temp_file,FALSE)
    
  } else {
    
    unleash(temp_file,temp_file)

# mod 30 sep 2025 JL - fix for bullets not gluing      
  glue_bullets <- function(lines) {
      result <- c()
      for (line in lines) {
        if (grepl("^\\s{2,}", line) && length(result) > 0 && grepl("^\\s*-\\s", result[length(result)])) {
          result[length(result)] <- paste(result[length(result)], trimws(line))
        } else {
          result <- c(result, line)
        }
      }
      result
    }
    
  }
 
  file.copy(temp_file, output_path, overwrite = TRUE)
  
  # Read and clean text
  translated_text <- readLines(output_path, encoding = "UTF-8")
  translated_text <- gsub("\\\\_", "_", translated_text)
# mod 30 sep 2025 JL - fix for bullets not gluing         
  translated_text <- glue_bullets(translated_text)
  
  # Detect YAML end
  yaml_end <- which(translated_text == "---")[2]
  full_text <- paste(translated_text, collapse = "\n")
  
  # Split into chunks

 chunks <- str_split(full_text, "(?<=```\\n)|(?=```\\{r)", simplify = FALSE)[[1]]
  
  # Function to process prose chunks
  add_comments <- function(chunk) {
    if (str_detect(chunk, "^```\\{r") || str_detect(chunk, "^```$")) return(chunk)
    chunk <- gsub("(\\n{2,})(?!<!--)", "\\1<!-- paragraph -->\\1", chunk, perl = TRUE)
    chunk <- gsub(
      "(?<!\\b(ex|etc|e\\.g|i\\.e|Dr|Mr|Mme|M|e\\.g\\.|\\(e\\.g))(?<=[\\.\\!\\?]|\\])\\s+(?!<!-- paragraph -->)(?!\\n{1,2}<!-- paragraph -->)",
      "\n<!-- comment -->\n", chunk, perl = TRUE
    )
    return(chunk)
  }
  
  # Process all chunks
  processed_chunks <- list()
  for (i in seq_along(chunks)) {
    chunk <- chunks[[i]]
    if (str_detect(chunk, "^```\\{r")) {
      processed_chunks[[length(processed_chunks) + 1]] <- chunk
      processed_chunks[[length(processed_chunks) + 1]] <- "<!-- paragraph -->"
    } else if (str_detect(chunk, "^```$")) {
      processed_chunks[[length(processed_chunks) + 1]] <- chunk
    } else {
      processed_chunks[[length(processed_chunks) + 1]] <- add_comments(chunk)
    }
  }
  
  # Final cleanup: remove extra line breaks after paragraph markers
  text_clean <- gsub("<!-- paragraph -->\\n{2,}", "<!-- paragraph -->\n\n", paste(processed_chunks, collapse = "\n"))
  
  # Write final output
  writeLines(text_clean, output_path, useBytes = TRUE)
}

#####################
################################################################


#################################

# Fonction de la traduction FR <- EN utilisant babeldown

Translate_FR_EN <- function(file_name = "README",
                            file_extension = ".md",
                            source_filepath = path_github_animint_book,
                            dest_filepath = path_local_animint2_fr,
                            chx = "ch05") {
  
  library(stringr)
  
  # Chemins d'accès
  
  output_path <- paste0(dest_filepath, "/", chx,"_source","", ".qmd")
  Rmd_OG_path <- paste0(dest_filepath, "/", chx,"_source", ".qmd")
  
  # Mod 10 septembre 2025
  # output_path <- paste0(dest_filepath, "/", chx,"_index", ifelse(ajoutFR, "_FR", ""), file_extension)
  # Rmd_OG_path <- paste0(dest_filepath, "/", chx,"_index", file_extension)
  
  # mod 09 septembre 2025
  # output_path <- paste0(dest_filepath, "/", file_name, ifelse(ajoutFR, "_FR", ""), file_extension) 
  #Rmd_OG_path <- paste0(dest_filepath, "/", file_name, file_extension)
  
  # Traduction via babeldown

# mod 30 sep 2025 JL - pas besoin de specifier quarto, ca fait juste bugger     
#   if (file_extension == ".qmd") {
#    babeldown::deepl_translate_quarto(
#      path = Rmd_OG_path,
#      source_lang = "EN",
#      target_lang = "FR",
#      out_path = output_path,
#      glossary_name = "animint-manual-glossaire-fr-en"
#    )
#  } else {
    babeldown::deepl_translate(
      path = Rmd_OG_path,
      source_lang = "EN",
      target_lang = "FR",
      out_path = output_path,
      glossary_name = "animint-manual-glossaire-fr-en"
    )
#  }
    
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

  if(FALSE){
    # Injection du header personnalisé
    yaml_end <- which(cleaned_lines == "---")[2]
    header <- c(
      "",
      ifelse(file_name == "README", "# animint-manual-fr", ""),
      "",
      "Traduction de l'[anglais](https://github.com/animint/animint-manual-en/tree/main/chapters/)",
      paste0("[", file_name, "](", source_filepath, "/",chx,"/", file_name, file_extension, ")"),
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
    
  } else {
    
    # Écriture du fichier final
    writeLines(cleaned_lines, output_path, useBytes = TRUE)
  }
}

# Traduction du README avec la fonction Translate_FR_EN

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

# Traduction Chapitre 03 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch03-showSelected",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                    TestFile = FALSE,
                    chx = "Ch03"
)

Translate_FR_EN(file_name = "Ch03-showSelected",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch03"),
                chx = "Ch03"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 04 ####


# Traduction Chapitre 04 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch04-clickSelects",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch04"),
                    TestFile = FALSE,
                    chx = "Ch04"
)

Translate_FR_EN(file_name = "Ch04-clickSelects",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch04"),
                chx = "Ch04"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 05 ######

# Traduction Chapitre 05 par Anna Artiges

ConvertRmd_comments(file_name = "Ch05-sharing",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch05"),
                    TestFile = FALSE,
                    chx = "Ch05"
)

Translate_FR_EN(file_name = "Ch05-sharing",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch05"),
                chx = "Ch05"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 06 ######

# Traduction Chapitre 06 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch06-other",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch06"),
                    TestFile = FALSE,
                    chx = "Ch06"
)

Translate_FR_EN(file_name = "Ch06-other",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch06"),
                chx = "Ch06"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")


##### Chapitre 07 ######

# Traduction Chapitre 06 par Anna Artiges

ConvertRmd_comments(file_name = "Ch07-limitations",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch07"),
                    TestFile = FALSE,
                    chx = "Ch07"
)

Translate_FR_EN(file_name = "Ch07-limitations",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch07"),
                chx = "Ch07"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")


##### Chapitre 08 ######

# Traduction Chapitre 08 par Jeremi Lepage

ConvertRmd_comments(file_name = "Ch08-WorldBank-facets",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch08"),
                    TestFile = FALSE,
                    chx = "Ch08"
)

Translate_FR_EN(file_name = "Ch08-WorldBank-facets",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch08"),
                chx = "Ch08"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 09 ######

# Traduction Chapitre 09 par Anna Artiges

ConvertRmd_comments(file_name = "Ch09-Montreal-bikes",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch09"),
                    TestFile = FALSE,
                    chx = "Ch09"
)

Translate_FR_EN(file_name = "Ch09-Montreal-bikes",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch09"),
                chx = "Ch09"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 10 ######

# Traduction Chapitre 10 par Jérémi Lepage

ConvertRmd_comments(file_name = "Ch10-nearest-neighbors",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch10"),
                    TestFile = FALSE,
                    chx = "Ch10"
)

Translate_FR_EN(file_name = "Ch10-nearest-neighbors",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch10"),
                chx = "Ch10"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 11 ######

# Traduction Chapitre 11 par Anna Artiges

ConvertRmd_comments(file_name = "Ch11-lasso",
                    file_extension = ".Rmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch11"),
                    TestFile = FALSE,
                    chx = "Ch11"
)

Translate_FR_EN(file_name = "Ch11-lasso",
                file_extension = ".Rmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch11"),
                chx = "Ch11"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 12 ######

# Traduction Chapitre 12 par Jérémi Lepage

ConvertRmd_comments(file_name = "Ch12-SVM",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch12"),
                    TestFile = FALSE,
                    chx = "Ch12"
)

Translate_FR_EN(file_name = "Ch12-SVM",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch12"),
                chx = "Ch12"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 13 ######

# Traduction Chapitre 13 par Anna Artiges

ConvertRmd_comments(file_name = "Ch13-poisson-regression",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch13"),
                    TestFile = FALSE,
                    chx = "Ch13"
)

Translate_FR_EN(file_name = "Ch13-poisson-regression",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch13"),
                chx = "Ch13"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 14 ######

# Traduction Chapitre 14 par Jérémi Lepage

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch14"),
                    TestFile = FALSE,
                    chx = "ch14"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch14"),
                chx = "Ch14"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 15 ######

# Traduction Chapitre 15 par Anna Artiges

ConvertRmd_comments(file_name = "Ch15-Newton",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch15"),
                    TestFile = FALSE,
                    chx = "Ch15"
)

Translate_FR_EN(file_name = "Ch15-Newton",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch15"),
                chx = "Ch15"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 16 ######

# Traduction Chapitre 16 par Jérémi Lepage

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch16"),
                    TestFile = FALSE,
                    chx = "Ch16"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch16"),
                chx = "Ch16"
)

stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 17 ######

# Traduction Chapitre 17 par Anna Artiges

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch17"),
                    TestFile = FALSE,
                    chx = "Ch17"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch17"),
                chx = "Ch17"
)


stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 18 ######

# Traduction Chapitre 18 par Jérémi Lepage

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch18"),
                    TestFile = FALSE,
                    chx = "Ch18"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch18"),
                chx = "Ch18"
)


stop("Exécution interrompue volontairement pour éviter d'écraser les chapitres déjà traduits. \nExecution halted intentionally to avoid overwriting already translated chapters. \n\nCe segment du script doit être lancé manuellement.\nPlease run this section manually if needed.")

##### Chapitre 19 ######

# Traduction Chapitre 19 par Anna Artiges

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch19"),
                    TestFile = FALSE,
                    chx = "Ch19"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch19"),
                chx = "Ch19"
)

##### Chapitre 00 & 1 ######

# Traduction Chapitre 0 & 01 par Jérémi Lepage

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres"),
                    TestFile = FALSE,
                    chx = ""
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres"),
                chx = "Ch00&01"
)


##### Chapitre 99 ######

# Traduction Chapitre 99 par Jérémi Lepage

ConvertRmd_comments(file_name = "index",
                    file_extension = ".qmd",
                    source_filepath = path_github_animint_book,
                    dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch99"),
                    TestFile = FALSE,
                    chx = "Ch99"
)

Translate_FR_EN(file_name = "index",
                file_extension = ".qmd",
                source_filepath = path_github_animint_book,
                dest_filepath = paste0(path_local_animint2_fr,"/Chapitres/Ch99"),
                chx = "Ch99"
)