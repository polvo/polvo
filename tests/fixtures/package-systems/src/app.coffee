# NPM
# ------------------------------------------------------------------------------

# global module require for npm module 
_ = require 'somelib'

# relative module require for npm module 
_2 = require '../node_modules/somelib'

# global module require for mapped folder
a = require 'mod'

# global in-folder require for mapped folder
b = require 'mod/lib'

# global in-file require for mapped folder
c = require 'mod/lib/file'

# relative require for index file inside a folder
d = require './folder-index'

# relative require for npm module inside a folder
e = require './local-mod'

# relative require for npm module inside a folder
f = require './local-mod-folder'
g = require './local-mod-folder/none'

# relative require for npm module inside a folder, without `main`
# entry in package.json
h = require './local-mod-no-main'

# non existent calls
i = require 'non-existent-a'
j = require './non-existent-b'
l = require 'mod/non-existent'


# COMPONENT
# ------------------------------------------------------------------------------
calendar = require 'calendar'

# BOWER
# ------------------------------------------------------------------------------
stringify = require 'stringify-object'