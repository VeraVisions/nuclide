# History

In November 2016 **eukara** started work on **OpenCS**, a project which focused
solely on creating a clean-room implementation of **Counter-Strike 1.5** in QuakeC
for **FTEQW**, which then was the only Quake engine fork which adhered to the
GPL **and** supported the **level and model format** of **Half-Life** mostly to spec.

Its strong game-logic enhancements such as **Client-Side QC** as well as its
QuakeWorld backbone also made it more desirable over other Quake engine forks.

**OpenCS** was feature complete with all CS 1.5's content had to offer by December
of 2016, however the name conflicted with the **OpenMW** sub-project **OpenCS**,
so eukara changed it to avoid any future conflicts.

To emphasize the free-software aspect, eukara renamed the project **FreeCS**.

Work on **FreeCS** had then paused so more work could be done on what would later
become the **gs-entbase** component. Another project (**The Wastes**) required more compatibility
with the full set of map entities present in Half-Life.

When those matured, they were then backported to the FreeCS source tree.

Then, in November 2017, **FreeCS** was featured on Phoronix.

After the release of **The Wastes** in April 2018, the game which introduced the
**gs-entbase** component, more work was done in the FreeCS source tree in regards to the netcode.

A lot had been learned about prediction and taking full advantage of the
custom networking available in **FTEQW**, but new features have also been
added to the engine to take full advantage of what the content had to offer:

Features like interacting with [OpenAL's EAX extension](@ref efx), [model-events](VVM.md), support
for WAD3 decal parsing and countless QuakeC extensions were all added by
either Spike (FTEQW Author) or eukara himself to make everything possible.

**Many projects running on FTE have since taken advantage of these extensions
as well!**

By the summer of 2019, multiple other mods from other engines started taking shape.
At this point, the tree was overhauled so it would support multiple mods easier
and that a lot of code would be shared between all of them.
This is the structure of the src tree we still use to this day.

*So a name had to be thought of that would neatly tie all projects under one
roof together*: **Nuclide!**

**Trivia**: *The name Nuclide calls back to an earlier project of ours, which tried to create
a work environment similar to GoldSrc for the original Quake engine.*

In April of 2020, the weapons were rewritten to be fully client-side predicted.

So the meaning and scope of **Nuclide** has changed, mainly to make work easier
as at one point The Wastes and FreeCS were two seperate code-trees. Now they're unified
into one. We'd like to consider Nuclide to be FTE's reference SDK for game-logic,
like **Source SDK Base** is to **Source Engine**.
