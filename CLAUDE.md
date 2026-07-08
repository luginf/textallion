# Textallion — Guide pour Claude

## Vue d'ensemble

Textallion est un processeur de documents léger (« Tiny almost-Kiss Word Processor ») écrit par Éric Forgeot (2008-2026). Il prend des fichiers `.t2t` (syntaxe txt2tags) en entrée et génère du HTML, du PDF (via LaTeX/XeTeX), de l'EPUB (via Calibre) et d'autres formats. Il inclut un module CYOA (gamebooks / livres dont vous êtes le héros) avec exports vers de nombreux moteurs de fiction interactive.

## Structure du dépôt

```
core/           Moteur Textallion
  textallion.t2t      Règles preproc/postproc centrales (symboles, mise en forme étendue)
  textallion.sh       Interface en ligne de commande (menus shell)
  txt2cyoa.t2t        Règles supplémentaires pour les documents CYOA
  textallion.sty      Style LaTeX par défaut
  textallion_beamer.t2t  Config pour présentations Beamer
  lines.py            Utilitaire Python
  adventurebook.pl    Exporteur Perl (gamebook)
  convert_*.sh        Scripts de conversion depuis d'autres formats

contrib/
  txt2tags/txt2tags3  Moteur txt2tags (Python 3) — ne pas modifier
  txt2tags/SKILLS.md  Référence complète de la syntaxe txt2tags

templates/          Gabarits HTML et LaTeX pour chaque cible
  latex.tex, xetex.tex, lettre.tex, gamebook.tex, beamer.tex…
  xhtml.html, epub.html, slidy.xhtml, website.html…
  choicescript/, renpy/, inform7/, inkle/, ramus.html…

includes/           Styles CSS et LaTeX réutilisables
  sample.css/sty      Style par défaut
  sample_cyoa.css/sty Style pour gamebooks
  epub.css, slidy_t2t.css…

samples/            Exemple de document standard + makefile de référence
samples_cyoa/       Exemples de jeux CYOA (.t2t)

docs/               Documentation source (.t2t)
  documentation_fr.t2t / documentation_en.t2t
  textallion_cyoa_fr.t2t / textallion_cyoa_en.t2t

test/               Tests de non-régression
  makefile, run_tests.sh
  ok/                Sorties de référence (.html, .pdf, .tex)

media/              Logos et images d'exemple
```

## Flux de compilation

1. Le fichier source `DOCUMENT.t2t` contient le texte en syntaxe txt2tags + directives `%!includeconf` pointant vers `core/textallion.t2t` (et optionnellement `core/txt2cyoa.t2t` pour les CYOA).
2. `make html/pdf/epub` appelle `txt2tags3` avec le gabarit approprié depuis `templates/`.
3. Pour le PDF : txt2tags génère un `.tex`, puis `pdflatex` (ou `xelatex`) compile en PDF (3 passes pour TOC + index).
4. Pour l'EPUB : txt2tags génère un `.html` intermédiaire, `ebook-convert` (Calibre) produit l'EPUB.

**Commande txt2tags typique :**
```sh
python3 contrib/txt2tags/txt2tags3 -T templates/xhtml.html -t xhtml \
  --css-inside --css-sugar --toc --outfile doc.html doc.t2t
```

## Makefile

Le fichier `samples/makefile` est le makefile de référence, copié dans chaque nouveau projet. Variables clés :
- `TEXTALLIONFOLDER` : chemin vers ce dépôt (ou `/usr/share/textallion/`)
- `TXT2TAGS` : commande Python 3 pour txt2tags3
- `DOCUMENT` : nom de base du fichier source (sans `.t2t`)
- `DOCUMENT_LANGUAGE` : `en` ou `fr` (conditionne des ajustements LaTeX)

Cibles principales : `html`, `pdf`, `xetex`, `epub`, `slidy`, `beamer`, `lettre`, `all`, `clean`, `website`, `vignettes`, `cover`

Cibles CYOA : `cyoa-html`, `cyoa-pdf`, `cyoa-epub`, `cyoa-graph`, `cyoa-renpy`, `cyoa-twee`, `cyoa-ramus`, `cyoa-undum`, `cyoa-cs`, `cyoa-inform7`, `cyoa-dialog`

## Système de symboles (core/textallion.t2t)

Textallion étend txt2tags via des règles `%!preproc` / `%!postproc`. Les symboles s'écrivent entre accolades avec 4 caractères (pour éviter les conflits avec le texte ordinaire) :

| Symbole | Code |
|---------|------|
| Lettrine | `{*~~~}` |
| Saut de page | `{/...}` |
| Saut de ligne | `{//..}` |
| Centrage début/fin | `{ ~~ }` / `{/~~ }` |
| Italic zone | `{ // }` / `{/// }` |
| Bold zone | `{ ** }` / `{/** }` |
| Encadré | `{ [] }` / `{/[] }` |
| Taille + | `{ ++ }` / `{/++ }` |
| Taille - | `{ -- }` / `{/-- }` |
| Petites caps | `{%%%%}` / `{/%%%}` |
| Guillemets fr. | `{" }` / `{ "}` |
| Note de bas de page | `°°texte note°°` |
| Exposant | `{ ^^ }` / `{/^^ }` |
| Indice | `{ ,, }` / `{/,, }` |
| Colonnes | `{|2|}`, `{|3|}`, `{|0|}` |
| Équation LaTeX | `{ $$ }formule{ $$ }` |
| Index | `{^}mot{^}` |
| Couleur | `@@COLOR@@red@@texte@@/COLOR@@` |
| Épigraphe | `{  ~~}` / `{/ ~~}` |
| Code (monospace) | `{####}` / `{/###}` |

## Format CYOA

Les chapitres sont délimités par `== numéro ==` et les choix par des listes à tirets liant vers d'autres sections : `- Texte du choix numéro` ou `[Texte|#label]`. Le script `core/textallion.sh` crée la structure initiale automatiquement.

## Dépendances

- **Python 3** : pour txt2tags3
- **LaTeX** (pdflatex / xelatex) : génération PDF
- **Calibre** (`ebook-convert`, `ebook-meta`) : génération EPUB
- **ImageMagick** (`convert`) : génération de couvertures depuis SVG
- **`meld`** (optionnel) : cible `configuration-update`
- **`graphviz`** (optionnel) : cible `cyoa-graph`

## Tests

```sh
cd test/
sh run_tests.sh
```
Compare les sorties générées avec les fichiers de référence dans `test/ok/`.

## Installation

```sh
sh textallion_install.sh
```
Copie le dépôt dans `/usr/share/textallion/`. Après installation, `textallion init` lance l'interface interactive.

## Conventions

- Les fichiers `.t2t` sont en UTF-8 sans BOM (le BOM corrompt l'en-tête titre pour LaTeX).
- Chaque projet vit dans `~/textalliondocs/NOM_PROJET/` avec son propre `makefile`, `.css`, `.sty`, `.jpg` et `.svg`.
- Les projets CYOA ont le préfixe `cyoa-`, les lettres le préfixe `lettre-`.
- `TEXTALLIONFOLDER` pointe vers la racine du dépôt ; ne jamais coder ce chemin en dur dans les sources de documents.
