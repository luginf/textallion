# Textallion — Référence des fonctionnalités

Textallion convertit des fichiers texte (syntaxe `.t2t`) en HTML, PDF et EPUB. Il repose sur txt2tags3 (voir `contrib/txt2tags/SKILLS.md` pour la syntaxe de base) et ajoute une couche de symboles typographiques, de gabarits et un module gamebook (CYOA).

---

## Types de documents

| Type | Préfixe dossier | Cibles make principales |
|------|-----------------|------------------------|
| Document général (livre, article) | *(aucun)* | `html`, `pdf`, `epub` |
| Lettre (format A4 français) | `lettre-` | `lettre` (PDF uniquement) |
| Gamebook CYOA | `cyoa-` | `cyoa-html`, `cyoa-pdf`, `cyoa-epub` |
| Présentation | *(aucun)* | `slidy`, `beamer` |

---

## Cibles make

### Document standard

| Commande | Résultat |
|----------|----------|
| `make html` | HTML avec CSS intégré |
| `make pdf` | PDF via pdflatex (3 passes, TOC + index) |
| `make xetex` | PDF via XeLaTeX (meilleure gestion Unicode/polices) |
| `make epub` | EPUB via Calibre |
| `make all` | HTML + PDF + EPUB + page web index |
| `make slidy` | Présentation HTML (Slidy) |
| `make beamer` | Présentation PDF (Beamer LaTeX) |
| `make lettre` | PDF lettre A4 |
| `make lettre-1page` | Réduit le PDF lettre à 1 page (pdfjam) |
| `make pdfweb` | PDF rendu depuis HTML via wkhtmltopdf |
| `make website` | Page index HTML avec liens vers les sorties |
| `make cover` | Génère JPG/PNG de couverture depuis le SVG |
| `make vignettes` | Page HTML de miniatures des images |
| `make booklet` | PDF en format livret (2 pages/feuille) |
| `make pdfsmall` | PDF 2 pages par feuille (pdfnup) |
| `make clean` | Supprime les fichiers temporaires LaTeX |
| `make configuration-update` | Diff entre makefile/CSS/STY projet et références |
| `make rename` | Renomme le document (éditer `DOCUMENTNEWNAME`) |

### CYOA (gamebooks)

| Commande | Résultat |
|----------|----------|
| `make cyoa-html` | Gamebook HTML interactif |
| `make cyoa-pdf` | Gamebook PDF (numéros de sections) |
| `make cyoa-epub` | Gamebook EPUB |
| `make cyoa-graph` | Graphe des nœuds (SVG/PNG, nécessite Graphviz) |
| `make cyoa-renpy` | Export Ren'Py (visual novel) |
| `make cyoa-twee` | Export Twee/Twine |
| `make cyoa-undum` | Export Undum (HTML JS) |
| `make cyoa-ramus` | Export Ramus (HTML JS) |
| `make cyoa-cs` | Export ChoiceScript |
| `make cyoa-inform7` | Export Inform 7 |
| `make cyoa-dialog` | Export Dialog (Z-machine) |
| `make cyoa-gbl` | Export GBL |

---

## Symboles Textallion

Ces codes s'ajoutent à la syntaxe txt2tags standard. Ils s'écrivent entre accolades.

### Mise en forme de zone (multiligne)

| Effet | Ouverture | Fermeture |
|-------|-----------|-----------|
| Centrage | `{ ~~ }` | `{/~~ }` |
| Taille augmentée | `{ ++ }` | `{/++ }` |
| Taille réduite | `{ -- }` | `{/-- }` |
| Zone italique | `{ // }` | `{/// }` |
| Zone grasse | `{ ** }` | `{/** }` |
| Encadré | `{ [] }` | `{/[] }` |
| Petites majuscules | `{%%%%}` | `{/%%%}` |
| Épigraphe | `{  ~~}` | `{/ ~~}` ou `{/ ~~}Auteur` |
| Code monospace | `{####}` | `{/###}` |

### Mise en forme en ligne

| Effet | Code |
|-------|------|
| Lettrine (grande initiale) | `{*~~~}` suivi du texte |
| Guillemets français « » | `{" }` … `{ "}` |
| Exposant | `{ ^^ }texte{/^^ }` |
| Indice | `{ ,, }texte{/,, }` |
| Équation LaTeX | `{ $$ }formule{ $$ }` |
| Couleur | `@@COLOR@@red@@texte@@/COLOR@@` |

### Ornements typographiques

| Symbole | Code | Unicode |
|---------|------|---------|
| Trois étoiles | `{** *}` | ✵✵✵ |
| Feuille aldine ❦ | `{-@- }` | ❦ |
| Feuille aldine ❧ | `{-/@-}` | ❧ |
| Soleil ☼ | `{(  )}` | ☼ |
| Croissant ☽ | `{ )) }` | ☽ |
| Dernier quartier ☾ | `{ (( }` | ☾ |
| Pleine lune ○ | `{ () }` | ○ |
| Tiret de dialogue | `---` | — |
| Grand espace | `*-*-` | `\bigskip` |

### Mise en page

| Effet | Code |
|-------|------|
| Saut de page | `{/...}` |
| Saut de ligne | `{//..}` ou `\\` |
| 2 colonnes | `{|2|}` … `{|0|}` |
| 3 colonnes | `{|3|}` … `{|0|}` |
| Index (LaTeX) | `{^}mot{^}` |
| Impression de l'index | `%%index` |

### Notes de bas de page

```
Texte principal°°contenu de la note°°
Texte principal°°id_note°°contenu de la note°°  (pour CYOA)
```

---

## Balises d'image étendues

```
[image.png]                   insertion simple
[image.png][50]               image avec largeur 50 mm (LaTeX)
[image.png]{~~~~}             image flottante à gauche (wrap)
{~~~~}[image.png]             image flottante à droite
[image.png][50]{~~~~}         image flottante gauche 50 mm
[[image.png] http://lien.com] image cliquable
```

Médias HTML5 (XHTML uniquement) :
```
[son.ogg]                     lecteur audio
[video.webm]                  lecteur vidéo
```

---

## Syntaxe CYOA

Structure d'un fichier gamebook :

```
Titre du jeu
Auteur
Date

%!includeconf: /usr/share/textallion/core/textallion.t2t

== 0 ==

- Commencer l'aventure 1


== 1 ==

Vous entrez dans la forêt sombre.

- Prendre le chemin de gauche [#gauche]
- Continuer tout droit 2


== 2 ==

...
```

- `== N ==` : numéro de section
- `- Texte N` : lien vers la section N
- `[Texte|#label]` : lien vers un label nommé
- `[Texte #label]` : syntaxe alternative

---

## Structure d'un fichier `.t2t`

```
Titre du document
Nom de l'auteur
Date (AAAA-MM-JJ)


%!postproc(tex): 'xx DOCUMENT TITLE xx' 'Mon titre'
%!postproc(tex): 'xx DOCUMENT AUTHOR xx' 'Mon nom'
%!style(tex): mondocument.sty
%!style(xhtml): mondocument.css
%!includeconf: /usr/share/textallion/core/textallion.t2t

= Chapitre 1 =

Contenu du document...
```

---

## Conversions vers d'autres formats

Scripts disponibles dans `core/` :
- `convert_twee_to_textallion.sh` : importer depuis Twee/Twine
- `convert_rpy_to_t2t.sh` : importer depuis Ren'Py
- `convert_choicescript_to_textallion.sh` : importer depuis ChoiceScript
- `fromtextile.sh` : importer depuis Textile

---

## Création d'un nouveau projet

### Via l'interface interactive
```sh
textallion init
```

### Via le makefile directement
```sh
cp -r /usr/share/textallion/samples/ ~/textalliondocs/monprojet/
cd ~/textalliondocs/monprojet/
# éditer makefile : DOCUMENT = monprojet
# créer monprojet.t2t
make html
```

---

## Personnalisation CSS et LaTeX

Chaque projet possède son propre `.css` et `.sty` dérivés de `includes/sample.css` et `includes/sample.sty`. La cible `make configuration-update` ouvre un diff pour synchroniser avec les versions d'origine.

Variables LaTeX configurables dans le `.sty` du projet : marges, police, taille de police, classe de document (`book` vs `article`), options de TOC, style de lettrine, etc.

---

## Dépendances requises

| Outil | Usage |
|-------|-------|
| Python 3 | Moteur txt2tags3 |
| pdflatex | PDF standard |
| xelatex | PDF avec polices Unicode/OpenType |
| Calibre (`ebook-convert`) | Génération EPUB |
| ImageMagick (`convert`) | Couvertures SVG → JPG/PNG |
| Graphviz (`dot`) | Graphes CYOA |
| wkhtmltopdf | PDF depuis HTML (sans LaTeX) |
| pdfjam / psbook | PDF livret / réduction |

---

## Voir aussi

- `contrib/txt2tags/SKILLS.md` : référence complète de la syntaxe txt2tags3
- `docs/documentation_fr.t2t` : documentation complète en français
- `docs/quickref.t2t` : aide-mémoire rapide
- `samples/examples.t2t` : exemples de toutes les syntaxes
