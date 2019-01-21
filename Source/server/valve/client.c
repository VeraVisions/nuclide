/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Game_ClientConnect(void)
{
	bprint(sprintf("%s connected\n", self.netname));
}
void Game_ClientDisconnect(void)
{
	bprint(sprintf("%s disconnected\n", self.netname));
}
void Game_ClientKill(void)
{
	
}

void Game_PlayerPreThink(void)
{
	
}
void Game_PlayerPostThink(void)
{
	self.SendFlags = 1;
}
void Game_RunClientCommand(void)
{
	Footsteps_Update();
	QPhysics_Run(self);
}

void Game_DecodeChangeParms(void)
{
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	self.angles[0] = parm4;
	self.angles[1] = parm5;
	self.angles[2] = parm6;
}
void Game_SetChangeParms(void)
{
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = self.angles[0];
	parm5 = self.angles[1];
	parm6 = self.angles[2];
}

void Game_PutClientInServer(void)
{
	if ( cvar( "sv_playerslots" ) == 1 ) {
		entity spot;
		self.SendEntity = Player_SendEntity;

		Game_DecodeChangeParms();

		if (startspot) {
			setorigin(self, Landmark_GetSpot());
			self.fixangle = TRUE;
		} else {
			spot = find( world, classname, "info_player_start" );
			//self.origin = spot.origin;
			setorigin(self, spot.origin);
			self.angles = spot.angles;
			self.fixangle = TRUE;
		}
	}
	
	self.classname = "player";
	self.health = self.max_health = 100;
	//forceinfokey( self, "*dead", "0" );
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

void Game_ParseClientCommand(string cmd)
{
	clientcommand(self, cmd);
}

void Game_SetNewParms(void)
{

}
