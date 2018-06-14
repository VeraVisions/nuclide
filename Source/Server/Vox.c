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
	localcmd( sprintf( "echo [VOX] Broadcast: %s\n", sMessage ) );
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
	localcmd( sprintf( "echo [VOX] Singlecast to %s: %s\n", eClient.netname, sMessage ) );
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_CHAT_VOX );
	WriteString( MSG_MULTICAST, sMessage );
	msg_entity = eClient;
	multicast( '0 0 0', MULTICAST_ONE_R );	
}
