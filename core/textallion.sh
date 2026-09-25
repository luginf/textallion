#!/bin/sh

# %%%% Textallion %%%%
# Tiny almost-Kiss Word Processor
# http://anamnese.online.fr/site2/textallion/docs/presentation.html
# Complete source code: https://textallion.sourceforge.io
# License: http://creativecommons.org/licenses/by-sa/3.0/

# initiate the variables, from the user's input

# (a function, not an alias: aliases are not expanded by bash in scripts.
# Falls back to the untranslated text if gettext is not installed.)
GETTEXT(){
	if command -v gettext >/dev/null 2>&1; then
		gettext "TEXTALLION" "$1"
	else
		printf '%s' "$1"
	fi
}

#TEXTDOMAINDIR=./
#TEXTDOMAIN=textallion.sh

export TEXTDOMAIN=textallion.sh
#export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAINDIR="/usr/share/textallion/core/locale"
#export TEXTDOMAINDIR="locale"

# change to =en or =fr for default language
export LANGUAGE=en

export TEXTALLIONDOCSPATH=$HOME/textalliondocs
export DOCUMENTFOLDER=sample
export DOCUMENTNAME=sample


PRESS_KEY=$(GETTEXT "PRESS A KEY TO CONTINUE")
CREATE_NEW=$(GETTEXT "Create a new")
MANIPULATE_SOURCE=$(GETTEXT "Manipulate sources or Generate HTML, PDF, EPUB...")
MORE_OPTIONS=$(GETTEXT "More options")
READ=$(GETTEXT "Read")
FROM=$(GETTEXT "from")
GENERATE=$(GETTEXT "Generate")
EXPORT_TO=$(GETTEXT "Export to")
EDIT=$(GETTEXT "Edit")
THIS_FOLDER=$(GETTEXT "This folder")
IS_ALREADY_PRESENT=$(GETTEXT "is already present")
PREVIOUS_MENU=$(GETTEXT "Previous menu")
AND=$(GETTEXT "and")
CREATE_INDEX=$(GETTEXT "then create an html index to distribute your files on internet")
WHO_IS_AUTHOR=$(GETTEXT "Who is the author?")
WHAT_IS_DOC_NAME=$(GETTEXT "What is the title name of the document file to be created?")
WHAT_IS_FILE_NAME=$(GETTEXT "What is the name of the game file (and folder) to be created? (Try to avoid accented letters, spaces and funky characters).")
GAME_CYOA=$(GETTEXT "CYOA game")
EXPORT_RENPY_AND_CO=$(GETTEXT "(export to renpy, undum, choicescript, create graph etc)")
CHOOSE_ANOTHER_DOC=$(GETTEXT "Choose another document to manipulate")
FIRST_TIME_USER=$(GETTEXT "It's probably the first time you're using textallion. We'll make you create a new document now.")
GAME_NOT_EXISTS=$(GETTEXT "This game is not existing, please choose another one or create a new one.")
DOCUMENT_NOT_EXISTS=$(GETTEXT "This document is not existing, please choose another one or create a new one.")
YOUR_EXISTING_GAMES=$(GETTEXT "Here are your already existing games:")
YOUR_EXISTING_DOC=$(GETTEXT "Here are your already existing documents:")
WHICH_ONE_DO_YOU_SELECT=$(GETTEXT "Which one do you select? (please type the full name, but you can omit the \"cyoa-\" or \"lettre-\" part in it if it applies.)")
GRAPH_NODES=$(GETTEXT "a graph of the nodes")
INITIATE_NEW_DOC=$(GETTEXT "This script will initiate a new document. All requested data are mandatory, except for the tags and the language code.")
MANIPULATE=$(GETTEXT "Manipulate")
OTHER_TOOLS=$(GETTEXT "other tools")
HELP=$(GETTEXT "Help")
QUIT=$(GETTEXT "Quit")
OF_DISTRIBUTED_VERSION_OF=$(GETTEXT "of the distributed version of")
WHAT_TAGS=$(GETTEXT "What are the tags defining this document (separated by commas)?")
WHAT_IS_LANGUAGE_CODE=$(GETTEXT "What is the language code of the document (2 letters, i.e. 'en' for English)?")
LETTER_DOC=$(GETTEXT "a letter (French A4 lettre)")
DOCUMENT_DOC=$(GETTEXT "general purpose document (book, article...)")




# $1: exit code (default 0)
usage()
{
	echo "Usage: textallion init"
	echo "         initiate a new document"
	echo ""
	echo "       textallion list"
	echo "         list the documents of ${TEXTALLIONDOCSPATH}"
	echo ""
	echo "       textallion command"
	echo "         for using within a makefile (cyoa_dialog, cyoa_ramus2)"
	echo ""
	exit "${1:-0}"
}




# http://stackoverflow.com/questions/2221562/using-gettext-in-bash
# xgettext -o TEXTALLION.pot  -L Shell --keyword --keyword=GETTEXT  textallion.sh
# msginit -i TEXTALLION.pot -l en.UTF-8
# msginit -i TEXTALLION.pot -l fr.UTF-8
# edit po
# msgfmt -v  en.po -o en.mo
# msgfmt -v  fr.po -o fr.mo
# install en.mo locale/en/LC_MESSAGES/TEXTALLION.mo
# install fr.mo locale/fr/LC_MESSAGES/TEXTALLION.mo
# sudo install en.mo /urs/share/locale/en/LC_MESSAGES/TEXTALLION.mo
# sudo install fr.mo /usr/share/locale/fr/LC_MESSAGES/TEXTALLION.mo
# LANGUAGE=fr  ./textallion.sh


## Helpers
# (no "local" in this script: ksh, the sh of OpenBSD, does not have it. The
# variables of the functions are global, so keep their names distinct.)

is_cygwin(){
	case $(uname) in
		CYGWIN*) return 0 ;;
		*) return 1 ;;
	esac
}

# make a pause. Resume by keypress.
pause(){
	echo ""
	echo "($PRESS_KEY)"
	echo ""
	if [ -t 0 ]; then
		_stty=$(stty -g)
		trap 'stty "$_stty"; exit 130' INT
		stty -echo -icanon min 1 time 0
		dd bs=1 count=1 >/dev/null 2>&1
		stty "$_stty"
		trap - INT
	else
		# input is not a terminal (pipe, file): just consume one character
		dd bs=1 count=1 >/dev/null 2>&1
	fi
}

# read a line into the variable named $1. Leave the program on end of input
# (ctrl-d), otherwise the menus would loop forever.
ask(){
	read -r "$1" || { echo ""; quit; }
}

banner(){
	is_cygwin || clear 2>/dev/null
	printf "\n
 @---------------@
 / Le Textallion /
 @---------------@\n\n"
}

# run "make $@" inside the folder of the current document
run_make(){
	( cd "${TEXTALLIONDOCSPATH}/${DOCUMENTNAME}" && make "$@" )
}

# open a shell inside the folder of the current document
shell_in_folder(){
	printf "(Type ctrl-d to exit once you have finished.)\n\n"
	( cd "${TEXTALLIONDOCSPATH}/${DOCUMENTNAME}" && "${SHELL:-bash}" )
}

read_pdf(){
	if is_cygwin; then
		echo "If SumatraPDF is not installed, please enter ${TEXTALLIONDOCSPATH}/${DOCUMENTNAME} and open the PDF from there."
		( cd "${TEXTALLIONDOCSPATH}/${DOCUMENTNAME}" && sumatrapdf "${DOCUMENTNAME}.pdf" )
	else
		run_make read
	fi
}

# sed_inplace FILE SED_ARGS...: portable "sed -i" (the GNU and BSD versions
# of the option are not compatible)
sed_inplace(){
	_file=$1
	shift
	sed "$@" "$_file" > "${_file}.tmp$$" && cat "${_file}.tmp$$" > "$_file"
	rm -f "${_file}.tmp$$"
}

# escape a string for the replacement part of a sed "s@...@...@" command
sed_escape(){
	printf '%s' "$1" | sed -e 's/[\\&@]/\\&/g'
}

# escape a string for the text of an XML/SVG document
xml_escape(){
	printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

# turn a name into a safe folder name: no accents, lower case, only a-z 0-9 _ -
# (alternations, not [bracket] sets: some sed work on bytes, not on UTF-8 characters)
slugify(){
	printf '%s' "$1" | sed -E \
		-e 's/(ê|è|é|ë|Ê|È|É|Ë)/e/g' \
		-e 's/(î|ì|í|ï|Î|Ì|Í|Ï)/i/g' \
		-e 's/(á|å|à|ä|â|À|Á|Â|Ä)/a/g' \
		-e 's/(ø|ô|ó|ò|ö|Ô|Ò|Ó|Ö)/o/g' \
		-e 's/(ü|û|ù|ú|Ù|Ú|Û|Ü)/u/g' \
		-e 's/(ç|Ç)/c/g' \
		-e 's/(ÿ|Ÿ)/y/g' \
		-e 's/(œ|Œ)/oe/g' \
		-e 's/(æ|Æ)/ae/g' |
	tr 'A-Z' 'a-z' | sed -e 's/[^a-z0-9_-]/_/g' -e 's/__*/_/g'
}

# quote a value for a txt2tags %!postproc rule: an apostrophe inside 'quotes'
# would leave the quotes in the replacement text
t2t_quote(){
	case $1 in
		*\'*)
			case $1 in
				*\"*) printf "'%s'" "$1" ;;
				*) printf '"%s"' "$1" ;;
			esac
			;;
		*) printf "'%s'" "$1" ;;
	esac
}

# print the folders of textalliondocs of one kind: doc, cyoa or lettre
list_projects(){
	for d in "${TEXTALLIONDOCSPATH}"/*/; do
		[ -d "$d" ] || continue
		n=${d%/}
		n=${n##*/}
		case $n in
			cyoa-*) k=cyoa ;;
			lettre-*) k=lettre ;;
			*) k=doc ;;
		esac
		[ "$k" = "$1" ] && printf '%s  ' "$n"
	done
	echo ""
}

# ask which project of kind $1 (doc, cyoa, lettre) to open, the prefix $2
# (cyoa-, lettre-) being optional in the answer. Set DOCUMENTNAME and return 0
# if the project exists.
select_project(){
	printf "\n\n$WHICH_ONE_DO_YOU_SELECT\n\n"
	ask DOCUMENTNAME
	case $DOCUMENTNAME in
		""|*/*|.*) return 1 ;;
	esac
	if [ -f "${TEXTALLIONDOCSPATH}/${DOCUMENTNAME}/${DOCUMENTNAME}.t2t" ]; then
		return 0
	elif [ -n "$2" ] && [ -f "${TEXTALLIONDOCSPATH}/$2${DOCUMENTNAME}/$2${DOCUMENTNAME}.t2t" ]; then
		DOCUMENTNAME=$2${DOCUMENTNAME}
		return 0
	fi
	return 1
}


## Menus

introduction(){
	banner
	echo "1: $CREATE_NEW document"
	echo "2: $MANIPULATE_SOURCE"
	echo ""
	echo "3: $MORE_OPTIONS $AND $OTHER_TOOLS ($MANIPULATE $GAME_CYOA, letters, updates...)"
	echo "4: $HELP"
	echo "0: $QUIT"
	echo ""
	ask ACTION

	case $ACTION in
		create | new | "1")
			choose_type_document
			;;
		generate| manipulate | "2")
			choose_doc
			;;
		other|more|"3")
			manipulate_ter
			;;
		help|"4")
			show_help
			;;
		quit|"0")
			quit
			;;
		*)
			introduction
			;;
	esac
}

show_help(){
	echo "This command-line interface is a replacement for the manipulation of a makefile. Please visit https://textallion.sourceforge.io for more informations about textallion."
	pause
	introduction
}

test_OS(){
if is_cygwin; then
    OS=Win
    #export?
	TEXTALLIONPATH=C:/cygwin/usr/share/textallion/
	#TEXTALLIONDOCSPATH=~/textalliondocs
	SUDO=
else
    OS=Unix
    #export?
	TEXTALLIONPATH=/usr/share/textallion/
	#TEXTALLIONDOCSPATH=~/textalliondocs
	if command -v sudo >/dev/null 2>&1; then
		SUDO=sudo
	elif command -v doas >/dev/null 2>&1; then
		SUDO=doas
	else
		SUDO=
	fi
	# no need for sudo if we are root
	[ "$(id -u)" = 0 ] && SUDO=
fi
}

updatetextallion(){
if [ ! -d "$TEXTALLIONPATH" ]; then
	echo "$TEXTALLIONPATH is not present on this system. We'll try to run the installer instead."
	pause
	installtextallion
elif [ ! -d "${TEXTALLIONPATH}/.git" ]; then
	echo "$TEXTALLIONPATH is not a git clone, so it can't be updated from here. Update it by running textallion_install.sh from a fresh clone of https://github.com/farvardin/textallion"
else
	$SUDO git -C "$TEXTALLIONPATH" pull
fi
}

installtextallion(){
if [ -e "$TEXTALLIONPATH" ]; then
	echo "$TEXTALLIONPATH $IS_ALREADY_PRESENT on this system. We'll try to run the updater instead."
	pause
	updatetextallion
else
	echo "Textallion will be installed into $TEXTALLIONPATH: this folder will be created, then it will try to be cloned from the GitHub repository. Is it ok? (Y/n)"
	ask choice
	case $choice in
		"n"|"N"|"no"|"NO"|"non")
			echo "Nothing was changed in your configuration"
			;;
		*)
			$SUDO git clone https://github.com/farvardin/textallion "$TEXTALLIONPATH"
			;;
	esac
fi
}


quit(){
printf "\nGoodbye :)\n\n       https://textallion.sourceforge.io\n  \n"
exit
}

choose_doc(){
banner
if [ -d "${TEXTALLIONDOCSPATH}" ]; then
	printf "$YOUR_EXISTING_DOC \n  \n"
	list_projects doc
	if select_project doc ""; then
		manipulate_doc
	else
		echo "$DOCUMENT_NOT_EXISTS"
		pause
		introduction
	fi
else
	printf "$FIRST_TIME_USER \n"
	pause
	create_new_doc
fi
}

manipulate_doc(){
	banner
	echo "1: $EDIT document $DOCUMENTNAME"
	echo ""
	echo "2: $GENERATE HTML $FROM $DOCUMENTNAME"
	echo "3: $GENERATE PDF $FROM $DOCUMENTNAME"
	echo "4: $GENERATE EPUB $FROM $DOCUMENTNAME"
	echo ""
	echo "5: $READ HTML $FROM $DOCUMENTNAME"
	echo "6: $READ PDF $FROM $DOCUMENTNAME"
	echo "7: $READ EPUB $FROM $DOCUMENTNAME"
	echo ""
	echo "8: $MORE_OPTIONS (index etc.)"
	echo ""
	echo "9: $CHOOSE_ANOTHER_DOC"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		edit | "1")
			run_make edit
			manipulate_doc
			;;
		html|"2")
			run_make html
			pause
			manipulate_doc
			;;
		pdf|"3")
			run_make pdf
			pause
			manipulate_doc
			;;
		epub|"4")
			run_make epub
			pause
			manipulate_doc
			;;
		readhtml|"5")
			run_make readhtml
			pause
			manipulate_doc
			;;
		read|"6")
			read_pdf
			pause
			manipulate_doc
			;;
		readepub|"7")
			run_make readepub
			pause
			manipulate_doc
			;;
		more|"8")
			manipulate_bis
			;;
		another|"9")
			choose_doc
			;;
		previous|"0")
			introduction
			;;
		*)
			manipulate_doc
			;;
	esac
}


manipulate_bis(){
	banner
	echo ""
	echo "1: $GENERATE HTML, PDF $AND EPUB, $CREATE_INDEX"
	echo "2: $READ HTML index $OF_DISTRIBUTED_VERSION_OF $DOCUMENTNAME"
	echo ""
	echo "3: Synchronize $DOCUMENTNAME makefile, LaTeX style and CSS style (need a diff tool, for Linux version)"
	echo ""
	echo "5: $GENERATE a cover from the svg document (needs image-magick)"
	echo ""
	echo "9: Command-line interface to the document folder $DOCUMENTNAME (for using makefile for ex.)"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		all|"1")
			run_make all
			pause
			manipulate_bis
			;;
		readindex|"2")
			run_make readindex
			pause
			manipulate_bis
			;;
		synchronize|"3")
			run_make configuration-update
			pause
			manipulate_bis
			;;
		cmd|"9")
			shell_in_folder
			manipulate_bis
			;;
		cover|"5")
			run_make cover
			pause
			manipulate_bis
			;;
		previous|"0")
			manipulate_doc
			;;
		*)
			manipulate_bis
			;;
	esac
}

manipulate_ter(){
	banner
	echo ""
	echo "1: $CREATE_NEW $GAME_CYOA"
	echo "2: $MANIPULATE $GAME_CYOA"
	echo ""
	echo "3: $CREATE_NEW $LETTER_DOC"
	echo "4: $MANIPULATE a LETTER document"
	echo ""
	#echo "6: Change default language / Modifier la langue par défault pour ce menu"
	echo "7: Try to install textallion on the system, if it's not already there"
	echo "8: Try to update textallion with the current devel version (need to be root on Linux)"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		cyoa|"1")
			create_new_cyoa
			pause
			manipulate_ter
			;;
		manipulate|"2")
			choose_cyoa
			pause
			manipulate_ter
			;;
		lettre|"3")
			create_new_lettre
			pause
			manipulate_ter
			;;
		lettreedit|"4")
			choose_lettre
			pause
			manipulate_ter
			;;
		changelang|"6")
			changelanguage
			pause
			manipulate_ter
			;;
		install|"7")
			installtextallion
			pause
			manipulate_ter
			;;
		update|"8")
			updatetextallion
			pause
			manipulate_ter
			;;
		previous|"0")
			introduction
			;;
		*)
			manipulate_ter
			;;
	esac
}

changelanguage(){
	banner
	echo "1: English"
	echo "2: Français / French"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		english|"1")
			export LANGUAGE=en
			echo "Language set to English"
			pause
			introduction
			;;
		french|"2")
			export LANGUAGE=fr
			echo "Langue française"
			pause
			introduction
			;;
		previous|"0")
			introduction
			;;
		*)
			changelanguage
			;;
	esac
}


## Creation of a new document, game or letter

# create_project KIND: KIND is doc, cyoa or lettre. Ask for the metadata, then
# create the folder. Return 0 if the project was created (its folder name is
# then in DOCUMENTFOLDER).
create_project(){
	kind=$1
	prefix=
	case $kind in
		cyoa)
			prefix=cyoa-
			nameprompt="$WHAT_IS_FILE_NAME We'll add cyoa- to the title."
			;;
		lettre)
			prefix=lettre-
			nameprompt="What is the name of the lettre file (and folder) to be created? (Try to avoid accented letters, spaces and funky characters). We'll add lettre- to the title."
			;;
		*)
			nameprompt=$WHAT_IS_FILE_NAME
			;;
	esac

	banner
	printf '%s\n\n' "$INITIATE_NEW_DOC"

	# replace space by underscore for the output files, remove accented letters, lower case
	while :; do
		echo "$nameprompt"
		ask DOCUMENTNAME
		slug=$(slugify "$DOCUMENTNAME")
		DOCUMENTFOLDER=${prefix}${slug}
		if [ -z "$slug" ]; then
			echo "A name is needed."
		elif [ -e "${TEXTALLIONDOCSPATH}/${DOCUMENTFOLDER}" ]; then
			echo "$THIS_FOLDER ${TEXTALLIONDOCSPATH}/${DOCUMENTFOLDER} $IS_ALREADY_PRESENT. Please choose another name or remove this folder."
		else
			break
		fi
		pause
	done

	echo "$WHAT_IS_DOC_NAME"
	ask DOCUMENTTITLE

	echo "$WHO_IS_AUTHOR"
	ask AUTHORNAME

	echo "$WHAT_TAGS"
	ask DOCTAGS

	echo "$WHAT_IS_LANGUAGE_CODE"
	ask DOCLANG
	[ -n "$DOCLANG" ] || DOCLANG=en

	if [ "$kind" = lettre ]; then
		setup_lettre
	else
		setup "$kind"
	fi
}

create_new_doc(){
	create_project doc || return
	# continue to the manipulation options
	export DOCUMENTNAME=$DOCUMENTFOLDER
	manipulate_doc
}


## CYOA

create_new_cyoa(){
	create_project cyoa || return
	export DOCUMENTNAME=$DOCUMENTFOLDER
	manipulate_cyoa
}

choose_cyoa(){
banner
if [ -d "${TEXTALLIONDOCSPATH}" ]; then
	printf "$YOUR_EXISTING_GAMES \n  \n"
	list_projects cyoa
	if select_project cyoa cyoa-; then
		manipulate_cyoa
	else
		echo "$GAME_NOT_EXISTS"
		pause
		manipulate_ter
	fi
else
	printf "$FIRST_TIME_USER \n"
	pause
	create_new_cyoa
fi
}

manipulate_cyoa(){
	banner
	echo "1: $EDIT $GAME_CYOA $DOCUMENTNAME"
	echo ""
	echo "2: $GENERATE HTML $FROM $DOCUMENTNAME"
	echo "3: $GENERATE PDF $FROM $DOCUMENTNAME"
	echo "4: $GENERATE EPUB $FROM $DOCUMENTNAME"
	echo ""
	echo "5: $READ HTML $FROM $DOCUMENTNAME"
	echo "6: $READ PDF $FROM $DOCUMENTNAME"
	echo "7: $READ EPUB $FROM $DOCUMENTNAME"
	echo ""
	echo "8: $MORE_OPTIONS $EXPORT_RENPY_AND_CO"
	echo ""
	echo "9: $CHOOSE_ANOTHER_DOC"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		edit | "1")
			run_make edit
			manipulate_cyoa
			;;
		html|"2")
			run_make cyoa-html
			pause
			manipulate_cyoa
			;;
		pdf|"3")
			run_make cyoa-pdf
			pause
			manipulate_cyoa
			;;
		epub|"4")
			run_make cyoa-epub
			pause
			manipulate_cyoa
			;;
		readhtml|"5")
			run_make readhtml
			pause
			manipulate_cyoa
			;;
		read|"6")
			read_pdf
			pause
			manipulate_cyoa
			;;
		readepub|"7")
			run_make readepub
			pause
			manipulate_cyoa
			;;
		more|"8")
			manipulate_cyoa2
			;;
		another|"9")
			choose_cyoa
			;;
		previous|"0")
			manipulate_ter
			;;
		*)
			manipulate_cyoa
			;;
	esac
}


manipulate_cyoa2(){
	banner
	echo "1: $GENERATE $GRAPH_NODES"
	echo ""
	echo "2: $EXPORT_TO Ramus format"
	echo "3: $EXPORT_TO Renpy format"
	echo "4: $EXPORT_TO Hyena format"
	echo "5: $EXPORT_TO Twee/Twine format"
	echo "6: $EXPORT_TO Undum format"
	echo "7: $EXPORT_TO Choice-script format"
	echo "8: $EXPORT_TO Inform 7 format"
	echo ""
	echo "9: Command-line interface to the game folder $DOCUMENTNAME (for using makefile for ex.). "
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		graph | "1")
			run_make cyoa-graph
			pause
			manipulate_cyoa2
			;;
		ramus|"2")
			run_make cyoa-ramus
			pause
			manipulate_cyoa2
			;;
		renpy|"3")
			run_make cyoa-renpy
			pause
			manipulate_cyoa2
			;;
		hyena|"4")
			run_make cyoa-hyena
			pause
			manipulate_cyoa2
			;;
		twee|twine|"5")
			run_make cyoa-twee
			pause
			manipulate_cyoa2
			;;
		undum|"6")
			run_make cyoa-undum
			pause
			manipulate_cyoa2
			;;
		inform7|"8")
			run_make cyoa-inform7
			pause
			manipulate_cyoa2
			;;
		cs|choicescript|"7")
			run_make cyoa-cs
			pause
			manipulate_cyoa2
			;;
		cmd|"9")
			shell_in_folder
			manipulate_cyoa2
			;;
		previous|"0")
			manipulate_cyoa
			;;
		*)
			manipulate_cyoa2
			;;
	esac
}



### Lettre

create_new_lettre(){
	create_project lettre || return
	export DOCUMENTNAME=$DOCUMENTFOLDER
	manipulate_lettre
}

choose_lettre(){
banner
if [ -d "${TEXTALLIONDOCSPATH}" ]; then
	printf "$YOUR_EXISTING_DOC \n  \n"
	list_projects lettre
	if select_project lettre lettre-; then
		manipulate_lettre
	else
		echo "$DOCUMENT_NOT_EXISTS"
		pause
		manipulate_ter
	fi
else
	printf "$FIRST_TIME_USER \n"
	pause
	create_new_lettre
fi
}

manipulate_lettre(){
	banner
	echo "1: $EDIT lettre $DOCUMENTNAME"
	echo ""
	#echo "2: Generate HTML from $DOCUMENTNAME"
	echo "3: $GENERATE PDF $FROM $DOCUMENTNAME"
	#echo "4: Generate EPUB from $DOCUMENTNAME"
	echo ""
	#echo "5: read HTML from $DOCUMENTNAME"
	echo "6: $READ PDF $FROM $DOCUMENTNAME"
	echo ""
	echo "7: Clean folder (remove temporary files)"
	echo ""
	echo "9: $CHOOSE_ANOTHER_DOC"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		edit | "1")
			run_make edit
			manipulate_lettre
			;;
		html|"2")
			run_make lettre-html
			pause
			manipulate_lettre
			;;
		pdf|"3")
			run_make lettre
			pause
			manipulate_lettre
			;;
		epub|"4")
			run_make lettre-epub
			pause
			manipulate_lettre
			;;
		readhtml|"5")
			run_make readhtml
			pause
			manipulate_lettre
			;;
		read|"6")
			read_pdf
			pause
			manipulate_lettre
			;;
		clean|"7")
			run_make clean
			manipulate_lettre
			;;
		another|"9")
			choose_lettre
			;;
		previous|"0")
			manipulate_ter
			;;
		*)
			manipulate_lettre
			;;
	esac
}


## SETUP

# setup [doc|cyoa]: create the folder ${DOCUMENTFOLDER} from the samples, using
# DOCUMENTTITLE, AUTHORNAME, DOCTAGS and DOCLANG
setup(){
	kind=${1:-doc}
	dest=${TEXTALLIONDOCSPATH}/${DOCUMENTFOLDER}
	t2t=${dest}/${DOCUMENTFOLDER}.t2t
	makefile=${dest}/makefile

	mkdir -p "$dest" || return 1

	# the CYOA targets (cyoa-html, cyoa-pdf...) are only in the CYOA makefile
	if [ "$kind" = cyoa ]; then
		cp "$TEXTALLIONPATH/samples_cyoa/makefile" "$makefile"
	else
		cp "$TEXTALLIONPATH/samples/makefile" "$makefile"
	fi
	cp "$TEXTALLIONPATH/includes/sample.css" "${dest}/${DOCUMENTFOLDER}.css"
	if [ "$kind" = cyoa ]; then
		cp "$TEXTALLIONPATH/includes/sample_cyoa.sty" "${dest}/${DOCUMENTFOLDER}.sty"
	else
		cp "$TEXTALLIONPATH/includes/sample.sty" "${dest}/${DOCUMENTFOLDER}.sty"
	fi

	cp "$TEXTALLIONPATH/media/textallion_cover.svg" "${dest}/${DOCUMENTFOLDER}.svg"
	cp "$TEXTALLIONPATH/media/sample_cover.png" "${dest}/${DOCUMENTFOLDER}.png"
	cp "$TEXTALLIONPATH/media/sample_cover.jpg" "${dest}/${DOCUMENTFOLDER}.jpg"

	e_path=$(sed_escape "$TEXTALLIONPATH")
	e_folder=$(sed_escape "$DOCUMENTFOLDER")
	e_lang=$(sed_escape "$DOCLANG")
	e_author=$(sed_escape "$AUTHORNAME")
	e_title=$(sed_escape "$DOCUMENTTITLE")
	e_tags=$(sed_escape "$DOCTAGS")
	e_date=$(date +%Y-%m-%d)

	sed_inplace "$makefile" \
		-e "s@TEXTALLIONFOLDER = ../@TEXTALLIONFOLDER = ${e_path}/@g" \
		-e "s@DOCUMENT = examples@DOCUMENT = ${e_folder}@g" \
		-e "s@DOCUMENT = the_blue_death@DOCUMENT = ${e_folder}@g" \
		-e "s@= ../contrib/dialog/@= ${e_path}/contrib/dialog/@g" \
		-e "s@xx DOCUMENT LANGUAGE xx@${e_lang}@g" \
		-e "s@xx DOCUMENT AUTHOR xx@${e_author}@g" \
		-e "s@xx DOCUMENT TITLE xx@${e_title}@g" \
		-e "s@xx DOCUMENT TAGS xx@${e_tags}@g" \
		-e "s@xx DOCUMENT DATE xx@${e_date}@g"

	# replace info in cover
	sed_inplace "${dest}/${DOCUMENTFOLDER}.svg" \
		-e "s@Author@$(sed_escape "$(xml_escape "$AUTHORNAME")")@g" \
		-e "s@Le Textallion@$(sed_escape "$(xml_escape "$DOCUMENTTITLE")")@g"

	{
		printf '%s\n' "$DOCUMENTTITLE"
		printf '%s\n' "$AUTHORNAME"
		printf '%s\n\n\n' "$(date +%Y-%m-%d)"
		printf '%s\n\n' "%% DEF DOCUMENT METADATA. Use your own. Remplace the second part only, don't modify the xx DOCUMENT ## xx "
		printf '%s\n\n' "%!postproc(tex): 'xx DOCUMENT TITLE xx' $(t2t_quote "$DOCUMENTTITLE")"
		printf '%s\n\n' "%!postproc(tex): 'xx DOCUMENT AUTHOR xx' $(t2t_quote "$AUTHORNAME")"
		printf '%s\n\n\n' "%!postproc(tex): 'xx DOCUMENT TAGS xx' $(t2t_quote "$DOCTAGS")"
		printf '%s\n\n' "%!style(tex): ${DOCUMENTFOLDER}.sty"
		printf '%s\n\n\n' "%!style(xhtml): ${DOCUMENTFOLDER}.css"
		# (includeconf txt2cyoa.t2t is not needed: the CYOA makefile passes it with --config-file)
		printf '%s\n\n' "%!includeconf: ${TEXTALLIONPATH}/core/textallion.t2t"
		printf '%s\n\n\n' "%!postproc(tex): 'TEXTALLIONPATH' '${TEXTALLIONPATH}'"
		if [ "$kind" = cyoa ]; then
			printf '== 0 ==\n\n- Start the game: 1\n\n\n== 1 ==\n\n\n\n'
		else
			echo ""
		fi
	} > "$t2t"

	echo "${DOCUMENTFOLDER} was created into the textalliondocs folder in your home. You can modify it from here and generate the target documents with this menu driven command line. (You can also enter this folder, edit ${t2t} with the text editor of your choice, and in order to generate the final documents, type \"make pdf\" or \"make html\" or \"make epub\"...)"
	pause
}


## SETUPLETTRE

setup_lettre(){
	dest=${TEXTALLIONDOCSPATH}/${DOCUMENTFOLDER}
	t2t=${dest}/${DOCUMENTFOLDER}.t2t
	makefile=${dest}/makefile

	mkdir -p "$dest" || return 1

	cp "${TEXTALLIONPATH}/samples/makefile" "$makefile"

	e_path=$(sed_escape "$TEXTALLIONPATH")
	e_folder=$(sed_escape "$DOCUMENTFOLDER")
	e_lang=$(sed_escape "$DOCLANG")
	e_author=$(sed_escape "$AUTHORNAME")
	e_title=$(sed_escape "$DOCUMENTTITLE")
	e_tags=$(sed_escape "$DOCTAGS")
	e_date=$(date +%Y-%m-%d)

	sed_inplace "$makefile" \
		-e "s@TEXTALLIONFOLDER = ../@TEXTALLIONFOLDER = ${e_path}/@g" \
		-e "s@DOCUMENT = examples@DOCUMENT = ${e_folder}@g" \
		-e "s@xx DOCUMENT LANGUAGE xx@${e_lang}@g" \
		-e "s@xx DOCUMENT AUTHOR xx@${e_author}@g" \
		-e "s@xx DOCUMENT TITLE xx@${e_title}@g" \
		-e "s@xx DOCUMENT TAGS xx@${e_tags}@g" \
		-e "s@xx DOCUMENT DATE xx@${e_date}@g"

	signature=${TEXTALLIONDOCSPATH}/signature.txt
	if [ -f "$signature" ]; then
		echo "We use your default signature"
	else
		printf "\n\nYou don't have a default signature, so we create one in %s\n\n\n" "${TEXTALLIONDOCSPATH}"
		cp "${TEXTALLIONPATH}/templates/signature.txt" "$signature"
	fi

	{
		printf '%s\n' "$DOCUMENTTITLE"
		printf '%s\n' "$AUTHORNAME"
		printf '%s\n\n\n' "$(date +%Y-%m-%d)"

		printf '%s\n\n' "%% DEF DOCUMENT METADATA. Use your own. Remplace the second part only, don't modify the xx DOCUMENT ## xx "
		printf '%s\n\n\n' "%!postproc(tex): 'xx DOCUMENT TAGS xx' $(t2t_quote "$DOCTAGS")"

		cat "$signature"
		printf '\n\n'

		# sample sender / recipient data, to be replaced by the user
		cat <<'EOF'
%!postproc(tex): 'xx DOCUMENT RECIPIENT GENDER xx'          'Madame'

%!postproc(tex): 'xx DOCUMENT RECIPIENT xx'                 '\textsc{Mélanie Farjot}'
%!postproc(tex): 'xx DOCUMENT RECIPIENT STREET xx'          '1, rue Maréchal Livolas'
%!postproc(tex): 'xx DOCUMENT RECIPIENT POSTAL CODE xx'     '77223'
%!postproc(tex): 'xx DOCUMENT RECIPIENT TOWN xx'            'Villedaim'

%!postproc(tex): 'xx DOCUMENT RECIPIENT PHONE xx'           'Tél : 41 83 53 54 22'
%!postproc(tex): 'xx DOCUMENT RECIPIENT FAX xx'             'Fax : 41 83 53 54 43'

EOF
		printf '%s\n\n' "%!postproc(tex): 'xx DOCUMENT TITLE xx' $(t2t_quote "$DOCUMENTTITLE")"
		printf '%s\n\n' "%!postproc(tex): '%\\date{}' '\\date{le 9 mars 2012}'"

		printf '\n\n'
		printf '%s\n\n' "%!style(tex): ${TEXTALLIONPATH}/includes/sample.sty"
		printf '%s\n\n' "%!includeconf: ${TEXTALLIONPATH}/core/textallion.t2t"
		echo ""
		printf '%s\n\n\n' "%!postproc(tex): 'TEXTALLIONPATH' '${TEXTALLIONPATH}'"
		echo ""
	} > "$t2t"

	echo "${DOCUMENTFOLDER} was created into the textalliondocs folder in your home. You can modify it from here and generate the target documents with this menu driven command line. (You can also enter this folder, edit ${t2t} with the text editor of your choice, and in order to generate the final documents, type \"make pdf\" or \"make html\" or \"make epub\"...)"
	pause
}


## Choose type of document

choose_type_document(){
	banner
	echo "1: $CREATE_NEW $DOCUMENT_DOC"
	echo "2: $CREATE_NEW $LETTER_DOC"
	echo "3: $CREATE_NEW $GAME_CYOA"
	echo ""
	echo "0: $PREVIOUS_MENU"
	echo ""
	ask ACTION
	case $ACTION in
		general | "1")
			create_new_doc
			;;
		lettre|"2")
			create_new_lettre
			;;
		cyoa|"3")
			create_new_cyoa
			;;
		*|"0")
			introduction
			;;
	esac
}





##### Converters

##### Converters



	
cyoa_dialog(){
    # for use with dialog
	# https://linusakesson.net/dialog/docs/timeprogress.html#choicemode
	# @DOLLAR@T expands as $T
printf '%b\n' "(intro)	(activate node #start)\n(library links enabled)\n(label @DOLLAR@Target)\n        (current node @DOLLAR@Origin)\n        (label @DOLLAR@Origin to @DOLLAR@Target)" |\
	perl -pe "s/\@DOL-LAR\@/'$'/g" > ${DOCUMENT}_export.dg 
	# remove 3 first lines of the t2t doc (from line 1 to end line 3) 
	cat ${DOCUMENT}.t2t  | sed '1,4d' | \
	# remove postproc for tex (TODO CHECK)|
	#perl -pe "s/\%\!postproc\(tex\): //g" |
	# convert crlf to lf if needed:
	perl -pi -e 's/\r\n/\n/g' |\
	# convert ( and ): 
	perl -pe 's/\(/\\(/g' |\
	perl -pe 's/\)/\\)/g' |\
	# metadata (before removing them all|
	perl -pe "s/\%\!postproc: \'xx DOCUMENT TITLE xx\'/\(story title\) \1/g" |\
	perl -pe "s/\%\!postproc: \'xx DOCUMENT AUTHOR xx\'/\(story author\) \1/g" |\
	perl -pe "s/\%\!postproc: \'xx DOCUMENT IFID xx\'/\(story ifid\) \1/g" |\
	perl -pe 's/^\%(.*)\n//' |\
		# for lone wolf mode: 
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
	 #perl -pe 's/turn to (\d+)/\1/g' |
	 perl -pe 's/, go to (\d+)/ \1/g' |\
	 perl -pe 's/rdv au (\d+)/ : \1/g' |\
	 perl -pe 's/, rendez-vous au (\d+)/ : \1/g' |\
	 perl -pe 's/rendez-vous au (\d+)/ : \1/g' |\
	 perl -pe 's/ au (\d+)/ ailleurs : \1/g' |\
	 #perl -pe 's/to the (\d+)/to somewhere else : \1/g' |
	 #perl -pe 's/to (\d+)/to somewhere else : \1/g' |
	 # replace any ="introduction" by 0 |
	 perl -pe "s/[I-i]ntro["duction"]*/0/g" |\
	 perl -pe "s/\=\"[I-i]ntro["duction"]*/0/g" |\
	 # code |
	 perl -pe "s/\`\`(.*?)\`\`/\1/g" |\
	 perl -pe 's/¯/ /g' |\
	 # remove extra textallion syntax |
	 perl -pe 's/[ ]*\{.{4}\}[ ]*//g' |\
	 perl -pe 's/[ ]*\{.{3}\}[ ]*//g' |\
	 perl -pe 's/rdv/rendez-vous/' |\
	 # images / [[bla.jpg] 1] est pour image sur premiere page |
	 perl -pe 's/\[\[(.*).jpg] 1\]//' |\
	 perl -pe 's/\[\[(.*).png] 1\]//' |\
	 perl -pe 's/\[(.*).jpg\]/%% (define resource ## \1) /' |\
	 perl -pe 's/\[(.*).png\]/%% /' |\
	 # why did we remove media? |\
	 #perl -pe 's/..\/media\///' |\
	 perl -pe 's/\[(.*).ogg\]//' |\
	 # choices and links (\r is for windows newline) \
	 #perl -pe 's/- (.*?) (\d+?)( *)\n/(label #node\2)\n      (line)\1 \n(* offers #node\2)\n/g' |
	 perl -pe 's/- (.*?) (\d+?)( *)\n/(label * to #node\2) \1 \n(* offers #node\2)\n/g' |\
	 perl -pe 's/- (.*?) (\d+?)( *)\r/(label * to #node\2) \1 \n(* offers #node\2)\n/g' |\
     perl -pe 's/(.*?) \[\#(.*?)\]/(label * to #\2) \1 \n(* offers #\2)\n/g' |\
	 # deprecated: perl -pe 's/\[(\d+) \#(.*?)\]/[[\2|\1]]/g' |\
	 #perl -pe 's/\[([^\#].*?) \| \#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[([^\#].*?)\|\#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[([^\#].*?) \#(.*?)\]/[[\1|\2]]/g' |\
	 #perl -pe 's/\[(\d+) \#(\d+)\]/[[\1]]/g' |\
	 #perl -pe 's/ \#(\d+?) / [[\1]] /g' |\
	 #perl -pe 's/ \#(.*?) / [[\1]] /g' |\
	 #perl -pe 's/ \#([^ ].*) / [[\1]]/g' |\
	 #perl -pe 's/\[\#(\d+?)\]/[[\1]]/g' |\
	 # notes and hr 
	 perl -pe 's/--------------------//g' |\
	 perl -pe 's/°°(.*?)°°(.*?)°°/ \/\/\2\/\/ /' |\
	 # chapters \
	 # lone wolf : 
	 perl -pe 's/== (\d+) ==/#node\1\n(disp *)(space 8)(bold)- \1 -(roman)/' |\
	 # normal : 
	 perl -pe 's/== (\d+) ==/#node\1\n(disp *)/' |\
	 perl -pe 's/==(\d+)==\[(.*)\]/#node\1\n(disp *)/' |\
	 #perl -pe 's/==(\d+)==/#node\1/\n(disp *)/' |
	 perl -pe 's/== (.*?) ==\[(.*?)\]/#node\2\n(disp *)/' |\
	 perl -pe 's/== (.*?) ==/#node\1\n(disp *)/' |\
	 # main text |
	perl -pe 's/^(.*)\.[ ]*\n/     (par)\1.\n/' |\
	perl -pe 's/^(.*)[ ]*\,[ ]*\n/      (par)\1,\n/' |\
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
	#  t2t syntax 
	perl -pe 's/\/\/(.*)\/\//(italic)\1(roman)/' |\
	perl -pe 's/\*\*(.*)\*\*/(bold)\1(roman)/' |\
	# special 
		perl -pe 's/TESTLUCK/      (par) Am I lucky today? \\(throwing a dice, 5 or 6 means luck\\) /'|\
	 perl -pe 's/THE END/     (par) THE END/'|\
	 perl -pe 's/@@FIN@@/     (par) (game over { FIN })/'|\
	 perl -pe 's/\@\@GAME OVER\@\@/     (par) (game over { GAME OVER })/'|\
	# |\
	# remove extra label |
	perl -pe 's/      \(par\)\(label/(label/' |\
	# remove blank lines 
	perl -pe s'/^\n|^[\ ]*\n//g' |\
	# add extra space before nodes 
	perl -pe 's/^#node/\n#node/' |\
	perl -pe 's/      \(par\)\(disp \*\)/(disp *) /s' |\
	#perl -pe 's/^     \(par\)\(offers/(offers/s' |
	perl -pe 's/      \(par\)\(\* offers/(* offers/g' |\
	#perl -pe 's/^\(disp \*\)\n     \(par\)/(disp *) /g' |
	perl -pe 's/     \(par\)\./ /g' |\
	 # make twee lists 
	 #perl -pe 's/^- /* /' |\
	 #perl -pe 's/^+ /# /' |\
	 # remove empty white spaces and lines\
	 #sed -r '/^\s*$/d' |
	perl -pe 's/#node0/#start/' >> ${DOCUMENT}_export.dg
	sed_inplace ${DOCUMENT}_export.dg -e "s/@DOLLAR@/$/g"
	make cyoa-dialog-z8
	make cyoa-dialog-html
	make cyoa-dialog-c64
}



cyoa_ramus2(){
	# https://notimetoplay.org/engines/ramus/
	${TXT2TAGS} -T ${TEXTALLIONFOLDER}/templates/ramus2.html  --config-file ${TEXTALLIONFOLDER}/core/txt2cyoa.t2t  -t xhtml --no-css-inside --outfile ${DOCUMENT}_ramus2.html ${DOCUMENT}.t2t
	sed_inplace ${DOCUMENT}_ramus2.html -e "s/href=\"#/rel=\"/g"
	sed_inplace ${DOCUMENT}_ramus2.html -e "s/style=\"display:none\"//g"
	#sed -i -e "s/onclick\(.*\)rel/rel/" ${DOCUMENT}_ramus2.html
	perl -pi -e 's{<p><br/><br/><br/></p></div>}{xxCLEARLINKSxx\n</div>}g' ${DOCUMENT}_ramus2.html
	# remove the 1st occurence only 
	perl -0pi -e 's/xxCLEARLINKSxx//' ${DOCUMENT}_ramus2.html
	# Create the do clear links
	# If you don't like it this way, uncomment the next line first, to remove everything
	#sed -i -e "s/rel=\"/rel=\"clear\" href=\"#/g" ${DOCUMENT}_ramus2.html
	sed_inplace ${DOCUMENT}_ramus2.html -e "s/rel=\"/href=\"#/g"
	#sed -i -e "s/\xxCLEARLINKSxx/<\?do clear_all_links\(\)\; \?\>/g" ${DOCUMENT}_ramus2.html
	sed_inplace ${DOCUMENT}_ramus2.html -e "s/xxCLEARLINKSxx//g"
	perl -pi -e 's{xxRAMUS_INITxx}{<div style="Display: none;">\n<div id="start">\n<li>Start: <b><a href="#page1">1</a></b>}g' ${DOCUMENT}_ramus2.html
	sed_inplace ${DOCUMENT}_ramus2.html -e "s/THE END/THE END<br\/><a rel=\"clear\" href=\"#start\"><i>Start over?<\/i><\/a>/g"
	cp ${DOCUMENT}_ramus2.html ${DOCUMENT}_ramus2b.html
	sed_inplace ${DOCUMENT}_ramus2b.html -e "s/href=/rel=\"clear\" href=/g"
}	

# Start of script

case "${1:-}" in
	"" | -h | --help | help)
		usage
		;;
	init)
		test_OS
		introduction
		;;
	list)
		ls "${TEXTALLIONDOCSPATH}/"
		;;
	cyoa_dialog | cyoa_ramus2)
		# for use within a makefile: $DOCUMENT, $TXT2TAGS... come from the environment
		test_OS
		echo "Thank you for using TEXTALLION"
		echo "You document is ${DOCUMENT}"
		echo " "
		"$1"
		;;
	*)
		echo "Sorry, invalid input: $1" >&2
		usage 1
		;;
esac
