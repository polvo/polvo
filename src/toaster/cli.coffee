module.exports = class Cli

  # requires
  optimist = require 'optimist'

  constructor:->
    usage = "#{'CoffeeToaster'.bold}\n"
    usage += "  Minimalist build system for CoffeeScript\n\n".grey
    
    usage += "#{'Usage:'}\n"
    usage += "  toaster [#{'options'.green}] [#{'path'.green}]\n\n"
    
    usage += "#{'Examples:'}\n"
    usage += "  toaster -n myawsomeapp   (#{'required'.red})\n"
    usage += "  toaster -i [myawsomeapp] (#{'optional'.green})\n"
    usage += "  toaster -c [myawsomeapp] (#{'optional'.green})\n"
    usage += "  toaster -w [myawsomeapp] (#{'optional'.green})\n"
    usage += "  toaster -wa [myawsomeapp] (#{'optional'.green})\n"

    @argv = (@opts = optimist.usage( usage )
      .alias('n', 'new')
      .describe('n', "Scaffold a very basic new App.")
      
      .alias('i', 'init')
      .describe('i', "Create a config (toaster.coffee) file for existing projects.")
      
      .alias('w', 'watch')
      .describe('w', "Start watching/compiling in dev mode.")
      
      .alias('c', 'compile')
      .describe('c', "Compile project in dev mode.")

      .alias('r', 'release')
      .describe('r', "Compile project in release mode.")

      .alias('s', 'server')
      .describe('s', "Serves project statically, options in config file.")

      .alias('a', 'autorun')
      .describe('a', 'Execute the script in node.js after compilation.')

      .alias('j', 'config')
      .string( 'j' )
      .describe('j', "Config file formatted as a json-string.")

      .alias( 'f', 'config-file' )
      .string( 'f' )
      .describe('f', "Path to a different config file.")

      .alias('v', 'version')
      .describe('v', '')

      .alias('h', 'help')
      .describe('h', '')
    ).argv