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

class scripted_sentence:CBaseTrigger
{
	string m_strSpeaker;
	string m_strSentence;
	float m_flDelay;
	float m_flWait;
	float m_flPitch;

	void() scripted_sentence;
	virtual void() Trigger;
	virtual void() Respawn;
};

void scripted_sentence::Trigger(void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, find(world, ::classname, m_strSpeaker));
	WriteString(MSG_MULTICAST, m_strSentence);
	WriteFloat(MSG_MULTICAST, m_flPitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PHS);
}

/* TODO: Make this redundant */
void scripted_sentence::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void scripted_sentence::scripted_sentence(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "entity":
			m_strSpeaker = argv(i+1);
		case "sentence":
			m_strSentence = argv(i+1);
			break;
		case "pitch":
			m_flPitch = stof(argv(i+1));
			break;
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		case "wait":
			m_flWait = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
	scripted_sentence::Respawn();
}
