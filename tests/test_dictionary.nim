import unittest2

include dictionary

test "can index into a node's letter list via []":
  var root = DictNode()
  check root['a'] == nil

test "indexing a node with uppercase returns nil":
  var root = DictNode()
  check root['A'] == nil

test "indexing a node with non-letter returns nil":
  var root = DictNode()
  check root['!'] == nil

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

test "looking up a word that exists returns true":
  var root = DictNode()
  root.addWord("dog")
  check root.contains("dog")

test "can use the keyword 'in' to check if a word exists":
  var root = DictNode()
  root.addWord("elephant")
  check "elephant" in root
  check "tiger" notin root

test "search with a wildcard '_' as first letter works":
  var root = DictNode()
  root.addWord("cat")
  var wordList = root.search("_")
  check "cat" notin wordList
  wordList = root.search("_at")
  check "cat" in wordList

test "search with a wildcard '_' as last letter":
  var root = DictNode()
  root.addWord("cat")
  root.addWord("dog")
  root.addWord("cartoon")
  let wordList = root.search("ca_")
  check "cat" in wordList
  check "dog" notin wordList
  check "cartoon" notin wordList

test "search can find more than one word":
  var root = DictNode()
  root.addWord("cat")
  root.addWord("car")
  root.addWord("cartoon")
  let wordList = root.search("ca_")
  check "cat" in wordList
  check "car" in wordList
  check "cartoon" notin wordList

test "search with a wildcard '_' in middle position works":
  var root = DictNode()
  root.addWord("cat")
  root.addWord("cot")
  root.addWord("cut")
  root.addWord("cart")
  let wordList = root.search("c_t")
  check "cat" in wordList
  check "cot" in wordList
  check "cut" in wordList
  check "cart" notin wordList
  check "catt" notin wordList

test "search with empty search pattern returns no matches":
  var root = DictNode()
  root.addWord("cat")
  let wordList = root.search("")
  check wordList.len == 0

test "search will not give results containing letters already in the pattern":
  var root = DictNode()
  root.addWord("call")
  root.addWord("hall")
  root.addWord("half")
  let wordList = root.search("_al_")
  check "call" notin wordList
  check "hall" notin wordList
  check "half" in wordList

#test "can serialize a dictionary to a string":
#  var root = DictNode()
#  root.addWord("cats")
#  #root.addWord("car")
#  #root.addWord("cat")
#  #root.addWord("catatonic")
#  echo root.marshal # == "{c d}"  # DWH: nim serialization to JSON?
