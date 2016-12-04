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

void cycler_sprite( void ) {
	static void cycler_sprite_use( void ) {
		remove( self );
	}
	
	precache_model( self.model );
	setmodel( self, self.model );
	self.vUse = cycler_sprite_use;
	
	Entities_RenderSetup();
}

void env_render( void ) {
	static void env_render_use( void ) {
		entity eFind = findchain( targetname, self.target );
	
		while ( eFind ) {
			entity eOldSelf = self;
			eFind.rendermode = self.rendermode;
			eFind.rendercolor = self.rendercolor;
			eFind.alpha = self.alpha;
			eFind = eFind.chain;
		}
	}
	
	Entities_RenderSetup();
	self.vUse = env_render_use;
}
