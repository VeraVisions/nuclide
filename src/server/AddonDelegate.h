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

/*! @file ncAddonDelegate.h
    @brief AddonC Delegate

    Everything regarding AddonC multi-progs on the server.
*/

/** This is a delegate class for individual active AddonC plugins. 

# Overview

These are dynamic server-side plugins, added on top of the current game. They can also be removed at any time.
This is similar to [MetaMod](http://www.metamod.org). Just integrated right into the SDK.

# Loading/Unloading Plugins

You can load a plugin using a series of commands.

## addon load [name]

Attempts to load the addon plugin at `<gamedir>/plugins/[name].dat`.

## addon close [name]

Unloads the named addon plugin.

## addon list

Lists the active addon plugins.

# Implementing Plugins

## Example AddonC

Here's an example "Hello world!" style plugin.

It is located under `src/plugins/helloworld.qc`:

```
#pragma target fte_5768
#pragma PROGS_DAT  "../../base/plugins/helloworld.dat"
#include "../server/api.h"

var bool g_firstLoaded = false;

void
Plug_Load(void)
{
	if (g_firstLoaded == false) {
		printf("Hello world!\n");
		g_firstLoaded = true;
	} else {
		printf("Hello again!\n");
	}
}

void
Plug_Shutdown(void)
{
	printf("See you again!\n");
}
```

Because the engine does not allow us to unload progs, you have to handle any shutdown logic yourself, plus remove any entities from the game if the game no longer needs them.

## Class To Progs Callback Mappings

Left = class method, right = name of the callback function for you to implement in progs.

ncAddonDelegate::Load = Plug_Load  
ncAddonDelegate::Shutdown = Plug_Shutdown  
ncAddonDelegate::ConsoleCommand = Plug_ConsoleCommand  
ncAddonDelegate::ClientCommand = Plug_ClientCommand  
ncAddonDelegate::PlayerConnect = Plug_PlayerConnect  
ncAddonDelegate::PlayerDisconnect = Plug_PlayerDisconnect  
ncAddonDelegate::PlayerSpawn = Plug_PlayerSpawn  
ncAddonDelegate::PlayerDeath = Plug_PlayerDeath  
ncAddonDelegate::NPCDeath = Plug_NPCDeath  

The underlying return values and parameters are inherited from its class counter-part.

@ingroup baseclass
*/
class ncAddonDelegate
{
public:
	void ncAddonDelegate(void);

	/** Overridable: Called when the plugin gets loaded. */
	virtual void Load(void);
	/** Overridable: Called when the plugin gets unloaded. */
	virtual void Shutdown(void);

	/** Overridable: Called when the server issues a console command. */
	virtual bool ConsoleCommand(ncPlayer,string);
	/** Overridable: Called when a client issues a client command. */
	virtual bool ClientCommand(ncClient, string);
	/** Overridable: Called when a ncPlayer joins the server. */
	virtual void PlayerConnect(ncPlayer);
	/** Overridable: Called when a ncPlayer leaves the server. */
	virtual void PlayerDisconnect(ncPlayer);
	/** Overridable: Called when a ncPlayer spawns, called sometime after joining. */
	virtual void PlayerSpawn(ncPlayer);
	/** Overridable: Called when a ncPlayer dies in the game. */
	virtual void PlayerDeath(ncPlayer, ncEntity, ncEntity, string);
	/** Overridable:: Called when an NPC gets killed. */
	virtual void NPCDeath(ncActor, ncEntity, ncEntity);

	/** Called to link functions defined within multiprogs with the delegate's methods. */
	virtual void LinkProgs(void);

	/** Creates an addon delegate from a progs handle. 
	@param addonName is the name of the addon. Required for look-up purposes.
	@param progsHandle is the valid handle of a progs loaded via addprogs(). */
	nonvirtual ncAddonDelegate CreateFromProgs(string addonName, float progsHandle);

	/** Closes the addon. */
	nonvirtual void Close(void);

	/** Returns the name of the addon. Generally the name (without extension) of the progs. */
	nonvirtual string Name(void);

private:
	float m_progHandle;
	string m_name;
};

#define ADDON_LINK(y, z) this.y = externvalue(m_progHandle, z); if (!this.y) { this.y = ncAddonDelegate::y; }
