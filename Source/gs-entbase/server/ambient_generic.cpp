/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags {
	AS_ARADIUS,
	AS_SRADIUS,
	AS_MRADIUS,
	AS_LRADIUS,
	AS_SILENT,
	AS_NOTTOGGLED
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
};

void ambient_generic::UseNormal(void)
{
	sound(this, CHAN_VOICE, m_strActivePath, m_flVolume, m_flRadius, m_flPitch);
}

void ambient_generic::UseLoop(void)
{
	if (m_iToggleSwitch == TRUE) {
		m_strActivePath = "common/null.wav";
	} else {
		m_strActivePath = m_strSoundPath;
	}
	m_iToggleSwitch = 1 - m_iToggleSwitch;
	UseNormal();
}

void ambient_generic::Respawn(void)
{
	m_strActivePath = m_strSoundPath;

	if (spawnflags & AS_NOTTOGGLED) {
		Trigger = UseNormal;
		m_iLoop = FALSE;
	} else {
		m_iLoop = TRUE;
	}

	if (spawnflags & AS_SILENT) {
		m_iToggleSwitch = FALSE;
	} else {
		m_iToggleSwitch = TRUE;
		UseNormal();
	}

	if (m_iLoop) {
		Trigger = UseLoop;
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

	CBaseTrigger::CBaseTrigger();
	ambient_generic::Respawn();
}
