# I. Joly Research

Site web académique d'Iragaël Joly, maître de conférences HDR en économie à Grenoble INP – Génie Industriel et chercheur au Grenoble Applied Economics Lab (GAEL).

**Adresse du site :** https://ijoly-research.github.io

## Contenu

- Présentation et thèmes de recherche : économétrie, modèles de choix discrets et de durée, modèles d'équations structurelles, appliqués au transport, aux choix des consommateurs et à la réputation des entreprises
- Publications
- Projets
- Communications et enseignements
- Articles (posts)
- CV et contact

## Fonctionnement

- Site statique généré avec [Hugo](https://gohugo.io/), rédaction possible avec R Markdown via [blogdown](https://pkgs.rstudio.com/blogdown/).
- Hébergé sur GitHub Pages : chaque modification poussée sur la branche `main` redéploie automatiquement le site via GitHub Actions.
- Les fichiers `.Rmd` sont transformés en `.html` en local (avec blogdown) avant le push, pour que le déploiement n'ait pas besoin de R.

## Modifier le site

| Je veux… | Comment |
|---|---|
| Écrire un article avec du code R | RStudio + blogdown, puis commit et push |
| Corriger une page ou écrire un article simple | Éditer le fichier Markdown directement sur GitHub |
| Ajouter une publication | Ajouter un dossier dans `content/publication/` |

## Historique

Ce site remplace l'ancienne version hébergée sur Netlify (https://ijolyresearch.netlify.app/).
