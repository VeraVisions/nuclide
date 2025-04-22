/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*! @file ncMapDelegate.h
    @brief MapC Delegate

    Everything regarding MapC multi-progs on the server.
*/

/** This class delegates active MapC logic. 

The ncMapDelegate class is for any set of active level specific logic.
It can be accessed in QuakeC via the global `g_grMap` from the server-side.

# Startup

Upon server init, the game will attempt to find a MapC progs file alongside the **BSP** or **MAP** that is being played on.

If you load `map foobar` in the console, and it'll find the map at `<gamedir>/maps/foobar.bsp`, then our server-game will look for a MapC progs over at `<gamedir>/maps/foobar.dat`.

# Implementing MapC Progs

Similarily to [RuleC](@ref ruleC), that progs can be implemented with
as many binds to the ncMapDelegate class as you like. The only requirement is you include the header found under `src/server/api.h`.

## Example MapC

To be written.


## Class To Progs Callback Mappings

Left = class method, right = name of the callback function for you to implement in progs.

** To be written.**

The underlying return values and parameters are inherited from its class counter-part.


@ingroup baseclass
*/
class ncMapDelegate:ncIO
{
public:
	void ncMapDelegate(void);

	virtual void Input(entity, string, string);

	/** Overridable: Called from initents(). */
	virtual void Precache(void);
	
	/* logic */
	/** Overridable: Called every server frame. */
	virtual void FrameStart(void);
	
	/* client */
	/** Overridable: Called when a ncPlayer joins the server. */
	virtual void PlayerConnect(ncPlayer);
	/** Overridable: Called when a ncPlayer leaves the server. */
	virtual void PlayerDisconnect(ncPlayer);
	/** Overridable: Called when a ncPlayer spawns, called sometime after joining. */
	virtual void PlayerSpawn(ncPlayer);
	/** Overridable: Called when a ncPlayer dies in the game. */
	virtual void PlayerDeath(ncPlayer, ncEntity, ncEntity, string);
	/** Overridable: Called when a ncPlayer feels pain. */
	virtual void PlayerPain(ncPlayer, ncActor, ncDict);
	/** Overridable:: Called when an NPC gets killed. */
	virtual void NPCDeath(ncActor, ncEntity, ncEntity);

	nonvirtual void LinkProgs(void);
	nonvirtual ncMapDelegate ActiveInstance(void);
};

/* our currently running mode */
ncMapDelegate g_grMap;
var float g_mapCProgs;

#define MAPLINK(x, y, z) x.y = externvalue(g_mapCProgs, z); if (!x.y) { x.y = ncMapDelegate::y; }

void MapC_Init(void);
