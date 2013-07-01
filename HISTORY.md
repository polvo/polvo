# Changelog

## 0.3.17 - 07/01/2013
* Simplifying whole test structure, updating testing libraries, fixing
everything, green sign

## 0.3.16 - 06/30/2013
* Upgrading outdated dependencies

## 0.3.15 - 06/30/2013
 * Addiong `stdio` flag, useful for libraries forking `polvo` as a child process

## 0.3.14 - 06/20/2013
 * Fixing dumb rush-written code (aka adding method params)
 * Adding `status.compiled` notification for parent processes

## 0.3.13 - 06/20/2013
 * Cleaning up all log messages
 * Handling `console.*` differently when running as a forked process
 * Adding notifications when running as forked process, to provide useful info
 to parent processes

## 0.3.12 - 06/18/2013
 * Adding almond to the party, using it instead of standard requirejs for
 optimized builds (saving some kbs)

## 0.3.11 - 06/10/2013
 * Adding approach for creating and applying dynamic styles tags in IE8

## 0.3.10 - 06/09/2013
 * Fixing critical error in `Optimizer.reorder` (don't know how things were
 working before, ask God)
 * Cleaning up a bunch of things in Optimizar

## 0.3.9 - 06/02/2013
 * Fixing indentation / apply of coffeescript files during compile.

## 0.3.8 - 05/31/2013
 * Fixing helpers merging routine with a simple line break (how did this never
 broken anything till now? oh my..)

## 0.3.7 - 05/31/2013
 * Detaching socket.io from polvo server in order to provide livereload across
 different applications running in different servers (rails for instance, etc)

## 0.3.6 - 05/23/2013
 * Fixing optimization routine for apps using multiple languages

## 0.3.5 - 05/23/2013
 * Fixing live reload to work across any machine or device viewing the app

## 0.3.4 - 05/17/2013
 * Dumb hotfix, publishing compiled file as src maps for `core/optimizer/loader`

## 0.3.3 - 05/15/2013
 * Fixing livereload approach for templates [[merging #4](https://github.com/serpentem/polvo/pull/4)]

## 0.3.2 - 05/08/2013
 * Fixing stupid engine version error in 'package.json'

## 0.3.1 - 05/08/2013
 * Fixing CSS live reload, removing the element first instead of just adding
 the changed one

## 0.3.0 - 05/08/2013
 * Handling partials dependency chain recursively.

## 0.2.9 - 05/08/2013
 * Fixing handling of newly created files
 * Adding properly handling for deleted files

## 0.2.8 - 05/07/2013
 * Properly handling partials (files starting with '_') for Stylus and Jade.
 * Upgrading 'chai' and 'uglify-js' dependencies.

## 0.2.7 - 04/26/2013
 * Removing postinstall routine in favor of greater compatibility.

## 0.2.6 - 04/23/2013
 * Fixing postinstall routine (works corss-platform)

## 0.2.5 - 04/22/2013
 * Handing 404 links
 * Automatically injecting helpers for the used compilers

## 0.2.4 - 04/21/2013
 * Upgrading jade dependency.

## 0.2.3 - 04/21/2013
 * Fixing post-install script
 * Improving builtin server for Single Page Applications

## 0.2.2 - 04/12/2013
 * Adding LiveReload for development mode

## 0.2.1 - 04/12/2013
 * Fixing lib version evaluation
 * Removing options not yet ready
 * Fixing memory leak with `source-map-support` for NodeJS

## 0.2.0 - 04/12/2013
 * Added Stylus support
 * Added Jade support
 * Added SourceMaps support for CoffeeScript
 * Added support for Literate CoffeeScript (files ending with `.coffee.md` and `.litcoffee`)

## 0.1.0 - 04/04/2013
 * Complete port of Coffee-Toaster to Polvo.


# Past forked Project

## 0.6.12 - **NEVER** - *Coffee-Toaster was discontinued*.
 * Fixing `Toaster.reset` when using Toaster as lib, initializing it with the
options hash.
 * Properly segmenting compilation and execution with more combinations using
different options combos.
 * Individualizing compile routines between `release` and `debug` versions.

## 0.6.11 - 12/29/2012
 * Listening for changes also in vendors
 * Adding autorun mode (-a) [closing[#56](https://github.com/serpentem/coffee-toaster/pull/56)] • Thanks to [Giacomo Trezzi](https://github.com/G3z)

## 0.6.10 - 12/24/2012
 * Fixing aliases again, now in Builder class

## 0.6.9 - 12/22/2012
 * Fixing path's evaluation also when aliases are in use

## 0.6.8 - 12/22/2012
 * Fixing path's evaluation for import directives

## 0.6.7 - 12/20/2012
 * Fixing custom config file evaluation

## 0.6.6 - 12/15/2012
 * Desmistifying conflicts betweeen Toaster and VIM [closing issue [#46](https://github.com/serpentem/coffee-toaster/issues/47)]
 * Making toaster cross-platform (Osx, Linux, Win7) [closing issues [#29](https://github.com/serpentem/coffee-toaster/issues/29) and [#30](https://github.com/serpentem/coffee-toaster/issues/30)]
 * Effectively restarting toaster after `toaster.coffee` file is edited.

## 0.6.5 - 11/27/2012
 * Fixing generators [closing issue [#46](https://github.com/serpentem/coffee-toaster/issues/46)]

## 0.6.4 - 11/18/2012
 * Adding test for initializing existent projects
 * Fixing GROWL icons path

## 0.6.3 - 07/01/2012
 * Fixing example 'package.' again (the zombie bug)
 * Fixing line number evaluation [closing issue [#26](http://github.com/serpentem/coffee-toaster/issues/26)]
 * Fixing 'c' / '--compile' option [closing issue [#27](http://github.com/serpentem/coffee-toaster/issues/27)]
 * Adding first test (finally)

## 0.6.2 - 06/25/2012
 * Fixing last upgrade in self-toasting system
 * Adjusting everything for self-toasting at version 0.6.2

## 0.6.1 - 06/16/2012
 * Adjusting everything for self-toasting at version 0.6.0
 * Fixing example package.json file that was broken npm installation

## 0.6.0 - 06/16/2012
 * Adding 'exclude' property to config file
 * Improving and fixing a bunch of things
 * Completely refactoring fs-util to improve it's usage and avoid memory-leak
 * Organizing single-folder and multi-folder examples
 * Standardizing API for javascript usage
 * Adding 'introspection' example with many javascript uses

## 0.5.5 - 04/19/2012
 * Config file was re-written to be more practical
 * Build routines removed in favor of simplicity
 * Multi-modules option is default now, without configuring anything
 * HTTP Folder property added to 'toaster.coffee' config file
 * Scaffolding routines improved according the design changes

## 0.5.0 - 04/12/2012
 * Packaging system completely revamped
 * Added some beauty to log messages
 * Growl integration implemented
 * Expose / Export aliases - export/expose your definitions to another scope
 * Minify support added
 * On/Off switches for:
  * Bare option to compile CoffeeScript with the 'bare' option
  * Packaging system
  * Minify

## 0.3.8 - 10/29/2011
 * Fixing bugs in generators
 * Fixing a bunch of small emergencial bugs

## 0.3.7 - 10/29/2011
 * Simplify config file syntax [feature done [#8](https://github.com/serpentem/coffee-toaster/issues/8)]
 * Adding buid routines [feature done [#9](https://github.com/serpentem/coffee-toaster/issues/9)]
 * Adding support for vendors across modules and build configs [feature [#10](https://github.com/serpentem/coffee-toaster/issues/10)]

## 0.3.6 - 10/25/2011
 * Critical bugfixes in the reorder routine
 * Optimizing architecture
 * Condensing src scructure

## 0.3.5 - 10/24/2011
 * Avoiding tmp files from being watched [closing issue [#4](http://github.com/serpentem/coffee-toaster/issues/4)]
 * Adding support for ordinary files again (with no class definitions inside)
 * Now all requirements must to be done based on filepath with slash<BR>
notation "foldera/folderb/filename"
 * Adding extra base class validation
 * Lots of improvements and bugfixes

## 0.3.0 - 10/16/2011
 * Refactoring entire Script class
 * Support for extends directive have been removed, now all dependencies<BR>
must be informed through '#<< package.name.ClassName'
 * Support for files without class declarations was (sadly) removed
 * Adding full package support automagically
 * Implementing wild-cards on requirements '#<< package.name.*'

## 0.2.2 - 10/02/2011
 * Starting tests implementation (using Vows BDD)
 * Implementing debug mode (-d --debug). Files are compiled individually<BR>
plus a boot file (toaster.js) file that will load everything in the right order.
 * Improving interactive processes to become good guessers
 * Adding support for file requirements based on 'a/b/c/filepath'<BR>
simultaneously with class requirements based in 'ClassName' notation (both<BR>
are case sensitive)
 * Bumping 'build/coffee-toaster' submodule to use tag 0.2.2 (level up)

## 0.2.1 - 09/22/2011
 * Implementing OptionParser (using Optimist)

## 0.2.0 - 09/18/2011
 * Tag 0.1.2 is now used as submodule in order to self-toast (aka manage<BR>
dependencies) of new versions of CoffeeToaster itself, starting from now
 * Refactoring everything, classes are now one per file, using dependency<BR>
directives from CoffeeToaster itself. From now on, things should evolve<BR>
a little easier.
 * Individualizing CoffeeScript handling
 * Starting plans for CoffeeKup and CoffeeCss support

## 0.1.2 - 09/17/2011
 * Fixing compilation method that was requiring coffee-script to be installed
 * Adding precise error handling
 * Checking circular dependency conflicts [closing issue [#2](http://github.com/serpentem/coffee-toaster/issues/2)]

## 0.1.1 - 09/16/2011
 * Adding basic error handling [closing issue [#1](http://github.com/serpentem/coffee-toaster/issues/1)]

## 0.1.0 - 09/11/2011
 * Scaffolding routine for new projects
 * Scaffolding routine for configuration file (toaster.coffee)
 * Dependency handlers:
  * Extends directive (class A extends B)
  * Include directive (#<< ClassNameA, ClassNameB..)
