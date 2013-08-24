# Polvo

Polyvalent cephalopod mollusc.

[![Stories in Ready](https://badge.waffle.io/polvo/polvo.png)](http://waffle.io/polvo/polvo)

[![Build Status](https://secure.travis-ci.org/polvo/polvo.png)](http://travis-ci.org/polvo/polvo) [![Dependency Status](https://gemnasium.com/polvo/polvo.png)](https://gemnasium.com/polvo/polvo) [![NPM version](https://badge.fury.io/js/polvo.png)](http://badge.fury.io/js/polvo)

# What the ★★★★?

Polvo is an application assembler for the browser.

You can think of Polvo as a mix of
[Browserify](https://github.com/substack/node-browserify) and
[Brunch](https://github.com/brunch/brunch).

 * `Browserify` assembles all your local requires for in-browser use.
   * **Polvo** do it as well.
 * `Brunch` assembles all your `scripts`, `templates` and `styles` for multiple
 languages with a miminal config file compared to other tools such as
 [Grunt](https://github.com/gruntjs/grunt).
   * **Polvo's** config file is *truly* minimalistic - given the local approach
   borrowed from `Browserify`, it is very simple and intuitive.

> Polvo is not a replacement for any of these tools (even it may be), but an
alternative that combines some of their features, which you won't find bundled
together as it is provided here.

# TL;DR

Tired of reading? Watch the [screencast](#screencast).

> Screencast screenshot here with link.

# Docs

 - [Philosophy](#philosophy-in-short)
 - [Features](#features)
 - [Dependency Resolution](#dependency-resolution)
 - [Packaging Systems](#packaging-systems)
 - [Plugins](#plugins-supported-languages)
   - [Built in](#built-in-plugins)
 - [Config file](#config)
   - [server](#server)
   - [input](#input)
   - [output](#output)
   - [aliases](#aliases)
   - [minify](#minify)
   - [boot](#boot)
 - [CLI](#cli)
 - [Examples](#examples)
 - [Stability](#stability)
 - [History](#history)

# Philosophy (in short)

 1. Your `scripts` and templates becomes all one `javascript`, and your `styles`
 becomes one `css`
 
 1. Both `scripts` and `templates` are wrapped as CJS modules and thus can be
 required usually as you'd do in NodeJS - `require('../path/to/my/file')`
 
 1. You end up with 2 files, `app.js` and `app.css`
 
Included both in your `html` and you're done!

# Features
 * Simple embeded webserver for *Single Page Applications*
 * Live Reload when developing
 * Live syntax-check for everything
 * Watch'n'compile in `development` mode
 * Automatic compression in `release` mode
 * SourceMaps support

<!-- * Vendors management-->
<!-- * Source Maps *(`coffeescript` only)*-->
<!-- * Broken and circular-loop dependencies validation-->
<!-- * Growl support for notifications-->
<!-- * ~~Scaffolding routines~~-->

# Dependency Resolution

Polvo uses the same resolution algorithm presented in NodeJS, so you can code
your libraries doing global or local requires as you wish, like you were
building a NodeJS app. In the end, everything will be ready for in-browser use.

> Of couse, you won't be able to use NodeJS core modules once inside the
Browser, such as `fs`, `process`, `cluster` and so on.

# Packaging Systems

In order not to lock you with one single packaging system, Polvo is intended to
support them all. It's not fully functional yet, but at the moment you can use:

 * NPM (fully supported)
 * Bower (through local/relative `require` calls only)
 * ~~Components~~ (yet to be done)
 * ~~Ender~~ (yet to be done)

# Plugins (supported languages)

Polvo is agnostic to languages, however it needs plugins for each one ir onder
to properly assemble it. Some of them is built in out of the box, and others
should be done / installed separately.

Polvo will search and initialize all plugins present in the `dependencies` field
of your `package.json` file.

## Built in plugins

Each plugin is an independent repository.

Click the links to see individual `README` for each one.

### ★ Scripts
 1. [Javascript](https://github.com/polvo/polvo-js) (`.js`)
 1. [CoffeeScript]((https://github.com/polvo/polvo-cs) (`.coffee`)
    * ✓ Literate Coffeescript (`.litcoffee`, `.coffee.md`)
    * ✓ Source Maps

### ★ Styles
 1. [CSS](https://github.com/polvo/polvo-css) (`.css`)
     * ✓ `partials` supported
 1. [Stylus](https://github.com/polvo/polvo-stylus) (`.styl`)
     * ✓ `nib` available
     * ✓ `partials` supported

### ★ Templates
 1. [HTML](https://github.com/polvo/polvo-html) (`.htm`, `.html`)
    * ✓ `partials` supported
 1. [Jade](https://github.com/polvo/polvo-jade) (`.jade`)
    * ✓ `partials` supported

# Config

A Polvo's complete config file will look such as:

## polvo.yml

````yaml
server:
  port: 3000
  root: ./public

input:
  - src

output:
  js: ./public/app.js
  css: ./public/app.css

aliases:
  app: src/

minify:
  js: false
  css: false

boot: src/app/app
````

### Server

Basic infos to serve your application, just inform desired port and your
`public` folder.

When using the option `-s` a basic webserver will be launched to serve the app.

### Input

Project's input `src` folders, can be one or many.

### Output

Project's output `files`, at least one should be specified.

### Aliases

Aliases is a handy option that lets you map some `names` to specific dirs. These
names will make folders act like modules.

For example, imagine a structure like this:

````
myapp
├── polvo.yml
├── src
│   └── app
│       ├── app.coffee
│       ├── controllers
│       │   └── controller.coffee
│       ├── models
│       │   └── model.coffee
│       └── views
│           └── views.coffee
└── vendors
    └── myframework
        └── src
            └── lib
                ├── controller.coffee
                ├── model.coffee
                └── view.coffee
````

The app's `controller.coffee` can require the framework's `controller.coffee`
as easy as:

````coffeescript
Controller = require '../../../vendors/myframework/src/lib/controller'
````

However, sometimes these relative paths can get nasty. In this cases, aliases
can help the way. Imagine this one:

````yml
alias:
  myframework: vendors/myframework/src
````

With this, `myframework` folder will act as if it was a NPM module present in
your `node_modules` folder, and `require` calls can be made in global-style
regardless of which file is requiring it:

````coffeescript
Controller = require 'myfraework/lib/controller'
````

Not that:

 1. The `myframework` keywork is our alias in the config file 
 1. It points to the folder `vendors/myframework/src`
 1. So requiring `myframewok/***` will be the same as requiring
 `vendors/myframework/src/***`

## Minify

In some cases you may want to disable minification in `release` mode, even tough
in both `development` and `release` mode you'll always have a single `.js` and
`.css` file.

So what's the catch?

In `development` mode other things will be injected among your scripts in the
`app.js` file. For example, the LiveReload embedded functionality.

In `release` mode it's removed, nothing special is injected. So you may want to
have a production ready `release` file (that doesn't includes magic), but at the
same time keep it uncompressed. In case you do, that's the way to go.

## Boot

By default, Polvo will wrap all your `scripts` and `templates` in CJS module
patterns, and register them all at startup. However, none will be required and
therefore none will be initialized.

You need to specify your app's entry point within the `boot` property. With this
Polvo will do a simple require to this file at startup, after everything is
registered.

Following the config presented above, it'd be:

````javascript
require( 'src/app/app' );
````

# CLI

Command line interface.

````
Usage:
  polvo [options] [params]

Options:
  -w, --watch        Start watching/compiling in dev mode             
  -c, --compile      Compile project in development mode              
  -r, --release      Compile project in release mode                  
  -s, --server       Serves project statically, options in config file
  -f, --config-file  Path to a different config file                  
  -v, --version      Show Polvo's version                             
  -h, --help         Shows this help screen                           

Examples:
  polvo -c
  polvo -cs
  polvo -w
  polvo -ws
  polvo -wsf custom-config-file-name.yml
````

# Examples

There's an `example-app` using all built in plugins.

  * [repo-link](…)

Live preview of this app.

  * [app-link](…)

# Satability?

Polvo is under heavy development, it's not bullet proof yet, but you can surely
use it. It's being used in production everyday. A properly test suite and
coverage analysys is on the way.

## History

> Polvo started as a natural evolution of
[Coffee Toaster](http://github.com/polvo/coffee-toaster) -- *a build system for
CoffeeScript*. As Toaster became too specific about CoffeeScript, Polvo comes
out to be a more inclusive build tool covering more languages around the same
goal.