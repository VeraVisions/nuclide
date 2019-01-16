/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*

TODO: This gamemode is odd about balancing, right now the last surviving terrorist
 	  will decide the match. Still have to think about what rules to set up.
*/

class func_escapezone
{
	void() func_escapezone;
	virtual void() touch;
};

void Escape_Touch(entity targ)
{
	entity eOld = self;
	self = targ;
	Spawn_MakeSpectator();
	self.classname = "player";
	forceinfokey( self, "*dead", "0" );
	self.health = 0;
	Rules_CountPlayers();
	self = eOld;
}

/*
=================
func_escapezone_touch
=================
*/
void func_escapezone::touch(void)
{
	if (other.classname == "player") {
		if (other.team == TEAM_T) {
			Escape_Touch(other);

			if (iAlivePlayers_T == 0) {
				Rules_RoundOver(TEAM_T, 2500, FALSE);
			}
		}
		other.fInEscapeZone = TRUE;
	}
}

/*
=================
SPAWN: func_escapezone

Entry function for the terrorist escape zone
=================
*/
void func_escapezone::func_escapezone(void)
{
	angles = [0,0,0];
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if ( model ) {
		setmodel( self, model );
	} else {
		setsize( self, mins, maxs );
	}

	model = 0;
	iEscapeZones++;
}
