import unittest2

include dictionary

test "can index into a node's letter list via []":
  var root = DictNode()
  check root['a'] == nil

test "indexing a node with uppercase raises an exception":
  var root = DictNode()
  expect IndexDefect:
    discard root['A']

test "indexing a node with non-letter raises an exception":
  var root = DictNode()
  expect IndexDefect:
    discard root['!']

test "adding one letter word":
  var root = DictNode()
  root.addWord("z")
  check root['z'] != nil

test "adding multi-letter word":
  var root = DictNode()
  root.addWord("cat")
  check root['c'] != nil
  check root['c']['a'] != nil
  check root['c']['a']['t'] != nil
  check root['c']['a']['t'].isWord

test "adding a duplicate word":
  var root = DictNode()
  root.addWord("cat")
  root.addWord("cat")
  check root['c'] != nil
  check root['c']['a'] != nil
  check root['c']['a']['t'] != nil
  check root['c']['a']['t'].isWord

test "adding a word that is a prefix of an existing word doesn't eliminate the existing word":
  var root = DictNode()
  root.addWord("cats")
  root.addWord("cat")
  check root['c']['a']['t']['s'] != nil
  check root['c']['a']['t']['s'].isWord

test "adding a word with uppercase letters adds the lowercased word":
  var root = DictNode()
  root.addWord("heLL")
  check root['h']['e']['l']['l'].isWord
