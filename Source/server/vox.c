/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
Vox_TimeToString

Assumes time in minutes.
TODO: Actually output proper, tokenized strings for not just 1-10 minutes
=================
*/
string Vox_TimeToString(float fTime)
{
	fTime = rint(fTime);

	switch (fTime) {
		case 0: return "less than one";
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
void Vox_Broadcast(string sMessage)
{
	localcmd(sprintf("echo [VOX] Broadcast: %s\n", sMessage));
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CHAT_VOX);
	WriteString(MSG_MULTICAST, sMessage);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);	
}

/*
=================
Vox_Singlecast

Broadcasts a VOX message to one player
=================
*/
void Vox_Singlecast(entity eClient, string sMessage)
{
	localcmd(sprintf("echo [VOX] Singlecast to %s: %s\n", eClient.netname, sMessage));
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CHAT_VOX);
	WriteString(MSG_MULTICAST, sMessage);
	msg_entity = eClient;
	multicast([0,0,0], MULTICAST_ONE_R);
}
