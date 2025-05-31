# animint-manual-fr

traduction de [English](https://github.com/tdhock/animint-book/)

<a href="https://github.com/tdhock/animint2/actions/workflows/tests.yaml"> <img src="https://github.com/tdhock/animint2/actions/workflows/tests.yaml/badge.svg" alt="Un badge vérifiant que ce paquet a passé tous ses tests."/> </a> \<N'hésitez pas à transformer le bloc HTML au-dessus de ce commentaire en Markdown. C'est juste en HTML parce que je n'ai pas réussi à trouver comment combiner correctement une image et un lien dans le Markdown à la sauce Github. --\>

Diapositives en [Anglais](https://docs.google.com/presentation/d/1QDwo9x4OM7UKAXffJrny6nSfeytFR0kO5NB-NQEspcE/edit?usp=sharing) et [français](https://docs.google.com/presentation/d/1WpRZs9qz9wm1yik_MLj8tIJyWuL5-IBPYKLhOHZ9X4Y/edit?usp=sharing) pour une présentation de 30 à 60 minutes sur animint2 ! [Résumé](https://github.com/animint/animint2/wiki/Presentations#30-60-minute-talk), [Vidéo de la présentation à Toulouse-Dataviz](https://www.youtube.com/watch?v=Em6AVJi37zo).

## A propos de

Animint2 est un paquetage R permettant de générer et de partager des visualisations de données interactives animées, parfois appelées animints. Il s'agit d'un fork de, et utilise une syntaxe similaire à, [ggplot2](https://ggplot2.tidyverse.org/). Animint2 est particulièrement utile pour les grands ensembles de données, mais des ensembles de données plus petits peuvent également être rendus interactifs. Il est également capable de générer des visualisations de données statiques.

<a href="https://rcdata.nau.edu/genomic-ml/WorldBank-facets/"><img src="man/figures/world_bank_screencast.gif" alt="Screencast d&apos;une visualisation de données interactive affichant des données sur la fertilité de la Banque mondiale. L&apos;utilisateur tape dans le menu de sélection et clique sur la légende, ce qui entraîne des changements dans la visualisation. GIF."/></a>

Jouer avec [cette visualisation interactive de données de la Banque mondiale](https://rcdata.nau.edu/genomic-ml/WorldBank-facets/) ou [une version plus récente qui comprend également une carte du monde](https://tdhock.github.io/2025-01-WorldBank-facets-map/). Pour plus d'exemples, voir ces galeries, qui contiennent des captures d'écran ainsi que des liens vers l'affichage interactif des données et le code source :

-   [NAU rcdata animint gallery](https://rcdata.nau.edu/genomic-ml/animint-gallery/) contient plus de 50 exemples de viz big data datant de la création d'animint en 2014.
-   [GitHub Pages animint gallery](https://animint.github.io/gallery) est une collection plus récente d'animints qui ont été publiés à l'aide de l'outil `animint2pages` fonction.

Pour apprendre à générer vos propres visualisations interactives de données, rendez-vous sur le site officiel de la [Manuel Animint2](https://rcdata.nau.edu/genomic-ml/animint2-manual/Ch00-preface.html). Si vous rencontrez des problèmes, veuillez consulter le [animint2 wiki](https://github.com/animint/animint2/wiki) ou [les signaler](https://github.com/animint/animint2/issues).

## Installation

``` r
# Install the official package from CRAN.
# This is the option most people should choose:
install.packages("animint2")

# If you want to install the development version:
devtools::install_github("animint/animint2")
```

## Utilisation

Animint2 utilise la même implémentation de `ggplot2` avec quelques ajouts. Si vous êtes familier avec `ggplot2` l'utilisation de `animint2` sera facile à utiliser. Si ce n'est pas le cas, ne vous inquiétez pas. Pour commencer, consultez la brève [Guide de démarrage rapide d'Animint2](https://animint.github.io/animint2/articles/animint2.html) ou lisez les premiers chapitres du [Manuel Animint2](https://rcdata.nau.edu/genomic-ml/animint2-manual/Ch00-preface.html).

`animint2` rend et anime des visualisations de données. Il ne peut ni manipuler les ensembles de données que vous lui fournissez, ni générer ses propres données.

## Paquets similaires

`animint2` n'est pas le seul package R permettant de créer des visualisations de données animées ou interactives.

[animation](https://cran.r-project.org/package=animation) et [gganimate](https://cloud.r-project.org/web/packages/gganimate/index.html) permettent d'animer les changements entre les variables au fil du temps. Les [lion](https://cran.r-project.org/package=loon) est spécialisé dans l'analyse exploratoire des données. [plotly](https://cran.r-project.org/package=plotly) est probablement le plus similaire à animint2 en termes de fonctionnalités.

Pour des comparaisons entre les paquets susmentionnés et `animint2` voir [la page wiki sur les différences](https://github.com/animint/animint2/wiki/Differences-with-other-packages).

## Problèmes ?

Les `animint2` est un travail en cours. Si vous repérez des bogues ou des comportements inattendus, merci de nous en informer par [en signalant un problème sur GitHub](https://github.com/animint/animint2/issues). Nous vous remercions. Bonne journée à tous.

## Autres galeries

[Vatsal-Rajput](https://github.com/Vatsal-Rajput/Vatsal-Animint-Gallery/tree/gh-pages) a créé une petite galerie avec un fichier index.Rmd différent.

[nhintruong](https://nhintruong.github.io/gallery_repo/) a créé une galerie avec plusieurs exemples adaptés du paquet d'animation, comme [la page wiki](https://github.com/tdhock/animint/wiki/Ports-of-animation-examples).
