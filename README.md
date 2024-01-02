# ![FTE Logo](Documentation/fte.svg) Nuclide - Software Development Kit 

Software Development Kit, built around id Technology with focus on advanced features and
clean-room implementations of true-and-tested game-logic frameworks.

*It's been used to ship a commercial product. So it's proven to some extent.*

All of this is written in QuakeC, but there's also some GLSL and shell scripts
in here. If you and your team are unfamilar with any of these, you may want something else.

## Features

- The missing SDK for engines like FTEQW
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

## Documentation

You can find up-to-date documentation over at https://developer.vera-visions.com/

This documentation is built entirely from this repository using doxygen.
You do not need to be on-line to view the documentation.

You can build the HTML documentation by running `doxygen` inside the root
of the repository. The output is located under `Documentation/html/index.html`

## Support

You can get personal support for Nuclide by negotiating a support contract with us. Reach out to marco@vera-visions.com if you want to know about our rates.

## Special Thanks

To id software and specifically John Carmack for having released the sources of
various works of id Technology under free licenses, without which a project like this would be unfeasible.

David Walton for **FTEQW** and the **FTEQCC** compiler, which is the brain of this SDK.

Timothee Besset and the **GtkRadiant** contributors, as well as the NetRadiant team for giving us a base for our editor **WorldSpawn**.

![idTech Logo](Documentation/idtech.svg)

## License
Copyright (c) 2016-2023 Vera Visions L.L.C.

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
