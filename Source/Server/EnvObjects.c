/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/


/*
=================
cycler_sprite

This entity lets you display and cycle through the animation of a sprite (or a model, engine doesn't care).

Attributes:
Name (targetname) - Property used to identify entities.
Pitch Yaw Roll (angles) - Sets the pitch (up / down), yaw (left / right) and roll (bank) respectively. The compass in WorldCraft / Hammer corresponds to Yaw. The settings are not always (or not all) used.
Sprite (model) - A sprite must be specified here (sprites/spritename.spr).
Frames per second (framerate) - Framerate the sprite will run at if animated.
=================
*/
void cycler_sprite( void ) {
	precache_model( self.model );
	setmodel( self, self.model );

	Entities_RenderSetup();
}

/*
=================
env_render

This entity allows you to change the rendering properties 
of most of the visible entities in the game (monsters, func_walls etc.), while the map is running. 
The four render properties of the env_render will be copied to its target. 

Attributes:
Name (targetname) - Property used to identify entities.
Target (target) - When an entity is activated, it triggers the entity with the name specified by Target.

Flags:
No Renderfx (1) - Render FX will not be copied.
No Renderamt (2) - Render Amount will not be copied.
No Rendermode (4) - Render Mode will not be copied.
No Rendercolor (8) - Render Color will not be copied.

Notes:
Use this entity to fake situations that would be impossible for the game engine, 
such as apparently binding multiple entities together (e.g. a moving doorhandle on a rotating door).
With a bit of careful setup, it is possible to let the the doorhandle move first, 
then become invisible, then let the door move (with a static doorhandle attached).
=================
*/

#define SF_NORENDERFX		1
#define SF_NORENDERAMT		2
#define SF_NORENDERMODE		4
#define SF_NORENDERCOLOR	8

void env_render( void ) {
	static void env_render_use( void ) {
		entity eFind = findchain( targetname, self.target );
	
		while ( eFind ) {
			entity eOldSelf = self;
			
			if ( !( self.spawnflags & SF_NORENDERMODE ) ) {
				eFind.rendermode = self.rendermode;
			}
			if ( !( self.spawnflags & SF_NORENDERCOLOR ) ) {
				eFind.colormod = self.colormod;
			}
			eFind.alpha = self.alpha;
			eFind = eFind.chain;
		}
	}
	
	self.colormod = self.rendercolor;
	
	Entities_RenderSetup();
	self.vUse = env_render_use;
}
