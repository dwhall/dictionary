import std/[os, paths, strformat]
import cmd
import dictionary

proc addWordsFromBuiltinFiles(root: DictNode)

proc main =
  var root = DictNode()
  root.addWordsFromBuiltinFiles()

  # a closure so that 'root' is captured
  proc loadCommand(ctx: var CmdPrompt, input: seq[string]) =
    ## Expects exactly one argument, the filename, in input.
    ## Loads the words from the file into the dictionary, root.
    if input.len != 1:
      echo "Expected exactly one argument, <filename>"
      return
    let fn = input[0]
    if not fileExists(fn):
      echo &"File \"{fn}\" does not exist"
      return
    let cwd = paths.getCurrentDir().string
    let fullPath = cwd / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count}words added from {fn}"

  let loadCmd = Command(name: "load", desc: "Loads a word file into the dictionary", exeCmd: loadCommand)
  var prompt = newCmdPrompt(promptString="dict> ", commands=[loadCmd,])
  prompt.run()

proc addWordsFromBuiltinFiles(root: DictNode) =
  echo "Loading built-in word files..."
  let cwd = paths.getCurrentDir().string
  let builtinWordFiles = ["4160offi.cia", "113809of.fic"]
  for fn in builtinWordFiles:
    let fullPath = cwd / "resources" / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count} words added from {fn}"
  echo "Ready."

when isMainModule:
  main()
