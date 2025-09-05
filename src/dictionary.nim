import std/[os, sequtils, strutils, tables]

const appFolder = "dictionary_en"
const appDataDir = getEnv("LOCALAPPDATA") / appFolder

type
  LowercaseLetter = 'a'..'z'
  DictNode* = ref object
    letters: Table[LowercaseLetter, DictNode]
    isWord: bool

converter toLowercaseLetter*(c: char): LowercaseLetter =
  LowercaseLetter(c)

proc `[]`(node: DictNode, c: char): DictNode {.inline.} =
  ## Returns the child node for the given letter, or nil if it doesn't exist.
  if c notin LowercaseLetters:
    return nil
  if c.toLowercaseLetter notin node.letters:
    return nil
  node.letters[c.toLowercaseLetter]

proc addWord(dict: DictNode, word: string) =
  ## Adds a word to the dictionary.
  let lowerWord = word.toLower
  if not all(lowerWord, proc(c:char): bool = c in LowercaseLetters):
    raise newException(ValueError, "Word contains non-letter characters.")
  var n = dict
  for c in lowerWord:
    if c notin n.letters:
      let newNode = DictNode()
      n.letters[c] = newNode
    n = n.letters[c]
  n.isWord = true

proc addWordsFromFile*(dict: DictNode, fn: string): int =
  ## Adds words from a file to the dictionary.
  ## Returns the number of words added.
  # Expects the file to have one word per line.
  for line in lines(fn):
    let word = line.strip()
    dict.addWord(word)
    inc result

proc contains*(dict: DictNode, word: string): bool =
  ## Returns true if the word exists in dict.
  let lowerWord = word.toLower
  if not all(lowerWord, proc(c:char): bool = c in LowercaseLetters):
    return false
  var n = dict
  for c in lowerWord:
    if n[c] == nil:
      return false
    n = n[c]
  return n.isWord


