/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

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
