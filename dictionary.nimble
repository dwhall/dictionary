# Package

version       = "0.1.0"
author        = "!!Dean"
description   = "English word dictionary tools"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]


# Dependencies

requires "nim >= 2.2.0"

requires "unittest2 >= 0.2.4"
requires "https://github.com/dwhall/cmd.nim#dwhMain"
