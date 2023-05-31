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

/* NPCs are more advanced than regular monsters in that they express emotions
 * and are able to interact more with the environment */

#ifdef SERVER
#define PLAYER_DETECT_RADIUS 512

enumflags
{
	MONSTER_USED,
	MONSTER_FEAR,
	MONSTER_METPLAYER,
	MONSTER_CANFOLLOW
};
#endif

/** This class represents NSMonsters that talk. They need to network extra
information and can speak more complicated dialogue.

They also can communicate with other NSTalkMonster based entities.
*/
class NSTalkMonster:NSMonster
{
public:
	void NSTalkMonster(void);

	/** When called, will play a [Sentence](Sentences.md) over the network. */
	virtual void Sentence(string);

#ifdef SERVER
	/** When called, will play a single sample (.wav/.ogg) over the network. */
	virtual void Speak(string);
	/** When called, will alert all allies in a nearby area. */
	virtual void WarnAllies(void);
	/** When called, will startle all allies in a nearby area. */
	virtual void StartleAllies(void);
	/** Internal use only.
	Run every frame to run after the player we are set to follow. */
	virtual void FollowPlayer(void);
	/** Internal use only.
	Run every frame to update who we're following in the chain */
	virtual void FollowChain(void);
	virtual void RunAI(void);
	/** Run every frame if we're in a state of panic. */
	virtual void PanicFrame(void);

	virtual void OnPlayerUse(void);
	//virtual void Hide(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual float SendEntity(entity,float);
	virtual void Save(float);
	virtual void Restore(string,string);

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

	/** Called when they're in a state of panic. */
	virtual void TalkPanic(void);
	/** Called when they want to ask the player a question. */
	virtual void TalkPlayerAsk(void);
	/** Called when they are greeting the player. */
	virtual void TalkPlayerGreet(void);
	/** Called when they are chit-chatting with the player. */
	virtual void TalkPlayerIdle(void);
	/** Called when they tell the player that they're wounded. */
	virtual void TalkPlayerWounded1(void);
	/** Called when they tell the player that severely wounded. */
	virtual void TalkPlayerWounded2(void);
	/** Called when they tell the player that they're near death. */
	virtual void TalkPlayerWounded3(void);
	/** Called when they tell the player that they'll give up following. */
	virtual void TalkUnfollow(void);
	/** Called when they tell the player that they'll start following. */
	virtual void TalkFollow(void);
	/** Called when they tell the player that they'll stop following. */
	virtual void TalkStopFollow(void);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);

	/** Plays a single sample from a sentence. */
	virtual void SentenceSample(string);
	/** Called once per frame to process the word queue */
	virtual void ProcessWordQue(void);
#endif

	/* model events */
	virtual void HandleAnimEvent(float,int,string);

private:
#ifdef SERVER
	/* our NPCs can have a unique pitch to their voice */
	float m_flPitch;
	float m_flNextSentence;
	int m_iFlags;

	entity m_eFollowing;
	entity m_eFollowingChain;
	vector m_vecLastUserPos;
	float m_flChangePath;
	float m_flTraceTime;
	float m_flFollowSpeedChanged;
	float m_flFollowSpeed;
	

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
	string m_talkAlert; /* we've been alerted to a threat */

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

	virtual void _Alerted(void);
#endif

#ifdef CLIENT
	/* sentence system */
	float m_flSentenceTime;
	sound_t *m_pSentenceQue;
	int m_iSentenceCount;
	int m_iSentencePos;
	float m_sndVoiceOffs;
	bool m_bWasPaused;
#endif
};

#ifdef CLIENT
void NSTalkMonster_ParseSentence(void);
void NSTalkMonster_ReadEntity(bool);
#endif
