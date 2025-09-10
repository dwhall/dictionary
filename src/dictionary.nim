import std/[sequtils, strutils, sugar, tables]

type
  LowercaseLetter = 'a' .. 'z'
  DictNode* = ref object
    letters: Table[LowercaseLetter, DictNode]
    isWord: bool

func hasOnlyLowercaseLetters(word: string): bool =
  all(word, (c) => c in LowercaseLetters)

proc `[]`(node: DictNode, c: char): DictNode {.inline.} =
  ## Returns the child node for the given letter, or nil if it doesn't exist.
  if c notin LowercaseLetters:
    return nil
  if c.LowercaseLetter notin node.letters:
    return nil
  node.letters[c.LowercaseLetter]

proc addWord(dict: DictNode, word: string) =
  ## Adds a word to the dictionary.
  let lowerWord = word.toLower
  if not hasOnlyLowercaseLetters(lowerWord):
    return
  var n = dict
  for c in lowerWord:
    if c notin n.letters:
      n.letters[c] = DictNode()
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

func unusedLetters(usedLetters: string): set[char] =
  result = LowercaseLetters
  for c in usedLetters:
    result.excl(c)

func search*(dict: DictNode, pattern: string): seq[string] =
  ## Searches the dictionary for words matching the given pattern.
  ## The pattern may include '_' as a wildcard character that matches any letter.
  ## Returns a sequence of matching words.
  var matches: seq[string] = @[]
  let searchLetters = unusedLetters(pattern)

  # Closure so that 'matches' and 'searchLetters' are captured
  proc searchRecursively(node: DictNode, pattern: string, prefix: string) =
    if pattern.len == 0:
      if node.isWord:
        matches.add(prefix)
      return

    let firstChar = pattern[0]
    let restPattern = pattern[1 ..^ 1]

    if firstChar == '_':
      # Try all possible letters for wildcard
      for c in searchLetters:
        if c in node.letters:
          searchRecursively(node.letters[c], restPattern, prefix & $c)
    else:
      # Match exact letter
      if firstChar in node.letters:
        searchRecursively(node.letters[firstChar], restPattern, prefix & $firstChar)

  if pattern.len > 0:
    searchRecursively(dict, pattern.toLower, "")
  return matches
