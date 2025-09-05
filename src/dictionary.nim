import std/[sequtils, strutils, sugar, tables]

type
  LowercaseLetter = 'a'..'z'
  DictNode* = ref object
    letters: Table[LowercaseLetter, DictNode]
    isWord: bool

converter toLowercaseLetter*(c: char): LowercaseLetter =
  LowercaseLetter(c)

func hasOnlyLowercaseLetters(word: string): bool =
  all(word, (c) => c in LowercaseLetters)

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
  if not hasOnlyLowercaseLetters(lowerWord):
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

func contains*(dict: DictNode, word: string): bool =
  ## Returns true if the word exists in dict.
  let lowerWord = word.toLower
  if not hasOnlyLowercaseLetters(lowerWord):
    return false
  var n = dict
  for c in lowerWord:
    if n[c] == nil:
      return false
    n = n[c]
  return n.isWord

func search*(dict: DictNode, pattern: string): seq[string] =
  ## Searches the dictionary for words matching the given pattern.
  ## The pattern may include '_' as a wildcard character that matches any letter.
  ## Returns a sequence of matching words.
  var matches: seq[string] = @[]
  if pattern.len == 0:
    return

  proc searchHelper(node: DictNode, pattern: string, prefix: string) =
    if pattern.len == 0:
      if node.isWord:
        matches.add(prefix)
      return

    let firstChar = pattern[0]
    let restPattern = pattern[1..^1]

    if firstChar == '_':
      # Try all possible letters for wildcard
      for c in 'a'..'z':
        if c in node.letters:
          searchHelper(node.letters[c], restPattern, prefix & $c)
    else:
      # Match exact letter
      if firstChar in node.letters:
        searchHelper(node.letters[firstChar], restPattern, prefix & $firstChar)

  searchHelper(dict, pattern.toLower, "")
  return matches
