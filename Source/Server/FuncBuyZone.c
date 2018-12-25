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
	if ( autocvar_fcs_knifeonly == TRUE ) {
		remove( self );
		return;
	}

	if ( autocvar_fcs_swapteams == TRUE ) {
		if (self.team == TEAM_T) {
			self.team = TEAM_CT;
		} else if (self.team == TEAM_CT) {
			self.team = TEAM_T;
		}
	}

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
	
	if ( autocvar_fcs_knifeonly == TRUE ) {
		return;
	}
	
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
