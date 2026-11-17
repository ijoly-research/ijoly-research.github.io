# I. Joly Research

Site web académique d'Iragaël Joly, maître de conférences HDR en économie à Grenoble INP – UGA, Génie Industriel, et chercheur au Grenoble Applied Economics Lab (GAEL).

**Adresse du site :** https://ijoly-research.github.io

## Fonctionnement

- Site construit avec [Quarto](https://quarto.org), en anglais.
- Chaque push sur la branche `main` reconstruit et publie le site automatiquement (GitHub Actions → GitHub Pages). Compter 3 à 5 minutes.
- Les pages Publications, Supervision et l'accueil sont **générées à partir des fichiers de données** : il suffit de mettre ces fichiers à jour.

## Structure

| Fichier ou dossier | Contenu |
|---|---|
| `index.qmd` | Accueil (présentation, intérêts de recherche, activités récentes) |
| `research.qmd` | Recherche, projets, expertise |
| `publications.qmd` | Publications, générées depuis `data/bib/` |
| `supervision.qmd` | Encadrements, générés depuis `data/*.csv` |
| `teaching.qmd` | Enseignement et responsabilités |
| `industry.qmd` | Accompagnement et formation en IA pour l'industrie |
| `posts/` | Billets de blog (un dossier par billet) |
| `data/bib/` | Les fichiers BibTeX, un par catégorie (les mêmes que pour le CV) |
| `data/phd-supervision.csv` | Thèses encadrées |
| `data/masters-supervision.csv` | Mémoires de master encadrés |
| `R/bib.R` | Lecture et mise en forme des références |
| `styles/` | Couleurs et polices |

## Mettre à jour le site

| Je veux… | Comment |
|---|---|
| Ajouter une publication ou une communication | L'ajouter dans le bon fichier de `data/bib/`, puis commit et push. Elle apparaît aussi dans « Recent activities » si elle est récente. |
| Ajouter un doctorant à souligner | Ajouter son nom dans `students`, en haut de `R/bib.R` |
| Ajouter un encadrement | Ajouter une ligne dans `data/phd-supervision.csv` ou `data/masters-supervision.csv` |
| Écrire un billet | Dans RStudio : créer `posts/AAAA-MM-JJ-titre/index.qmd` (copier le billet existant), cliquer sur *Render*, puis commit et push **avec le dossier `_freeze/`** |
| Modifier une page | Éditer le fichier `.qmd` correspondant, dans RStudio ou directement sur GitHub |

## Billets avec du code R

Les billets sont « gelés » (`freeze: auto`) : le code R est exécuté sur votre ordinateur au moment du *Render*, et les résultats sont enregistrés dans `_freeze/`. Le serveur de publication réutilise ces résultats sans relancer le code, donc pas besoin d'installer vos packages R sur GitHub. Pensez à committer `_freeze/`.

## Prévisualiser en local

Dans RStudio, ouvrir le projet, puis dans le terminal : `quarto preview`. Le site s'ouvre dans le navigateur et se met à jour à chaque sauvegarde.

## Historique

Ce site remplace l'ancienne version Hugo/Wowchemy hébergée sur Netlify (https://ijolyresearch.netlify.app/).
