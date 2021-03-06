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

/* NPCs are more advanced than regular monsters in that they express emotions
 * and are able to interact more with the environment */

#define PLAYER_DETECT_RADIUS 512

enumflags
{
	MONSTER_USED,
	MONSTER_FEAR,
	MONSTER_METPLAYER,
	MONSTER_FALLING,
	MONSTER_CANFOLLOW
};

class CBaseNPC:CBaseMonster
{
	/* our NPCs can have a unique pitch to their voice */
	float m_flPitch;
	float m_flNextSentence;
	int m_iFlags;

	entity m_eFollowing;
	entity m_eFollowingChain;
	vector m_vecLastUserPos;
	float m_flChangePath;
	float m_flTraceTime;

	/* sentences identifiers */
	string m_talkAnswer; /* random answer to whenever a question is asked */
	string m_talkAsk; /* asks a random generic question */
	string m_talkAllyShot; /* asks to not shoot an ally further */
	string m_talkGreet; /* greet other NPCs */
	string m_talkIdle; /* idle chatter */
	string m_talkPanic; /* panic screams */
	string m_talkHearing; /* what did we just hear? */
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

	void(void) CBaseNPC;
	virtual void(string) Speak;
	virtual void(string) Sentence;
	virtual void(void) WarnAllies;
	virtual void(void) StartleAllies;
	virtual void(void) FollowPlayer;
	virtual void(void) FollowChain;
	virtual void(void) Physics;
	virtual void(void) OnPlayerUse;
	virtual void(void) PanicFrame;
	virtual void(void) Hide;
	virtual void(void) Respawn;

	/*virtual void(void) TalkAnswer;
	virtual void(void) TalkAsk;
	virtual void(void) TalkAllyShot;
	virtual void(void) TalkGreet;
	virtual void(void) TalkIdle;
	virtual void(void) TalkHearing;
	virtual void(void) TalkSmelling;
	virtual void(void) TalkStare;
	virtual void(void) TalkSurvived;
	virtual void(void) TalkWounded;*/
	virtual void(void) TalkPanic;
	virtual void(void) TalkPlayerAsk; 
	virtual void(void) TalkPlayerGreet;
	virtual void(void) TalkPlayerIdle;
	virtual void(void) TalkPlayerWounded1;
	virtual void(void) TalkPlayerWounded2;
	virtual void(void) TalkPlayerWounded3;
	virtual void(void) TalkUnfollow;
	virtual void(void) TalkFollow;
	virtual void(void) TalkStopFollow;
	virtual void(string, string) SpawnKey;
};
