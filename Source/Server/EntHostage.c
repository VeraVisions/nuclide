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
SPAWN: hostage_entity

Entry function for the hostages.
=================
*/
void hostage_entity( void ) {
	precache_model( self.model );
	setorigin( self, self.origin + '0 0 -36');
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	setmodel( self, self.model );
	setsize( self, VEC_HULL_MIN + '0 0 36', VEC_HULL_MAX + '0 0 36' );

	self.frame = 13; // Idle frame
	
	iHostages = iHostages + 1; // Increase the global count of hostages
}
