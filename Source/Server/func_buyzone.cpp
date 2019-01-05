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

class func_buyzone
{
	void() func_buyzone;
	virtual void() touch;
};

void func_buyzone::touch(void)
{
	/* This will be cleared every frame inside SV_RunClientCommand */
	if((other.classname == "player" ) && (other.team == self.team)) {
		other.fInBuyZone = TRUE;
	}
}

void func_buyzone::func_buyzone(void)
{
	if (autocvar_fcs_knifeonly == TRUE) {
		remove( self );
		return;
	}

	if (autocvar_fcs_swapteams == TRUE) {
		if (team == TEAM_T) {
			team = TEAM_CT;
		} else if (team == TEAM_CT) {
			team = TEAM_T;
		}
	}

	angles = '0 0 0';
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if (model) {
		setmodel(this, model);
	} else {
		mins = '-128 -128 -36';
		maxs = '128 128 36';
		setsize(this, mins, maxs);
	}

	model = 0;
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
			spawnfunc_func_buyzone();
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
			spawnfunc_func_buyzone();
			self.team = TEAM_CT;
			
			eFind = eFind.chain;
		}
		self = eOld;
	}
}
