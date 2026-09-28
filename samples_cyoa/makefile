# Makefile for Textallion CYOA (gamebook) projects
# Tiny almost-Kiss Word Processor
# http://anamnese.online.fr/site2/textallion/docs/presentation.html
# License: http://en.wikipedia.org/wiki/BSD_licenses
#
# get newest textallion at https://textallion.sourceforge.io
#
# This is a Makefile for *GNU make*, the default for Linux.
# On *BSD systems, you'll need to use "gmake" instead of "make"
#
# This makefile only holds this project's data. The targets (html, pdf,
# epub, cyoa-html, cyoa-renpy...) live in core/textallion-common.mk and
# core/textallion-cyoa.mk, included below: edit those files, not a copy of
# them, to change what a target does. An old-style makefile (one that still
# has its own copy of every target) is upgraded to this shape with
# "textallion migrate", or the "Synchronize" menu entry.

# Makefile initially generated on xx DOCUMENT DATE xx

# Override on the command line or in the environment to use another copy of
# Textallion, e.g. "make TEXTALLIONFOLDER=~/src/textallion cyoa-html"
export TEXTALLIONFOLDER ?= ../

ifdef TEXTALLIONDOC
  export DOCUMENT = $(TEXTALLIONDOC)
else
  export DOCUMENT = la_mort_bleue
endif

DOCUMENT_TITLE = La Mort Bleue
DOCUMENT_AUTHOR = Otto Grimwald
DOCUMENT_TAGS = cyoa, steampunk
DOCUMENT_IFID =
DOCUMENT_INFO = textallion - https://textallion.sourceforge.io

ifdef DOCLANG
  DOCUMENT_LANGUAGE = $(DOCLANG)
else
  DOCUMENT_LANGUAGE = fr
endif

DOCUMENT_COVER = $(DOCUMENT).jpg

# for the "dialog" export (cyoa-dialog): https://linusakesson.net/dialog/
DIALOGC = $(TEXTALLIONFOLDER)/contrib/dialog/dialogc
AAMBUNDLE = $(TEXTALLIONFOLDER)/contrib/dialog/aambundle
#DIALOGLIB = $(TEXTALLIONFOLDER)/contrib/dialog/stdlib-fr
#DIALOGLIB = $(TEXTALLIONFOLDER)/contrib/dialog/stdlib_de
DIALOGLIB = $(TEXTALLIONFOLDER)/contrib/dialog/stdlib

# Tool choices (PDFREADER, EPUBREADER, HTMLREADER, EDITTOOL, DIFFTOOL,
# RENPY...) are not set here: they default from core/textallion-defaults.mk,
# and can be set once for every project in ~/.config/textallion/config.mk.
# To override just this project, set them above this line.

include $(TEXTALLIONFOLDER)/core/textallion-common.mk
include $(TEXTALLIONFOLDER)/core/textallion-cyoa.mk

# project-specific target overrides, if any (not created by default)
-include local.mk
