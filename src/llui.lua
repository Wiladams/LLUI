#!/usr/bin/env luajit

package.path = package.path..";core/?.lua"

local kernel = require("kernel")()

local app = dofile(arg[1])
