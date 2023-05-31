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

void
NSTalkMonster::NSTalkMonster(void)
{
#ifdef SERVER
	m_eFollowing = world;
	m_flPitch = 1.0f;
	m_flNextSentence = 0.0f;
	m_iFlags = 0i;
	m_eFollowingChain = __NULL__;
	m_vecLastUserPos = g_vec_null;
	m_flChangePath = 0.0f;
	m_flTraceTime = 0.0f;
	m_flFollowSpeedChanged = 0.0f;
	m_flFollowSpeed = 0.0f;
	m_talkAnswer = __NULL__;
	m_talkAsk = __NULL__;
	m_talkAllyShot = __NULL__;
	m_talkGreet = __NULL__;
	m_talkIdle = __NULL__;
	m_talkPanic = __NULL__;
	m_talkHearing = __NULL__;
	m_talkSmelling = __NULL__;
	m_talkStare = __NULL__;
	m_talkSurvived = __NULL__;
	m_talkWounded = __NULL__;
	m_talkAlert = __NULL__;
	m_talkPlayerAsk = __NULL__;
	m_talkPlayerGreet = __NULL__;
	m_talkPlayerIdle = __NULL__;
	m_talkPlayerWounded1 = __NULL__;
	m_talkPlayerWounded2 = __NULL__;
	m_talkPlayerWounded3 = __NULL__;
	m_talkUnfollow = __NULL__;
	m_talkFollow = __NULL__;
	m_talkStopFollow = __NULL__;
#else
	m_flSentenceTime = 0.0f;
	m_pSentenceQue = __NULL__;
	m_iSentenceCount = 0i;
	m_iSentencePos = 0i;
	m_sndVoiceOffs = 0.0f;
	m_bWasPaused = false;
#endif
}

void
NSTalkMonster::HandleAnimEvent(float flTimeStamp, int iCode, string strData)
{
	switch(iCode) {
#ifdef SERVER
	case 1005:	/* plays a dialogue sentence. monsters only right now */
		NSTalkMonster targ = (NSTalkMonster)self;
		targ.Sentence(strData);
		break;
#endif
	default:
		super::HandleAnimEvent(flTimeStamp, iCode, strData);
	}
}

#ifdef SERVER
void
NSTalkMonster::_Alerted(void)
{
	super::_Alerted();

	if (m_talkAlert)
		Sentence(m_talkAlert);
}

void
NSTalkMonster::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "m_flPitch", m_flPitch);
	SaveFloat(handle, "m_flNextSentence", m_flNextSentence);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveEntity(handle, "m_eFollowing", m_eFollowing);
	SaveEntity(handle, "m_eFollowingChain", m_eFollowingChain);
	SaveVector(handle, "m_vecLastUserPos", m_vecLastUserPos);
	SaveFloat(handle, "m_flChangePath", m_flChangePath);
	SaveFloat(handle, "m_flTraceTime", m_flTraceTime);
	SaveFloat(handle, "m_flFollowSpeedChanged", m_flFollowSpeedChanged);
	SaveFloat(handle, "m_flFollowSpeed", m_flFollowSpeed);

	SaveString(handle, "m_talkAnswer", m_talkAnswer);
	SaveString(handle, "m_talkAsk", m_talkAsk);
	SaveString(handle, "m_talkAllyShot", m_talkAllyShot);
	SaveString(handle, "m_talkGreet", m_talkGreet);
	SaveString(handle, "m_talkIdle", m_talkIdle);
	SaveString(handle, "m_talkPanic", m_talkPanic);
	SaveString(handle, "m_talkHearing", m_talkHearing);
	SaveString(handle, "m_talkSmelling", m_talkSmelling);
	SaveString(handle, "m_talkStare", m_talkStare);
	SaveString(handle, "m_talkSurvived", m_talkSurvived);
	SaveString(handle, "m_talkWounded", m_talkWounded);
	SaveString(handle, "m_talkAlert", m_talkAlert);
	SaveString(handle, "m_talkPlayerAsk", m_talkPlayerAsk);
	SaveString(handle, "m_talkPlayerGreet", m_talkPlayerGreet);
	SaveString(handle, "m_talkPlayerIdle", m_talkPlayerIdle);
	SaveString(handle, "m_talkPlayerWounded1", m_talkPlayerWounded1);
	SaveString(handle, "m_talkPlayerWounded2", m_talkPlayerWounded2);
	SaveString(handle, "m_talkPlayerWounded3", m_talkPlayerWounded3);
	SaveString(handle, "m_talkUnfollow", m_talkUnfollow);
	SaveString(handle, "m_talkFollow", m_talkFollow);
	SaveString(handle, "m_talkStopFollow", m_talkStopFollow);
}

void
NSTalkMonster::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flPitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "m_flNextSentence":
		m_flNextSentence = ReadFloat(strValue);
		break;
	case "m_iFlags":
		m_iFlags = ReadInt(strValue);
		break;
	case "m_eFollowing":
		m_eFollowing = ReadEntity(strValue);
		break;
	case "m_eFollowingChain":
		m_eFollowingChain = ReadEntity(strValue);
		break;
	case "m_vecLastUserPos":
		m_vecLastUserPos = ReadVector(strValue);
		break;
	case "m_flChangePath":
		m_flChangePath = ReadFloat(strValue);
		break;
	case "m_flTraceTime":
		m_flTraceTime = ReadFloat(strValue);
		break;
	case "m_flFollowSpeedChanged":
		m_flFollowSpeedChanged = ReadFloat(strValue);
		break;
	case "m_flFollowSpeed":
		m_flFollowSpeed = ReadFloat(strValue);
		break;
	case "m_talkAnswer":
		m_talkAnswer = ReadString(strValue);
		break;
	case "m_talkAsk":
		m_talkAsk = ReadString(strValue);
		break;
	case "m_talkAllyShot":
		m_talkAllyShot = ReadString(strValue);
		break;
	case "m_talkGreet":
		m_talkGreet = ReadString(strValue);
		break;
	case "m_talkIdle":
		m_talkIdle = ReadString(strValue);
		break;
	case "m_talkPanic":
		m_talkPanic = ReadString(strValue);
		break;
	case "m_talkHearing":
		m_talkHearing = ReadString(strValue);
		break;
	case "m_talkSmelling":
		m_talkSmelling = ReadString(strValue);
		break;
	case "m_talkStare":
		m_talkStare = ReadString(strValue);
		break;
	case "m_talkSurvived":
		m_talkSurvived = ReadString(strValue);
		break;
	case "m_talkWounded":
		m_talkWounded = ReadString(strValue);
		break;
	case "m_talkAlert":
		m_talkAlert = ReadString(strValue);
		break;
	case "m_talkPlayerAsk":
		m_talkPlayerAsk = ReadString(strValue);
		break;
	case "m_talkPlayerGreet":
		m_talkPlayerGreet = ReadString(strValue);
		break;
	case "m_talkPlayerIdle":
		m_talkPlayerIdle = ReadString(strValue);
		break;
	case "m_talkPlayerWounded1":
		m_talkPlayerWounded1 = ReadString(strValue);
		break;
	case "m_talkPlayerWounded2":
		m_talkPlayerWounded2 = ReadString(strValue);
		break;
	case "m_talkPlayerWounded3":
		m_talkPlayerWounded3 = ReadString(strValue);
		break;
	case "m_talkUnfollow":
		m_talkUnfollow = ReadString(strValue);
		break;
	case "m_talkFollow":
		m_talkFollow = ReadString(strValue);
		break;
	case "m_talkStopFollow":
		m_talkStopFollow = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSTalkMonster::WarnAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			NSTalkMonster w = (NSTalkMonster)b;
			w.m_iFlags |= MONSTER_METPLAYER;
			w.m_eFollowing = world;
			w.m_eFollowingChain = world;
		}
	}
}
void
NSTalkMonster::StartleAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			NSTalkMonster w = (NSTalkMonster)b;
			w.m_iFlags |= MONSTER_FEAR;
			w.m_eFollowing = world;
			w.m_eFollowingChain = world;
		}
	}
}

void
NSTalkMonster::Sentence(string sentence)
{
	if (GetState() == MONSTER_DEAD)
		return;

	string seq = Sentences_GetSamples(sentence);

	if (seq == "")
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, this);
	WriteInt(MSG_MULTICAST, Sentences_GetID(seq));
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
NSTalkMonster::Speak(string sentence)
{
	if (GetState() == MONSTER_DEAD)
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, sentence);
	WriteFloat(MSG_MULTICAST, m_flPitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
NSTalkMonster::TalkPlayerGreet(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	if (m_flNextSentence > time)
		return;

	if (m_iFlags & MONSTER_METPLAYER)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerGreet);
			m_flNextSentence = time + 10.0;
			m_iFlags |= MONSTER_METPLAYER;
			break;
		}
	}
}

void
NSTalkMonster::TalkPlayerIdle(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;
	if (HasSpawnFlags(MSF_PREDISASTER))
		return;
	if (m_flNextSentence > time)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {

		if (!IsFriend(p.m_iAlliance)) {
			continue;
		}

		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerIdle);
			m_flNextSentence = time + 10.0;
			break;
		}
	}
}

void
NSTalkMonster::TalkPlayerAsk(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;
	if (HasSpawnFlags(MSF_PREDISASTER))
		return;
	if (m_flNextSentence > time)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerAsk);
			m_flNextSentence = time + 10.0;
			break;
		}
	}
}

void
NSTalkMonster::TalkPlayerWounded1(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	if (m_flNextSentence > time)
		return;

	if (base_health < health)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_flNextSentence = time + 10.0;
			break;
		}
	}
}
void
NSTalkMonster::TalkPlayerWounded2(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	if (m_flNextSentence > time)
		return;

	if ((base_health / 2) < health)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_flNextSentence = time + 10.0;
			break;
		}
	}
}

void
NSTalkMonster::TalkPlayerWounded3(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	if (m_flNextSentence > time)
		return;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_flNextSentence = time + 10.0;
			break;
		}
	}
}

void
NSTalkMonster::TalkPanic(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkPanic);
	m_flNextSentence = time + 2.5;
}


void
NSTalkMonster::TalkUnfollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkUnfollow);
	m_flNextSentence = time + 10.0;
}

void
NSTalkMonster::TalkFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkFollow);
	m_flNextSentence = time + 10.0;
}

void
NSTalkMonster::TalkStopFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkStopFollow);
	m_flNextSentence = time + 10.0;
}

void
NSTalkMonster::FollowPlayer(void)
{
	float flPlayerDist;
	input_angles = vectoangles(m_eFollowingChain.origin - origin);
	input_angles[0] = 0;
	input_angles[1] = Math_FixDelta(input_angles[1]);
	input_angles[2] = 0;

	/* for best results, we want to ignore the Z plane
	   this avoids the problem of a follower spinning 
	    around when above/below you on a platform */
	vector vecParent = m_eFollowingChain.origin;
	vecParent[2] = origin[2];

	flPlayerDist = vlen(vecParent - origin);

	/* Give up after 1024 units */
	if (flPlayerDist > 1024) {
		m_eFollowing = world;
	} else if (flPlayerDist > 64) {
		/* we only allow speed changes every second, avoid jitter */
		if (m_flFollowSpeedChanged < time) {
			float flNextSpeed = GetChaseSpeed();

			/* if we're close enough, we ought to walk */
			if (flPlayerDist < 256)
				flNextSpeed = GetWalkSpeed();

			/* only update the timer when speed changed */
			if (flNextSpeed != m_flFollowSpeed) {
				m_flFollowSpeed = flNextSpeed;
				m_flFollowSpeedChanged = time + 1.0f;
			}
		}

		input_movevalues[0] = m_flFollowSpeed;

		other = world;
		traceline(origin, m_eFollowingChain.origin, MOVE_OTHERONLY, this);

		/* Tracing failed, there's world geometry in the way */
		if (trace_fraction < 1.0f) {
			input_angles = vectoangles(m_vecLastUserPos - origin);
			input_angles[0] = 0;
			input_angles[1] = Math_FixDelta(input_angles[1]);
			input_angles[2] = 0;
		} else {
			m_vecLastUserPos = m_eFollowingChain.origin;
		}

		/* Trace again to see if another hostage is in our path and if so
		 * follow them instead, this makes pathing easier */
		traceline(origin, /*mins, maxs,*/ m_vecLastUserPos, FALSE, this);
		if (trace_ent.classname == classname) {
			NSTalkMonster que = (NSTalkMonster)trace_ent;
			if (que.m_eFollowingChain == m_eFollowing) {
				if (trace_ent != this) {
					m_eFollowingChain = trace_ent;
				}
			}
		}
	}
}

void
NSTalkMonster::PanicFrame(void)
{
	m_iFlags |= MONSTER_METPLAYER;
	maxspeed = 240;
	input_movevalues = [maxspeed, 0, 0];

	if (m_flTraceTime < time) {
		traceline(origin, origin + (v_forward * 64), FALSE, this);
				
		if (trace_fraction < 1.0f) {
			m_flChangePath = 0.0f;
		}
		m_flTraceTime = time + 0.5f;
	}

	if (m_flChangePath < time) {
		input_angles[1] -= 180 + ((random() - 0.5) * 90);
		input_angles[1] = Math_FixDelta(input_angles[1]);
		m_flChangePath = time + floor(random(2,10));
	}

	if (m_flNextSentence > time)
		return;

	TalkPanic();
}

void
NSTalkMonster::FollowChain(void)
{
	/* Deal with a hostage being rescued when it's following someone else */
	if (m_eFollowingChain.classname == classname) {
		if (m_eFollowingChain.solid == SOLID_NOT) {
			m_eFollowingChain = m_eFollowing;
		}
	}
	/* Deal with the hostage losing its rescuer (death) */
	if (m_eFollowing.health <= 0) {
		m_eFollowing = world;
	}
}

void
NSTalkMonster::RunAI(void)
{
	SeeThink();
	AttackThink();
	TalkPlayerGreet();
	FollowChain();

	if (m_eFollowing != world) {
		FollowPlayer();
	} else if (m_iFlags & MONSTER_FEAR) {
		PanicFrame();
	} else {
		if (random() < 0.5) {
			TalkPlayerAsk();
		} else {
			TalkPlayerIdle();
		}
	}
}

void
NSTalkMonster::Respawn(void)
{
	NSMonster::Respawn();
	m_eFollowing = world;
	m_eFollowingChain = world;
}

void
NSTalkMonster::OnPlayerUse(void)
{
	if (m_iFlags & MONSTER_FEAR)
		return;

	/* can't press use any non-allies */
	if (!(m_iFlags & MONSTER_CANFOLLOW))
		return;

	if ((m_eFollowing == world)) {
		if (!(m_iFlags & MONSTER_USED)) {
			m_iFlags |= MONSTER_USED;
		}

		TalkFollow();
		m_eFollowing = eActivator;
		m_eFollowingChain = m_eFollowing;
		m_vecLastUserPos = m_eFollowing.origin;
	} else {
		TalkUnfollow();
		m_eFollowing = world;
	}
}

void
NSTalkMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "UnUseSentence":
		m_talkUnfollow = strcat("!", strValue);
		break;
	case "UseSentence":
		m_talkFollow = strcat("!", strValue);
		break;
	default:
		NSMonster::SpawnKey(strKey, strValue);
		break;
	}
}

float
NSTalkMonster::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_TALKMONSTER);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(view_ofs[2], MONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, MONFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, MONFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, MONFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], MONFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, MONFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, MONFL_CHANGED_SKINHEALTH)
	SENDENTITY_FLOAT(health, MONFL_CHANGED_SKINHEALTH)
	SENDENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	SENDENTITY_BYTE(m_iBody, MONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_ANGLE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)

	return (1);
}

#else

/*
============
NSTalkMonster::SentenceSample

whatever comes out of the 'mouth',
============
*/
void
NSTalkMonster::SentenceSample(string sample)
{
	sound(this, CHAN_VOICE, sample, 1.0, ATTN_NORM, 100, SOUNDFLAG_FOLLOW);
}

/*
============
NSTalkMonster::ProcessWordQue

Handles the sentences word que
============
*/
void
NSTalkMonster::ProcessWordQue(void)
{
	if (time < 1 || !m_iSentenceCount) {
		return;
	}

	if (m_flSentenceTime > time) {
		return;
	}

	SentenceSample(m_pSentenceQue[m_iSentencePos].m_strSnd);

	NSMonster_Log("^2NSEntity::^3ProcessWordQue^7: Speaking %s", m_pSentenceQue[m_iSentencePos].m_strSnd);
	m_iSentencePos++;

	if (m_iSentencePos == m_iSentenceCount) {
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_iSentencePos = 0;
		m_pSentenceQue = 0;
	} else {
		m_flSentenceTime = time + m_pSentenceQue[m_iSentencePos - 1].m_flLength;
	}
}

/*
============
NSTalkMonster::Sentence

we'll pass it a sentences.txt word (e.g. !BA_TEST) and start queing it
============
*/
void
NSTalkMonster::Sentence(string msg)
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

	/* first we have to get the info out of the token */
	for (int i = 0; i < m_iSentenceCount; i++) {
		m_pSentenceQue[i].m_strSnd = sprintf("%s.wav", argv(i));
	}

	/* process more info, we'll need to override argv() here */
	for (int i = 0; i < m_iSentenceCount; i++) {
		m_pSentenceQue[i].m_strSnd = Sentences_ProcessSample(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flLength = soundlength(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flPitch = 100;
	}
	m_flSentenceTime = time;
}

float
NSTalkMonster::predraw(void)
{
	//float render;
	//render = super::predraw();

	/* TODO: this is from NSRenderableEntity, shoul make these nonvirtual methods */
	{
	RenderFXPass();
	RenderDebugSkeleton();

	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1)
		frame1time += frametime;

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, HandleAnimEvent);
	} /* TODO end */

	/* mouth flapping action */
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;

	m_flBaseTime = frame1time;
	ProcessWordQue();

	/* pause/unpause CHAN_VOICE */
	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1) {
		/* resume; negative soundofs makes soundupdate act absolute */
		if (m_bWasPaused == true)
			soundupdate(this, CHAN_VOICE, "", 1.0, ATTN_NORM, 0, 0, -m_sndVoiceOffs);

		m_bWasPaused = false;
	} else {
		/* called once when pausing */
		if (m_bWasPaused == false)
			m_sndVoiceOffs = getsoundtime(this, CHAN_VOICE); /* length into the sample */

		/* make silent and keep updating so the sample doesn't stop */
		soundupdate(this, CHAN_VOICE, "", 0.0, ATTN_NORM, 0, 0, -m_sndVoiceOffs);
		m_bWasPaused = true;
	}

	addentity(this);
	_RenderDebugViewCone();

	return (PREDRAW_NEXT);
}

/*
============
NSTalkMonster::ReceiveEntity
============
*/
void
NSTalkMonster::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(view_ofs[2], MONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, MONFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, MONFL_CHANGED_FLAGS)
	READENTITY_INT(flags, MONFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], MONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], MONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], MONFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, MONFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, MONFL_CHANGED_SKINHEALTH)
	READENTITY_FLOAT(health, MONFL_CHANGED_SKINHEALTH)
	READENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	READENTITY_BYTE(m_iBody, MONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	READENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	READENTITY_ANGLE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & MONFL_CHANGED_FRAME)
		frame1time = 0.0f;
	if (flChanged & MONFL_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & MONFL_CHANGED_BODY)
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));

	setorigin(this, origin);
}

void
NSTalkMonster_ParseSentence(void)
{
	entity ent;
	NSTalkMonster targ;
	string sentence;
	float e;

	/* parse packets */
	e = readentitynum();
	sentence = Sentences_GetString(readint());

	ent = findfloat(world, entnum, e);

	if (ent) {
		if (ent.classname != "NSTalkMonster" && ent.classname != "ambient_generic")
		NSMonster_Log("^3 NSTalkMonster_ParseSentence ^7: Entity %d not a NSTalkMonster!", e);
		else {
			targ = (NSTalkMonster)ent;
			targ.Sentence(sentence);
			NSMonster_Log("^3 NSTalkMonster_ParseSentence ^7: Entity %d saying %s", e, sentence);
		}
	} else {
		NSMonster_Log("^3 NSTalkMonster_ParseSentence ^7: Entity %d not in PVS", e);
	}
}
#endif

#ifdef CLIENT
void
NSTalkMonster_ReadEntity(bool new)
{
	NSTalkMonster me = (NSTalkMonster)self;
	if (new) {
		spawnfunc_NSTalkMonster();
	}
	me.ReceiveEntity(new, readfloat());
}
#endif
