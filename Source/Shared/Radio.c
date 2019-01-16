/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum {
	RADIO_BLOW,
	RADIO_BOMBDEF,
	RADIO_BOMBPL,
	RADIO_CIRCLEBACK,
	RADIO_CLEAR,
	RADIO_COM_FOLLOWCOM,
	RADIO_COM_GETINPOS,
	RADIO_COM_GO,
	RADIO_COM_REPORTIN,
	RADIO_CT_AFFIRM,
	RADIO_CT_BACKUP,
	RADIO_CT_COVERME,
	RADIO_CT_ENEMYS,
	RADIO_CT_FIREINHOLE,
	RADIO_CT_IMHIT,
	RADIO_CT_INPOS,
	RADIO_CT_POINT,
	RADIO_CT_REPORTINGIN,
	RADIO_CTWIN,
	RADIO_ENEMYDOWN,
	RADIO_FALLBACK,
	RADIO_FIREASSIS,
	RADIO_FOLLOWME,
	RADIO_GETOUT,
	RADIO_GO,
	RADIO_HITASSIST,
	RADIO_HOSDOWN,
	RADIO_LETSGO,
	RADIO_LOCKNLOAD,
	RADIO_MATEDOWN,
	RADIO_MEETME,
	RADIO_MOVEOUT,
	RADIO_NEGATIVE,
	RADIO_POSITION,
	RADIO_REGROUP,
	RADIO_RESCUED,
	RADIO_ROGER,
	RADIO_ROUNDDRAW,
	RADIO_STICKTOG,
	RADIO_STORMFRONT,
	RADIO_TAKEPOINT,
	RADIO_TERWIN,
	RADIO_VIP,
};

#ifdef CSQC
string sRadioSamples[43] = {
	"radio/blow.wav",
	"radio/bombdef.wav",
	"radio/bombpl.wav",
	"radio/circleback.wav",
	"radio/clear.wav",
	"radio/com_followcom.wav",
	"radio/com_getinpos.wav",
	"radio/com_go.wav",
	"radio/com_reportin.wav",
	"radio/ct_affirm.wav",
	"radio/ct_backup.wav",
	"radio/ct_coverme.wav",
	"radio/ct_enemys.wav",
	"radio/ct_fireinhole.wav",
	"radio/ct_imhit.wav",
	"radio/ct_inpos.wav",
	"radio/ct_point.wav",
	"radio/ct_reportingin.wav",
	"radio/ctwin.wav",
	"radio/enemydown.wav",
	"radio/fallback.wav",
	"radio/fireassis.wav",
	"radio/followme.wav",
	"radio/getout.wav",
	"radio/go.wav",
	"radio/hitassist.wav",
	"radio/hosdown.wav",
	"radio/letsgo.wav",
	"radio/locknload.wav",
	"radio/matedown.wav",
	"radio/meetme.wav",
	"radio/moveout.wav",
	"radio/negative.wav",
	"radio/position.wav",
	"radio/regroup.wav",
	"radio/rescued.wav",
	"radio/roger.wav",
	"radio/rounddraw.wav",
	"radio/sticktog.wav",
	"radio/stormfront.wav",
	"radio/takepoint.wav",
	"radio/terwin.wav",
	"radio/vip.wav"
};

string sRadioChat[43] = {
	_("RADIO_BLOW"),
	_("RADIO_BOMBDEF"),
	_("RADIO_BOMBPL"),
	_("RADIO_CIRCLEBACK"),
	_("RADIO_CLEAR"),
	_("RADIO_COM_FOLLOWCOM"),
	_("RADIO_COM_GETINPOS"),
	_("RADIO_COM_GO"),
	_("RADIO_COM_REPORTIN"),
	_("RADIO_CT_AFFIRM"),
	_("RADIO_CT_BACKUP"),
	_("RADIO_CT_COVERME"),
	_("RADIO_CT_ENEMYS"),
	_("RADIO_CT_FIREINHOLE"),
	_("RADIO_CT_IMHIT"),
	_("RADIO_CT_INPOS"),
	_("RADIO_CT_POINT"),
	_("RADIO_CT_REPORTINGIN"),
	_("RADIO_CTWIN"),
	_("RADIO_ENEMYDOWN"),
	_("RADIO_FALLBACK"),
	_("RADIO_FIREASSIS"),
	_("RADIO_FOLLOWME"),
	_("RADIO_GETOUT"),
	_("RADIO_GO"),
	_("RADIO_HITASSIST"),
	_("RADIO_HOSDOWN"),
	_("RADIO_LETSGO"),
	_("RADIO_LOCKNLOAD"),
	_("RADIO_MATEDOWN"),
	_("RADIO_MEETME"),
	_("RADIO_MOVEOUT"),
	_("RADIO_NEGATIVE"),
	_("RADIO_POSITION"),
	_("RADIO_REGROUP"),
	_("RADIO_RESCUED"),
	_("RADIO_ROGER"),
	_("RADIO_ROUNDDRAW"),
	_("RADIO_STICKTOG"),
	_("RADIO_STORMFRONT"),
	_("RADIO_TAKEPOINT"),
	_("RADIO_TERWIN"),
	_("RADIO_VIP"),
};

/*
=================
Radio_InitSounds

Who doesn't love precaching sounds
=================
*/
void Radio_InitSounds( void ) {
	for ( int i = 0; i < 43; i++ ) {
		precache_sound( sRadioSamples[ i ] );
	}
}

/*
=================
Radio_PlayMessage

Play a radio message that doesn't come from a player
=================
*/
void Radio_PlayMessage( float fMessage ) {
	sound( world, CHAN_VOICE, sRadioSamples[ fMessage ], 1, ATTN_NONE, 0, SOUNDFLAG_NOSPACIALISE );
	CSQC_Parse_Print( sprintf( "^2[RADIO]^xF80: %s\n", sRadioChat[ fMessage ] ), PRINT_CHAT );
}

/*
=================
Radio_PlayPlayerMessage

This radio message does come from a player
=================
*/
void Radio_PlayPlayerMessage( float fPlayerNum, float fMessage ) {
	sound( world, CHAN_VOICE, sRadioSamples[ fMessage ], 1, ATTN_NONE, 0, SOUNDFLAG_NOSPACIALISE );
	CSQC_Parse_Print( sprintf( "^2[RADIO] %s%s^xF80: %s\n", HUD_GetChatColorHEX( stof( getplayerkeyvalue( fPlayerNum, "*team" ) ) ), getplayerkeyvalue( fPlayerNum, "name" ), sRadioChat[ fMessage ] ), PRINT_CHAT );
}
#endif


#ifdef SSQC
/*
=================
Radio_BroadcastMessage

A global radio message for all players
=================
*/
void Radio_BroadcastMessage( float fMessage ) {
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_RADIOMSG );
	WriteByte( MSG_MULTICAST, fMessage );
	msg_entity = self;
	multicast( '0 0 0', MSG_BROADCAST );
}

/*
=================
Radio_TeamMessage

A radio message targetted at members of a specific team
=================
*/
void Radio_TeamMessage( float fMessage, float fTeam ) {
	static void Radio_TeamMessage_Send( float fMessage, entity eEnt ) {
		WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
		WriteByte( MSG_MULTICAST, EV_RADIOMSG );
		WriteByte( MSG_MULTICAST, fMessage );
		msg_entity = eEnt;
		multicast( '0 0 0', MULTICAST_ONE );
	}
	
	for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
		if ( eFind.team == fTeam ) {
			Radio_TeamMessage_Send( fMessage, eFind );
		} else if ( eFind.team == TEAM_VIP && fTeam == TEAM_CT ) {
			Radio_TeamMessage_Send( fMessage, eFind );
		}
	}
}

/*
=================
Radio_DefaultStart

Pick a generic, random radio string for global start messages
=================
*/
float Radio_DefaultStart( void ) {
	float fRand = floor( random( 1, 4 ) );
	
	if ( fRand == 1 ) {
		return RADIO_MOVEOUT;
	} else if ( fRand == 2 ) {
		return RADIO_LOCKNLOAD;
	} else {
		return RADIO_LETSGO;
	}
}

/*
=================
Radio_StartMessage

Decide which startmessage to play at the beginning of each round
=================
*/
void Radio_StartMessage( void ) {
	if ( iVIPZones > 0 ) {
		Radio_TeamMessage( RADIO_VIP, TEAM_CT );
		Radio_TeamMessage( Radio_DefaultStart(), TEAM_T );
	} else if ( iEscapeZones > 0 ) {
		Radio_TeamMessage( RADIO_GETOUT, TEAM_T );
		Radio_TeamMessage( Radio_DefaultStart(), TEAM_CT );
	} else {
		Radio_BroadcastMessage( Radio_DefaultStart() );
	}
}

/*
=================
CSEv_RadioMessage_f

Triggered by clients, plays a message to members of the same team
=================
*/
void CSEv_RadioMessage_f( float fMessage ) {
	static void CSEv_RadioMessage_Send( float fMessage, entity eEnt ) {
		WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
		WriteByte( MSG_MULTICAST, EV_RADIOMSG2 );
		WriteByte( MSG_MULTICAST, num_for_edict( eEnt ) - 1 );
		WriteByte( MSG_MULTICAST, fMessage );
		msg_entity = eEnt;
		multicast( '0 0 0', MULTICAST_ONE );
	}
	
	// Don't allow spamming
	if ( self.fRadioFinished > time ) {
		return;
	}
	
	// When dead, don't talk
	if ( self.health <= 0 ) {
		return;
	}
	
	// Make sure that VIPs and CTs get eachother
	float fTargetTeam = self.team;
	if ( fTargetTeam == TEAM_VIP ) {
		fTargetTeam = TEAM_CT;
	}
	
	for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
		if ( eFind.team == fTargetTeam ) {
			CSEv_RadioMessage_Send( fMessage, eFind );
		} else if ( eFind.team == TEAM_VIP && fTargetTeam == TEAM_CT ) {
			CSEv_RadioMessage_Send( fMessage, eFind );
		}
	}
	
	self.fRadioFinished = time + 3.0f;
}
#endif
