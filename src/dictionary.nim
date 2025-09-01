import std/[os, paths, sequtils, strformat, strutils]

import cmd

const appFolder = "dictionary_en"
const appDataDir = getEnv("LOCALAPPDATA") / appFolder

type
  DictNode = ref object
    letters: array['a'..'z', DictNode]
    isWord: bool

proc `[]`(node: DictNode, c: char): DictNode {.inline.} =
  if c notin LowercaseLetters:
    raise newException(IndexDefect, "Character out of range.  Expecting lowercase.")
  node.letters[c]

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
    if n.letters[c] == nil:
      let newNode = DictNode()
      n.letters[c] = newNode
      n = newNode
    else:
      n = n.letters[c]
  n.isWord = true

proc addWordsFromFile(root: DictNode, fn: string): int =
  for line in lines(fn):
    let word = line.strip()
    root.addWord(word)
    inc result

proc addWordsFromBuiltinFiles(root: DictNode): int =
  let cwd = paths.getCurrentDir().string
  let builtinWordFiles = ["4160offi.cia", "113809of.fic"]
  for fn in builtinWordFiles:
    let fullPath = cwd / "resources" / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count} words added from {fn}"
    result += count

proc main =
  var root = DictNode()

  proc loadCommand(ctx: var CmdPrompt, input: seq[string]) =
    if input.len != 1: return
    let fn = input[0]
    let cwd = paths.getCurrentDir().string
    let fullPath = cwd / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count}words added from {fn}"

  discard root.addWordsFromBuiltinFiles()
  let loadCmd = Command(name: "load", desc: "Loads a word file into the dictionary", exeCmd: loadCommand)
  var prompt = newCmdPrompt(promptString="dict> ", commands=[loadCmd,])
  prompt.run()

when isMainModule:
  main()

# TODO: store the dictionary to a file and load it back
