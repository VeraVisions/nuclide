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

/*QUAKED ambient_generic (1 1 1) (-8 -8 -8) (8 8 8) AS_ARADIUS AS_SRADIUS AS_MRADIUS AS_LRADIUS AS_SILENT AS_NOTTOGGLED
Plays a sound sample of whatever format the engine is configured to support.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"message" : Sound file to play, or sentences.txt entry if prefixed with a '!'
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
	AMBIENT_PATH,
	AMBIENT_VOLUME,
	AMBIENT_RADIUS,
	AMBIENT_PITCH,
	AMBIENT_ORIGIN,
	AMBIENT_ENABLED
};

class ambient_generic:NSTalkMonster
{
	/* networked attributes */
	PREDICTED_STRING(m_strActivePath);
	PREDICTED_FLOAT(m_flVolume);
	PREDICTED_FLOAT(m_flRadius);
	PREDICTED_FLOAT(m_flPitch);
	PREDICTED_BOOL(m_bLoops);
	bool m_bToggle;

	/* spawn values */
	string m_strSpawnPath;
	float m_flSpawnVolume;
	float m_flSpawnPitch;

	void(void) ambient_generic;

	/* overrides */
	virtual void(void) Spawned;
#ifdef SERVER
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void(void) Respawn;
	virtual void(entity, int) UseNormal;
	virtual void(entity, int) UseLoop;
#else
	virtual void(float, float) ReceiveEntity;
	virtual float(void) predraw;
	virtual void(string) SentenceSample;
#endif
	virtual void(string, string) SpawnKey;
	virtual void(void) OnRemoveEntity;
};

void
ambient_generic::OnRemoveEntity(void)
{
	sound(this, CHAN_BODY, "common/null.wav", 0.1f, 0);
}

#ifdef SERVER
void
ambient_generic::Save(float handle)
{
	SaveString(handle, "activepath", m_strActivePath);
	SaveString(handle, "soundpath", m_strSpawnPath);
	SaveFloat(handle, "volume", m_flVolume);
	SaveFloat(handle, "radius", m_flRadius);
	SaveFloat(handle, "pitch", m_flPitch);
	SaveInt(handle, "toggleswitch", m_bToggle);
	SaveInt(handle, "loop", m_bLoops);
	super::Save(handle);
}

void
ambient_generic::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "loop":
		m_bLoops = ReadInt(strValue);
		break;
	case "toggleswitch":
		m_bToggle = ReadInt(strValue);
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
		m_strSpawnPath = ReadString(strValue);
		break;
	case "activepath":
		m_strActivePath = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
ambient_generic::UseNormal(entity act, int state)
{
	NSLog("Sound once: %S Volume: %f; Radius: %d; Pitch: %d", \
		m_strActivePath, m_flVolume, m_flRadius, m_flPitch);

	if (substring(m_strActivePath, 0, 1) == "!") {
		string seq = Sentences_GetSamples(m_strActivePath);

		if (seq == "")
			return;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SENTENCE);
		WriteEntity(MSG_MULTICAST, this);
		WriteString(MSG_MULTICAST, seq);
		msg_entity = this;
		multicast(origin, MULTICAST_PHS);
	} else
		sound(this, CHAN_BODY, m_strActivePath, m_flVolume, m_flRadius, m_flPitch);
}

void
ambient_generic::UseLoop(entity act, int state)
{
	if (m_bToggle == TRUE) {
		NSLog("^2ambient_generic::^3UseLoop^7: %s stops `%s`", 
			target, m_strActivePath);
		m_strActivePath = "common/null.wav";
	} else {
		m_strActivePath = m_strSpawnPath;
		NSLog("^2ambient_generic::^3UseLoop^7: %s plays `%s`", 
			target, m_strActivePath);
	}

	m_bToggle = 1 - m_bToggle;
}

void
ambient_generic::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	m_strActivePath = m_strSpawnPath;
	m_flPitch = m_flSpawnPitch;
	m_flVolume = m_flSpawnVolume;

	/* handle volume */
	if (!m_flSpawnVolume) {
		m_flVolume = 1.0f;
	}

	/* attenuation */
	if (HasSpawnFlags(AS_ARADIUS)) {
		m_flRadius = ATTN_NONE;
	} else if (HasSpawnFlags(AS_SRADIUS)) {
		m_flRadius = ATTN_IDLE;
	} else if (HasSpawnFlags(AS_MRADIUS)) {
		m_flRadius = ATTN_STATIC;
	} else if (HasSpawnFlags(AS_LRADIUS)) {
		m_flRadius = ATTN_NORM;
	} else {
		m_flRadius = ATTN_STATIC;
	}

	pvsflags = PVSF_USEPHS;

	if (HasSpawnFlags(AS_NOTTOGGLED)) {
		Trigger = UseNormal;
		m_bLoops = false;
	} else {
		m_bLoops = true;

		/* set our sample up */
		if (HasSpawnFlags(AS_SILENT)) {
			m_bToggle = false;
			m_strActivePath = "common/null.wav";
		} else {
			m_bToggle = true;
			m_strActivePath = m_strSpawnPath;
		}

		Trigger = UseLoop;
	}
}

void
ambient_generic::EvaluateEntity(void)
{
	if (ATTR_CHANGED(origin))
		SetSendFlags(AMBIENT_ORIGIN);
	if (ATTR_CHANGED(m_strActivePath))
		SetSendFlags(AMBIENT_PATH);
	if (ATTR_CHANGED(m_flVolume))
		SetSendFlags(AMBIENT_VOLUME);
	if (ATTR_CHANGED(m_flRadius))
		SetSendFlags(AMBIENT_RADIUS);
	if (ATTR_CHANGED(m_flPitch))
		SetSendFlags(AMBIENT_PITCH);
	if (ATTR_CHANGED(m_bLoops))
		SetSendFlags(AMBIENT_ENABLED);

	SAVE_STATE(origin);
	SAVE_STATE(m_strActivePath);
	SAVE_STATE(m_flVolume);
	SAVE_STATE(m_flRadius);
	SAVE_STATE(m_flPitch);
	SAVE_STATE(m_bLoops);
}

float
ambient_generic::SendEntity(entity ePEnt, float flChanged)
{
	if (m_bLoops == true && m_bToggle == false)
		return (0);

	WriteByte(MSG_ENTITY, ENT_AMBIENTSOUND);
	WriteFloat(MSG_ENTITY, flChanged);

	if (flChanged & AMBIENT_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	
	if (flChanged & AMBIENT_PATH)
		WriteString(MSG_ENTITY, m_strActivePath);
	if (flChanged & AMBIENT_VOLUME)
		WriteFloat(MSG_ENTITY, m_flVolume);
	if (flChanged & AMBIENT_RADIUS)
		WriteByte(MSG_ENTITY, m_flRadius);
	if (flChanged & AMBIENT_PITCH)
		WriteFloat(MSG_ENTITY, m_flPitch);
	if (flChanged & AMBIENT_ENABLED)
		WriteByte(MSG_ENTITY, m_bLoops);

	return (1);
}
#else
void
ambient_generic::ReceiveEntity(float isnew, float flChanged)
{
	if (flChanged & AMBIENT_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setsize(this, [0,0,0], [0,0,0]);
		setorigin(this, origin);
		drawmask = MASK_ENGINE;
	}
	
	if (flChanged & AMBIENT_PATH)
		m_strActivePath = readstring();
	if (flChanged & AMBIENT_VOLUME)
		m_flVolume = readfloat();
	if (flChanged & AMBIENT_RADIUS)
		m_flRadius = readbyte();
	if (flChanged & AMBIENT_PITCH)
		m_flPitch = readfloat();
	if (flChanged & AMBIENT_ENABLED)
		m_bLoops = readbyte();

	NSLog("Sound received: %S Volume: %f; Radius: %d; Pitch: %d", m_strActivePath, m_flVolume, m_flRadius, m_flPitch);


	if (m_bLoops == true)
		soundupdate(this, CHAN_BODY, m_strActivePath, m_flVolume, m_flRadius, m_flPitch, 0, 0);
}

void
ambient_generic::SentenceSample(string sample)
{
	/* honestly, the 0.25 for the radius is probably inaccurate (winged it), ATTN_NORM is too short though */
	sound(this, CHAN_VOICE, sample, 1.0, m_flRadius, 100, SOUNDFLAG_FOLLOW);
}

float
ambient_generic::predraw(void)
{
	ProcessWordQue();

	/* pause/unpause CHAN_VOICE, because yes these ents are used for SPEECH */
	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1) {
		/* resume; negative soundofs makes soundupdate act absolute */
		if (m_bWasPaused == true)
			soundupdate(this, CHAN_VOICE, "", 1.0, 0.25, 0, 0, -m_sndVoiceOffs);

		m_bWasPaused = false;
	} else {
		/* called once when pausing */
		if (m_bWasPaused == false)
			m_sndVoiceOffs = getsoundtime(this, CHAN_VOICE); /* length into the sample */

		/* make silent and keep updating so the sample doesn't stop */
		soundupdate(this, CHAN_VOICE, "", 0.0, 0.25, 0, 0, -m_sndVoiceOffs);
		m_bWasPaused = true;
	}

	return (PREDRAW_NEXT);
}
#endif

void
ambient_generic::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "message":
		m_strSpawnPath = strValue;
		precache_sound(m_strSpawnPath);
		message = __NULL__;
		break;
	case "volume":
		m_flSpawnVolume = stof(strValue);
		break;
	case "pitch":
		m_flSpawnPitch = stof(strValue);
		break;
	/* backwards compat */
	case "health":
		m_flSpawnVolume = stof(strValue) * 0.1f;
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
ambient_generic::Spawned(void)
{
	precache_sound("common/null.wav");
}

void
ambient_generic::ambient_generic(void)
{
}

#ifdef CLIENT
void
ambient_generic_ReadEntity(float new)
{
	ambient_generic me = (ambient_generic)self;
	if (new) {
		spawnfunc_ambient_generic();
	}
	me.ReceiveEntity(new, readfloat());
}
#endif
