
# About {#about}

The Nuclide project produces a freely available game-logic component and
development platform on top of [FTE](https://www.fteqw.org); which is a featureful engine based on the **1999** source code release of **Quake** (1996) by id Software.

![](wand.png) **The general idea is that Nuclide takes care of ~90% of the code you shouldn't have to worry about.**

It is targeted towards developers with a background/interest in id Technology, and we incorporate design aspects from across the known spectrum of existing engines and tech.

It comes with a simple example game (simply referred to as 'TestGame' or 'Base') and some test maps. There's also some other, third-party example projects.

# Features

## Rendering System

The rendering system in FTE allows for a wide range of styles for low system requirements, due to a versatile renderer supporting Vulkan, OpenGL (with and without shaders) to legacy versions of Direct3D on Windows.

- **Physically Based Rendering.** State-of-the-art basis for rendering is standard and in base.
- **Lighting system choice.** You're not forced to use lightmapped-only paths. All entities are prepared to be mixed with different lighting technologies seamlessly.
- **Iris-adaptation, like Source HDR.** Simulated feel of high-dynamic-range with iris adaption can be turned on/off for every game. Of course we also have real HDR support in-engine.

## Modeling & Animation

With the wide selection of formats that FTE supports, rest assured your content gets in the game real easy.
The SDK itself is prepared to work with most formats.*

- **Hitmeshes..** Artists can use geometry in their ref to define precise damage areas, which any hitscan accurately detects.
- **Model events.** Define animation-sequence events that should happen on an exact keyframe basis, to be interpreted by both client and server.
- **Activities.** No longer hard-code which sequences and behaviour a model can express. The model can communicate it itself.

*Formats other than VVM require the use of an external, plain text file to define framegroups, events and activities.

## Environments

Make levels with the tools you've used before, and have been maintained by the community for decades.

- **Integrated Radiant.** Generate game-packs for your game with a single command, and get mapping right away.
- **Powerful BSP compiler.** Use *VMAP* to bake levels like you're used to from similar engine technology, with high quality lightmaps, cubemap-based environment mapping and adjustable vertex colors on spline-based meshes.
- **Map-specific rules.** Let the level control some aspects of the simulation through the use of an external [QuakeC progs](@ref progs).

## Physics

Nuclide integrates [Open Dynamics Engine](http://www.ode.org) to achieve networked, physically simulated bodies and ragdolls with consistent, game-specific feedback.

- **Consistent Prop Behaviour.** Set up a model once with its [mass and other prop data](@ref propdata) and Nuclide will handle impacts against other entities and real-world interactions.
- **Advanced constraint systems.** Set up rigs of constraints, like welds, ropes, pulleys and sliding mechanisms.

## Game Mechanics

- **IO System.** A custom implementation of a *Source Engine* compatible input output system for entities. Utilized by AI tasks/schedules as well.
- **Navmesh navigation.** Solid pathfinding within complex environments, with a simple-to-use navmesh editor.
- **Configurable movement.** Players, NPCs and bots can walk, run, sprint, duck, prone around the levels.

## Programming

Complete engine access available in the form of C code.
When writing game-logic, you'll be writing primarily in QuakeC, which is greatly enhanced by [FTEQCC](https://www.fteqcc.org).
However, that is not the only way you can modify aspects of the game greatly.

- **Higher-level prototyping.** Defining game objects such as NPCs, items and behaviour can be done entirely using external [decl](@ref decl) files.
- **Powerful debugging.** Complementing FTE's console and debugging capabilities is detailed event-logging with a focus on data and entity IDs for easy identification.
- **Easy custom builds.** Creating custom branded builds is as easy as copying a header file and editing it.
- **Easy deployment.** Build Steam depot folders with 1 command, building game archives and cross-platform binaries using gcc and mingw64 on Linux.

## Audio

The engine provides backends for audio through OpenAL, which has its DSP/Reverb features integrated into our SDK.

- **Sound scripting.** Customize the sound of any surface, and fine-tune how each sound is perceived from near and far using plain text definitions.
- **Voice chat integration..** Additional features such as player voice-chat (using Opus or Speex codecs) over the protocol are integrated.
- **Real-time sound file stitching.** Play a series of separate sounds as if they were one, with adjustable pitch and volume between segments.

## Networking

Tried and tested networking powered by QuakeWorld isn't the only thing it has got going for it.

- **Rock-solid lag compensation.** The player movement, including weapon and vehicle handling is predicted (simulated on both client and server) for smooth, lag-free feeling gameplay.
- **Integrated messaging.**. Players can keep track of their friends using a persistent chat/friends-list system.
- **Workshop style package manager.** Players can download levels, skins and addons through the built-in addon manager.
- **Hassle-free server hosting.** Players can host servers without the need for port forwarding using **Frag-Net**.

# Frequently Asked Questions

## 1. Why might I want to use it? {#why}

![](cross.png) You might be migrating from an engine that is no longer being licensed and don't want to learn a new engine and toolchain.

![](bricks.png) You might want to develop a game using a lot of complex and well-tested objects
which might be tedious to implement on your own.

![](wrench.png) You might want to run or make modifications for a game using Nuclide and need full
control over what you can do.

## 2. How free is Nuclide? {#license}

Everything in Nuclide is **free software**. The copyright terms for the game-logic are
very permitting. Nuclide *does not use the GPL* as a point of reference in terms of license, it instead uses a **ISC-like license**. This means you can use, copy, modify and distribute the code and work resulting from it for any purpose.

@note Please read the very short 'LICENSE' document for details.

## 3. What are the alternatives? {#alternatives}

Implementing systems such as prediction, complex map objects and entities on
your own, from scratch - or licensing another engine such as [Source](https://partner.steamgames.com/doc/sdk/uploading/distributing_source_engine) that ships with its own **Source SDK Base**.

## 4. Any example projects? {#examples}

- [The Wastes](https://store.steampowered.com/app/793670) is a commerical game built using Nuclide.
- [Rad-Therapy](https://www.github.com/eukara/freehl) is a clone of 'Half-Life: Deathmatch' on Nuclide.
- [Tactical-Retreat](https://www.github.com/eukara/freecs) is a clone of 'Counter-Strike', for Rad-Therapy.
