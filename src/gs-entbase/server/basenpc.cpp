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

/* NPCs are more advanced than regular monsters in that they express emotions
 * and are able to interact more with the environment */

class CBaseNPC:CBaseMonster
{
	/* our NPCs can have a unique pitch to their voice */
	float m_flPitch;

	/* sentences identifiers */
	string m_talkAnswer; /* random answer to whenever a question is asked */
	string m_talkAsk; /* asks a random generic question */
	string m_talkAllyShot; /* asks to not shoot an ally further */
	string m_talkGreet; /* greet other NPCs */
	string m_talkIdle; /* idle chatter */
	string m_talkSmelling; /* is something smelling bad? */
	string m_talkStare; /* when NPC is being stared at */
	string m_talkSurvived; /* we're near death */
	string m_talkWounded; /* we've sustained light wounds */

	/* things that NPCs will only say to the player */
	string m_talkPlayerAsk; /* ask player some question */
	string m_talkPlayerGreet; /* say hello to the player */
	string m_talkPlayerIdle; /* idle chatter with the player */
	string m_talkPlayerWounded1; /* slightly wounded player comment */
	string m_talkPlayerWounded2; /* a bit worse */
	string m_talkPlayerWounded3; /* yup, got thus far */
	string m_talkUnfollow; /* when the player asks us to stop following */
	string m_talkFollow; /* whenever player asks the NPC to follow */
	string m_talkStopFollow; /* we have to stop following */

	void() CBaseNPC;
	virtual void(string) Speak;
	virtual void(string) Sentence;
};

void
CBaseNPC::Sentence(string sentence)
{
	string seq = Sentences_GetSamples(sentence);

	print(sprintf("^2CBaseNPC::Sentence: Attempting %s\n", seq));

	if (seq == "") {
		return;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, seq);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
CBaseNPC::Speak(string sentence)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, sentence);
	WriteFloat(MSG_MULTICAST, m_flPitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
CBaseNPC::CBaseNPC(void)
{

}
