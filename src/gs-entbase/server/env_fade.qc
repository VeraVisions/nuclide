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

/*QUAKED env_fade (0 0 0) (-8 -8 -8) (8 8 8) EVF_FADEDROM EVF_MODULATE EVF_ONLYUSER
Overlay that blinds/obscures players vision when triggered.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"rendercolor" : RGB8 Color of the fade effect.
"renderamt" : A8 alpha value we'll hit at max.
"duration" : Duration of the effect in seconds.
"holdtime" : How long we'll hold on the max color/alpha.

-------- SPAWNFLAGS --------
EVF_FADEDROM : Inverts the fading animation.
EVF_MODULATE : Modulate tints the image after "rendercolor" instead of obscuring it.
EVF_ONLYUSER : Don't blind everyone, just the activator.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	EVF_FADEDROM,
	EVF_MODULATE,
	EVF_ONLYUSER
};

class env_fade:NSRenderableEntity
{
	float m_flFadeDuration;
	float m_flFadeHold;

	void(void) env_fade;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
env_fade::Save(float handle)
{
	SaveFloat(handle, "fade_duration", m_flFadeDuration);
	SaveFloat(handle, "hold", m_flFadeHold);
	super::Save(handle);
}

void
env_fade::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "fade_duration":
		m_flFadeDuration = ReadFloat(strValue);
		break;
	case "hold":
		m_flFadeHold = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_fade::Trigger(entity act, int state)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_FADE);

#ifdef GS_RENDERFX
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteFloat(MSG_MULTICAST, m_flRenderAmt);
#else
	WriteFloat(MSG_MULTICAST, colormod[0]);
	WriteFloat(MSG_MULTICAST, colormod[1]);
	WriteFloat(MSG_MULTICAST, colormod[2]);
	WriteFloat(MSG_MULTICAST, alpha);
#endif

	WriteFloat(MSG_MULTICAST, m_flFadeDuration);
	WriteFloat(MSG_MULTICAST, m_flFadeHold);
	WriteByte(MSG_MULTICAST, spawnflags);
	msg_entity = act;

	if (HasSpawnFlags(EVF_ONLYUSER))
		multicast([0,0,0], MULTICAST_ONE_R);
	else
		multicast([0,0,0], MULTICAST_ALL);
}

void
env_fade::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "duration":
		m_flFadeDuration = stof(strValue);
		break;
	case "holdtime":
		m_flFadeHold = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_fade::env_fade(void)
{
}
