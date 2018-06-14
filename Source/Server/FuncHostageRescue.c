/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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
		if ( self.solid == SOLID_NOT ) {
			return;
		}
		
		Radio_BroadcastMessage( RADIO_RESCUED );
		iHostagesRescued++;
		
		Money_AddMoney( other.eUser, 1000 );
		Money_QueTeamReward( TEAM_CT, 800 );
		
		if ( other.eTargetPoint != other.eUser ) {
			remove( other.eTargetPoint );
		}
		
		other.eTargetPoint = other.eUser = world;
		
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
