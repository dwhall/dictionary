import std/[os, paths, strformat]
import cmd
import dictionary

proc addWordsFromBuiltinFiles(dict: DictNode)

proc main() =
  var dict = DictNode()
  dict.addWordsFromBuiltinFiles()

  # a closure so that 'dict' is captured
  proc loadCommand(ctx: var CmdPrompt, input: seq[string]) =
    ## Expects exactly one argument, the filename, in input.
    ## Loads the words from the file into the dict.
    if input.len != 1:
      echo "Expected exactly one argument, <filename>"
      return
    let fn = input[0]
    if not fileExists(fn):
      echo &"File \"{fn}\" does not exist"
      return
    let cwd = paths.getCurrentDir().string
    let fullPath = cwd / fn
    let count = dict.addWordsFromFile(fullPath)
    echo &"{count}words added from {fn}"

  proc searchCommand(ctx: var CmdPrompt, input: seq[string]) =
    ## Expects exactly one argument, the word pattern to search for.
    ## Searches the dictionary for matching words.
    if input.len != 1:
      echo "Expected exactly one argument, <word pattern>"
      return
    let pattern = input[0]
    let matches = dict.search(pattern)
    if matches.len == 0:
      echo "No matches found"
    else:
      echo &"Found {matches.len} matches:"
      for word in matches:
        echo word

  let loadCmd = Command(
    name: "load", desc: "Loads a word file into the dictionary", exeCmd: loadCommand
  )
  let searchCmd = Command(
    name: "search", desc: "Searches for words matching a pattern", exeCmd: searchCommand
  )
  var prompt = newCmdPrompt(promptString = "dict> ", commands = [loadCmd, searchCmd])
  prompt.run()

proc addWordsFromBuiltinFiles(dict: DictNode) =
  echo "Loading built-in word files..."
  let cwd = paths.getCurrentDir().string
  let builtinWordFiles = ["4160offi.cia", "113809of.fic"]
  for fn in builtinWordFiles:
    let fullPath = cwd / "resources" / fn
    let count = dict.addWordsFromFile(fullPath)
    echo &"{count} words added from {fn}"
  echo "Ready."

when isMainModule:
  main()
