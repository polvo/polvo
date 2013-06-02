# Polvo

Polyvalent cephalopod mollusc.

> Version 0.3.9

[![Build Status](https://secure.travis-ci.org/serpentem/polvo.png)](http://travis-ci.org/serpentem/polvo) [![Dependency Status](https://gemnasium.com/serpentem/polvo.png)](https://gemnasium.com/serpentem/polvo)

# What the ★★★★?

Polvo is an application assembler for the browser.

 1.  You write code using CJS signature for `scripts` and plain schemes according the syntax provided by your pre-compiled language of choice for *html*-`templates` and `styles`.

 1. Polvo will compile everything to *`.js`* files as AMD modules, *including your styles*.

 1. You can require all your **scripts**, **templates** and **styles** using CJS require's.
 
 1. You end up with a 100% modular application that can be easily optimized as needed.

<a name="supported-languages"></a>
## Supported Languages

Some of them is yet ~~to be done~~.

### Javascript
 1. CoffeeScript
   1. ✓ Literate Coffeescript
   1. ✓ Source Maps
 1. *~~TypeScript~~*
 1. *~~LiveScript~~*
 1. *~~Pure Javascript~~*
 1. *continues..*

### Styles
 1. Stylus
     1. ✓ `nib` available
 1. *~~Less~~*
 1. *~~Pure CSS~~*
 1. *continues..*

### Templates
 1. Jade
 1. *~~Handlebars~~*
 1. *~~Pure HTML~~*
 1. *continues..*

<a name="features"></a>
## Features
 * Watch'n'compile in `development` mode
 * Optimization routines for `release` mode
 * Live Reload when developing
 * Live syntax-check
 * Vendors management
 * Source Maps *(`coffeescript` only)*
 * Broken and circular-loop dependencies validation
 * Growl support for notifications
 * Minify support
 * ~~Scaffolding routines~~

<a name="examples"></a>
## Examples

There are no examples yet, but you can check the [tests](https://github.com/serpentem/polvo/tree/master/tests) provided for real example usages.

<a name="history"></a>
## History

> Polvo started as a natural evolution of [Coffee Toaster](http://github.com/serpentem/coffee-toaster) -- *a build system for CoffeeScript*. As Toaster became too specific about CoffeeScript, Polvo comes out to be a more inclusive build tool covering more languages around the same goal.