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

#ifdef SERVER
enumflags
{
	SPEAKFL_SILENT
};

string g_speaker_hlpresets[] = {
	"!C1A0_",
	"!C1A1_",
	"!C1A2_",
	"!C1A3_",
	"!C1A4_",
	"!C2A1_",
	"!C2A2_",
	"!C2A3_",
	"!C2A4_",
	"!C2A5_",
	"!C3A1_",
	"!C3A2_"
};
#endif

/*! \brief Shared-Entity: Announcement Speaker System */
/*!QUAKED speaker (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Creates a public announcement system that randomly plays announcements from
the sentences.txt file.

# KEYS
- "targetname" : Name
- "preset" : Preset sentence group.
- "message" : Sentence group name (used when preset is 0)
- "health" : Message volume (value from 0-10)

# NOTES
Valid values for 'preset":
    - 0 = Use Sentence group name
    - 1 = C1A0_
    - 2 = C1A1_
    - 3 = C1A2_
    - 4 = C1A3_
    - 5 = C1A4_
    - 6 = C2A1_
    - 7 = C2A2_
    - 8 = C2A3_
    - 9 = C2A4_
    - 10 = C2A5_
    - 11 = C3A1_
    - 12 = C3A2_

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup shared
@ingroup pointentity
*/
class
speaker:NSTalkMonster
{
public:
	void speaker(void);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	
	nonvirtual void Announce(void);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
#endif

#ifdef SERVER
private:

	string m_strSentence;
	float m_flVolume;
#endif
};

void
speaker::speaker(void)
{
#ifdef SERVER
	m_strSentence = __NULL__;
	m_flVolume = 1.0f;
#endif
}

#ifdef SERVER
void
speaker::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSentence", m_strSentence);
	SaveFloat(handle, "m_flVolume", m_flVolume);
}

void
speaker::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSentence":
		m_strSentence = ReadString(strValue);
		break;
	case "m_flVolume":
		m_flVolume = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
speaker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "preset":
		int p = stoi(strValue);

		/* fit in a valid preset string */
		if (p > 0 && p < g_speaker_hlpresets.length)
			m_strSentence = g_speaker_hlpresets[p-1];
		break;
	case "message":
		m_strSentence = strValue;
		break;
	case "health":
		m_flVolume = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
speaker::Spawned(void)
{
	/* HACK: avoid de-spawning */
	spawnflags |= MSF_MULTIPLAYER;

	super::Spawned();
}

void
speaker::Respawn(void)
{
	super::Respawn();

	if (HasSpawnFlags(SPEAKFL_SILENT) == false) {
		ScheduleThink(Announce, 10.0f);
	}
}

void
speaker::Announce(void)
{
	string seq = Sentences_GetSamples(m_strSentence);

	if (seq == "") {
		return;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, this);
	WriteInt(MSG_MULTICAST, Sentences_GetID(seq));
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);

	/* ...onto the next announcement */
	ScheduleThink(Announce, random(30.0f, 60.0f));
}

void
speaker::Trigger(entity eAct, triggermode_t foo)
{
	ScheduleThink(Announce, 0.0f);
}

void
speaker::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, MONFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, MONFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, MONFL_CHANGED_ORIGIN_Z)
}

/* Make sure StartFrame calls this */
float
speaker::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SPEAKER);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)

	return (1);
}
#endif

#ifdef CLIENT
void
speaker::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	SetOrigin(origin);
}
#endif