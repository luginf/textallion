# Makefile for Textallion
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
# epub...) live in core/textallion-common.mk, included below: edit that file,
# not a copy of it, to change what a target does. An old-style makefile (one
# that still has its own copy of every target) is upgraded to this shape with
# "textallion migrate", or the "Synchronize" menu entry.

# Makefile initially generated on xx DOCUMENT DATE xx

# Override on the command line or in the environment to use another copy of
# Textallion, e.g. "make TEXTALLIONFOLDER=~/src/textallion html"
export TEXTALLIONFOLDER ?= ../

ifdef TEXTALLIONDOC
  export DOCUMENT = $(TEXTALLIONDOC)
else
  export DOCUMENT = examples
endif

DOCUMENT_TITLE = Textallion - Samples
DOCUMENT_AUTHOR = Various Authors
DOCUMENT_TAGS = Novel, poetry, prosa
DOCUMENT_IFID =
DOCUMENT_INFO = textallion - https://textallion.sourceforge.io

ifdef DOCLANG
  DOCUMENT_LANGUAGE = $(DOCLANG)
else
  DOCUMENT_LANGUAGE = en
endif

DOCUMENT_COVER = $(DOCUMENT).jpg

# Tool choices (PDFREADER, EPUBREADER, HTMLREADER, EDITTOOL, DIFFTOOL...) are
# not set here: they default from core/textallion-defaults.mk, and can be set
# once for every project in ~/.config/textallion/config.mk. To override just
# this project, set them above this line.

include $(TEXTALLIONFOLDER)/core/textallion-common.mk

# project-specific target overrides, if any (not created by default)
-include local.mk
