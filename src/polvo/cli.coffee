module.exports = class Cli

  # requires
  optimist = require 'optimist'

  constructor:->
    usage = "#{'Polvo'.bold}\n"
    usage += "  Ambitious build system.\n\n".grey
    
    usage += "#{'Usage:'}\n"
    usage += "  polvo [#{'options'.green}] [#{'path'.green}]\n\n"
    
    usage += "#{'Examples:'}\n"
    # usage += "  polvo -n myawsomeapp   (#{'required'.red})\n"
    # usage += "  polvo -i [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -c [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -cs [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -w [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -ws [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -r [myawsomeapp] (#{'optional'.green})\n"
    usage += "  polvo -rs [myawsomeapp] (#{'optional'.green})\n"

    @argv = (@opts = optimist.usage( usage )
      # .alias('n', 'new')
      # .describe('n', "Scaffold a very basic new App.")
      
      # .alias('i', 'init')
      # .describe('i', "Create a config (polvo.coffee) file for existing projects.")
      
      .alias('w', 'watch')
      .describe('w', "Start watching/compiling in dev mode.")
      
      .alias('c', 'compile')
      .describe('c', "Compile project in development mode.")

      .alias('r', 'release')
      .describe('r', "Compile project in release mode.")

      .alias('s', 'server')
      .describe('s', "Serves project statically, options in config file.")

      # .alias('a', 'autorun')
      # .describe('a', 'Execute the script in node.js after compilation.')

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