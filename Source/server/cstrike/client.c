/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
SpectatorThink

Run every frame on every spectator
=================
*/
void Game_SpectatorThink(void)
{
	self.SendFlags = 1;
}

/*
=================
ClientKill

Suicide command 'kill' executes this function.
=================
*/
void Game_ClientKill(void)
{
	Damage_Apply(self, self, self.health, self.origin, TRUE);
}

/*
=================
ClientConnect

Run whenever a new client joins
=================
*/
void Game_ClientConnect(void) {}

/*
=================
SpectatorConnect

Called when a spectator joins the game
=================
*/
void Game_SpectatorConnect(void)
{
	//Spawn_MakeSpectator();
	//Spawn_ObserverCam();
	ClientConnect();
	PutClientInServer();
}

/*
=================
SpectatorDisconnect

Called when a spectator leaves the game
=================
*/
void Game_SpectatorDisconnect(void)
{
	Spray_RemoveAll(self);
}

/*
=================
ClientDisconnect

Run whenever a client quits
=================
*/
void Game_ClientDisconnect(void)
{
	// We were part of the session
	self.health = 0;
	Rules_CountPlayers();
	Rules_DeathCheck();
	Spray_RemoveAll(self);
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

/*
=================
PutClientInServer

Puts a client into the world.
=================
*/
void Game_PutClientInServer(void)
{
	if (cvar("sv_playerslots") == 1) {
		entity spot;
		self.SendEntity = Player_SendEntity;

		Game_DecodeChangeParms();

		if (startspot) {
			self.origin = Landmark_GetSpot();
			self.fixangle = TRUE;
		} else {
			spot = find(world, classname, "info_player_start");
			self.origin = spot.origin;
			self.angles = spot.angles;
			self.fixangle = TRUE;
		}

		self.classname = "player";
		self.health = self.max_health = 100;
		forceinfokey(self, "*dead", "0");
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_WALK;
		self.flags = FL_CLIENT;
		self.vPain = Player_Pain;
		self.vDeath = Player_Death;
		self.iBleeds = TRUE;
		self.pvsflags = PVSF_IGNOREPVS;
		self.fSlotGrenade = 0;
		self.viewzoom = 1.0;
		setmodel(self, "models/player/vip/vip.mdl");
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
		self.view_ofs = VEC_PLAYER_VIEWPOS;
		self.velocity = '0 0 0';
		self.frame = 1; // Idle frame
		self.fBombProgress = 0;
		self.team = TEAM_CT;
		forceinfokey(self, "*spec", "0"); 
		return;
	}

	entity eTarget = world;

	Spawn_MakeSpectator();
	Spawn_ObserverCam();
	self.SendEntity = Player_SendEntity;

	// Because we don't want to reset these when we die
	Money_AddMoney(self, autocvar_mp_startmoney);

	if (cvar("mp_timelimit") > 0) {
		if (autocvar_fcs_voxannounce == TRUE) {
			float fTimeLeft = cvar("mp_timelimit") - (time / 60);
			Vox_Singlecast(self, sprintf("we have %s minutes remaining", Vox_TimeToString(fTimeLeft)));
		}
	}
	
	self.team = 0;
	forceinfokey(self, "*team", "0"); 
}

/*
=================
SV_RunClientCommand

Funtion that can interrupt client commands before physics are run
=================
*/
void Game_RunClientCommand(void)
{
	/*if (clienttype(self) == CLIENTTYPE_BOT) {
		((CBot)self).RunAI();
	}*/

	if (fGameState == GAME_FREEZE && self.health > 0) {
		input_movevalues = '0 0 0';
		//input_buttons = 0;
		input_impulse = 0;
	}

	// The individual zones will just override this behavior
	self.fInBombZone = FALSE;
	self.fInBuyZone = FALSE;
	self.fInHostageZone = FALSE;
	self.fInEscapeZone = FALSE;
	self.fInVIPZone = FALSE;

	QPhysics_Run(self);
}

void Game_SetNewParms(void)
{

}

/*
=================
Client_SendEvent

Send a game event
=================
*/
void Client_SendEvent(entity eClient, float fEVType)
{
	Weapon_UpdateCurrents();
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, fEVType);
	WriteByte(MSG_MULTICAST, num_for_edict(eClient));
	msg_entity = eClient;
	multicast(self.origin, MULTICAST_PVS);
}
