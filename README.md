# Polvo

Polyvalent cephalopod mollusc.

> Version 0.1.0

[![Build Status](https://secure.travis-ci.org/serpentem/polvo.png)](http://travis-ci.org/serpentem/polvo) [![Dependency Status](https://gemnasium.com/serpentem/polvo.png)](https://gemnasium.com/serpentem/polvo)

# What the f?

Yet another application assembler for the browser.

# Hello World

A brief 1 min screencast showing the basics.

![Screencast at Vimeo](https://secure-b.vimeocdn.com/ts/589/314/58931491_640.jpg)

# Supported Languages & Features

 * For javascript:
   1. CoffeeScript
     <br/>✓ Literate Coffeescript
     <br/>✖ ~~Source Maps~~ `todo`
   1. *~~TypeScript~~* `todo`
   1. *~~JavaScript~~* `todo`
 * Styles
   1. Stylus
   1. *~~Less~~* `todo`
   1. *~~CSS~~* `todo`
 * Templates
   1. Jade
   1. *~~Handlebars~~* `todo`
   1. *~~HTML~~* `todo`

# How it works

  1. You code using CJS signature for `scripts`, or plain schemes using the syntax provided by your pre-compiled language of choice regarding `templates` and `styles`.
  
  1. Polvo will compile everything to *`.js`* files as AMD modules, including your styles.
  
You can require `scripts`, `templates` and `styles` modularly in the same fashion way, no matter what.

## Goals

The goal is to provide a confortable enviorment for using **any** pre-compiled language you want, ending up with a hundred percent modular application that can be optimized using *different approaches* [1].

By now the only one available is `merge`, that will merge everything into one single file or even inject the code buffer into a `script` tag whithin your `index.html` page -- *this will result in a single request per page*.

* [1] *Other optimization approaches is under development.*

# Examples

Check the [tests](https://github.com/serpentem/polvo/tree/master/tests) provided for real example usages.

# History

Polvo started as a natural evolution of [Coffee Toaster](http://github.com/serpentem/coffee-toaster) -- *CoffeeScript build system*.

As Toaster became too specific, Polvo comes out be a more flexible build tool.