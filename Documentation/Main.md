# Overview

Welcome to the documentation for Nuclide.

This is a software development kit and development environment created by [Vera Visions, L.L.C.](https://www.vera-visions.com/)

## What this project is {#what}

The Nuclide project produces a freely available game-logic component and 
development platform on top of FTEQW; which is the engine we happen to use.
The goal is to create a modern research base for new advancements, as well
as to have a stable base with a decent API for making games.

- Client-side predicted movement and inputs for things like weapons-systems
- Lots of well documented objects to use in level formats supported by FTEQW
- Reference implementations for a lot of features exlusive to FTEQW compared
  to other idTech engines
- Designed to be familar to developers who're used to GoldSrc and Source engine
  projects

### 1. Why might I want to use it? {#why}

You want to develop a game using a lot of complex and well-tested objects
which might be tedious to implement on your own.

You want to run or make modifications for a game using Nuclide and need full
control over what you can do.

### 2. How free is Nuclide? {#license}

Everything in Nuclide is **free software**. The copyright terms for the game-logic are
very permitting. Nuclide does not use the GPL as a point of reference, it
instead uses a ISC-like license. This means you can use, copy, modify and
distribute the code and work resulting from it for any purpose.

Please read the very short 'LICENSE' document for details.

### 3. What are the alternatives? {#alternatives}

Implementing systems such as prediction, complex map objects and entities on
your own or licensing another engine such as [Source](https://partner.steamgames.com/doc/sdk/uploading/distributing_source_engine) that ships with its own **Source SDK Base**.

## Getting started {#prerequisites}

First of all, you want to be sure this is what you want to get into.
If you do posess a basic knowledge of the following:

- The C programming language
- Debugging a native application
- Makefiles
- Compiling your own binaries
- Concept of public and private APIs

Then you will have a good time.
We strive to keep the codebase portable and conform to open standards wherever possible.
This means that if you develop on Windows, you probably want to install something like [Cygwin](https://www.cygwin.com/) to make this bearable.

Please don't ask us how to learn UNIX/Cygwin.

**This is a development kit and a development environment. This is not a game.**

## Actually getting started {#how}

You clone the Nuclide git repository first. There's multiple places to get it, one such place may be GitHub:

`git clone https://github.com/veravisions/nuclide`

And then you can [get started on building the engine and the rest of the toolchain](Building.md).