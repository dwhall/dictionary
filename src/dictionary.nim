import std/[sequtils, strutils, sugar, tables]

type
  LowercaseLetter = 'a' .. 'z'
  DictNode* = ref object
    letters: Table[LowercaseLetter, DictNode]
    isWord: bool

func parseSearchArgs(args: seq[string]): Table[string, string]

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

func search*(dict: DictNode, args: seq[string]): seq[string] =
  ## Searches the dictionary for words matching the given pattern.
  ## The pattern may include '_' as a wildcard character that matches any letter.
  ## Returns a sequence of matching words.
  var matches: seq[string] = @[]
  let searchArgs = parseSearchArgs(args)
  let pattern = searchArgs["pattern"]

  # If a lower bound is specified, limit the search space for the first letter
  var searchFirstLetters = unusedLetters(pattern)
  if ">" in searchArgs:
    let lowerBound = searchArgs[">"][0]
    if lowerBound in LowercaseLetters:
      for c in 'a' .. lowerBound:
        searchFirstLetters.excl(c)

  # Closure so that 'matches', 'pattern' and 'searchFirstLetters' are captured
  proc searchRecursively(node: DictNode, patternIdx: int, prefix: string) =
    if patternIdx >= pattern.len:
      if node.isWord:
        matches.add(prefix)
      return

    let searchLetters =
      if patternIdx == 0:
        searchFirstLetters
      else:
        unusedLetters(searchArgs["pattern"])

    let firstChar = pattern[patternIdx]

    if firstChar == '_':
      # Try all possible letters for wildcard
      for c in searchLetters:
        if c in node.letters:
          searchRecursively(node.letters[c], patternIdx + 1, prefix & $c)
    else:
      # Match exact letter
      if firstChar in node.letters:
        searchRecursively(node.letters[firstChar], patternIdx + 1, prefix & $firstChar)

  if pattern.len > 0:
    searchRecursively(dict, 0, "")
  return matches

func search*(dict: DictNode, args: string): seq[string] =
  search(dict, @[args])

func parseSearchArgs(args: seq[string]): Table[string, string] =
  ## Returns an args table built from expected patterns.
  result = initTable[string, string]()
  result["pattern"] = args[0].strip()
  for part in args[1 ..^ 1]:
    let trimmed = part.strip
    if trimmed[0] == '>':
      if trimmed.len == 2:
        result[">"] = trimmed[1 ..^ 1]

