# Textallion — Guide pour Claude

## Vue d'ensemble

Textallion est un processeur de documents léger (« Tiny almost-Kiss Word Processor ») écrit par Éric Forgeot (2008-2026). Il prend des fichiers `.t2t` (syntaxe txt2tags) en entrée et génère du HTML, du PDF (via LaTeX/XeTeX), de l'EPUB (via Calibre) et d'autres formats. Il inclut un module CYOA (gamebooks / livres dont vous êtes le héros) avec exports vers de nombreux moteurs de fiction interactive.

## Structure du dépôt

```
core/           Moteur Textallion
  textallion.t2t      Règles preproc/postproc centrales (symboles, mise en forme étendue)
  textallion.sh       Interface en ligne de commande (menus shell, POSIX sh)
  textallion-common.mk   Cibles make partagées par tout projet (html, pdf, epub, typst...)
  textallion-cyoa.mk     Cibles make CYOA (cyoa-html, cyoa-renpy...), en plus de common.mk
  textallion-defaults.mk Valeurs par défaut des outils (lecteurs, éditeur...), surchargeables
  txt2cyoa.t2t        Règles supplémentaires pour les documents CYOA
  textallion.sty      Style LaTeX par défaut
  textallion_beamer.t2t  Config pour présentations Beamer
  epub-generator.sh   Génère l'EPUB depuis le HTML intermédiaire (via pandoc)
  typst-generator.sh  Génère le .typ Typst depuis le HTML intermédiaire (via pandoc)
  lines.py            Utilitaire Python
  adventurebook.pl    Exporteur Perl (gamebook)
  convert_*.sh        Scripts de conversion depuis d'autres formats

contrib/
  txt2tags/txt2tags3  Moteur txt2tags (Python 3), code amont vendu tel quel — ne pas modifier sauf correctif de bug ciblé et explicitement demandé (ex. 2026-09 : `neutralize_repl_backslashes()`, un repli qui évite qu'un `%!preproc`/`%!postproc` dont le remplacement contient un `\` littéral suivi d'une lettre — ex. `'\date{...}'`, `'\textsc{...}'` — fasse planter ou corrompe la conversion ; les vrais usages de `\1`, `\g<...>` ou `\n` dans un remplacement ne sont pas concernés)
  txt2tags/SKILLS.md  Référence complète de la syntaxe txt2tags

templates/          Gabarits HTML et LaTeX pour chaque cible
  latex.tex, xetex.tex, lettre.tex, gamebook.tex, beamer.tex…
  xhtml.html, epub.html, slidy.xhtml, website.html…
  choicescript/, renpy/, inform7/, inkle/, ramus.html…

includes/           Styles CSS et LaTeX réutilisables
  sample.css/sty      Style par défaut
  sample_cyoa.css/sty Style pour gamebooks
  epub.css, slidy_t2t.css…

samples/            Exemple de document standard + makefile fin de référence
samples_cyoa/       Exemples de jeux CYOA (.t2t) + makefile fin de référence (CYOA)

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
4. Pour l'EPUB : txt2tags génère un `.html` intermédiaire (gabarit `templates/epub.html`), nettoyé par quelques `sed`, puis `core/epub-generator.sh` (s'appuie sur `pandoc`) produit l'EPUB directement — plus de dépendance à Calibre. Ce script est une copie de ~/src/epub-generator/epub-generator.sh, vendue dans `core/` comme `lines.py`/`vignettes.sh`.
5. Pour Typst (`make typst` / `typst-pdf`) : même intermédiaire `.html` que l'EPUB, converti en `.typ` par `core/epub-generator.sh`'s sibling `core/typst-generator.sh` (aussi `pandoc`, qui a un writer Typst — txt2tags n'a pas de cible Typst directe). `typst-pdf` enchaîne avec `typst compile` (CLI Typst séparée, non fournie).

**Commande txt2tags typique :**
```sh
python3 contrib/txt2tags/txt2tags3 -T templates/xhtml.html -t xhtml \
  --css-inside --css-sugar --toc --outfile doc.html doc.t2t
```

## Makefile

Depuis 2026-09, un makefile de projet (`samples/makefile`, `samples_cyoa/makefile`, ou celui écrit par `textallion init`) est **fin** : il ne contient que les données du projet (titre, auteur, tags, langue, `TEXTALLIONFOLDER`) et se termine par `include $(TEXTALLIONFOLDER)/core/textallion-common.mk` (+ `core/textallion-cyoa.mk` pour un CYOA). Toutes les cibles (`html`, `pdf`, `cyoa-html`...) vivent dans ces fichiers `core/textallion-*.mk`, partagés par tous les projets : on les modifie une fois, dans le dépôt, et chaque projet en profite immédiatement sans être régénéré.

- `core/textallion-common.mk` : cibles communes à tout projet (document, lettre ou CYOA) — `html`, `pdf`, `xetex`, `epub`, `typst`, `typst-pdf`, `slidy`, `beamer`, `lettre`, `all`, `clean`, `website`, `vignettes`, `cover`, `configuration-update`...
- `core/textallion-cyoa.mk` : cibles CYOA uniquement — `cyoa-html`, `cyoa-pdf`, `cyoa-epub`, `cyoa-typst`, `cyoa-graph`, `cyoa-renpy`, `cyoa-twee`, `cyoa-ramus`, `cyoa-undum`, `cyoa-cs`, `cyoa-inform7`, `cyoa-dialog`...
- `core/textallion-defaults.mk` : valeurs par défaut des outils (`PDFREADER`, `EDITTOOL`, `DIFFTOOL`...), en `?=` — surchargeables par projet (avant la ligne `include`) ou pour toute la machine dans `~/.config/textallion/config.mk`.

Variables clés définies par le makefile du projet : `TEXTALLIONFOLDER` (chemin vers ce dépôt, `?=` donc surchargeable via `make TEXTALLIONFOLDER=... cible`), `DOCUMENT` (nom de base du fichier source, sans `.t2t`), `DOCUMENT_TITLE`/`DOCUMENT_AUTHOR`/`DOCUMENT_TAGS`, `DOCUMENT_LANGUAGE`.

Un ancien makefile « épais » (une copie complète des cibles par projet, format d'avant 2026-09) se met à niveau avec `textallion migrate NOM` ou l'entrée de menu « Synchronize » — l'ancien fichier est gardé en `makefile.bak`. Une règle personnalisée ajoutée à l'ancien makefile n'est pas reprise automatiquement : il faut la déplacer à la main dans un `local.mk` à côté du nouveau makefile (`-include local.mk` en fin de fichier).

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
- **pandoc**, via `core/epub-generator.sh` : génération EPUB
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
