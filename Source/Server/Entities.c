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
	}
}

void func_door( void ) {
	func_wall();
}

void func_breakable( void ) {
	func_wall();
}

void func_button( void ) {
	func_wall();
}

void func_illusionary( void ){
	setmodel( self, self.model );  
	self.solid = SOLID_NOT;
}

void func_water( void ) {
	func_illusionary();
}

void ambient_generic( void ) {
	precache_sound( self.message );
 	ambientsound( self.origin, self.message, 1, ATTN_NORM );
}
