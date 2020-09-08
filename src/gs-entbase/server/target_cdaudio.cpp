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

/*QUAKED target_cdaudio (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"health"        Music track to play (1-30). -1 to stop.
"radius"        Radius in which the entity will be triggered in.

A radius based trigger_cdaudio.
Disables itself upon activation.

I honestly don't know what the point is, as trigger_cdaudio should
act the same in practice.
*/

class target_cdaudio:CBaseTrigger
{
	float m_flRadius;
	int m_iCDTrack;

	void(void) target_cdaudio;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
target_cdaudio::touch(void)
{
	if (!(other.flags & FL_CLIENT)) {
		return;
	}

	dprint(sprintf("^2target_cdaudio::^3Trigger^7: CD Track %i requested\n", 
		m_iCDTrack));

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSICTRACK);
	WriteByte(MSG_MULTICAST, m_iCDTrack);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
	solid = SOLID_NOT;
}

void
target_cdaudio::Respawn(void)
{
	/* nobody cares that this is non-spherical... right? */
	solid = SOLID_TRIGGER;
	mins = [-m_flRadius, -m_flRadius, -m_flRadius];
	maxs = [m_flRadius, m_flRadius, m_flRadius];
	setsize(this, mins, maxs);
}

void
target_cdaudio::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		m_iCDTrack = stoi(strValue);
		break;
	case "radius":
		m_flRadius = stof(strValue) / 2;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
target_cdaudio::target_cdaudio(void)
{
	CBaseTrigger::CBaseTrigger();
}
