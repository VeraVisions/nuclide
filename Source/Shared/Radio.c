/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

enum {
	RADIO_MODE_ALL = 0,
	RADIO_MODE_T,
	RADIO_MODE_CT
};

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

void Radio_InitSounds( void ) {
	for ( int i = 0; i < 43; i++ ) {
		precache_sound( sRadioSamples[ i ] );
	}
}
#endif

void Radio_BroadcastMessage( float fMessage ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_RADIOMSG );
	WriteByte( MSG_MULTICAST, fMessage );

	msg_entity = self;
	multicast( '0 0 0', MSG_BROADCAST );
#else 
	sound( world, CHAN_VOICE, sRadioSamples[ fMessage ], 1, ATTN_NONE, 0, SOUNDFLAG_NOSPACIALISE );
#endif
}
