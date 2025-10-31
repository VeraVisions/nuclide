/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/* one-time network events */
enum
{
	EV_INTERMISSION,
	EV_MUSICTRACK,
	EV_MUSICLOOP,
	EV_MUSIC_ONCE,
	EV_MUSIC_LOOP,
	EV_MUSIC_STOP,
	EV_ENTITYEVENT,
	EV_PICKUP,
	EV_DAMAGE,
	EV_HITNOTIFY,
	EV_ANGLE,
	EV_IMPACT,
	EV_GIBHUMAN,
	EV_EXPLOSION,
	EV_SPARK,
	EV_SHAKE,
	EV_HUDHINT,
	EV_FADE,
	EV_TEXT,
	EV_TEXT_STRING,
	EV_MESSAGE,
	EV_SPRITE,
	EV_MODELGIB,
	EV_CAMERATRIGGER,
	EV_OLDREMOVEME,
	EV_OBITUARY, // new one
	EV_SPEAK,
	EV_SENTENCE,
	EV_CHAT,
	EV_CHAT_TEAM,
	EV_CHAT_VOX,
	EV_GPRINT,
	EV_VIEWMODEL,
	EV_CLEARDECALS,
	EV_SURFIMPACT,
	EV_SURFIMPACTID,
	EV_DECALGROUP,
	EV_BREAKMODELDATA,
	EV_BREAKMODEL,
	EV_BEAMCYLINDER,
	EV_MUZZLEFLASH,
	EV_TRACEDEBUG,
	EV_ACHIEVEMENT,
	EV_MOTD_CHANGED,
	EV_GAME_SAVED,
	EV_SEPARATOR
};

#ifdef SERVER
/** A single, no-parameter event that is reliably sent over the network
	to anyone connected to the game.
    Used merely to minimize space */
void
networkEventBroadcast(float eventType)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, eventType);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}

/** A single, no-parameter event that is reliably sent over the network
	to anyone within a specific PVS (or in laymans terms, location)
	to optimize network usage. Used mainly for cosmetics, or fluff located
	to a certain region of a map. */
void
networkEventInPVS(float eventType, vector castAtPos)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, eventType);
	msg_entity = world;
	multicast(castAtPos, MULTICAST_PVS_R);
}

/** A single, no-parameter event that is reliably sent over the network to
	an individual client. */
void
networkEventSingle(float eventType, entity targetEntity)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, eventType);
	msg_entity = targetEntity;
	multicast([0,0,0], MULTICAST_ONE_R);
}
#endif
