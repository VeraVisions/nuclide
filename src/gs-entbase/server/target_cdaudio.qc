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

/*QUAKED target_cdaudio (1 0 0) (-8 -8 -8) (8 8 8)
A radius based trigger_cdaudio.
Disables itself upon activation.

-------- KEYS --------
"targetname" : Name
"health" : Music track to play (1-30). -1 to stop.
"radius" : Radius in which the entity will be triggered in.

-------- NOTES --------
I honestly don't know what the point is, as trigger_cdaudio should
act the same in practice.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class target_cdaudio:NSPointTrigger
{
	float m_flRadius;
	int m_iCDTrack;

	void(void) target_cdaudio;

	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
target_cdaudio::Save(float handle)
{
	SaveFloat(handle, "radius", m_flRadius);
	SaveInt(handle, "cdtrack", m_iCDTrack);
	super::Save(handle);
}

void
target_cdaudio::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "radius":
		m_flRadius = ReadFloat(strValue);
		break;
	case "cdtrack":
		m_iCDTrack = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
target_cdaudio::Touch(entity eToucher)
{
	if (!(eToucher.flags & FL_CLIENT)) {
		return;
	}

	dprint(sprintf("^2target_cdaudio::^3Trigger^7: CD Track %i requested\n", 
		m_iCDTrack));

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSICTRACK);
	WriteByte(MSG_MULTICAST, m_iCDTrack);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
	SetSolid(SOLID_NOT);
}

void
target_cdaudio::Respawn(void)
{
	geomtype = GEOMTYPE_SPHERE;
	mins = [-m_flRadius, -m_flRadius, -m_flRadius];
	maxs = [m_flRadius, m_flRadius, m_flRadius];
	SetSolid(SOLID_TRIGGER);
	SetSize(mins, maxs);
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
		super::SpawnKey(strKey, strValue);
	}
}

void
target_cdaudio::target_cdaudio(void)
{
	super::NSPointTrigger();
}
