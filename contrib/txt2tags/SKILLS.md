# txt2tags3 — Skills & Reference

txt2tags3 est un convertisseur de texte balisé vers de nombreux formats cibles. Il est écrit en Python 3 et maintenu dans le dépôt Textallion.

---

## Syntaxe de balisage

### Structure du document

Un fichier `.t2t` se compose de trois zones séparées par des lignes vides :

```
Titre du document
Auteur
Date / version

%%% Zone de configuration (facultative) %%%

Corps du document
```

### Formatage en ligne

| Effet         | Balisage          | Exemple                  |
|---------------|-------------------|--------------------------|
| Gras          | `**texte**`       | **texte**                |
| Italique      | `//texte//`       | //texte//                |
| Souligné      | `__texte__`       | __texte__                |
| Barré         | `--texte--`       | --texte--                |
| Monospace     | ` ``texte`` `     | ``texte``                |
| Brut (raw)    | `""texte""`       | sortie sans échappement  |
| Balisé        | `''texte''`       | sortie cible directe     |
| Mathématique  | `$$formule$$`     | formule LaTeX            |

### Titres

```
= Titre niveau 1 =
== Titre niveau 2 ==
=== Titre niveau 3 ===
==== Titre niveau 4 ====
===== Titre niveau 5 =====

+ Titre numéroté niveau 1 +
++ Titre numéroté niveau 2 ++
```

Labels : `= Titre = [mon-label]`

### Listes

```
- élément de liste
  - sous-élément
- autre élément

+ élément numéroté
  + sous-élément numéroté

: terme
  définition (liste de définitions)
```

Fermeture explicite d'une liste : ligne contenant uniquement `-`, `+` ou `:` avec espaces.

### Tableaux

```
|| En-tête 1  | En-tête 2  | En-tête 3  |
|  cellule 1  | cellule 2  | cellule 3  |
```

- `||` : ligne d'en-têtes
- `|_` : alignement à gauche de la colonne
- `|/` : fusion de cellules

### Liens et images

```
http://exemple.com                       (lien automatique)
www.exemple.com                          (lien auto sans protocole)
user@domaine.com                         (email automatique)
[label http://exemple.com]               (lien avec libellé)
[image.png]                             (image)
[[image.png] http://exemple.com]        (image-lien)
```

Formats d'image supportés : `.png`, `.jpg`, `.jpeg`, `.gif`, `.eps`, `.bmp`, `.svg`

### Blocs

```
```
code verbatim multiligne
```

"""
texte brut multiligne (pas d'échappement)
"""

'''
balisage cible direct multiligne
'''

%%%
commentaire multiligne (non rendu)
%%%
```

Versions sur une seule ligne :

```
``` code verbatim
""" texte brut
''' balisage direct
% commentaire (ligne entière)
```

### Séparateurs

```
--------------------   (trait fin, 20+ tirets)
====================   (trait épais, 20+ signes égal)
____________________   (trait fin souligné, 20+ underscores)
```

### Citation (quote)

```
	Texte indenté par une tabulation = citation niveau 1
		Double tabulation = citation niveau 2
```

### Table des matières

```
%%toc
```

Place la TDM à cet emplacement (sinon générée en début de document avec `--toc`).

---

## Macros

À utiliser dans le corps du document avec `%%nom` ou `%%nom(format)` :

| Macro             | Valeur                                      |
|-------------------|---------------------------------------------|
| `%%date`          | Date de conversion (`%Y-%m-%d` par défaut)  |
| `%%mtime`         | Date de modification du fichier source      |
| `%%infile`        | Nom du fichier source                       |
| `%%outfile`       | Nom du fichier de sortie                    |
| `%%target`        | Format cible actuel                         |
| `%%encoding`      | Encodage du fichier source                  |
| `%%cmdline`       | Ligne de commande utilisée                  |
| `%%header1/2/3`   | Lignes d'en-tête du document                |
| `%%appname`       | Nom de l'application                        |
| `%%appversion`    | Version de l'application                    |
| `%%appurl`        | URL de l'application                        |
| `%%cc`            | Licence Creative Commons                    |
| `%%toc`           | Position de la table des matières           |

Formatage de date : `%%date(%d/%m/%Y)` utilise les codes `strftime`.

---

## Configuration dans le fichier source

Directives `%!` placées dans la zone de configuration :

```
%! target  : html
%! encoding: UTF-8
%! style   : mon-style.css
%! options : --toc --no-headers
%! preproc : /motif/ remplacement
%! postproc: /motif/ remplacement
%! include : autre-fichier.t2t
%! includeconf : fichier.rc
```

---

## Options de la ligne de commande

```
txt2tags [OPTIONS] [fichier.t2t ...]
```

| Option                  | Description                                           |
|-------------------------|-------------------------------------------------------|
| `-t, --target=TYPE`     | Format de sortie cible                                |
| `-i, --infile=FILE`     | Fichier d'entrée (`-` pour STDIN)                     |
| `-o, --outfile=FILE`    | Fichier de sortie (`-` pour STDOUT)                   |
| `--encoding=ENC`        | Encodage source (UTF-8, iso-8859-1…)                  |
| `--toc`                 | Ajouter une table des matières automatique            |
| `--toc-title=S`         | Titre personnalisé pour la TDM                        |
| `--toc-level=N`         | Profondeur maximale de la TDM                         |
| `--toc-only`            | Afficher seulement la TDM et quitter                  |
| `-n, --enum-title`      | Numéroter les titres (1, 1.1, 1.1.1…)                 |
| `--style=FILE`          | Feuille de style (CSS pour HTML)                      |
| `--css-sugar`           | Balises HTML/XHTML adaptées aux CSS                   |
| `--css-inside`          | Intégrer le CSS dans les en-têtes HTML                |
| `--embed-images`        | Intégrer les images en base64 (HTML, RTF, aat, aap)   |
| `-H, --no-headers`      | Supprimer en-tête et pied de page                     |
| `-T, --template=FILE`   | Utiliser un fichier gabarit                           |
| `--mask-email`          | Masquer les emails contre les robots spam             |
| `--width=N`             | Largeur de sortie en colonnes (aat, aap, aatw…)       |
| `--height=N`            | Hauteur de sortie en lignes (aap)                     |
| `--chars=S`             | Caractères de dessin ASCII Art                        |
| `-C, --config-file=F`   | Lire la configuration depuis un fichier               |
| `--fix-path`            | Corriger les chemins des ressources                   |
| `--gui`                 | Interface graphique Tk                                |
| `-q, --quiet`           | Mode silencieux                                       |
| `-v, --verbose`         | Messages d'information détaillés                      |
| `--dump-config`         | Afficher la configuration complète et quitter         |
| `--dump-source`         | Afficher la source avec les inclusions développées    |
| `--targets`             | Lister tous les formats disponibles et quitter        |

Le préfixe `--no-` désactive une option : `--no-toc`, `--no-style`, `--no-enum-title`…

---

## Formats de sortie (targets)

### HTML / Web
| Cible    | Description                          |
|----------|--------------------------------------|
| `html`   | Page HTML                            |
| `html5`  | Page HTML5                           |
| `xhtml`  | Page XHTML                           |
| `xhtmls` | Page XHTML Strict                    |
| `htmls`  | HTML Spreadsheet                     |
| `wp`     | Article WordPress                    |

### Wiki / Markup léger
| Cible      | Description                        |
|------------|------------------------------------|
| `txt2t`    | Document txt2tags                  |
| `md`       | Markdown                           |
| `rst`      | reStructuredText                   |
| `adoc`     | AsciiDoc                           |
| `creole`   | Creole 1.0                         |
| `wiki`     | Wikipedia / MediaWiki              |
| `gwiki`    | Google Wiki                        |
| `doku`     | DokuWiki                           |
| `pmw`      | PmWiki                             |
| `moin`     | MoinMoin                           |
| `bbcode`   | BBCode                             |
| `red`      | Redmine Wiki                       |
| `spip`     | Article SPIP                       |
| `tml`      | Foswiki / TWiki                    |
| `vimwiki`  | Vimwiki                            |
| `gmi`      | Gemtext (Gemini)                   |

### Publication / Bureau
| Cible    | Description                          |
|----------|--------------------------------------|
| `tex`    | LaTeX                                |
| `texs`   | LaTeX Spreadsheet                    |
| `sgml`   | SGML                                 |
| `dbk`    | DocBook                              |
| `lout`   | Lout                                 |
| `mgp`    | MagicPoint (présentation)            |
| `pm6`    | PageMaker                            |
| `rtf`    | RTF                                  |
| `mom`    | MOM (groff macro)                    |
| `utmac`  | Utmac / utroff                       |
| `ods`    | OpenDocument Spreadsheet             |
| `csv`    | CSV                                  |
| `csvs`   | CSV Spreadsheet                      |
| `db`     | Base SQLite                          |

### Texte / ASCII Art
| Cible    | Description                              |
|----------|------------------------------------------|
| `txt`    | Texte brut                               |
| `man`    | Page de manuel UNIX                      |
| `aat`    | ASCII Art Text                           |
| `aap`    | ASCII Art Présentation (slides)          |
| `aas`    | ASCII Art Spreadsheet                    |
| `aatw`   | ASCII Art Text Web                       |
| `aapw`   | ASCII Art Présentation Web               |
| `aasw`   | ASCII Art Spreadsheet Web                |
| `aapp`   | ASCII Art Présentation imprimable        |

---

## Utilisation comme module Python

```python
import sys
sys.argv = ['txt2tags', '-t', 'html', '--no-headers', '-o', '-', 'fichier.t2t']

import txt2tags3 as t2t
t2t.exec_command_line()
```

Ou via l'API interne :

```python
source = t2t.SourceDocument(filename='fichier.t2t')
config = t2t.process_source_file('fichier.t2t')
```

---

## Fichier de configuration externe

Créer un fichier `~/.txt2tagsrc` (ou passer `-C fichier.rc`) :

```
%! target  : html
%! encoding: UTF-8
%! options : --toc
```

---

## Compatibilité

- Python 3.6 à 3.12+
- Fonctionne en ligne de commande, en module Python, ou via l'interface graphique Tk (`--gui`)
- Fork de la version officielle : conserve les gabarits (`--template`), l'interface graphique, les macros et tous les formats
