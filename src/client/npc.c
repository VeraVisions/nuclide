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

class CBaseNPC
{
	float m_flSentenceTime;
	sound_t *m_pSentenceQue;
	int m_iSentenceCount;
	int m_iSentencePos;

	int body;
	float frame_last;

	virtual float() predraw;
	virtual void(string) Speak;
	virtual void(string) Sentence;
	virtual void() ProcessWordQue;
	virtual void(float flChanged) ReadEntity;
};

void
CBaseNPC::Speak(string msg)
{
	sound(this, CHAN_VOICE, msg, 1.0, ATTN_NORM);
}

float
CBaseNPC::predraw(void)
{
	if (lerpfrac > 0) {
		lerpfrac -= frametime * 5;
		if (lerpfrac < 0) {
			lerpfrac = 0;
		}
	}

	if (frame != frame_last) {
		frame2time = frame1time;
		frame2 = frame_last;
		frame_last = frame;
		lerpfrac = 1.0f;
		frame1time = 0.0f;
	}

	frame2time += clframetime;
	frame1time += clframetime;
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;

	ProcessWordQue();

	addentity(this);
	return PREDRAW_NEXT;
}

void
CBaseNPC::ProcessWordQue(void)
{
	if (time < 2 || !m_iSentenceCount) {
		return;
	}

	if (m_flSentenceTime > time) {
		return;
	}
	Speak(m_pSentenceQue[m_iSentencePos].m_strSnd);
	dprint(sprintf("^2CBaseNPC: Speaking %s\n", m_pSentenceQue[m_iSentencePos].m_strSnd));
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
CBaseNPC::Sentence(string msg)
{
	/* not defined */
	if (msg == "") {
		return;
	}

	if (m_iSentenceCount) {
		dprint(sprintf("^1CBaseNPC::Sentence: Freeing que for new sentence\n", m_iSentenceCount));
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_pSentenceQue = 0;
		m_iSentencePos = 0;
	}

	m_iSentenceCount = tokenize(Sentences_GetSamples(msg));
	dprint(sprintf("^2CBaseNPC::Sentence: Speaking %i word/s\n", m_iSentenceCount));
	m_pSentenceQue = memalloc(sizeof(sound_t) * m_iSentenceCount);

	for (int i = 0; i < m_iSentenceCount; i++) {
		dprint(sprintf("^2CBaseNPC::Sentence: Constructing... %s\n", m_pSentenceQue[i].m_strSnd));
		m_pSentenceQue[i].m_strSnd = sprintf("%s.wav", argv(i));
		m_pSentenceQue[i].len = soundlength(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flPitch = 100;
	}
	m_flSentenceTime = time;
}

void
CBaseNPC::ReadEntity(float fl)
{
	if (fl & NPC_MODELINDEX)
		modelindex = readshort();
	if (fl & NPC_ORIGIN_X)
		origin[0] = readcoord();
	if (fl & NPC_ORIGIN_Y)
		origin[1] = readcoord();
	if (fl & NPC_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & NPC_ANGLES_X)
		angles[0] = readfloat();
	if (fl & NPC_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & NPC_ANGLES_Z)
		angles[2] = readfloat();
	if (fl & NPC_VELOCITY_X)
		velocity[0] = readcoord();
	if (fl & NPC_VELOCITY_Y)
		velocity[1] = readcoord();
	if (fl & NPC_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & NPC_FRAME)
		frame = readbyte();
	if (fl & NPC_SKIN)
		skin = readbyte();

	if (fl & NPC_BODY) {
		body = readbyte();
		setcustomskin(this, "", sprintf("geomset 1 %i\n", body));
	}

	setorigin(this, origin);
}

void
CBaseNPC::CBaseNPC(void)
{
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	customphysics = Empty;
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
}

/* our EV_SENTENCE event */
void
CBaseNPC_ParseSentence(void)
{
	entity ent;
	CBaseNPC targ;
	string sentence;
	float e;

	/* parse packets */
	e = readentitynum();
	sentence = readstring();

	ent = findfloat(world, entnum, e);

	if (ent) {
		targ = (CBaseNPC)ent;
		targ.Sentence(sentence);
	} else {
		dprint(sprintf("^1CBaseNPC_ParseSentence: Entity %d not in PVS\n", e));
	}
}
