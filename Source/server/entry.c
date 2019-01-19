/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void main(void)
{
}

void StartFrame(void)
{
#ifdef CSTRIKE
	Cstrike_StartFrame();
#endif

#ifdef VALVE
	Valve_StartFrame();
#endif
}

void ClientConnect(void)
{
#ifdef CSTRIKE
	Cstrike_ClientConnect();
#endif

#ifdef VALVE
	Valve_ClientConnect();
#endif
}

void ClientDisconnect(void)
{
#ifdef CSTRIKE
	Cstrike_ClientDisconnect();
#endif

#ifdef VALVE
	Valve_ClientDisconnect();
#endif
}

void ClientKill(void)
{
#ifdef CSTRIKE
	Cstrike_ClientKill();
#endif

#ifdef VALVE
	Valve_ClientKill();
#endif
}

void SpectatorThink(void)
{
#ifdef CSTRIKE
	Cstrike_SpectatorThink();
#endif

#ifdef VALVE
	Valve_SpectatorThink();
#endif
}
void SpectatorConnect(void)
{
#ifdef CSTRIKE
	Cstrike_SpectatorConnect();
#endif

#ifdef VALVE
	Valve_SpectatorConnect();
#endif
}
void SpectatorDisconnect(void)
{
#ifdef CSTRIKE
	Cstrike_SpectatorDisconnect();
#endif

#ifdef VALVE
	Valve_SpectatorDisconnect();
#endif
}

void PutClientInServer(void)
{
#ifdef CSTRIKE
	Cstrike_PutClientInServer();
#endif

#ifdef VALVE
	Valve_PutClientInServer();
#endif
}

void PlayerPreThink(void)
{
#ifdef CSTRIKE
	Cstrike_PlayerPreThink();
#endif

#ifdef VALVE
	Valve_PlayerPreThink();
#endif
}

void PlayerPostThink(void)
{
#ifdef CSTRIKE
	Cstrike_PlayerPostThink();
#endif

#ifdef VALVE
	Valve_PlayerPostThink();
#endif
}

void SetNewParms(void)
{
#ifdef CSTRIKE
	Cstrike_SetNewParms();
#endif

#ifdef VALVE
	Valve_SetNewParms();
#endif
}

void SetChangeParms(void)
{
#ifdef CSTRIKE
	Cstrike_SetChangeParms();
#endif

#ifdef VALVE
	Valve_SetChangeParms();
#endif
}

void SV_RunClientCommand( void )
{
#ifdef CSTRIKE
	Cstrike_RunClientCommand();
#endif

#ifdef VALVE
	Valve_RunClientCommand();
#endif
}

void SV_ParseClientCommand(string cmd)
{
#ifdef CSTRIKE
	Cstrike_ParseClientCommand(cmd);
#endif

#ifdef VALVE
	Valve_ParseClientCommand(cmd);
#endif
}

void worldspawn(void)
{
	string sTemp;

	if (g_initialized) {
		return;
	}
	g_initialized = TRUE;
	
	// Let's load materials.txt because someone thought this was the best idea
	filestream fileMaterial = fopen( "sound/materials.txt", FILE_READ );
	hashMaterials = hash_createtab( 512, HASH_ADD );
	
	if ( fileMaterial >= 0 ) {
		while ( ( sTemp = fgets( fileMaterial ) ) ) {			
			// Tokenize and just parse this stuff in
			if ( tokenize_console( sTemp ) == 2 ) {
				hash_add( hashMaterials, strtolower( argv( 1 ) ), str2chr( argv( 0 ), 0 ) );
			}
		}
		fclose( fileMaterial );
	} else {
		error( "Failed to load sound/materials.txt!\n" );	
	}

	precache_sound( "weapons/explode3.wav" );
	precache_sound( "weapons/explode4.wav" );
	precache_sound( "weapons/explode5.wav" );
	
	precache_sound( "debris/glass1.wav" );
	precache_sound( "debris/glass2.wav" );
	precache_sound( "debris/glass3.wav" );
	precache_sound( "debris/wood1.wav" );
	precache_sound( "debris/wood2.wav" );
	precache_sound( "debris/wood3.wav" );
	precache_sound( "debris/metal1.wav" );
	precache_sound( "debris/metal2.wav" );
	precache_sound( "debris/metal3.wav" );
	precache_sound( "debris/flesh1.wav" );
	precache_sound( "debris/flesh2.wav" );
	precache_sound( "debris/flesh3.wav" );
	precache_sound( "debris/flesh5.wav" );
	precache_sound( "debris/flesh6.wav" );
	precache_sound( "debris/flesh7.wav" );
	precache_sound( "debris/concrete1.wav" );
	precache_sound( "debris/concrete2.wav" );
	precache_sound( "debris/concrete3.wav" );
	
	precache_sound( "player/pl_metal1.wav" );
	precache_sound( "player/pl_metal2.wav" );
	precache_sound( "player/pl_metal3.wav" );
	precache_sound( "player/pl_metal4.wav" );
	
	precache_sound( "player/pl_duct1.wav" );
	precache_sound( "player/pl_duct2.wav" );
	precache_sound( "player/pl_duct3.wav" );
	precache_sound( "player/pl_duct4.wav" );
	
	precache_sound( "player/pl_dirt1.wav" );
	precache_sound( "player/pl_dirt2.wav" );
	precache_sound( "player/pl_dirt3.wav" );
	precache_sound( "player/pl_dirt4.wav" );
	
	precache_sound( "player/pl_slosh1.wav" );
	precache_sound( "player/pl_slosh2.wav" );
	precache_sound( "player/pl_slosh3.wav" );
	precache_sound( "player/pl_slosh4.wav" );
	
	precache_sound( "player/pl_tile1.wav" );
	precache_sound( "player/pl_tile2.wav" );
	precache_sound( "player/pl_tile3.wav" );
	precache_sound( "player/pl_tile4.wav" );
	
	precache_sound( "player/pl_grate1.wav" );
	precache_sound( "player/pl_grate2.wav" );
	precache_sound( "player/pl_grate3.wav" );
	precache_sound( "player/pl_grate4.wav" );
	
	precache_sound( "player/pl_snow1.wav" );
	precache_sound( "player/pl_snow2.wav" );
	precache_sound( "player/pl_snow3.wav" );
	precache_sound( "player/pl_snow4.wav" );
	
	precache_sound( "player/pl_step1.wav" );
	precache_sound( "player/pl_step2.wav" );
	precache_sound( "player/pl_step3.wav" );
	precache_sound( "player/pl_step4.wav" );
	
	precache_sound( "items/9mmclip1.wav" );
	precache_sound( "items/gunpickup2.wav" );
	precache_sound( "common/wpn_select.wav" );
	precache_sound( "common/wpn_denyselect.wav" );
	precache_sound( "player/sprayer.wav" );

	lightstyle( 0, "m" );
	lightstyle( 1, "mmnmmommommnonmmonqnmmo" );
	lightstyle( 2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba" );
	lightstyle( 3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg" );
	lightstyle( 4, "mamamamamama" );
	lightstyle( 5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj" );
	lightstyle( 6, "nmonqnmomnmomomno" );
	lightstyle( 7, "mmmaaaabcdefgmmmmaaaammmaamm" );
	lightstyle( 8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa" );
	lightstyle( 9, "aaaaaaaazzzzzzzz" );
	lightstyle( 10, "mmamammmmammamamaaamammma" );
	lightstyle( 11, "abcdefghijklmnopqrrqponmlkjihgfedcba" );
	
#ifdef CSTRIKE
	Cstrike_worldspawn();
#elif VALVE
	Valve_worldspawn();
#endif
}
