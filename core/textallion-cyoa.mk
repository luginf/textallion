# core/textallion-cyoa.mk: the cyoa-* targets, for CYOA (gamebook) projects.
# Included by the project's makefile, after core/textallion-common.mk (which
# it depends on: TXT2TAGS, DOCUMENT, DOCUMENT_TITLE...).
#
# Do not edit a copy of this file per project: edit this one, in the
# Textallion repository, and every CYOA project picks up the change.

cyoa-play:
	$(BROWSER) $(DOCUMENT).html

cyoa-html:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/cyoa.html --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t xhtml --css-inside --outfile $(DOCUMENT).html $(DOCUMENT).t2t
	
	
cyoa-ramus:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/ramus.html  --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t  -t xhtml --no-css-inside --outfile $(DOCUMENT)_ramus.html $(DOCUMENT).t2t
	sed -i -e "s/href=\"#/rel=\"/g" $(DOCUMENT)_ramus.html
	sed -i -e "s/style=\"display:none\"//g" $(DOCUMENT)_ramus.html
	#sed -i -e "s/onclick\(.*\)rel/rel/" $(DOCUMENT)_ramus.html
	sed -i -e "s/<p><br\/><br\/><br\/><\/p><\/div>/xxCLEARLINKSxx\n<\/div>/g" $(DOCUMENT)_ramus.html
	# remove the 1st occurence only 
	sed -i -e "0,/\xxCLEARLINKSxx/s/\xxCLEARLINKSxx//" $(DOCUMENT)_ramus.html
	# Create the do clear links
	# If you don't like it this way, uncomment the next line first, to remove everything
	#sed -i -e "s/xxCLEARLINKSxx//g" $(DOCUMENT)_ramus.html
	sed -i -e "s/\xxCLEARLINKSxx/\[\?do clear_links\(\)\; \?\]/g" $(DOCUMENT)_ramus.html
	sed -i -e "s/xxRAMUS_INITxx/<div id=\"story\" style=\"Display: none;\">\n<div id=\"start\">\n<li>Start: <b><a rel=\"page1\">1<\/a><\/b>/g" $(DOCUMENT)_ramus.html
	

cyoa-ramus2:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/ramus2.html  --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t  -t xhtml --no-css-inside --outfile $(DOCUMENT)_ramus2.html $(DOCUMENT).t2t
	sed -i -e "s/href=\"#/rel=\"/g" $(DOCUMENT)_ramus2.html
	sed -i -e "s/style=\"display:none\"//g" $(DOCUMENT)_ramus2.html
	#sed -i -e "s/onclick\(.*\)rel/rel/" $(DOCUMENT)_ramus2.html
	sed -i -e "s/<p><br\/><br\/><br\/><\/p><\/div>/xxCLEARLINKSxx\n<\/div>/g" $(DOCUMENT)_ramus2.html
	# remove the 1st occurence only 
	sed -i -e "0,/\xxCLEARLINKSxx/s/\xxCLEARLINKSxx//" $(DOCUMENT)_ramus2.html
	# Create the do clear links
	# If you don't like it this way, uncomment the next line first, to remove everything
	#sed -i -e "s/rel=\"/rel=\"clear\" href=\"#/g" $(DOCUMENT)_ramus2.html
	sed -i -e "s/rel=\"/href=\"#/g" $(DOCUMENT)_ramus2.html
	#sed -i -e "s/\xxCLEARLINKSxx/<\?do clear_all_links\(\)\; \?\>/g" $(DOCUMENT)_ramus2.html
	sed -i -e "s/\xxCLEARLINKSxx//g" $(DOCUMENT)_ramus2.html
	sed -i -e "s/xxRAMUS_INITxx/<div style=\"Display: none;\">\n<div id=\"start\">\n<li>Start: <b><a href=\"#page1\">1<\/a><\/b>/g" $(DOCUMENT)_ramus2.html
	sed -i -e "s/THE END/THE END<br\/><a rel=\"clear\" href=\"#start\"><i>Start over?<\/i><\/a>/g" $(DOCUMENT)_ramus2.html
	cp $(DOCUMENT)_ramus2.html $(DOCUMENT)_ramus2b.html
	sed -i -e "s/href=/rel=\"clear\" href=/g" $(DOCUMENT)_ramus2b.html
	


cyoa-check:
	-cat $(DOCUMENT).t2t | grep -i "==" > check.txt 
	-cat $(DOCUMENT).t2t | grep -i "[^.\/\?\!=]$$" >> check.txt 

cyoa-txt:
	$(TXT2TAGS) --no-headers -t txt $(DOCUMENT).t2t

cyoa-pdf:
	#$(TXT2TAGS) -t tex --outfile $(DOCUMENT).tex $(DOCUMENT).t2t
	#-pdflatex $(DOCUMENT).tex
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/latex.tex --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t tex --no-toc --outfile $(DOCUMENT).tex $(DOCUMENT).t2t
	-pdflatex -interaction batchmode $(DOCUMENT).tex
	
cyoa-xetex:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/xetex.tex --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t tex --no-toc --outfile $(DOCUMENT).tex $(DOCUMENT).t2t
	-xelatex -interaction batchmode $(DOCUMENT).tex
	#-xelatex -interaction batchmode $(DOCUMENT).tex


cyoa-dialog:
	# for use with dialog
	# https://linusakesson.net/dialog/docs/timeprogress.html#choicemode
	# @DOLLAR@T expands as $T
	echo "(intro)	(activate node #start)\n(library links enabled)\n(label @DOLLAR@Target)\n        (current node @DOLLAR@Origin)\n        (label @DOLLAR@Origin to @DOLLAR@Target)" |\
	perl -pe "s/\@DOL-LAR\@/'$'/g" > $(DOCUMENT)_export.dg 
	# remove 3 first lines of the t2t doc (from line 1 to end line 3) \
	cat $(DOCUMENT).t2t  | sed '1,4d' | \
	# remove postproc for tex (TODO CHECK)|\
	#perl -pe "s/\%\!postproc\(tex\): //g" |\
	# convert ( and ): \
	perl -pe 's/\(/\\(/g' |\
	perl -pe 's/\)/\\)/g' |\
	# metadata (before removing them all|\
	perl -pe "s/\%\!postproc: \'xx DOCUMENT TITLE xx\'/\(story title\) \1/g" |\
	perl -pe "s/\%\!postproc: \'xx DOCUMENT AUTHOR xx\'/\(story author\) \1/g" |\
	perl -pe "s/\%\!postproc: \'xx DOCUMENT IFID xx\'/\(story ifid\) \1/g" |\
	perl -pe 's/^\%(.*)\n//' |\
		# for lone wolf mode: \
	 perl -pe 's/(.*) \[(.*) (\d+)\|\#sect(\d+)\]/(label * to #node\4)\1 \2 \3 \n(* offers #node\4)\n/g' |\
	 perl -pe 's/\[(.*) (\d+)\|\#sect(\d+)\]/(label * to #node\3)\1 \2 \n(* offers #node\3)\n/g' |\
	  perl -pe 's/\[Illustration ([^ ].*?)\]//g' |\
	 perl -pe 's/\[Random Number Table \#random\]/Random Number Table/g' |\
	 perl -pe 's/(.*)\: COMBAT SKILL (.*?)   ENDURANCE (.*?)/     (par)\1:  COMBAT SKILL \2   ENDURANCE \3/g' |\
	 #\
	 # abbreviations |\
	 #perl -pe 's/tt (\d+)/ \1/g' |\
	 #lone wolf style \
	 #perl -pe 's/\[turn to (\d+) \#sect(\d+)\]/\2/g' |\
	 #perl -pe 's/Turn to (\d+)/\1/g' |\
	 #perl -pe 's/turn to (\d+)/\1/g' |\
	 perl -pe 's/rdv au (\d+)/ : \1/g' |\
	 perl -pe 's/, rendez-vous au (\d+)/ : \1/g' |\
	 perl -pe 's/rendez-vous au (\d+)/ : \1/g' |\
	 perl -pe 's/ au (\d+)/ ailleurs : \1/g' |\
	 #perl -pe 's/to the (\d+)/to somewhere else : \1/g' |\
	 #perl -pe 's/to (\d+)/to somewhere else : \1/g' |\
	 # replace any ="introduction" by 0 (DANGER) |\
	 #   perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	 #   perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\
	 # code |\
	 perl -pe "s/\`\`(.*?)\`\`/\1/g" |\
	 perl -pe 's/¯/ /g' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's/rdv/rendez-vous/' |\
	 # images / [[bla.jpg] 1] est pour image sur premiere page |\
	 perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[\[(.*).mp3] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]/%% (define resource ## \1) /' |\
	 perl -pe 's/\[(.*).png\]/%% /' |\
	 perl -pe 's/\[(.*).mp3\]/%% /' |\
	 # why did we remove media? |\
	 #perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 # choices and links (\r is for windows newline) \
	 #perl -pe 's/- (.*?) (\d+?)( *)\n/(label #node\2)\n      (line)\1 \n(* offers #node\2)\n/g' |\
	 perl -pe 's/- (.*?) (\d+?)( *)\n/(label * to #node\2) \1 \n(* offers #node\2)\n/g' |\
	 perl -pe 's/- (.*?) (\d+?)( *)\r/(label * to #node\2) \1 \n(* offers #node\2)\n/g' |\
     perl -pe 's/(.*?) \[\#(.*?)\]/(label * to #\2) \1 \n(* offers #\2)\n/g' |\
     # remove text label (can't be used in dialog this way?) \
	 ##perl -pe 's/\[(.*?) \#(.*?)\]/(label * to #\2) \1 (* offers #\2)/g' |\
	 perl -pe 's/\[(.*?) \#(.*?)\]/\1/g' |\
	 # remove extra external links \
	 perl -pe 's/\[//g' |\
	 perl -pe 's/\]//g' |\
	 # deprecated: perl -pe 's/\[(\d+) \#(.*?)\]/[[\2|\1]]/g' |\
	 #perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[([^\#].*?) \#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[(\d+) \#(\d+)\]/[[\1]]/g' |\
	 #perl -pe 's/ \#(\d+?) / [[\1]] /g' |\
	 #perl -pe 's/ \#(.*?) / [[\1]] /g' |\
	 #perl -pe 's/ \#([^ ].*) / [[\1]]/g' |\
	 #perl -pe 's/\[\#(\d+?)\]/[[\1]]/g' |\
	 # notes and hr \
	 perl -pe 's/--------------------//g' |\
	 perl -pe 's/°°(.*?)°°(.*?)°°/ \/\/\2\/\/ /' |\
	 # chapters \
	 # lone wolf : \
	 perl -pe 's/== (\d+) ==/#node\1\n(disp *)(space 8)(bold)- \1 -(roman)/' |\
	 # normal : \
	 perl -pe 's/== (\d+) ==/#node\1\n(disp *)/' |\
	 perl -pe 's/==(\d+)==\[(.*)\]/#node\1\n(disp *)/' |\
	 #perl -pe 's/==(\d+)==/#node\1/\n(disp *)/' |\
	 perl -pe 's/== (.*?) ==\[(.*?)\]/#node\2\n(disp *)/' |\
	 perl -pe 's/== (.*?) ==/#node\1\n(disp *)/' |\
	 # main text |\
	perl -pe 's/^(.*)\.[ ]*\n/     (par)\1.\n/' |\
	perl -pe 's/^(.*)[ ]*\![ ]*\n/      (par)\1 !\n/' |\
	perl -pe 's/^(.*)[ ]*\?[ ]*\n/      (par)\1 ?\n/' |\
	perl -pe 's/^(.*)[ ]*\:[ ]*\n/      (par)\1 \n/' |\
	perl -pe 's/^(.*)[ ]*\"[ ]*\n/      (par)\1 "\n/' |\
	perl -pe 's/^(.*)[ ]*\»[ ]*\n/      (par)\1 »\n/' |\
	perl -pe 's/^(.*)[ ]*\’[ ]*\n/      (par)\1’\n/' |\
	perl -pe 's/^(.*)[ ]*\)[ ]*\n/      (par)\1)\n/' |\
	perl -pe 's/^(.*)[ ]*\*\*[ ]*\n/      (par)\1**\n/' |\
	perl -pe 's/^(.*)[ ]*\/\/[ ]*\n/      (par)\1\/\/\n/' |\
	perl -pe 's/^\"(.*)\n/      (par)"\1 \n/' |\
	perl -pe 's/^\«(.*)\n/      (par)«\1 \n/' |\
	#  t2t syntax TODO fix url \
	perl -pe 's/\/\/(.*)\/\//(italic)\1(roman)/' |\
	perl -pe 's/\*\*(.*)\*\*/(bold)\1(roman)/' |\
	perl -pe 's@:\(italic\)www@://www@' |\
	perl -pe 's@:\(roman\)www@://www@' |\
	perl -pe 's@https:\(italic\)@https://@' |\
	perl -pe 's@https:\(roman\)@https://@' |\
	perl -pe 's@http:\(italic\)@http://@' |\
	perl -pe 's@http:\(roman\)@http://@' |\
	perl -pe 's@- Voir le plan des chapitres@ @' |\
	perl -pe 's@- Adresse permanente : https:\/\/farvardin.itch.io\/la-reclusion-de-callisto@\t (par) Adresse permanente : @' |\
	perl -pe 's@- Info@ @' |\
# remove extra code \
	perl -pe 's@\(par\)\(italic\)info\(roman\)@ @' |\
	# special \
		perl -pe 's/TESTLUCK/      (par) Am I lucky today? \\(throwing a dice, 5 or 6 means luck\\) /'|\
	 perl -pe 's/THE END/     (par) THE END/'|\
	 perl -pe 's/FIN/     (par) (game over { FIN })/'|\
	# |\
	# remove extra label |\
	perl -pe 's/      \(par\)\(label/(label/' |\
	# remove blank lines \
	perl -pe s'/^\n|^[\ ]*\n//g' |\
	# add extra space before nodes \
	perl -pe 's/^#node/\n#node/' |\
	perl -pe 's/      \(par\)\(disp \*\)/(disp *) /s' |\
	#perl -pe 's/^     \(par\)\(offers/(offers/s' |\
	perl -pe 's/      \(par\)\(\* offers/(* offers/g' |\
	#øperl -pe 's/^\(disp \*\)\n     \(par\)/(disp *) /g' |\
	perl -pe 's/     \(par\)\./ /g' |\
	 # make twee lists \
	 #perl -pe 's/^- /* /' |\
	 #perl -pe 's/^+ /# /' |\
	 # remove empty white spaces and lines\
	 #sed -r '/^\s*$/d' |\
	 # start at node1 instead of node0 \
	perl -pe 's/#node0/#start/' >> $(DOCUMENT)_export.dg
	sed -i -e "s/@DOLLAR@/$$/g" $(DOCUMENT)_export.dg
	make cyoa-dialog-z8
	make cyoa-dialog-html
	make cyoa-dialog-c64


cyoa-dialog-z8:
	$(DIALOGC) -t z8 $(DOCUMENT)_export.dg $(DIALOGLIB).dg

cyoa-dialog-aa:
	$(DIALOGC) -t aa $(DOCUMENT)_export.dg $(DIALOGLIB).dg

cyoa-dialog-html:
	make cyoa-dialog-aa
	-rm -fr $(DOCUMENT)_export_html
	$(AAMBUNDLE) -o $(DOCUMENT)_export_html $(DOCUMENT)_export.aastory

cyoa-dialog-c64:
	make cyoa-dialog-aa
	-rm -fr $(DOCUMENT)_export_c64
	$(AAMBUNDLE) -t c64 -o $(DOCUMENT)_export_c64 $(DOCUMENT)_export.aastory


	 
cyoa-gamebook: 
# doesnt work yet!
# http://www.ctan.org/tex-archive/macros/latex/contrib/gamebook
	#$(TXT2TAGS) -t tex --outfile $(DOCUMENT).tex $(DOCUMENT).t2t
	#-pdflatex $(DOCUMENT).tex
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/gamebook.tex --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t tex --no-toc --outfile $(DOCUMENT).tex $(DOCUMENT).t2t
	#sed -i -e "s/\\textbf{\\begin{center}\\subsection\*{\\Huge{([^ ].*?)}}\\end{center}\\vskip-2em}/\gbsection{\1}/g" $(DOCUMENT).tex
	sed -i -e "s/\\textbf{\\begin{itemize}/\begin{gbturnoptions}/g" $(DOCUMENT).tex
	sed -i -e "s/\\item/\gbitem/g" $(DOCUMENT).tex
	-pdflatex -interaction batchmode $(DOCUMENT).tex
	
cyoa-epub:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/epub.html --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t xhtml --no-style --no-toc --outfile $(DOCUMENT).html $(DOCUMENT).t2t
	cat $(DOCUMENT).html | sed -e "s/<audio\(.*\)audio>//g" > $(DOCUMENT)2.html
	mv $(DOCUMENT)2.html $(DOCUMENT).html
	# -make tidy
	cat $(DOCUMENT).html | sed -e "s/&#10086;/*/g" | sed -e "s/&#10087;/*/g" | sed -e "s/&#10037;/*/g" | sed -e "s/&#9788;/*/g" | sed -e "s/&#9789;/*/g" | sed -e "s/&#9790;/*/g" | sed -e "s/&#9675;/*/g" |\
	sed -e "s/ : <b><a onclick/, rendez-vous au <b><a onclick/g" |\
	sed -e "s/el[1-9].style.visibility = 'hidden';//g" |\
	sed -e "s/span.c[1-9] {display:none}//g" |\
	sed -e "s/span.c[1-9] {display: none}//g" |\
	sed -e "s/div.c[1-9] {display:none}//g" |\
	sed -e "s/span.c[1-9] {visibility:hidden}//g" |\
	sed -e 's/<div id="\([a-zA-Z0-9_]*\)"\( style="display:\(none\|block\)"\)\?>/<span id="\1"><\/span>/g' |\
	sed -e 's/<p><br\/><br\/><br\/><\/p><\/div>/<p><br\/><br\/><br\/><\/p>/g' > $(DOCUMENT)2.html
	mv $(DOCUMENT)2.html $(DOCUMENT).html
	#
	sh $(TEXTALLIONFOLDER)/core/epub-generator.sh $(DOCUMENT).html $(DOCUMENT).epub --title "$(DOCUMENT_TITLE)" --authors "$(DOCUMENT_AUTHOR)" --tags "$(DOCUMENT_TAGS)" --language $(DOCUMENT_LANGUAGE) --cover $(DOCUMENT_COVER) --css $(TEXTALLIONFOLDER)/includes/epub.css --comments "textallion - https://textallion.sourceforge.io" --producer "textallion & txt2cyoa - https://textallion.sourceforge.io" --split-level 2

# uses pandoc, to typst markup (and optionally the typst CLI, to PDF)

cyoa-typst:
	$(TXT2TAGS) -T $(TEXTALLIONFOLDER)/templates/epub.html --config-file $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t -t xhtml --no-style --no-toc --outfile $(DOCUMENT)_typst.html $(DOCUMENT).t2t
	sh $(TEXTALLIONFOLDER)/core/typst-generator.sh $(DOCUMENT)_typst.html $(DOCUMENT).typ --title "$(DOCUMENT_TITLE)" --author "$(DOCUMENT_AUTHOR)"

cyoa-typst-pdf: cyoa-typst
	$(TYPST) compile $(DOCUMENT).typ $(DOCUMENT)_typst.pdf


cyoa-graph:	
	printf "\n \n \n \n"  > graph.txt
	-cat $(TEXTALLIONFOLDER)/core/txt2cyoa.t2t $(DOCUMENT).t2t |grep -E "^#|^>|^==|^-|rdv|preproc|postproc" >> graph.txt
	-$(TXT2TAGS) --no-headers -o graph2.txt -t txt graph.txt 
	-echo "digraph G { " > graph.txt
	-echo "bgcolor=beige; "                                          >> graph.txt
	-echo "node [shape=egg, fillcolor=antiquewhite2, style=filled];" >> graph.txt
	-echo "edge [arrowsize=1, fillcolor=gold];"                      >> graph.txt
	-cat graph2.txt | grep -E "\->|;" | sed -e "s/'//g" >> graph.txt
	-echo "} " >> graph.txt
	-cp graph.txt graph2.txt
	#gawk '/->/ { z=$0} /[0-9]+[^->]/ {print z$0}' fichier.txt
	# we convert to graphviz using the python script, and remove the extra "0->" before the conf
	-cat graph2.txt | python3 $(TEXTALLIONFOLDER)/includes/lines.py  | sed -e "s/0->bgcolor/bgcolor/g" | sed -e "s/0->node/node/g" | sed -e "s/0->edge/edge/g" > graph.txt
	-rm graph2.txt
	-dot graph.txt  -Tpng > $(DOCUMENT)_graph.png
	-dot graph.txt  -Tsvg > $(DOCUMENT)_graph.svg
	-mv graph.txt  $(DOCUMENT)_graph.txt
	
cyoa-gbl:
	printf "$(DOCUMENT)\nPar YourName\n%%date(%Y-%m-%d)\n" > $(DOCUMENT)_gbl.t2t 
	echo "%!includeconf: txt2cyoa.t2t" >> $(DOCUMENT)_gbl.t2t 
	cat $(DOCUMENT).gbl | sed -e "s/= \(.*\) =/\n=== \1 ===\n/g" |\
	# sed -e "s/=\(.*\)=/\n=== \1 ===\n/g" | sed -e "s/= \(.*\)=/\n=== \1 ===\n/g" | sed -e "s/=\(.*\) =/\n=== \1 ===\n/g" |\
	sed -e "s/^#\([0-9]*\)# \(.*\)/\n\n== \1 ==\n\n=== \2 ===\n\n/g" | sed -e "s/^>\(.*\)=\([0-9]*\)/- \1, rdv au \2/g" >> $(DOCUMENT)_gbl.t2t	



cyoa-inkle:
	# for use with http://www.inklestudios.com/ink/
	cat $(DOCUMENT).t2t  | perl -pe 's/^\%(.*)\n/\/\//' | sed -e "s/== 0 ==/-> start\n\n === start ===/g" |\
	# remove extra textallion syntax |\
	perl -pe 's/TESTLUCK/\/\/Am I lucky today? (throwing a dice, 5 or 6 means luck)\/\//'|\
	perl -pe 's/¯/ /g' |\
	perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	# images and sound not supported in ink?|\
	perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]//' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	# replace any ="introduction" by 0 TODO dangerous outsite heading |\
	# perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	# perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\
	# italic and underline are the same. Only bold is different |\
	perl -pe "s/\*\*(.*?)\*\*/''\1''/g" |\
	# choices and links  \
	perl -pe 's/- (.*?) (\d+?)( *)\n/* \1 -> paragraph_\2 \n/g' |\
	perl -pe 's/^- /* /g' |\
	perl -pe 's/\[\#(\d+?)\]/-> paragraph_\1 \n/g' |\
	perl -pe 's/\[\#(.*?)\]/-> \1 \n/g' |\
	perl -pe 's/\[([^\#].*?) \| \#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	perl -pe 's/\[([^\#].*?)\|\#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	perl -pe 's/\[([^\#].*?) \#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	 perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/ [\1] -> \2 \n/g' |\
	 perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/ [\1] -> \2 \n/g' |\
	 perl -pe 's/\[([^\#].*?) \#(.*?)\]/ [\1] -> \2 \n/g' |\
	perl -pe 's/: ->/->/g' |\
	perl -pe 's/THE END/->END/g' |\
	perl -pe 's/FIN/->END/g' |\
	# abbreviations |\
	perl -pe 's/tt ->/->/g' |\
	perl -pe 's/, rdv au ->/->/g' |\
	perl -pe 's/, rendez-vous au ->/->/g' |\
	perl -pe 's/ au ->/->/g' |\
	perl -pe 's/ to the ->/->/g' |\
	# chapters \
	perl -pe 's/==(\d+)==\[(.*)\]/== \1 ==/' |\
	#perl -pe 's/== (.*?) ==\[(.*?)\]/\2/' TODO?\
	perl -pe 's/== (.*?) ==\[(.*?)\]/== \1 ==/' |\
	#perl -pe 's/== (.*?) == /== \1 ==/' \
	perl -pe 's/==(\d+)==/=== paragraph_\1 ===/'  |\
	perl -pe 's/== (\d+) ==/=== paragraph_\1 ===/' > $(DOCUMENT)_inkle.ink
	# export to html
	-mkdir $(DOCUMENT)_inkle/
	cat $(TEXTALLIONFOLDER)/templates/inkle/index.html |\
	sed -e "s/TEXTALLION STORY/$(DOCUMENT_TITLE)/g" > $(DOCUMENT)_inkle/index.html
	cp $(TEXTALLIONFOLDER)/templates/inkle/ink.js $(DOCUMENT)_inkle/
	cp $(TEXTALLIONFOLDER)/templates/inkle/main.js $(DOCUMENT)_inkle/
	cp $(TEXTALLIONFOLDER)/templates/inkle/style.css $(DOCUMENT)_inkle/
	mono $(TEXTALLIONFOLDER)/templates/inkle/inklecate.exe $(DOCUMENT)_inkle.ink 
	echo "var storyContent = "> $(DOCUMENT)_inkle/textallion_story.js
	cat $(DOCUMENT)_inkle.ink.json >> $(DOCUMENT)_inkle/textallion_story.js
	echo ";" >> $(DOCUMENT)_inkle/textallion_story.js


cyoa-tavern:
	# for use with http://zzo38computer.org/fossil/tavern.ui/
	cat $(DOCUMENT).t2t  |\
 	# replace === title === used in "who are you" |\
	perl -pe "s/=== (.*) ===/\1/g" |\
	# replace any ="introduction" by 0  TODO : dangerous outsite heading|\
	#perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	#perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\perl -pe 's/^\%(.*)\n/\/\//' | sed -e "s/== 0 ==/INCLUDE bookadv.inc\n\n START-PAGE INTRO/g" |\
	# remove extra textallion syntax |\
	perl -pe 's/TESTLUCK/\/\/Am I lucky today? (throwing a dice, 5 or 6 means luck)\/\//'|\
	perl -pe 's/¯/ /g' |\
	perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	# images and sound not supported in tavern?|\
	perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]//' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	# remove italic, underline and bold |\
	perl -pe "s/\*\*(.*?)\*\*/\1/g" |\
	# choices and links  \
	perl -pe 's/- (.*?) (\d+?)( *)\n/>|  \1 | \2 \n/g' |\
	perl -pe 's/^- />|   /g' |\
	perl -pe 's/\[\#(\d+?)\]/>|  \1 \n/g' |\
	perl -pe 's/\[\#(.*?)\]/>|  \1 \n/g' |\
	perl -pe 's/\[([^\#].*?) \| \#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	perl -pe 's/\[([^\#].*?)\|\#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	perl -pe 's/\[([^\#].*?) \#(\d+)\]/ [\1] -> paragraph_\2 \n/g' |\
	 perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/ [\1] -> \2 \n/g' |\
	 perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/ [\1] -> \2 \n/g' |\
	 perl -pe 's/\[([^\#].*?) \#(.*?)\]/ [\1] -> \2 \n/g' |\
	perl -pe 's/: ->/->/g' |\
	perl -pe 's/THE END/->END/g' |\
	perl -pe 's/FIN/->END/g' |\
	# paragraphs |\
	perl -pe 's/^[ ?]?([a-z].)/ PT| \1/g' |\
	perl -pe 's/^[ ?]?([A-Z].)/ PT| \1/g' |\
	perl -pe 's/(!|\?|\.)[ ?]?\r?\n/\1|/g' |\
	# abbreviations |\
	perl -pe 's/tt (\d+)/| \1/g' |\
	perl -pe 's/turn to (\d+)/| \1/g' |\
	perl -pe 's/, rdv au  (\d+)/| \1/g' |\
	perl -pe 's/, rendez-vous au  (\d+)/| \1/g' |\
	perl -pe 's/ au  (\d+)->/| \1/g' |\
	perl -pe 's/ go to (\d+)/| \1/g' |\
	# chapters \
	perl -pe 's/==(\d+)==\[(.*)\]/PAGE>>>\n\n<<<PAGE \1 /' |\
	#perl -pe 's/== (.*?) ==\[(.*?)\]/\2/' TODO?\
	perl -pe 's/== (.*?) ==\[(.*?)\]/PAGE>>>\n\n<<<PAGE \1/' |\
	perl -pe 's/== (.*?) ==/PAGE>>>\n\n<<<PAGE \1/' |\
	perl -pe 's/==(\d+)==/PAGE>>>\n\n<<<PAGE \1/'  |\
	perl -pe 's/== (\d+) ==/PAGE>>>\n\n<<<PAGE \1/' > $(DOCUMENT)_tavern.txt
	# export to tavern
	~/bin/tavernc < $(DOCUMENT)_tavern.txt > $(DOCUMENT)_tavern.tav
	
	
cyoa-togbl:
	cat $(DOCUMENT).t2t | sed -e "s/=== \1 ===/ \(.*\) =/g" |\
	 sed -e "s/^#\([0-9]*\)# \(.*\)/\n\n== \1 ==\n\n=== \2 ===\n\n/g" | sed -e "s/^>\(.*\)=\([0-9]*\)/- \1, rdv au \2/g"  >> $(DOCUMENT)_export.gbl

cyoa-twine:	cyoa-twee

cyoa-twee:
	# for use with https://github.com/tweecode
	# corrected twee parser at https://github.com/mcdemarco/twee
	#echo "du texte et puis à la fin de la ligne, un numéro par exemple 42"|sed -e "s/\([0-9]\+\)$/\[\[\1 \1\]\]/g"
	# try to use Unix line feed if possible
	echo ":: StoryTitle" > $(DOCUMENT)_export.tw 
	cat $(DOCUMENT).t2t  | perl -pe 's/^\%(.*)\n//' |\
	# remove extra textallion syntax |\
	 perl -pe 's/TESTLUCK/\/\/Am I lucky today? (throwing a dice, 5 or 6 means luck)\/\//'|\
	 # abbreviations |\
	 perl -pe 's/tt (\d+)/turn to [[\1]]/g' |\
	 perl -pe 's/rdv au (\d+)/rendez-vous au [[\1]]/g' |\
	 perl -pe 's/rendez-vous au (\d+)/rendez-vous au [[\1]]/g' |\
	 # replace any ="introduction" by 0 |\
	 #  perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	 #  perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\
	 # italic and underline are the same. Only bold is different |\
	 perl -pe "s/\*\*(.*?)\*\*/''\1''/g" |\
	 perl -pe "s/\`\`(.*?)\`\`/{{{\1}}}/g" |\
	 perl -pe 's/¯/ /g' |\
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's/rdv/rendez-vous/' |\
	 # images / [[bla.jpg] 1] est pour image sur premiere page |\
	 perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]/\[img\[\1.jpg\]\]/' |\
	 perl -pe 's/\[(.*).png\]/\[img\[\1.png\]\]/' |\
	 # why did we remove media? |\
	 #perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 # choices and links (\r is for windows newline) \
	 perl -pe 's/- (.*?) (\d+?)( *)\n/- \1 [[\2]]\n/g' |\
	 perl -pe 's/- (.*?) (\d+?)( *)\r/- \1 [[\2]]/g' |\
	 # deprecated: perl -pe 's/\[(\d+) \#(.*?)\]/[[\2|\1]]/g' |\
	 perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/[[\1|\2]]/g' |\
	 perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/[[\1|\2]]/g' |\
	 perl -pe 's/\[([^\#].*?) \#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[(\d+) \#(\d+)\]/[[\1]]/g' |\
	 #perl -pe 's/ \#(\d+?) / [[\1]] /g' |\
	 #perl -pe 's/ \#(.*?) / [[\1]] /g' |\
	 #perl -pe 's/ \#([^ ].*) / [[\1]]/g' |\
	 perl -pe 's/\[\#(\d+?)\]/[[\1]]/g' |\
	 perl -pe 's/\[\#(.*?)\]/[[\1]]/g' |\
	 # notes \
	 perl -pe 's/°°(.*?)°°(.*?)°°/ \/\/\2\/\/ /' |\
	 # chapters \
	 perl -pe 's/== (\d+) ==/:: \1/' |\
	 perl -pe 's/==(\d+)==\[(.*)\]/:: \1/' |\
	 perl -pe 's/==(\d+)==/:: \2/' |\
	 perl -pe 's/== (.*?) ==\[(.*?)\]/:: \2/' |\
	 perl -pe 's/== (.*?) ==/:: \1/' |\
	 # make twee lists \
	 perl -pe 's/^- /* /' |\
	 perl -pe 's/^+ /# /' |\
	 # \
	 perl -pe 's/:: 0/:: Start/' >> $(DOCUMENT)_export.tw 
	 -iconv -f UTF-8 -t ISO-8859-15 $(DOCUMENT)_export.tw -o $(DOCUMENT)_export_iso8859.tw
	# export to html
	$(PYTHONVER) $(TEXTALLIONFOLDER)/templates/twee/twee -t jonah $(DOCUMENT)_export.tw > $(DOCUMENT)_twee_jonah.html
	$(PYTHONVER) $(TEXTALLIONFOLDER)/templates/twee/twee -t sugarcane $(DOCUMENT)_export.tw > $(DOCUMENT)_twee_sugarcane.html
	$(PYTHONVER) $(TEXTALLIONFOLDER)/templates/twee/twee -t mobile $(DOCUMENT)_export.tw > $(DOCUMENT)_twee_mobile.html
	$(PYTHONVER) $(TEXTALLIONFOLDER)/templates/twee/twee -t sugarcube $(DOCUMENT)_export.tw > $(DOCUMENT)_twee_sugarcube.html

cyoa-hyena:
	# for use with http://www.projectaon.org/staff/jens/
	# specifications: http://www.collectingsmiles.com/wiki/index.php?title=Hyena_AudioGame_specifications
	# implementation (player): http://www.freegameengines.org/gamebook-engine/
	printf "#start \nStart the game: Click #page0\n" > $(DOCUMENT)_export.gamebook
	cat $(DOCUMENT).t2t  | perl -pe 's/^\%(.*)\n//' | perl -pe 's/(\d+)\n/Click #page\1\n/' | perl -pe 's/== (\d+) ==/#page\1/' |  perl -pe 's/==(\d+)==\[(.*)\]/page\1/' >> $(DOCUMENT)_export.gamebook 
	printf "\n#script\n\n" >> $(DOCUMENT)_export.gamebook 

cyoa-choicescript:
	# for use with http://www.choiceofgames.com/
	# specifications: http://www.choiceofgames.com/make-your-own-games/choicescript-intro/
	-rm -fr $(DOCUMENT)_choicescript
	-mkdir -p $(DOCUMENT)_choicescript/media/
	-cp -fr $(TEXTALLIONFOLDER)/templates/choicescript/* $(DOCUMENT)_choicescript
	sed "s/ChoiceScript Game/`sed q $(DOCUMENT).t2t`/" $(TEXTALLIONFOLDER)/templates/choicescript/mygame/index.html > $(DOCUMENT)_choicescript/mygame/index.html
	sed "s/ChoiceScript Game/`sed q $(DOCUMENT).t2t`/" $(TEXTALLIONFOLDER)/templates/choicescript/mygame/index_fr.html > $(DOCUMENT)_choicescript/mygame/index_fr.html
	printf "*comment Made using ChoiceScript and Textallion.\n" > $(DOCUMENT)_choicescript/mygame/scenes/textallion.txt 
	#printf "Welcome \n*page_break\n" > choicescript/mygame/scenes/textallion.txt \
	cat $(DOCUMENT).t2t  | perl -pe 's/^\%(.*)\n//' | perl -pe 's/^\%(.*)\n//' |\
	#sed can't replace multiple newlines. So we remove them, and add them back later. \
	 perl -pe  's/\n/NEWLINE/g' |\
	 perl -pe 's/NEWLINENEWLINE- /\n\n*choice\n- /g' |\
	 perl -pe 's/NEWLINE/\n/g' |\
	 perl -pe 's/(\d+)\n/\1\n\t\t*goto \1\n/' |\
	 perl -pe 's/- /\t# \1/' |\
	 perl -pe 's/== (\d+) ==/\n*label \1\n\[b\]\1\[\/b\]/g' |\
	 perl -pe 's/==(\d+)==\[(.*)\]/*label \1\n\[b\]\1\[\/b\]/g' |\
	 perl -pe 's/==(\d+)==/*label \1\n\[b\]\1\[\/b\]/g' |\
	# end of game |\
	 perl -pe 's/FIN/FIN\n*ending/' |\
	 perl -pe 's/THE END/THE END\n*ending/' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/TESTLUCK/\[i\]Am I lucky today? (throwing a dice, 5 or 6 means luck)\[\/i\]/'|\
	 perl -pe 's/¯/ /g' |\
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's|\/\/(.*)\/\/|\[i\]\1\[/i\]|' |\
	 perl -pe 's/\[\[(.*).jpg] 1\]/*image \1.jpg/' |\
	 perl -pe 's/\[\[(.*).png] 1\]/*image \1.jpg/' |\
	 perl -pe 's/\[(.*).jpg\]/*image \1.jpg/' |\
	 perl -pe 's/\[(.*).jpg\]/*image \1.jpg/' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 perl -pe 's/rdv/rendez-vous/'   >> $(DOCUMENT)_choicescript/mygame/scenes/textallion.txt
	 -cp *.jpg $(DOCUMENT)_choicescript/mygame/
	 -cp *.png $(DOCUMENT)_choicescript/mygame/
	 -cp ../media/*.jpg $(DOCUMENT)_choicescript/mygame/
	 -cp ../media/*.png $(DOCUMENT)_choicescript/mygame/
	 

cyoa-cs: cyoa-choicescript


cyoa-undum:
	# for use with http://www.undum.com/
	# pb with undum if 1 extra line break in the code
	-rm -fr $(DOCUMENT)_undum
	-mkdir -p $(DOCUMENT)_undum/media/
	-cp -fr $(TEXTALLIONFOLDER)/templates/undum_media/* $(DOCUMENT)_undum/media/
	-cat $(TEXTALLIONFOLDER)/templates/undum.html > $(DOCUMENT)_undum/$(DOCUMENT)_undum.html
	-cat $(DOCUMENT).t2t  | perl -pe 's/^\%(.*)\n//' |\
	# remove 1 empty useless image \
	perl -pe 's/\{->--\}\[\[(.*)\] 1\]\{-<--\}//' |\
	# remove 3 first lines of the t2t doc \
	     sed '1,4d' |\
	 perl -pe 's/^\%(.*)\n//' |\
	# remove textallion specific syntax (and later also) \
         perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	perl -pe  's/\{/NEWLINE/g' |\
	 #sed can't replace multiple newlines. So we remove them, and add them back later. |\
	 perl -pe  's/\n/NEWLINE/g' |\
	 perl -pe  "s/\'/APOSTROPHE/g" |\
	 perl -pe 's/NEWLINENEWLINE- (.*?)(\d+)NEWLINE/<\/p>APOSTROPH2\n\+ APOSTROPH2<ul class=GUILLEMEToptionsGUILLEMET><li><a href=GUILLEMETnode\2GUILLEMET>\1 \2<\/a><\/li>APOSTROPH2NEWLINE/g' |\
	 perl -pe 's/NEWLINENEWLINENEWLINE//g' |\
	 perl -pe 's/NEWLINENEWLINE//g' |\
	 perl -pe 's/\.NEWLINE/. /g' |\
	 perl -pe 's/\. NEWLINE/. /g' |\
	 perl -pe 's/\!NEWLINE/! /g' |\
	 perl -pe 's/\! NEWLINE/! /g' |\
	 perl -pe 's/\?NEWLINE/? /g' |\
	 perl -pe 's/\? NEWLINE/? /g' |\
	 perl -pe 's/»NEWLINE/» /g' |\
	 perl -pe 's/NEWLINE/\n/g' |\
	 perl -pe 's/- (.*?)(\d+)/\+ APOSTROPH2<li><a href=GUILLEMETnode\2GUILLEMET>\1 \2<\/a><\/li>APOSTROPH2/g' |\
	 perl -pe 's/== (\d+) ==/ \n \);\n\n undum.game.situations.node\1 = new undum.SimpleSituation\(\nAPOSTROPH2<p><br\/><h2>\1<\/h2>/g' |\
	 # end of game |\
	 perl -pe 's/FIN/FIN APOSTROPH2/' |\
	 perl -pe 's/THE END/THE END APOSTROPH2/' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/TESTLUCK/\[i\]Am I lucky today? (throwing a dice, 5 or 6 means luck)\[\/i\]/'|\
	 perl -pe 's/¯/ /g' |\
	 perl -pe "s/APOSTROPHE/\\\'/g" |\
	 perl -pe "s/APOSTROPH2/\'/g" |\
	 perl -pe 's/GUILLEMET/\"/g' |\
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's|\/\/(.*)\/\/|\[i\]\1\[/i\]|' |\
	 perl -pe 's/\[\[(.*).jpg] 1\]/*image \1.jpg/' |\
	 perl -pe 's/\[\[(.*).png] 1\]/*image \1.jpg/' |\
	 perl -pe 's/\[(.*).jpg\]/*image \1.jpg/' |\
	 perl -pe 's/\[(.*).jpg\]/*image \1.jpg/' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 perl -pe 's/rdv/rendez-vous/'  >> $(DOCUMENT)_undum/$(DOCUMENT)_undum.html
	 -echo "); </script></body></html>" >> $(DOCUMENT)_undum/$(DOCUMENT)_undum.html

play-cyoa-renpy:
	#
	$(RENPY) $(DOCUMENT)_renpy


cyoa-renpy:
	# for use with http://renpy.org/
	rm -fr $(DOCUMENT)_renpy
	mkdir $(DOCUMENT)_renpy
	# sed can't replace multiple newlines. So we remove them, and add them back later.
	cp -fr $(TEXTALLIONFOLDER)/templates/renpy/* $(DOCUMENT)_renpy
	touch  $(DOCUMENT)_renpy/.nomedia
	cat $(DOCUMENT).t2t   |\
     sed '1,4d' |\
	 perl -pe 's/^\%(.*)\n//' |\
	 perl -pe 's/^(.*): *\n/    "\1:"\n/'  |\
	 perl -pe 's/\n/NEWLINE/' |\
	 perl -pe 's/NEWLINENEWLINE-/\n\n    menu:\n-/g' |\
	 perl -pe 's/NEWLINE/\n/g' |\
	 perl -pe 's/"    menu:\"/menu:\n/'  |\
	 perl -pe 's/tt (\d+)/continue \1/g' |\
	 perl -pe 's/\(rdv au (\d+)\)/ \1/g' |\
	 perl -pe 's/rdv au (\d+)/ \1/g' |\
	 perl -pe 's/continue[r|z] au (\d+)/continuer \1/g' |\
	 perl -pe 's/rendez-vous au (\d+)/ \1/g' |\
	 perl -pe 's/[A|a]lle[z|r] au (\d+)/: \1/g' |\
	 perl -pe 's/ au (\d+)/ \1/g' |\
	 perl -pe 's/(.*) (\d+)[ ]*\n/        "\1":\n            jump page\2\n/' |\
	 perl -pe 's/(.*) \[(.*) #(.*)\][ ]*\n/        "\1":\n            jump page\2\n/' |\
	 perl -pe 's/== (\d+) ==[ ]*\n/\nlabel page\1:\n    scene bg\n    with None\n/' |\
	 perl -pe 's/==(\d+)==\[(.*)\]\n/\nlabel page\1:\n    scene bg\n    with None\n/' |\
	 perl -pe 's/== (.*) ==[ ]*\n/\nlabel page\1:\n    scene bg\n    with None\n/' |\
	 perl -pe 's/\[\[(.*).jpg] 1\]/    image \1 = "\1.jpg"\n    \x{0024} showmypic("\1")/' |\
	 perl -pe 's/\[\[(.*).png] 1\]/    image \1 = "\1.png"\n    \x{0024} showmypic("\1")/' |\
	 perl -pe 's/\[(.*).jpg\]/    image \1 = "\1.jpg"\n    \x{0024} showmypic("\1")/' |\
	 perl -pe 's/\[(.*).png\]/    image \1 = "\1.png"\n    \x{0024} showmypic("\1")/' |\
	 perl -pe 's/\[(.*).ogg\]/    \x{0024} renpy.music.play("\1.ogg", loop=False)\n/' |\
	 perl -pe 's/\[(.*).mid\]/    \x{0024} renpy.music.play("\1.mid", loop=False)\n/' |\
	 perl -pe 's/..\/images\///g' |\
	 perl -pe 's/..\/media\///g' |\
	 perl -pe 's/¯/ /g' |\
	 perl -pe 's/\[(.*)\]//' |\
	 perl -pe 's/^(.*)\.[ ]*\n/    "\1."/' |\
	 perl -pe 's/^(.*),[ ]*\n/    "\1,"/' |\
	 perl -pe 's/^(.*)”[ ]*\n/    "\1”"/' |\
	 perl -pe 's/^(.*)»[ ]*\n/    "\1»"/' |\
	 perl -pe 's/^(.*)![ ]*\n/    "\1!"/'  |\
	 perl -pe 's/^(.*)\?[ ]*\n/    "\1?"/' |\
	 perl -pe 's/^\/\/(.*)\/\/\n/    "\{i\}\1\{\/i\}"/' |\
	 perl -pe 's/^\*\*(.*)\*\*\n/    "\{b\}\1\{\/b\}"/' |\
	 perl -pe 's/^-(.*)/        "~~ missing line (please review your source code)~~"/' |\
	 perl -pe 's/        \"- /        " /' |\
	 #italic |\
	 #perl -pe 's/\{ \/\/ \}/\{i\}/' |\
	 #perl -pe 's/\{\/\/\/ \}/\{\/i\}/' |\
	 perl -pe 's/\{ \/\/ \}//' |\
	 perl -pe 's/\{\/\/\/ \}//' |\
	 perl -pe 's/\/\/(.*)\/\//\{i\}\1\{\/i\}/' |\
	 perl -pe 's/\{.{3}\}(.*){(.*)\}/    "\2"/' |\
	 perl -pe 's/\{{3}\}//' |\
	 perl -pe 's/TESTLUCK/    "Am I lucky today? (throwing a dice, 5 or 6 means luck)"/'|\
	 perl -pe 's/:\":/\":/'|\
	 perl -pe 's/\" THE END \"/jump end/' |\
	 perl -pe 's/THE END/    jump end/'	 >> $(DOCUMENT)_renpy/game/script.rpy 
	 printf "\nlabel end:\n    show expression Text(\"THE END.\", size=50, yalign=0.5, xalign=0.5, drop_shadow=(2, 2)) as text\n    with dissolve\n    \" \" \n" >> $(DOCUMENT)_renpy/game/script.rpy 
	 

cyoa-inform7-temp:

	# before : remove comments
		 # change " |\
	 # TODO # perl -pe 's/\"(.*)\"/\[\"\]\1\[\"\]/g' |\  

cyoa-inform7:
	 sed 's/^$$/ /' $(DOCUMENT).t2t > $(DOCUMENT).tmp  
	 printf  "== 00 ==\n" >> $(DOCUMENT).tmp  
	 cat $(DOCUMENT).tmp |\
	 perl -pe 's/==(\d+)==\[(.*)\]/== \1 ==/' |\
	 perl -pe 's/== (\d+) ==/\n== \1 ==\n/' |\
	 perl -pe 's/TESTLUCK/Am I lucky today? (throwing a dice, 5 or 6 means luck)/'|\
	 # remove comments |\
	 perl -pe 's/^\%(.*)\n//' |\
	 # remove syntax such as [11 #nord] |\
	 perl -pe 's/\[(\d+) #([^ ].*?)\]/\2/g' |\
	 perl -pe 's/- (.*) \[(.*)\]\n/- \1 \2\n/g' |\
	 perl -pe 's/- (.*) \((.*)\)\n/- \1 \2\n/g' |\
	 perl -pe 's/\[(.*)\]{(.*)\}\n//g' |\
	 perl -pe 's/\[(.*)\]\n//g' |\
	 perl -pe 's/\[(.*)\]//g' |\
	 perl -pe 's/{~~~~}/ /g' |\
	 perl -pe 's/¯/ /g' |\
	 perl -pe 's/\?/\? /g' 	> $(DOCUMENT).tmp2
	 printf "\"$(DOCUMENT_TITLE)\" by $(DOCUMENT_AUTHOR)\n\nInclude Adventure Book by Edward Griffiths.\n\n\n" > $(DOCUMENT).i7
	 printf "The first Page is a page. \"Starting the game...\" It is followed by Page1.\n\n" >> $(DOCUMENT).i7
	 perl $(TEXTALLIONFOLDER)/core/adventurebook.pl $(DOCUMENT).tmp2 >> $(DOCUMENT).i7
	 cat $(DOCUMENT).i7 |\
	 # remove extra spaces |\
	 perl -pe 's/  [ ]*"./ "./g' |\
	 perl -pe 's/  [ ]*/ /g' |\
	 perl -pe 's/\{->--\} FIN \{-<--\}[ ]*"./". \nIt is followed by GameEnd./' |\
	 perl -pe 's/\{->--\} THE END \{-<--\}[ ]*"./". \nIt is followed by GameEnd./' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/{(.*)}\n//g' |\
	 perl -pe 's/{(.*)}//g' > $(DOCUMENT).tmp
	 printf "\nGameEnd is a page. \"** THE END **\".\n\n" >> $(DOCUMENT).tmp
	 #  convert French apostrophes for inform7 source
	 cat $(DOCUMENT).tmp | sed -e "s/S'/S[\']/g" | sed -e "s/N'/N[\']/g" | sed -e "s/L'/L[\']/g" | sed -e "s/C'/C[\']/g" | sed -e "s/D'/D[\']/g" | sed -e "s/J'/J[\']/g" | sed -e "s/M'/M[\']/g"  | sed -e "s/U'/U[\']/g" | sed -e "s/s'/s[\']/g" | sed -e "s/ n'/ n[\']/g" | sed -e "s/l'/l[\']/g" | sed -e "s/ c'/ c[\']/g" | sed -e "s/d'/d[\']/g" | sed -e "s/j'/j[\']/g" | sed -e "s/m'/m[\']/g" | sed -e "s/u'/u[\']/g" > $(DOCUMENT).i7
	 -rm $(DOCUMENT).tmp
	 -rm $(DOCUMENT).tmp2
	 cp -fr $(TEXTALLIONFOLDER)/templates/inform7 ./
	 cp $(DOCUMENT).i7 inform7/cyoa.inform/Source/story.ni
	 cd inform7
	 make z8

cyoa-inform5:
	cat $(DOCUMENT).t2t | perl -pe 's/^\%(.*)\n//' |\
	# remove extra textallion syntax |\
	 perl -pe 's/TESTLUCK/print "Am I lucky today? (throwing a dice, 5 or 6 means luck)";/'|\
	 perl -pe 's/THE END/print "THE END";/'|\
	 # abbreviations |\
	 perl -pe 's/tt (\d+)/turn to [[\1]]/g' |\
	 perl -pe 's/rdv au (\d+)/rendez-vous au [[\1]]/g' |\
	 perl -pe 's/rendez-vous au (\d+)/rendez-vous au [[\1]]/g' |\
	 # replace any ="introduction" by 0 |\
	 perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	 perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\
	 # italic and underline are the same. Only bold is different |\
	 perl -pe "s/\*\*(.*?)\*\*/''\1''/g" |\
	 perl -pe "s/\`\`(.*?)\`\`/{{{\1}}}/g" |\
	 perl -pe 's/¯/ /g' |\
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's/rdv/rendez-vous/' |\
	 # remove images / [[bla.jpg] 1] est pour image sur premiere page |\
	 perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]/ /' |\
	 perl -pe 's/\[(.*).png\]/ /' |\
	 # why did we remove media? |\
	 #perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 # choices and links (\r is for windows newline) \
	 perl -pe 's/- (.*?) (\d+?)( *)\r/print \"\1\: \2"; \naddchoice\(@@@\2@@@, chapter\2\);/g' |\
	 perl -pe 's/- (.*?) (\d+?)( *)\n/print \"\1: \2\"; \naddchoice\(@@@\2@@@, chapter\2\);/g' |\
	 # deprecated: perl -pe 's/\[(\d+) \#(.*?)\]/[[\2|\1]]/g' |\
	 perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/[[\1|\2]]/g' |\
	 perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/[[\1|\2]]/g' |\
	 perl -pe 's/\[([^\#].*?) \#(.*?)\]/[[\1|\2]]/g' |\
	 # main text |\
	 perl -pe 's/^(.*)\.[ ]*\n/ print "\1.";/' |\
	perl -pe 's/^(.*)[ ]*\![ ]*\n/ print \1 !";/' |\
	perl -pe 's/^(.*)[ ]*\?[ ]*\n/ print "\1 ?";/' |\
	perl -pe 's/^(.*)[ ]*\:[ ]*\n/ print "\1 :";/' |\
	 #perl -pe 's/\[(\d+) \#(\d+)\]/[[\1]]/g' |\
	 #perl -pe 's/ \#(\d+?) / [[\1]] /g' |\
	 #perl -pe 's/ \#(.*?) / [[\1]] /g' |\
	 #perl -pe 's/ \#([^ ].*) / [[\1]]/g' |\
	 #perl -pe 's/\[\#(\d+?)\]/[[\1]]/g' |\
	 #perl -pe 's/\[\#(.*?)\]/[[\1]]/g' |\
	 # notes \
	 perl -pe 's/°°(.*?)°°(.*?)°°/ \/\/\2\/\/ /' |\
	 perl -pe 's/“/"/g' |\
	 perl -pe 's/”/"/g' |\
	 # chapters \
	 perl -pe 's/==(\d+)==\[(.*)\]/\n];\n\[ chapter\1 ; /g' |\
	 perl -pe 's/==(\d+)==/\n];\n\[ chapter\1 ; /g' |\
	 perl -pe 's/== (\d+) ==/\n];\n\[ chapter\1 ; /g' |\
	 perl -pe 's/== (.*?) ==\[(.*?)\]/:: \2/g' |\
	 perl -pe 's/== (.*?) ==/:: \1/g' |\
	 # make  lists \
	 perl -pe 's/^+ / /'|\
	 perl -pe "s/@@@/'/g" |\
	 perl -pe 's/^- /* /' 	 > $(DOCUMENT)_z3.inf



cyoa-inform6:
	inform +source_path=$(TEXTALLIONFOLDER)/templates/inform6/ +include_path=./,$(TEXTALLIONFOLDER)/templates/inform6/,/usr/share/inform/include +code_path=./ "$1".inf 
	
	
cyoa-zx:
	sed 's/^$$/ /' $(DOCUMENT).t2t > $(DOCUMENT).tmp  
	printf  "CLS\nstart:\n" >> $(DOCUMENT).tmp  
	cat $(DOCUMENT).tmp |\
	perl -pe 's/==(\d+)==\[(.*)\]/\nlabel\1:\n/' |\
	perl -pe 's/== (\d+) ==/\nlabel\1:\n/' |\
	perl -pe 's/^(.*)\.[ ]*\n/  CLS\n PRINT  "\1."/' |\
	perl -pe 's/^(.*)\![ ]*\n/  CLS\n PRINT  "\1 !"/' |\
	perl -pe 's/^(.*)\?[ ]*\n/  CLS\n PRINT  "\1 ?"/' |\
	perl -pe 's/^(.*)\:[ ]*\n/  CLS\n PRINT  "\1 :"/' |\
	perl -pe 's/\{->--\} FIN \{-<--\}[ ]*"./PRINT "FIN"/' |\
	perl -pe 's/\{->--\} THE END \{-<--\}[ ]*"./PRINT "THE END"/' |\
	perl -pe 's/%(.*)/ REM \1 /' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/{(.*)}\n//g' |\
	 perl -pe 's/{(.*)}//g' |\
	 # images and sound not supported yet|\
	perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]//' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	perl -pe 's/- (.*?) (\d+?)( *)\n/PRINT "\1 (\2)"\nChoice=INPUT(4)\n if Choice="\2" then GOTO label\2\nEND IF\n/g' > $(DOCUMENT)_zx.bas
	

cyoa-bbcbasic:
	sed 's/^$$/ /' $(DOCUMENT).t2t > $(DOCUMENT).tmp  
	printf  "CLS\nstart:\n" >> $(DOCUMENT).tmp  
	cat $(DOCUMENT).tmp |\
	perl -pe 's/==(\d+)==\[(.*)\]/\nlabel\1:\n/' |\
	perl -pe 's/== (\d+) ==/\nlabel\1:\n/' |\
	perl -pe 's/^(.*)\.[ ]*\n/  CLS\n PRINT  "\1."/' |\
	perl -pe 's/^(.*)\![ ]*\n/  CLS\n PRINT  "\1 !"/' |\
	perl -pe 's/^(.*)\?[ ]*\n/  CLS\n PRINT  "\1 ?"/' |\
	perl -pe 's/^(.*)\:[ ]*\n/  CLS\n PRINT  "\1 :"/' |\
	perl -pe 's/\{->--\} FIN \{-<--\}[ ]*"./PRINT "FIN"/' |\
	perl -pe 's/\{->--\} THE END \{-<--\}[ ]*"./PRINT "THE END"/' |\
	perl -pe 's/%(.*)/ REM \1 /' |\
	 # remove extra textallion syntax |\
	 perl -pe 's/{(.*)}\n//g' |\
	 perl -pe 's/{(.*)}//g' |\
	 # images and sound not supported yet|\
	perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]//' |\
	 perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	perl -pe 's/- (.*?) (\d+?)( *)\n/PRINT "\1 (\2)"\nINPUT Choice\n IF Choice="\2" THEN GOTO label\2\nEND IF\n/g' > $(DOCUMENT)_zx.bas


# for using with Gemini / gemtext format:

cyoa-gemtext:
	$(TXT2TAGS) -t md $(DOCUMENT).t2t
	cat $(DOCUMENT).md |\
	perl -pe 's/CONVERT(.*)END//' |\
	perl -pe 's/CONVERT(.*)BEGIN//' |\
	perl -pe 's/au 14/14/' |\
	perl -pe 's/WRAPLEFT(.*)WRAPLEFT//' |\
	perl -pe 's/\[(.*)\]//' |\
#	perl -pe "s/TESTLUCK/Ai-je de la chance aujourd'hui ? Quand je tire un dé de ma poche, je peux être considéré comme chanceux si je fais un 5 ou un 6 avec./" |\
	perl -pe "s/TESTLUCK/Am I lucky today? When I draw a die, I can be considered lucky if I roll a 5 or a 6 with it./" |\
	perl -pe 's/^ \* (.*) : (\d+)/=> section\2.gmi \1/' |\
	perl -pe 's/^ \* (.*): (\d+)/=> section\2.gmi \1/' |\
	perl -pe 's/^ \* (.*) (\d+)/=> section\2.gmi \1/' |\
	perl -pe 's/section1.gmi/section01.gmi/' |\
	perl -pe 's/section2.gmi/section02.gmi/' |\
	perl -pe 's/section3.gmi/section03.gmi/' |\
	perl -pe 's/section4.gmi/section04.gmi/' |\
	perl -pe 's/section5.gmi/section05.gmi/' |\
	perl -pe 's/section6.gmi/section06.gmi/' |\
	perl -pe 's/section7.gmi/section07.gmi/' |\
	perl -pe 's/section8.gmi/section08.gmi/' |\
	perl -pe 's/section9.gmi/section09.gmi/' |\
	perl -pe 's/¯/ /g' |\
	perl -pe 's/, rdv au//g' |\
	perl -pe 's/, rendez-vous au//g'  > $(DOCUMENT).gmi
	-mkdir gemtext_$(DOCUMENT)
	cp $(DOCUMENT).gmi gemtext_$(DOCUMENT)
	# then edit the generated gemtext_doc.... and remove the # 0 section and the titles above it. And then run:
	# cd gemtext_$(DOCUMENT)
	# csplit la_mort_bleue.gmi /##/ {*}
	# csplit the_blue_death.gmi /##/ {*}
	# rename 's/xx/section/gi' *
	# rename -v -- 's/$/.gmi/' *
	# ( rename 's/\.gmi$//' *.gmi )
	# some parts might need some tweakings...


# https://librogamesland.github.io/magebook

cyoa-magebook:
	$(TXT2TAGS) -t md $(DOCUMENT).t2t
	cat $(DOCUMENT).md |\
	perl -pe 's/CONVERT(.*)END//' |\
	perl -pe 's/CONVERT(.*)BEGIN//' |\
	perl -pe 's/## /### /' |\
	#perl -pe 's/au 14/14/' |\
	perl -pe 's/WRAPLEFT(.*)WRAPLEFT//' |\
	# perl -pe 's/\[(.*)\]//' |\
	perl -pe 's/^ \* (.*) : (\d+)/* \1 [\2]/' |\
	perl -pe 's/^ \* (.*): (\d+)/* \1 [\2]/' |\
	perl -pe 's/^ \* (.*) (\d+)/* \1 [\2]/' |\
	perl -pe "s/TESTLUCK/Ai-je de la chance aujourd'hui ? Quand je tire un dé de ma poche, je peux être considéré comme chanceux si je fais un 5 ou un 6 avec./" |\
#	perl -pe "s/TESTLUCK/Am I lucky today? When I draw a die, I can be considered lucky if I roll a 5 or a 6 with it./" |\
	perl -pe 's/¯/ /g' |\
	perl -pe 's/, rdv au//g' |\
	perl -pe 's/, rendez-vous au//g'  > $(DOCUMENT).magebook
	# some parts might need some tweakings...
