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
func_hostage_rescue_touch
=================
*/
void func_hostage_rescue_touch( void ) {
	if ( ( other.classname == "player" ) && ( other.team == TEAM_CT ) ) {
		other.fInHostageZone = TRUE; // Note: this will be cleared every frame inside SV_RunClientCommand
	} else if ( other.classname == "hostage_entity" ) {
		
		Radio_BroadcastMessage( RADIO_RESCUED );
		iHostagesRescued++;
		
		Money_AddMoney( other.eUser, 1000 );
		Money_QueTeamReward( TEAM_CT, 800 );
		if ( other.eTargetPoint != other.eUser ) {
			remove( other.eTargetPoint );
		}
		
		entity eOld = self;
		self = other;
		Entities_Remove();
		self = eOld;
		
		if ( iHostagesRescued >= iHostagesMax ) {
			// TODO: Broadcast_Print: All Hostages have been rescued!
			Rules_RoundOver( TEAM_CT, 0, FALSE );
		}
	}
}

/*
=================
SPAWN: func_hostage_rescue

Entry function for the rescue area-markings.
=================
*/
void func_hostage_rescue( void ) {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	
	if ( self.model ) {
		setmodel( self, self.model );
	} else {
		setsize( self, self.mins, self.maxs );
	}
	
	self.model = 0;
	self.touch = func_hostage_rescue_touch;
	
	iRescueZones++;
}

void info_hostage_rescue( void ) {
	self.mins = '-128 -128 -36';
	self.maxs = '128 128 36';
	func_hostage_rescue();
}

/*
=================
Game_CreateRescueZones

Called by StartFrame if we somehow got no rescue zones
=================
*/
void Game_CreateRescueZones( void ) {
	entity eFind = findchain( classname, "info_player_start" );
	
	while ( eFind ) {
		entity eRescueZone = spawn();
		setorigin( eRescueZone, eFind.origin );
		
		entity eOld = self;
		self = eRescueZone;
		info_hostage_rescue();
		self = eOld;
		eFind = eFind.chain;
	}
}
