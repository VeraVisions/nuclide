/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
	AMBIENT_ENABLED,
	AMBIENT_MODERN
};

/*! \brief Shared-Entity: Sound/Sentence Emitter */
/*!QUAKED ambient_generic (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) ARADIUS SRADIUS MRADIUS LRADIUS SILENT NOTTOGGLED
# OVERVIEW
Plays a sound sample of whatever format the engine is configured to support.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "message" : Sound file to play, or [sentences.txt entry](@ref sentences) if prefixed with a '!'
- "volume" : Playback volume from 0.0 to 1.0 (default)
- "pitch" : Playback pitch, default is 100.

# SPAWNFLAGS
- ARADIUS (1) : Plays the sound everywhere. Heard by everyone.
- SRADIUS (2) : Small playback radius.
- MRADIUS (4) : Medium playback radius.
- LRADIUS (8) : Large playback radius.
- SILENT (16) : Start silent, trigger to make it play!
- NOTTOGGLED (32) : Don't toggle playback. When triggered, only play the sample once.

# NOTES
If you want it to loop, you have to give the sound file itself a loop flag.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup pointentity
*/
class ambient_generic:ncTalkMonster
{
public:
	void ambient_generic(void);

	/* overrides */
#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Precache(void);
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void UseNormal(entity,triggermode_t);
	virtual void UseLoop(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual void DebugDraw(void);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
	virtual void SentenceSample(string);
#endif
	virtual void OnRemoveEntity(void);

private:
	/* networked attributes */
	PREDICTED_STRING(m_strActivePath)
	PREDICTED_FLOAT(m_flVolume)
	PREDICTED_FLOAT(m_flRadius)
	PREDICTED_FLOAT(m_flPitch)
	PREDICTED_BOOL(m_bLoops)
	bool m_bToggle;
	bool m_bIsModern;

	/* spawn values */
	string m_strSpawnPath;
	float m_flSpawnVolume;
	float m_flSpawnPitch;
};

void
ambient_generic::ambient_generic(void)
{
	m_strActivePath = __NULL__;
	m_flVolume = 0.0f;
	m_flRadius = 0.0f;
	m_flPitch = 0.0f;
	m_bLoops = false;
	m_bToggle = false;
	m_bIsModern = false;
	m_strSpawnPath = __NULL__;
	m_flSpawnVolume = 0.0f;
	m_flSpawnPitch = 0.0f;
}

void
ambient_generic::OnRemoveEntity(void)
{
	sound(this, CHAN_BODY, "common/null.wav", 0.1f, 0);
}

#ifdef SERVER
void
ambient_generic::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strActivePath", m_strActivePath);
	SaveString(handle, "m_strSpawnPath", m_strSpawnPath);
	SaveFloat(handle, "m_flVolume", m_flVolume);
	SaveFloat(handle, "m_flRadius", m_flRadius);
	SaveFloat(handle, "m_flPitch", m_flPitch);
	SaveInt(handle, "m_bToggle", m_bToggle);
	SaveInt(handle, "m_bLoops", m_bLoops);
	SaveBool(handle, "m_bIsModern", m_bIsModern);
}

void
ambient_generic::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_bLoops":
		m_bLoops = ReadInt(setValue);
		break;
	case "m_bToggle":
		m_bToggle = ReadInt(setValue);
		break;
	case "m_flPitch":
		m_flPitch = ReadFloat(setValue);
		break;
	case "m_flRadius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "m_flVolume":
		m_flVolume = ReadFloat(setValue);
		break;
	case "m_strSpawnPath":
		m_strSpawnPath = ReadString(setValue);
		break;
	case "m_strActivePath":
		m_strActivePath = ReadString(setValue);
		break;
	case "m_bIsModern":
		m_bIsModern = ReadBool(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
ambient_generic::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "message":
		m_strSpawnPath = setValue;
		message = __NULL__;
		break;
	case "volume":
		m_flSpawnVolume = stof(setValue);
		break;
	case "pitch":
		m_flSpawnPitch = stof(setValue);
		break;
	/* backwards compat with GoldSrc/Source */
	case "health":
		m_flSpawnVolume = stof(setValue) * 0.1f;
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
	case "radius":
		m_bIsModern = true;
		break;
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
ambient_generic::Spawned(void)
{
	/* HACK: avoid de-spawning */
	spawnflags |= MSF_MULTIPLAYER;

	super::Spawned();
}

void
ambient_generic::Precache(void)
{
	precache.Sound(m_strSpawnPath);
}

void
ambient_generic::Respawn(void)
{
	super::Respawn();

	SetSize([0,0,0], [0,0,0]);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

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
		m_flRadius = ATTN_STATIC;
	} else if (HasSpawnFlags(AS_MRADIUS)) {
		m_flRadius = ATTN_IDLE;
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

	customphysics = __NULL__;
}

void
ambient_generic::DebugDraw(void)
{
	R_BeginPolygon("textures/editor/ambient_generic", 0, 0);
		R_PolygonVertex(GetOrigin() + v_right * 16 - v_up * 16, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 16 - v_up * 16, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 16 + v_up * 16, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(GetOrigin() + v_right * 16 + v_up * 16, [1,0], [1,1,1], 1.0f);
	R_EndPolygon();
}

void
ambient_generic::UseNormal(entity act, triggermode_t state)
{
	SndEntLog("Sample: %S Volume: %f; Radius: %d; Pitch: %f", m_strActivePath, m_flVolume, m_flRadius, m_flPitch);

	if (substring(m_strActivePath, 0, 1) == "!") {
		string sentenceWord = strtoupper(m_strActivePath);
		string seq = Sentences_GetSamples(sentenceWord);

		if (seq == "")
			return;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SENTENCE);
		WriteEntity(MSG_MULTICAST, this);
		WriteInt(MSG_MULTICAST, Sentences_GetID(sentenceWord));
		msg_entity = this;
		multicast(origin, MULTICAST_PHS);
	} else {
		/* if the file doesn't exist, assume it's a SoundDef */
		if (fileExists(strcat("sound/", m_strActivePath)) == false) {
			SoundDef_Play(this, CHAN_BODY, m_strActivePath);
		} else {
			sound(this, CHAN_BODY, m_strActivePath, m_flVolume, m_flRadius, m_flPitch);
		}
	}
}

void
ambient_generic::UseLoop(entity act, triggermode_t state)
{
	if (m_bToggle == true) {
		SndEntLog( "%s stops %S", target, m_strActivePath);
		m_strActivePath = "common/null.wav";
	} else {
		m_strActivePath = m_strSpawnPath;
		SndEntLog( "%s plays %S", target, m_strActivePath);
	}

	m_bToggle = !m_bToggle;
}

void
ambient_generic::Input(entity eAct, string strKey, string setValue)
{
	switch (strKey) {
	case "Pitch":
		m_flPitch = stof(setValue);
		break;
	case "PlaySound":
		m_bToggle = false;
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "StopSound":
		m_bToggle = true;
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "ToggleSound":
		m_bToggle = !m_bToggle;
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "Volume":
		m_flVolume = stof(setValue) / 10;
		break;
	default:
		super::Input(eAct, strKey, setValue);
	}
}

void
ambient_generic::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, AMBIENT_ORIGIN)
	EVALUATE_VECTOR(origin, 1, AMBIENT_ORIGIN)
	EVALUATE_VECTOR(origin, 2, AMBIENT_ORIGIN)
	EVALUATE_FIELD(m_strActivePath, AMBIENT_PATH)
	EVALUATE_FIELD(m_flVolume, AMBIENT_VOLUME)
	EVALUATE_FIELD(m_flRadius, AMBIENT_RADIUS)
	EVALUATE_FIELD(m_flPitch, AMBIENT_PITCH)
	EVALUATE_FIELD(m_bLoops, AMBIENT_ENABLED)
}

float
ambient_generic::SendEntity(entity ePEnt, float flChanged)
{
	if (m_bLoops == true && m_bToggle == false)
		return (0);

	WriteByte(MSG_ENTITY, ENT_AMBIENTSOUND);

	if (m_bIsModern) {
		flChanged |= AMBIENT_MODERN;
	} else {
		flChanged &= ~AMBIENT_MODERN;
	}

	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], AMBIENT_ORIGIN)
	SENDENTITY_COORD(origin[1], AMBIENT_ORIGIN)
	SENDENTITY_COORD(origin[2], AMBIENT_ORIGIN)

	if (flChanged & AMBIENT_PATH) {
		if (flChanged & AMBIENT_MODERN) {
			SENDENTITY_STRING(m_strActivePath, AMBIENT_PATH)
		} else {
			WriteFloat(MSG_ENTITY, getsoundindex(m_strActivePath, true));
			m_strActivePath_net = m_strActivePath;
		}
	}

	SENDENTITY_FLOAT(m_flVolume, AMBIENT_VOLUME)
	SENDENTITY_BYTE(m_flRadius, AMBIENT_RADIUS)
	SENDENTITY_FLOAT(m_flPitch, AMBIENT_PITCH)
	SENDENTITY_BYTE(m_bLoops, AMBIENT_ENABLED)

	return (1);
}
#endif

#ifdef CLIENT
void
ambient_generic::ReceiveEntity(float isnew, float flChanged)
{
	if (flChanged & AMBIENT_ORIGIN) {
		vector oldOrg = origin;
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		solid = SOLID_NOT;
		setsize(this, [0,0,0], [0,0,0]);
		setorigin(this, origin);
		drawmask = MASK_ENGINE;
	}
	
	if (flChanged & AMBIENT_PATH) {
		if (flChanged & AMBIENT_MODERN) {
			m_strActivePath = readstring();
		} else {
			m_strActivePath = soundnameforindex(readfloat());
		}
	}

	if (flChanged & AMBIENT_VOLUME)
		m_flVolume = readfloat();
	if (flChanged & AMBIENT_RADIUS)
		m_flRadius = readbyte();
	if (flChanged & AMBIENT_PITCH)
		m_flPitch = readfloat();
	if (flChanged & AMBIENT_ENABLED)
		m_bLoops = readbyte();

	SndEntLog("Received: %S Volume: %d%%; Radius: %d units; Pitch: %d, Org: %v", m_strActivePath, m_flVolume * 100, cvar("s_nominaldistance") / m_flRadius, m_flPitch, origin);

	if (m_bLoops == true) {
		if (flChanged & AMBIENT_MODERN) {
			SoundDef_Update(this, CHAN_BODY, SoundDef_GetID(m_strActivePath), m_flVolume);
		} else {
			soundupdate(this, CHAN_BODY, 
				m_strActivePath, m_flVolume, m_flRadius, m_flPitch, 0, 0);
		}
	}
}

void
ambient_generic::SentenceSample(string sample)
{
	/* honestly, the 0.25 for the radius is probably inaccurate (winged it), 
	   ATTN_NORM is too short though */
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
