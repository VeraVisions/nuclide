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
func_vip_safetyzone_touch
=================
*/
void func_vip_safetyzone_touch( void ) {
	if ( ( other.classname == "player" ) && ( other.team == TEAM_VIP ) ) {
		Rules_RoundOver( TEAM_CT, 2500, FALSE );
		
		entity eOld = self;
		self = other;
		
		Spawn_MakeSpectator();
		self.classname = "player";
		self.team = TEAM_CT;
		forceinfokey( self, "*dead", "0" );
		iAlivePlayers_CT--;
		
		self = eOld;
	} 
}

/*
=================
SPAWN: func_vip_safetyzone

Entry function for the VIP escape zone
=================
*/
void func_vip_safetyzone( void ) {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	
	if ( self.model ) {
		setmodel( self, self.model );
	} else {
		setsize( self, self.mins, self.maxs );
	}
	
	self.model = 0;
	self.touch = func_vip_safetyzone_touch;
	iVIPZones++;
}
