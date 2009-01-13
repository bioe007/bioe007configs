#!/bin/bash
GBASE='http://www.google.com/search?q='
SEL="$(xsel -p -o)"
GSFX='&ie=UTF-8&oe=UTF-8'

FULLSRCH="${GBASE}${SEL}${GSFX}"

firefox "$FULLSRCH"
