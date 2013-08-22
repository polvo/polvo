# Polvo

Polyvalent cephalopod mollusc.

[![Stories in Ready](https://badge.waffle.io/polvo/polvo.png)](http://waffle.io/polvo/polvo)

[![Build Status](https://secure.travis-ci.org/polvo/polvo.png)](http://travis-ci.org/polvo/polvo) [![Dependency Status](https://gemnasium.com/polvo/polvo.png)](https://gemnasium.com/polvo/polvo) [![NPM version](https://badge.fury.io/js/polvo.png)](http://badge.fury.io/js/polvo)

# What the ★★★★?

Polvo is an application assembler for the browser.

You can think of Polvo as a mix of [Browserify](https://github.com/substack/node-browserify) / [OneJs](https://github.com/azer/onejs) and [Brunch](https://github.com/brunch/brunch).

 * `Browserify` and `OneJS` assembles all your local requires for in-browser use.
   * **Polvo** do it as well.
 * `Brunch` assembles all your `scripts`, `templates` and `styles` for multiple languages with a miminal config file compared to other tools such as [Grunt](https://github.com/gruntjs/grunt).
   * **Polvo's** config file is *truly* minimalistic - given the local approach borrowed from `Browserify` and `OneJs`, it is very simple and intuitive.

> Polvo is not a replacement for any of these tools (even it may be), but an alternative that combines some of their features, which you won't find bundled together as it is provided here.

# Dependency Resolution

Polvo uses the same resolution algorithm presented in NodeJS, so you can code your libraries doing global or local requires as you wish, like you were building a NodeJS app. In the end, everything will be ready for in-browser use.

> Of couse, you won't be able to use NodeJS core modules once inside the Browser, such as `fs`, `process`, `cluster` and so on.

# Packaging Systems

In order not to lock you with one single packaging system, Polvo is intended to support some of them:

 * NPM (fully supported)
 * Bower (through `local` - relative - requires only)
 * ~~Components~~ (yet to be done)
 * ~~Ender~~ (yet to be done)

# Speed?

Polvo is stupidly fast. *Seriously*.

First compilation will take some seconds depending on the size of your application, but subsequent changes (compiled in `watch` mode) *will happen in a blink*.

# Philosophy (in short)

 1.  You write code using CJS pattern signature for `scripts` and plain schemes according the syntax provided by your pre-compiled language of choice for *html*-`templates` and `styles`.
 
 1. You require your `scripts` and `templates` as common CJS modules, like you do in NodeJS.
 
 1. CSS (`app.css`) and JS (`app.js`) files should be included in your in your `html` file.
 
 1. You end up with a 2 files, `app.js` and `app.css` -  both can be easily optimized (compressed) as needed with the `-r` option.

# Plugins (supported languages)

Polvo is agnostic to languages, however it needs plugins for each one ir onder to properly assemble it. Some of them is built in out of the box, and others should be done / installed separately.

## Built in plugins

### ★ for Scripts
 1. Pure Javascript (`.js`)
 1. CoffeeScript (`.coffee`)
    * ✓ Literate Coffeescript (`.litcoffee`, `.coffee.md`)
    * ✓ Source Maps

### ★ for Styles
 1. Pure CSS (`.css`)
     * ✓ `partials` supported
 1. Stylus (`.styl`)
     * ✓ `nib` available
     * ✓ `partials` supported

### ★ for Templates
 1. Pure HTML (`.htm`, `.html`)
    * ✓ `partials` supported
 1. Jade (`.jade`)
    * ✓ `partials` supported

#### Repos

 * [https://github.com/polvo/polvo-html](https://github.com/polvo/polvo-html)
 * [https://github.com/polvo/polvo-jade](https://github.com/polvo/polvo-jade)
 * [https://github.com/polvo/polvo-stylus](https://github.com/polvo/polvo-stylus)
 * [https://github.com/polvo/polvo-css](https://github.com/polvo/polvo-css)
 * [https://github.com/polvo/polvo-js](https://github.com/polvo/polvo-js)
 * [https://github.com/polvo/polvo-cs](https://github.com/polvo/polvo-cs)

# Features
 * Simple embeded webserver for *Single Page Applications*
 * Live Reload when developing
 * Live syntax-check for everything
 * Watch'n'compile in `development` mode
 * Compression routine for everything in `release` mode

<!-- * Vendors management-->
<!-- * Source Maps *(`coffeescript` only)*-->
<!-- * Broken and circular-loop dependencies validation-->
<!-- * Growl support for notifications-->
<!-- * Minify support-->
<!-- * ~~Scaffolding routines~~-->

# Config

A Polvo's complete config file will look such as:

````yaml

# server configs
server:
  port: 3000
  root: ./public

# input folders
input:
  - src

# output files
output:
  js: ./public/app.js
  css: ./public/app.css

# optional mapping configs (default is none)
# mappings:
#   'app': 'src/'

# optional minify options  (default is true for both)
# minify:
#   js: false
#   css: false

# main file to initialize your program
boot: src/boot
````

# Help

````
Usage:
  polvo [options] [params]

Options:
  -w, --watch        Start watching/compiling in dev mode             
  -c, --compile      Compile project in development mode              
  -r, --release      Compile project in release mode                  
  -s, --server       Serves project statically, options in config file
  -C, --config-file  Path to a different config file                  
  -J, --config       Config file formatted as a json-string           
  -v, --version      Show Polvo's version                             
  -h, --help         Shows this help screen                           

Examples:
  polvo -c
  polvo -cs
  polvo -w
  polvo -ws
````

# Examples

Complete example-app using all built in plugins with a complete config file.

  * [repo-link](…)

Live preview of this app.

  * [app-link](…)

# Screencast

You can watch a quick screencast showing the basics here:
 
 * [video-link](…)


# Satability?

Polvo is under heavy development, it's not bullet proof yet, but you can surely
used as you will. A properly test suite and coverage analysys is on the way.


## History

> Polvo started as a natural evolution of [Coffee Toaster](http://github.com/polvo/coffee-toaster) -- *a build system for CoffeeScript*. As Toaster became too specific about CoffeeScript, Polvo comes out to be a more inclusive build tool covering more languages around the same goal.

> It is being used in production for about 2 years now (aug/2013), and besides some minimal bugs, it proves itself to be stable enough to be trusted.