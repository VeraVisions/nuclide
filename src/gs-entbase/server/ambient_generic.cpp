/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"message"       Sound file to play
"volume"        Playback volume from 0.0 to 1.0
"pitch"         Playback pitch from 0.0 to 2.0

Plays a sound sample of whatever format the engine is configured to support.
If you want it to loop, you have to give the file itself a loop flag.

TODO: Add a forced loop flag for non .wav samples?
*/

enumflags {
	AS_ARADIUS,
	AS_SRADIUS,
	AS_MRADIUS,
	AS_LRADIUS,
	AS_SILENT,
	AS_NOTTOGGLED
};

enumflags {
	AG_INFO,
	AG_SAMPLE
};

class ambient_generic:CBaseTrigger
{
	string m_strActivePath;
	string m_strSoundPath;
	float m_flVolume;
	float m_flRadius;
	float m_flPitch;
	int m_iToggleSwitch;
	int m_iLoop;

	void() ambient_generic;
	
	virtual void() Respawn;
	virtual void() UseNormal;
	virtual void() UseLoop;
	virtual float(entity, float) SendEntity;
};

float ambient_generic::SendEntity(entity ePEnt, float fChanged)
{
	/* only override when we're doing the toggle guff */
	if (m_iLoop == FALSE) {
		return FALSE;
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

	return TRUE;
}

void ambient_generic::UseNormal(void)
{
	sound(this, CHAN_VOICE, m_strActivePath, m_flVolume, m_flRadius, m_flPitch);
	print( sprintf( "%s::UseNormal: Play `%s`\n", 
		this.classname, m_strActivePath ) );
}

void ambient_generic::UseLoop(void)
{
	if (m_iToggleSwitch == TRUE) {
		dprint( sprintf( "%s::UseLoop: Stop `%s`\n", 
			this.classname, m_strActivePath ) );
		m_strActivePath = "common/null.wav";
	} else {
		m_strActivePath = m_strSoundPath;
		dprint( sprintf( "%s::UseLoop: Play `%s`\n", 
			this.classname, m_strActivePath ) );
	}

	m_iToggleSwitch = 1 - m_iToggleSwitch;
	SendFlags |= AG_SAMPLE;
}

void ambient_generic::Respawn(void)
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
		SendFlags |= AG_SAMPLE;
	}
}

void ambient_generic::ambient_generic(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "message":
			m_strSoundPath = argv(i+1);
			m_strActivePath = m_strSoundPath;
			message = __NULL__;
			break;
		case "health":
			m_flVolume = stof(argv(i+1)) * 0.1f;
			health = __NULL__;
			break;
		case "volume":
			m_flVolume = stof(argv(i+1));
			break;
		case "pitch":
			m_flPitch = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	if (!m_strSoundPath) {
		objerror("ambient_generic: No sound file specified!");
	}

	precache_sound(m_strSoundPath);

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
	CBaseTrigger::CBaseTrigger();
}
