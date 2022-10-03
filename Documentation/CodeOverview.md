# Code: Overview

## Getting started
Most developers probably only want to get their hands on the game-logic component.

In Nuclide we have 3 main modules supplied to the engine:

- **Client**
- **Server**
- **Menu**

When we build these with the **fteqcc** compiler, we will get three files:

- csprogs.dat
- progs.dat
- menu.dat

In the source code tree of Nuclide itself, you'll find all the core entry functions that
the engine calls in a file called `entry.qc` which exists in each sub-module its directory.

However, you probably don't want to modify the Nuclide `./src/...` tree directly (unless you got a good reason) and want to focus on your own tree.

A minimal basis you can copy and paste can be found under `./base/` which implements a very minimal game. You can walk around, jump and even shoot a projectile or two.

This is an example codebase implementing the minimum required to get going with Nuclide.
So make a copy of it and play around there to get a feel for what you can do.

There are some other example games, such as **FreeHL** which you may want to look at too. Some games (usually not provided by us) have a different **license** so watch out as you don't want to step on anyones toes.

However if it's provided by us (**Vera Visions, L.L.C.**) then you can usually assume it's under some sort of **free license**. Wouldn't hurt to check however.

## Example: Base

To be written.


