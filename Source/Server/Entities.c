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

void func_wall( void ) {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;

	setmodel (self, self.model);
	
	// GoldSrc-Rendermode support
	if( self.rendermode == 2 ) {
		self.alpha = ( self.renderamt / 255 );
	} else if ( self.rendermode == 5 ) {
		self.effects = EF_ADDITIVE;
		self.alpha = ( self.renderamt / 255 );
	}
}

void func_door( void ) {
	func_wall();
}

void func_button( void ) {
	func_wall();
}

void func_illusionary( void ){
	func_wall();
	self.solid = SOLID_NOT;
}

void func_water( void ) {
	func_wall();
	self.skin = CONTENT_WATER;
}

void ambient_generic( void ) {
	precache_sound( self.message );
	
	if ( self.spawnflags & 1 ) {
		self.style = ATTN_NONE;
	} else if ( self.spawnflags & 2 ) {
		self.style = ATTN_IDLE;
	} else if ( self.spawnflags & 4 ) {
		self.style = ATTN_STATIC;
	} else if ( self.spawnflags & 8 ) {
		self.style = ATTN_NORM;
	} else {
		self.style = ATTN_STATIC;
	}
	
 	ambientsound( self.origin, self.message, 1, self.style );
}
