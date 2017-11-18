/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

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

/*
=================
Vox_TimeToString

Assumes time in minutes.
TODO: Actually output proper, tokenized strings for not just 1-10 minutes
=================
*/
string Vox_TimeToString( float fTime ) {
	fTime = rint( fTime );

	switch ( fTime ) {
		case 0: return "no"; 
		case 1: return "one";	
		case 2: return "two";	
		case 3: return "three";	
		case 4: return "four";	
		case 5: return "five";	
		case 6: return "six";	
		case 7: return "seven";	
		case 8: return "eight";	
		case 9: return "nine";	
		case 10: return "ten";	
		default: return "over ten";
	}
}

/*
=================
Vox_Broadcast

Broadcasts a VOX message to all players
=================
*/
void Vox_Broadcast( string sMessage ) {
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_CHAT_VOX );
	WriteString( MSG_MULTICAST, sMessage );
	msg_entity = world;
	multicast( '0 0 0', MULTICAST_ALL );	
}

/*
=================
Vox_Singlecast

Broadcasts a VOX message to one player
=================
*/
void Vox_Singlecast( entity eClient, string sMessage ) {
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_CHAT_VOX );
	WriteString( MSG_MULTICAST, sMessage );
	msg_entity = eClient;
	multicast( '0 0 0', MULTICAST_ONE_R );	
}