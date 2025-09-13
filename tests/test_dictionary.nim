import unittest2

include dictionary

test "can index into a node's letter list via []":
  var node = DictNode()
  check node['a'] == nil

test "indexing a node with uppercase returns nil":
  var node = DictNode()
  check node['A'] == nil

test "indexing a node with non-letter returns nil":
  var node = DictNode()
  check node['!'] == nil

test "adding one letter word":
  var dict = DictNode()
  dict.addWord("z")
  check dict['z'] != nil

test "adding multi-letter word":
  var dict = DictNode()
  dict.addWord("cat")
  check dict['c'] != nil
  check dict['c']['a'] != nil
  check dict['c']['a']['t'] != nil
  check dict['c']['a']['t'].isWord

test "adding a duplicate word":
  var dict = DictNode()
  dict.addWord("cat")
  dict.addWord("cat")
  check dict['c'] != nil
  check dict['c']['a'] != nil
  check dict['c']['a']['t'] != nil
  check dict['c']['a']['t'].isWord

test "adding a word that is a prefix of an existing word doesn't eliminate the existing word":
  var dict = DictNode()
  dict.addWord("cats")
  dict.addWord("cat")
  check dict['c']['a']['t']['s'] != nil
  check dict['c']['a']['t']['s'].isWord

test "adding a word with uppercase letters adds the lowercased word":
  var dict = DictNode()
  dict.addWord("heLL")
  check dict['h']['e']['l']['l'].isWord

test "looking up a word that exists returns true":
  var dict = DictNode()
  dict.addWord("dog")
  check dict.contains("dog")

test "can use the keyword 'in' to check if a word exists":
  var dict = DictNode()
  dict.addWord("elephant")
  check "elephant" in dict
  check "tiger" notin dict

test "search with a wildcard '_' as first letter works":
  var dict = DictNode()
  dict.addWord("cat")
  var wordList = dict.search("_")
  check "cat" notin wordList
  wordList = dict.search("_at")
  check "cat" in wordList

test "search with a wildcard '_' as last letter":
  var dict = DictNode()
  dict.addWord("cat")
  dict.addWord("dog")
  dict.addWord("cartoon")
  let wordList = dict.search("ca_")
  check "cat" in wordList
  check "dog" notin wordList
  check "cartoon" notin wordList

test "search can find more than one word":
  var dict = DictNode()
  dict.addWord("cat")
  dict.addWord("car")
  dict.addWord("cartoon")
  let wordList = dict.search("ca_")
  check "cat" in wordList
  check "car" in wordList
  check "cartoon" notin wordList

test "search with a wildcard '_' in middle position works":
  var dict = DictNode()
  dict.addWord("cat")
  dict.addWord("cot")
  dict.addWord("cut")
  dict.addWord("cart")
  let wordList = dict.search("c_t")
  check "cat" in wordList
  check "cot" in wordList
  check "cut" in wordList
  check "cart" notin wordList
  check "catt" notin wordList

test "search with empty search pattern returns no matches":
  var dict = DictNode()
  dict.addWord("cat")
  let wordList = dict.search("")
  check wordList.len == 0

test "search will not give results containing letters already in the pattern":
  var dict = DictNode()
  dict.addWord("call")
  dict.addWord("hall")
  dict.addWord("half")
  let wordList = dict.search("_al_")
  check "call" notin wordList
  check "hall" notin wordList
  check "half" in wordList

test "search with a lower bound limits the word list":
  var dict = DictNode()
  dict.addWord("axe")
  dict.addWord("bat")
  dict.addWord("car")
  let wordList = dict.search(@["___", ">b"])
  check "axe" notin wordList
  check "bat" notin wordList
  check "car" in wordList

test "search with a lower bound that comes after the first character in the pattern returns an empty result":
  var dict = DictNode()
  dict.addWord("axe")
  dict.addWord("bat")
  dict.addWord("car")
  let wordList = dict.search(@["a__", ">b"])
  check wordList.len == 0

test "search with an upper bound limits the word list":
  var dict = DictNode()
  dict.addWord("axe")
  dict.addWord("bat")
  dict.addWord("car")
  let wordList = dict.search(@["___", "<b"])
  check "axe" in wordList
  check "bat" notin wordList
  check "car" notin wordList

test "search with an upper bound that comes before the first character in the pattern returns an empty result":
  var dict = DictNode()
  dict.addWord("axe")
  dict.addWord("bat")
  dict.addWord("car")
  let wordList = dict.search(@["c__", "<b"])
  check wordList.len == 0

test "search with an upper and lower bound limits the word list":
  var dict = DictNode()
  dict.addWord("axe")
  dict.addWord("bat")
  dict.addWord("car")
  let wordList = dict.search(@["___", ">a", "<c"])
  check "axe" notin wordList
  check "bat" in wordList
  check "car" notin wordList

test "search with certain letters restricted for all positions":
  var dict = DictNode()
  dict.addWord("cat")
  dict.addWord("bat")
  dict.addWord("rat")
  dict.addWord("hat")
  let wordList = dict.search(@["___", "-bcz"])
  check "cat" notin wordList
  check "bat" notin wordList
  check "rat" in wordList
  check "hat" in wordList

test "search with a trailing space should not cause an exception":
  var dict = DictNode()
  dict.addWord("cat")
  let wordList = dict.search(@["_at", " "])
  check wordList.len == 1

#test "can serialize a dictionary to a string":
#  var dict = DictNode()
#  dict.addWord("cats")
#  #dict.addWord("car")
#  #dict.addWord("cat")
#  #dict.addWord("catatonic")
#  echo dict.marshal # == "{c d}"  # DWH: nim serialization to JSON?
