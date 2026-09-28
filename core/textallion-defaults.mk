# Default tools used by core/textallion-common.mk and core/textallion-cyoa.mk.
#
# Every value here uses "?=", so it is only a default: it can be overridden
# per-project (set it again, after the "include", in the project's makefile
# or in a local.mk it includes) or once for every project of this machine, in
# ~/.config/textallion/config.mk (read at the end of this file).
#
# This file is meant to be included once, from core/textallion-common.mk.

PDFREADER ?= xdg-open
EPUBREADER ?= ebook-viewer
HTMLREADER ?= firefox
DIFFTOOL ?= meld
RENPY ?= /opt/renpy/renpy.sh
BROWSER ?= xdg-open
PYTHONVER ?= python3
TYPST ?= typst

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
  EDITTOOL ?= open
  BROWSER ?= open
else
  EDITTOOL ?= geany
# EDITTOOL ?= gvim
# EDITTOOL ?= vim
# EDITTOOL ?= nano
# EDITTOOL ?= SciTE
endif

# user-wide overrides, read last so they win over the defaults above (but a
# value already set by the project's own makefile still wins over this file,
# since "?=" never replaces a variable that is already defined)
-include $(HOME)/.config/textallion/config.mk
