#!/bin/bash

#Queries for a useless fact and displays it in the output in plain text
curl \
  -H "Accept: text/plain" \
  -sLl "https://uselessfacts.jsph.pl/api/v2/facts/random?langauge=en" | cut -d ':' -f4 | cut -d '>' -f2
