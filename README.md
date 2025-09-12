# Dictionary

A CLI with a suite of English word dictionary tools.
Also: a toy project to help me practice programming in Nim.

## Status

Two words files are included and loaded into the Dictionary by default.
More word files can be loaded.
Searching with wildcards, and optional upper and lower boundaries is working.

## CLI commands:

* `load <filename>`: load a word file into the dict.
* `search <pattern> [>lowerBound][<upperBound]`: list all words that match the pattern.
        lowerBound and upperBound are single characters.
