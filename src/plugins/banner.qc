/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

#include "../shared/events.h"

void BannerPlugin_MapInfo(void);
void BannerPlugin_Hostname(void);

void
BannerPlug_Broadcast(string bmsg)
{

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_TEXT);
	WriteByte(MSG_MULTICAST, 1);
	WriteString(MSG_MULTICAST, bmsg);
	WriteFloat(MSG_MULTICAST, -1);
	WriteFloat(MSG_MULTICAST, 0.6);
	WriteByte(MSG_MULTICAST, 2);
	WriteByte(MSG_MULTICAST, 255);
	WriteByte(MSG_MULTICAST, 255);
	WriteByte(MSG_MULTICAST, 255);
	WriteByte(MSG_MULTICAST, 0);
	WriteByte(MSG_MULTICAST, 255);
	WriteByte(MSG_MULTICAST, 0);
	WriteFloat(MSG_MULTICAST, 0.01f);
	WriteFloat(MSG_MULTICAST, 0.5f);
	WriteFloat(MSG_MULTICAST, 4.0f);
	WriteFloat(MSG_MULTICAST, 0.25f);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
}

void
BannerPlugin_MapInfo(void)
{
	string bmsg;
	string mname;

	mname = serverkey("mapname");
	bmsg = sprintf("Hope you enjoy your time on ^2%s^7!", mname);
	BannerPlug_Broadcast(bmsg);

	/* loop back to the hostname info in 4 minutes */
	self.think = BannerPlugin_Hostname;
	self.nextthink = time + 240.0f;
}

void
BannerPlugin_Hostname(void)
{
	string bmsg;
	string hname;

	hname = cvar_string("hostname");
	bmsg = sprintf("You're playing on ^1%s^7.", hname);
	BannerPlug_Broadcast(bmsg);

	/* play the map info in 5 seconds */
	self.think = BannerPlugin_MapInfo;
	self.nextthink = time + 5.0f;
}

void
FMX_InitEnts(void)
{
	entity banner;
	banner = spawn();
	banner.think = BannerPlugin_Hostname;
	banner.nextthink = time + 30.0f;
}
