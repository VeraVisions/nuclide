/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
	entity a;

	if ( autocvar_fcs_knifeonly == TRUE ) {
		return;
	}

	if ( iBuyRestriction == BUY_T || iBuyRestriction == BUY_BOTH ) {
		for (a = world; (a = find(a, classname, "info_player_deathmatch"));) {
			func_buyzone zone = spawn(func_buyzone);
			setorigin(zone, a.origin);
			zone.team = TEAM_T;
		}
	}

	if ( iBuyRestriction == BUY_CT || iBuyRestriction == BUY_BOTH ) {
		for (a = world; (a = find(a, classname, "info_player_start"));) {
			func_buyzone zone = spawn(func_buyzone);
			setorigin(zone, a.origin);
			zone.team = TEAM_CT;
		}
	}
}
