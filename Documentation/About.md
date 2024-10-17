
# About The Project {#about}

The Nuclide project produces a freely available game-logic component and
development platform on top of [FTEQW](https://www.fteqw.org); which is a featureful QuakeWorld-based engine.

**The general idea is that Nuclide takes care of ~90% of the code you shouldn't have to worry about.**

It is targetted towards developers with a background/interest in id Technology.

It comes with a simple example game (simply referred to as 'Base') and some test maps. There's also some other, third-party example projects.

General feature overview:

- The 'missing' SDK for engines like FTEQW
- Support for client-side predicted movement, weaponry and vehicles
- Documented APIs for everything you need to interface with the engine
- APIs and Frameworks for managing updates, mods, servers, and platform specific features
- Complete re-implementations of hundreds of entities, from GoldSrc/Source engine games
- Entity communication via traditional one-way triggers, or our Source Engine I/O compatible system
- Includes BotLib, a framework for multiplayer-AI that can receive game-specific overrides
- Includes VGUILib, a re-imagining of Valve's GUI library, which can also be used for in-game surface based interfaces
- Designed to be familar to developers coming from GoldSrc/Source
- VR/XR aware codebase
- All permissively licensed


# Frequently Asked Questions

## 1. Why might I want to use it? {#why}

You might be migrating from an engine that is no longer being licensed and don't want to learn a new engine and toolchain.

You might want to develop a game using a lot of complex and well-tested objects
which might be tedious to implement on your own.

You might want to run or make modifications for a game using Nuclide and need full
control over what you can do.

## 2. How free is Nuclide? {#license}

Everything in Nuclide is **free software**. The copyright terms for the game-logic are
very permitting. Nuclide *does not use the GPL* as a point of reference in terms of license, it instead uses a **ISC-like license**. This means you can use, copy, modify and
distribute the code and work resulting from it for any purpose.

**Please read the very short 'LICENSE' document for details.**

## 3. What are the alternatives? {#alternatives}

Implementing systems such as prediction, complex map objects and entities on
your own, from scratch - or licensing another engine such as [Source](https://partner.steamgames.com/doc/sdk/uploading/distributing_source_engine) that ships with its own **Source SDK Base**.

## 4. Any example projects? {#examples}

- [The Wastes](https://store.steampowered.com/app/793670) is a commerical game built using Nuclide.
- [Rad-Therapy](https://www.github.com/eukara/freehl) is a clone of 'Half-Life: Deathmatch' on Nuclide.
- [Tactical Retreat](https://www.github.com/eukara/freecs) is a clone of 'Counter-Strike', for Rad-Therapy.
