/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

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

TODO: This gamemode is odd about balancing, right now the last surviving terrorist
 	  will decide the match. Still have to think about what rules to set up.
*/

/*
=================
func_escapezone_touch
=================
*/
void func_escapezone_touch( void ) {
	if ( ( other.classname == "player" ) && ( other.team == TEAM_T ) ) {
		entity eOld = self;
		self = other;
		
		Spawn_MakeSpectator();
		self.classname = "player";
		forceinfokey( self, "*dead", "0" );
		iAlivePlayers_T--;
		
		self = eOld;
		
		if ( iAlivePlayers_T == 0 ) {
			Rules_RoundOver( TEAM_T, 2500, FALSE );
		}
	} 
}

/*
=================
SPAWN: func_escapezone

Entry function for the terrorist escape zone
=================
*/
void func_escapezone( void ) {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	
	if ( self.model ) {
		setmodel( self, self.model );
	} else {
		setsize( self, self.mins, self.maxs );
	}
	
	self.model = 0;
	self.touch = func_escapezone_touch;
	
	iEscapeZones++;
}
