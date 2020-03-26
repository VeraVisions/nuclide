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

string __fullspawndata;
string Sentences_GetSamples(string);

// keep in sync with client/baseentity.cpp
enumflags
{
	BASEFL_CHANGED_ORIGIN,
	BASEFL_CHANGED_ANGLES,
	BASEFL_CHANGED_MODELINDEX,
	BASEFL_CHANGED_SIZE,
	BASEFL_CHANGED_SOLID,
	BASEFL_CHANGED_FRAME,
	BASEFL_CHANGED_SKIN,
	BASEFL_CHANGED_MOVETYPE,
	BASEFL_CHANGED_ALPHA,
	BASEFL_CHANGED_EFFECTS
};

class CBaseEntity
{
	float m_flSentenceTime;
	sound_t *m_pSentenceQue;
	int m_iSentenceCount;
	int m_iSentencePos;

	string targetname;
	string target;
	float spawnflags;

	void() CBaseEntity;
	virtual void() Init;
	virtual void() Initialized;
	virtual void(string, string) SpawnKey;
	virtual void(string) Sentence;
	virtual void() ProcessWordQue;
	virtual void(float flChanged) ReadEntity;
	virtual float(void) predraw;
};

float
CBaseEntity::predraw(void)
{
	frame1time += clframetime;
	ProcessWordQue();
	addentity(this);
	return PREDRAW_NEXT;
}

void
CBaseEntity::ProcessWordQue(void)
{
	if (time < 1 || !m_iSentenceCount) {
		return;
	}

	if (m_flSentenceTime > time) {
		return;
	}

	sound(this, CHAN_VOICE, m_pSentenceQue[m_iSentencePos].m_strSnd, 1.0, ATTN_NORM);
	dprint(sprintf("^2CBaseEntity::ProcessWordQue^7: Speaking %s\n", m_pSentenceQue[m_iSentencePos].m_strSnd));
	m_iSentencePos++;

	if (m_iSentenceCount == m_iSentenceCount) {
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_iSentencePos = 0;
		m_pSentenceQue = 0;
	} else {
		m_flSentenceTime = time + m_pSentenceQue[m_iSentenceCount - 1].len;
	}
}

/* we'll pass it a sentences.txt word (e.g. !BA_TEST) and start queing it */
void
CBaseEntity::Sentence(string msg)
{
	/* not defined */
	if (msg == "") {
		return;
	}

	if (m_iSentenceCount) {
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_pSentenceQue = 0;
		m_iSentencePos = 0;
	}

	m_iSentenceCount = tokenize(Sentences_GetSamples(msg));
	m_pSentenceQue = memalloc(sizeof(sound_t) * m_iSentenceCount);

	for (int i = 0; i < m_iSentenceCount; i++) {
		m_pSentenceQue[i].m_strSnd = sprintf("%s.wav", argv(i));
		m_pSentenceQue[i].len = soundlength(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flPitch = 100;
	}
	m_flSentenceTime = time;
}

void CBaseEntity::ReadEntity(float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		modelindex = readshort();
	}
	if (flChanged & BASEFL_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & BASEFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_FRAME) {
		frame1time = 0.0;
		frame = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & BASEFL_CHANGED_ALPHA) {
		alpha = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_EFFECTS) {
		effects = readfloat();
	}

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	setorigin(this, origin);
	setsize(this, mins, maxs);
}

void CBaseEntity::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		/* compiler specific stuff */
		case "angle":
		case "_minlight":
		case "_cs":
			break;
		case "shadows":
			if (stof(strKey) == 1) {
				effects &= ~EF_NOSHADOW;
			}
			break;
		case "targetname":
			targetname = strKey;
			break;
		case "target":
			target = strKey;
			break;
		case "origin":
			origin = stov(strKey);
			setorigin(this, origin);
			break;
		case "angles":
			angles = stov(strKey);
			break;
		case "model":
			model = strKey;
			break;
		case "style":
			style = stof(strKey);
			break;
		case "color":
			color = stov(strKey);
			break;
		case "movetype":
			movetype = stof(strKey);
			break;
		case "solid":
			solid = stof(strKey);
			break;
		case "scale":
			scale = stof(strKey);
			break;
		case "spawnflags":
			spawnflags = stof(strKey);
			break;
		default:
#ifdef GS_DEVELOPER
			print( sprintf( "%s::SpawnKey: Unknown '%s' value '%s'\n", 
				this.classname, strField, strKey ) );
#endif
	}
}

void CBaseEntity::Init(void)
{
	effects |= EF_NOSHADOW;
	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}
	Initialized();
}

void CBaseEntity::Initialized(void)
{
}

void CBaseEntity::CBaseEntity(void)
{
}

/* our EV_SENTENCE event */
void
CBaseEntity_ParseSentence(void)
{
	entity ent;
	CBaseEntity targ;
	string sentence;
	float e;

	/* parse packets */
	e = readentitynum();
	sentence = readstring();

	ent = findfloat(world, entnum, e);

	if (ent) {
		targ = (CBaseEntity)ent;
		targ.Sentence(sentence);
	} else {
		print(sprintf("^1CBaseNPC_ParseSentence^7: Entity %d not in PVS\n", e));
	}
}
