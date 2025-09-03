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
  if c notin LowercaseLetters:
    return nil
  if c.toLowercaseLetter notin node.letters:
    return nil
  node.letters[c.toLowercaseLetter]

proc `$`(node: DictNode): string =
  if node == nil:
    return "nil"
  result = "{"
  for c in 'a'..'z':
    if node[c] != nil:
      if result.len > 1:
        result.add(" ")
      result.add(c)
  result.add("}")

proc addWord(node: DictNode, word: string) =
  let lowerWord = word.toLower
  if not all(lowerWord, proc(c:char): bool = c in LowercaseLetters):
    raise newException(ValueError, "Word contains non-letter characters.")
  var n = node
  for c in lowerWord:
    if c notin n.letters:
      let newNode = DictNode()
      n.letters[c] = newNode
    n = n.letters[c]
  n.isWord = true

proc addWordsFromFile*(root: DictNode, fn: string): int =
  for line in lines(fn):
    let word = line.strip()
    root.addWord(word)
    inc result

proc contains*(root: DictNode, word: string): bool =
  let lowerWord = word.toLower
  if not all(lowerWord, proc(c:char): bool = c in LowercaseLetters):
    return false
  var n = root
  for c in lowerWord:
    if n[c] == nil:
      return false
    n = n[c]
  return n.isWord

#proc marshal*(node: DictNode): string =
#  $$node

# TODO: store the dictionary to a file via:
# * serialize the dict to a string
# * write the string to a file
# and the reverse
