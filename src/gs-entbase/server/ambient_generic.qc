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

/*QUAKED ambient_generic (1 1 1) (-8 -8 -8) (8 8 8) AS_ARADIUS AS_SRADIUS AS_MRADIUS AS_LRADIUS AS_SILENT AS_NOTTOGGLED
Plays a sound sample of whatever format the engine is configured to support.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"message" : Sound file to play
"volume" : Playback volume from 0.0 to 1.0
"pitch" : Playback pitch from 0.0 to 2.0

-------- SPAWNFLAGS --------
AS_ARADIUS : Plays the sound everywhere. Heard by everyone.
AS_SRADIUS : Small playback radius.
AS_MRADIUS : Medium playback radius.
AS_LRADIUS : Large playback radius.
AS_SILENT : Start silent, trigger to make it play!
AS_NOTTOGGLED : Don't toggle playback. When triggered, only play the sample once.

-------- NOTES --------
If you want it to loop, you have to give the file itself a loop flag.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	AS_ARADIUS,
	AS_SRADIUS,
	AS_MRADIUS,
	AS_LRADIUS,
	AS_SILENT,
	AS_NOTTOGGLED
};

enumflags
{
	AG_INFO,
	AG_SAMPLE
};

class ambient_generic:NSPointTrigger
{
	string m_strActivePath;
	string m_strSoundPath;
	float m_flVolume;
	float m_flRadius;
	float m_flPitch;
	int m_iToggleSwitch;
	int m_iLoop;

	void(void) ambient_generic;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;

	virtual void(entity, int) UseNormal;
	virtual void(entity, int) UseLoop;
};

void
ambient_generic::Save(float handle)
{
	SaveInt(handle, "loop", m_iLoop);
	SaveInt(handle, "toggleswitch", m_iToggleSwitch);
	SaveFloat(handle, "pitch", m_flPitch);
	SaveFloat(handle, "radius", m_flRadius);
	SaveFloat(handle, "volume", m_flVolume);
	SaveString(handle, "soundpath", m_strSoundPath);
	SaveString(handle, "activepath", m_strActivePath);
	super::Save(handle);
}

void
ambient_generic::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "loop":
		m_iLoop = ReadInt(strValue);
		break;
	case "toggleswitch":
		m_iToggleSwitch = ReadInt(strValue);
		break;
	case "pitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "radius":
		m_flRadius = ReadFloat(strValue);
		break;
	case "volume":
		m_flVolume = ReadFloat(strValue);
		break;
	case "soundpath":
		m_strSoundPath = ReadString(strValue);
		break;
	case "activepath":
		m_strActivePath = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

float
ambient_generic::SendEntity(entity ePEnt, float fChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	/* only override when we're doing the toggle guff */
	if (m_iLoop == FALSE) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_AMBIENTSOUND);
	WriteFloat(MSG_ENTITY, fChanged);

	if (fChanged & AG_INFO) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
		WriteFloat(MSG_ENTITY, m_flVolume);
		WriteByte(MSG_ENTITY, m_flRadius);
		WriteFloat(MSG_ENTITY, m_flPitch);
	}

	/* TODO: work with soundindices? */
	if (fChanged & AG_SAMPLE) {
		WriteString(MSG_ENTITY, m_strActivePath);
	}

	return (1);
}

void
ambient_generic::UseNormal(entity act, int state)
{
	sound(this, CHAN_VOICE, m_strActivePath, m_flVolume, m_flRadius, m_flPitch);
	dprint(sprintf("^2ambient_generic::^3UseNormal^7: %s plays `%s`\n", 
		target, m_strActivePath));
}

void
ambient_generic::UseLoop(entity act, int state)
{
	if (m_iToggleSwitch == TRUE) {
		dprint(sprintf("^2ambient_generic::^3UseLoop^7: %s stops `%s`\n", 
			target, m_strActivePath));
		m_strActivePath = "common/null.wav";
	} else {
		m_strActivePath = m_strSoundPath;
		dprint(sprintf("^2ambient_generic::^3UseLoop^7: %s plays `%s`\n", 
			target, m_strActivePath));
	}

	m_iToggleSwitch = 1 - m_iToggleSwitch;
	SetSendFlags(AG_SAMPLE);
}

void
ambient_generic::Respawn(void)
{
	m_strActivePath = m_strSoundPath;

	if (spawnflags & AS_NOTTOGGLED) {
		Trigger = UseNormal;
		m_iLoop = FALSE;
	} else {
		m_iLoop = TRUE;

		/* set our sample up */
		if (spawnflags & AS_SILENT) {
			m_iToggleSwitch = FALSE;
			m_strActivePath = "common/null.wav";
		} else {
			m_iToggleSwitch = TRUE;
			m_strActivePath = m_strSoundPath;
		}

		Trigger = UseLoop;
		SetSendFlags(AG_SAMPLE);
	}
}

void
ambient_generic::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "message":
		m_strSoundPath = strValue;
		m_strActivePath = m_strSoundPath;
		precache_sound(m_strSoundPath);
		message = __NULL__;
		break;
	case "health":
		m_flVolume = stof(strValue) * 0.1f;
		health = __NULL__;
		break;
	case "volume":
		m_flVolume = stof(strValue);
		break;
	case "pitch":
		m_flPitch = stof(strValue);
		break;
	/* TODO: currently unimplemented */
	case "preset":
	case "volstart":
	case "fadein":
	case "fadeout":
	case "pitchstart":
	case "spinup":
	case "spindown":
	case "lfotype":
	case "lforate":
	case "lfomodpitch":
	case "lfomodvol":
	case "cspinup":
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
ambient_generic::ambient_generic(void)
{
	super::NSPointTrigger();

	if (!m_strSoundPath) {
		objerror("ambient_generic: No sound file specified!");
	}

	if (!m_flVolume) {
		m_flVolume = 1.0f;
	}

	// There can be only one
	if (spawnflags & AS_ARADIUS) {
		m_flRadius = ATTN_NONE;
	} else if (spawnflags & AS_SRADIUS) {
		m_flRadius = ATTN_IDLE;
	} else if (spawnflags & AS_MRADIUS) {
		m_flRadius = ATTN_STATIC;
	} else if (spawnflags & AS_LRADIUS) {
		m_flRadius = ATTN_NORM;
	} else {
		m_flRadius = ATTN_STATIC;
	}

	pvsflags = PVSF_USEPHS;
}
