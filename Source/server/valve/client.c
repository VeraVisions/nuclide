/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Valve_ClientConnect(void)
{
	bprint(sprintf("%s connected\n", self.classname));
}
void Valve_ClientDisconnect(void)
{
	bprint(sprintf("%s disconnected\n", self.classname));
}
void Valve_ClientKill(void)
{
	
}

void Valve_PlayerPreThink(void)
{
	
}
void Valve_PlayerPostThink(void)
{
	
}
void Valve_SetChangeParms(void)
{
	
}
void Valve_RunClientCommand(void)
{
	QPhysics_Run(self);
}

void Valve_PutClientInServer(void)
{
	if ( cvar( "sv_playerslots" ) == 1 ) {
		entity spot;
		self.SendEntity = Player_SendEntity;

		//Valve_DecodeChangeParms();

		if (startspot) {
			self.origin = Landmark_GetSpot();
			self.fixangle = TRUE;
		} else {
			spot = find( world, classname, "info_player_start" );
			self.origin = spot.origin;
			self.angles = spot.angles;
			self.fixangle = TRUE;
		}
	}
	
	self.classname = "player";
	self.health = self.max_health = 100;
	forceinfokey( self, "*dead", "0" );
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.viewzoom = 1.0;
	setmodel( self, "models/player.mdl" );
	setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
	self.view_ofs = VEC_PLAYER_VIEWPOS;
	self.velocity = '0 0 0';
	self.frame = 1;
	forceinfokey( self, "*spec", "0" );
}

void Valve_ParseClientCommand(string cmd)
{

}

void Valve_SetNewParms(void)
{

}
