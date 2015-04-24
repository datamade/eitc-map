# From http://clarkgrubb.com/makefile-style-guide#prologue
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Variables specific to this build
PG_HOST="localhost"
PG_USER="derekeder"
PG_DB="eitc"
PG_PORT="5432"
