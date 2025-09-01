import std/[os, paths, strformat]
import cmd
import dictionary

proc addWordsFromBuiltinFiles(root: DictNode) =
  let cwd = paths.getCurrentDir().string
  let builtinWordFiles = ["4160offi.cia", "113809of.fic"]
  for fn in builtinWordFiles:
    let fullPath = cwd / "resources" / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count} words added from {fn}"

proc main =
  var root = DictNode()

  proc loadCommand(ctx: var CmdPrompt, input: seq[string]) =
    if input.len != 1: return
    let fn = input[0]
    if not fileExists(fn):
      echo &"File \"{fn}\" does not exist"
      return
    let cwd = paths.getCurrentDir().string
    let fullPath = cwd / fn
    let count = root.addWordsFromFile(fullPath)
    echo &"{count}words added from {fn}"

  root.addWordsFromBuiltinFiles()
  let loadCmd = Command(name: "load", desc: "Loads a word file into the dictionary", exeCmd: loadCommand)
  var prompt = newCmdPrompt(promptString="dict> ", commands=[loadCmd,])
  prompt.run()

when isMainModule:
  main()
