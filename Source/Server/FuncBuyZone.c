/*
OpenCS Project
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
=================
func_buyzone_touch
=================
*/
void func_buyzone_touch( void ) {
	if( ( other.classname == "player" ) && ( other.team == self.team ) ) {
		other.fInBuyZone = TRUE; // Note: this will be cleared every frame inside SV_RunClientCommand
	}
}

/*
=================
SPAWN: func_buyzone

Entry function for the buyzone area-markings.
=================
*/
void func_buyzone( void ) {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	
	if ( self.model ) {
		setmodel( self, self.model );
	} else {
		self.mins = '-128 -128 -36';
		self.maxs = '128 128 36';
		setsize( self, self.mins, self.maxs );
	}
	
	self.model = 0;
	self.touch = func_buyzone_touch;
	iBuyZones++;
}

/*
=================
Game_CreateBuyZones

Called by StartFrame if we somehow got no buy zones
=================
*/
void Game_CreateBuyZones( void ) {
	entity eFind;
	entity eOld;
	
	if ( iBuyRestriction == BUY_T || iBuyRestriction == BUY_BOTH ) {
		eFind = findchain( classname, "info_player_deathmatch" );
		eOld = self;
		while ( eFind ) {
			entity eBuyZoneT = spawn();
			setorigin( eBuyZoneT, eFind.origin );
			self = eBuyZoneT;
			func_buyzone();
			self.team = TEAM_T;
			
			eFind = eFind.chain;
		}
		self = eOld;
	}
	
	if ( iBuyRestriction == BUY_CT || iBuyRestriction == BUY_BOTH ) {
		eFind = findchain( classname, "info_player_start" );
		
		eOld = self;
		while ( eFind ) {
			entity eBuyZoneCT = spawn();
			setorigin( eBuyZoneCT, eFind.origin );
			self = eBuyZoneCT;
			func_buyzone();
			self.team = TEAM_CT;
			
			eFind = eFind.chain;
		}
		self = eOld;
	}
}
