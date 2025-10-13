/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
ncTalkMonster::ncTalkMonster(void)
{
#ifdef SERVER
	m_followingEntity = world;
	m_sentencePitch = 1.0f;
	m_sentenceNext = 0.0f;
	m_iFlags = 0i;
	m_useFollowChain = __NULL__;
	m_useLastAtPosition = g_vec_null;
	m_useFollowChangePathTime = 0.0f;
	m_useFollowTraceTime = 0.0f;
	m_useFollowSpeedChanged = 0.0f;
	m_useFollowSpeed = 0.0f;
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
	m_talkDenyFollow = __NULL__;
	m_bFollowOnUse = false;
	m_flFollowDistance = 128.0f;
	m_flMaxFollowDistance = 2048.0f;
	m_bFollowGrouping = false;
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
ncTalkMonster::HandleAnimEvent(float flTimeStamp, int iCode, string strData)
{
	switch(iCode) {
	case 1005:	/* plays a dialogue sentence. monsters only right now */
#ifdef SERVER
		Sentence(strData);
#endif
		break;
	case 1009: /* play names sequence with 25% chance */
#ifdef SERVER
		if (random() < 0.25) {
			Sentence(strData);
		}
#endif
		break;
	default:
		super::HandleAnimEvent(flTimeStamp, iCode, strData);
	}
}

#ifdef SERVER
void
ncTalkMonster::_Alerted(void)
{
	super::_Alerted();

	if (m_talkAlert)
		Sentence(m_talkAlert);
}

void
ncTalkMonster::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "m_sentencePitch", m_sentencePitch);
	SaveFloat(handle, "m_sentenceNext", m_sentenceNext);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveEntity(handle, "m_followingEntity", m_followingEntity);
	SaveEntity(handle, "m_useFollowChain", m_useFollowChain);
	SaveVector(handle, "m_useLastAtPosition", m_useLastAtPosition);
	SaveFloat(handle, "m_useFollowChangePathTime", m_useFollowChangePathTime);
	SaveFloat(handle, "m_useFollowTraceTime", m_useFollowTraceTime);
	SaveFloat(handle, "m_useFollowSpeedChanged", m_useFollowSpeedChanged);
	SaveFloat(handle, "m_useFollowSpeed", m_useFollowSpeed);
	SaveBool(handle, "m_bFollowOnUse", m_bFollowOnUse);
	SaveFloat(handle, "m_flFollowDistance", m_flFollowDistance);
	SaveFloat(handle, "m_flMaxFollowDistance", m_flMaxFollowDistance);

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
	SaveString(handle, "m_talkDenyFollow", m_talkDenyFollow);
}

void
ncTalkMonster::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_sentencePitch":
		m_sentencePitch = ReadFloat(setValue);
		break;
	case "m_sentenceNext":
		m_sentenceNext = ReadFloat(setValue);
		break;
	case "m_iFlags":
		m_iFlags = ReadInt(setValue);
		break;
	case "m_followingEntity":
		m_followingEntity = ReadEntity(setValue);
		break;
	case "m_useFollowChain":
		m_useFollowChain = ReadEntity(setValue);
		break;
	case "m_useLastAtPosition":
		m_useLastAtPosition = ReadVector(setValue);
		break;
	case "m_useFollowChangePathTime":
		m_useFollowChangePathTime = ReadFloat(setValue);
		break;
	case "m_useFollowTraceTime":
		m_useFollowTraceTime = ReadFloat(setValue);
		break;
	case "m_useFollowSpeedChanged":
		m_useFollowSpeedChanged = ReadFloat(setValue);
		break;
	case "m_useFollowSpeed":
		m_useFollowSpeed = ReadFloat(setValue);
		break;
	case "m_bFollowOnUse":
		m_bFollowOnUse = ReadBool(setValue);
		break;
	case "m_flFollowDistance":
		m_flFollowDistance = ReadFloat(setValue);
		break;
	case "m_flMaxFollowDistance":
		m_flMaxFollowDistance = ReadFloat(setValue);
		break;
	case "m_talkAnswer":
		m_talkAnswer = ReadString(setValue);
		break;
	case "m_talkAsk":
		m_talkAsk = ReadString(setValue);
		break;
	case "m_talkAllyShot":
		m_talkAllyShot = ReadString(setValue);
		break;
	case "m_talkGreet":
		m_talkGreet = ReadString(setValue);
		break;
	case "m_talkIdle":
		m_talkIdle = ReadString(setValue);
		break;
	case "m_talkPanic":
		m_talkPanic = ReadString(setValue);
		break;
	case "m_talkHearing":
		m_talkHearing = ReadString(setValue);
		break;
	case "m_talkSmelling":
		m_talkSmelling = ReadString(setValue);
		break;
	case "m_talkStare":
		m_talkStare = ReadString(setValue);
		break;
	case "m_talkSurvived":
		m_talkSurvived = ReadString(setValue);
		break;
	case "m_talkWounded":
		m_talkWounded = ReadString(setValue);
		break;
	case "m_talkAlert":
		m_talkAlert = ReadString(setValue);
		break;
	case "m_talkPlayerAsk":
		m_talkPlayerAsk = ReadString(setValue);
		break;
	case "m_talkPlayerGreet":
		m_talkPlayerGreet = ReadString(setValue);
		break;
	case "m_talkPlayerIdle":
		m_talkPlayerIdle = ReadString(setValue);
		break;
	case "m_talkPlayerWounded1":
		m_talkPlayerWounded1 = ReadString(setValue);
		break;
	case "m_talkPlayerWounded2":
		m_talkPlayerWounded2 = ReadString(setValue);
		break;
	case "m_talkPlayerWounded3":
		m_talkPlayerWounded3 = ReadString(setValue);
		break;
	case "m_talkUnfollow":
		m_talkUnfollow = ReadString(setValue);
		break;
	case "m_talkFollow":
		m_talkFollow = ReadString(setValue);
		break;
	case "m_talkStopFollow":
		m_talkStopFollow = ReadString(setValue);
		break;
	case "m_talkDenyFollow":
		m_talkDenyFollow = ReadString(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
ncTalkMonster::SetSentencePitch(float sentencePitch)
{
	m_sentencePitch = sentencePitch;
}

void
ncTalkMonster::WarnAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			ncTalkMonster w = (ncTalkMonster)b;
			w.m_iFlags |= MONSTER_METPLAYER;
			w.m_followingEntity = world;
			w.m_useFollowChain = world;
		}
	}
}
void
ncTalkMonster::StartleAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			ncTalkMonster w = (ncTalkMonster)b;
			w.m_iFlags |= MONSTER_FEAR;
			w.m_followingEntity = world;
			w.m_useFollowChain = world;
		}
	}
}

void
ncTalkMonster::Sentence(string sentence)
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

	SndEntLog("Attempting to say %S", seq);
}

void
ncTalkMonster::Speak(string sentence)
{
	if (GetState() == MONSTER_DEAD)
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, sentence);
	WriteFloat(MSG_MULTICAST, m_sentencePitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
ncTalkMonster::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "SpeakSentence":
		Sentence(dataField);
		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}

void
ncTalkMonster::SeenPlayer(ncActor thePlayer)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}
	if (m_iFlags & MONSTER_METPLAYER) {
		return;
	}

	Sentence(m_talkPlayerGreet);
	m_sentenceNext = time + 10.0;
	m_iFlags |= MONSTER_METPLAYER;
	m_eLookAt = thePlayer;
}

void
ncTalkMonster::SeenFriend(ncActor theActor)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkPlayerIdle);
	m_sentenceNext = time + 10.0;
}

void
ncTalkMonster::TalkPlayerAsk(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	for (entity p = world; (p = next.Player(p));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerAsk);
			m_sentenceNext = time + 10.0;
			break;
		}
	}
}

void
ncTalkMonster::TalkPlayerWounded1(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	if (base_health < health)
		return;

	for (entity p = world; (p = next.Player(p));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_sentenceNext = time + 10.0;
			break;
		}
	}
}
void
ncTalkMonster::TalkPlayerWounded2(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	if ((base_health / 2) < health)
		return;

	for (entity p = world; (p = next.Player(p));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_sentenceNext = time + 10.0;
			break;
		}
	}
}

void
ncTalkMonster::TalkPlayerWounded3(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_sentenceNext > time) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	for (entity p = world; (p = next.Player(p));) {
		/* Find players in a specific radius */
		if (vlen(p.origin - origin) < PLAYER_DETECT_RADIUS) {
			/* If we can't physically see him, don't do anything */
			traceline(origin, p.origin, FALSE, this);
			if (trace_ent != p) {
				continue;
			}
			Sentence(m_talkPlayerWounded3);
			m_sentenceNext = time + 10.0;
			break;
		}
	}
}

void
ncTalkMonster::TalkPanic(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkPanic);
	m_sentenceNext = time + 2.5;
}


void
ncTalkMonster::TalkUnfollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkUnfollow);
	m_sentenceNext = time + 10.0;
}

void
ncTalkMonster::TalkFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkFollow);
	m_sentenceNext = time + 10.0;
}

void
ncTalkMonster::TalkStopFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkStopFollow);
	m_sentenceNext = time + 10.0;
}

void
ncTalkMonster::TalkDenyFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		return;
	}
	if (m_bGagged) {
		return;
	}

	Sentence(m_talkDenyFollow);
	m_sentenceNext = time + 10.0;
}

void
ncTalkMonster::Touch(entity eToucher)
{
	if (eToucher == world)
		return;

	if (eToucher == m_followingEntity) {
		makevectors(eToucher.angles);
		velocity = v_forward * 250.0f;
		return;
	}

	/* ugly hack */
	if (eToucher.classname == "func_door_rotating") {
		owner = eToucher;
	}

	super::Touch(eToucher);
}

void
ncTalkMonster::FollowPlayer(void)
{
	float flPlayerDist;
	input_angles = vectoangles(m_useFollowChain.origin - origin);
			input_angles[0] = 0;
			input_angles[1] = fixAngleDelta(input_angles[1]);
			input_angles[2] = 0;
	_LerpTurnToYaw(input_angles[1]);

	/* for best results, we want to ignore the Z plane
	   this avoids the problem of a follower spinning
	    around when above/below you on a platform */
	vector vecParent = m_useFollowChain.origin;
	vecParent[2] = origin[2];

	flPlayerDist = distance(vecParent, origin);

	/* Give up after 1024 units */
	if (flPlayerDist > m_flMaxFollowDistance) {
		m_followingEntity = world;
		ncMonsterLog("Maximum follow distance reached. Will stop following.");
	} else if (flPlayerDist >= m_flFollowDistance) {
		/* we only allow speed changes every second, avoid jitter */
		if (m_useFollowSpeedChanged < time) {
			float flNextSpeed = GetChaseSpeed();

			/* if we're close enough, we ought to walk */
			if (flPlayerDist < (m_flFollowDistance * 1.5f))
				flNextSpeed = GetWalkSpeed();

			/* only update the timer when speed changed */
			if (flNextSpeed != m_useFollowSpeed) {
				m_useFollowSpeed = flNextSpeed;
				m_useFollowSpeedChanged = time + 1.0f;
			}
		}

		if (DistanceFromYaw(vecParent) > 0.9f)
			input_movevalues[0] = m_useFollowSpeed;

		/* when we're in a chain... can we see the user any more? */
		if (m_useFollowChain != m_followingEntity) {
			traceline(GetOrigin(), m_followingEntity.origin, MOVE_NORMAL, this);

			/* the answer is no. */
			if (trace_fraction < 1.0 || trace_ent != m_followingEntity) {
				/* go straight to our user */
				ncEntity zamn = (ncEntity)m_followingEntity;
				vector endPos = zamn.GetNearbySpot();

				if (endPos != g_vec_null) {
					RouteToPosition(endPos);
					m_flSequenceSpeed = GetChaseSpeed();
				}
				return;
			}
		}

		traceline(origin, m_useFollowChain.origin, MOVE_NORMAL, this);

		/* Tracing failed, there's world geometry in the way */
		if (trace_fraction < 1.0f && trace_ent != m_useFollowChain) {
			/* are they still generally accessible? */
			traceline(m_useLastAtPosition, vecParent, MOVE_NORMAL, this);

			if (trace_fraction < 1.0f && trace_ent != m_followingEntity) {
				RouteToPosition(m_followingEntity.origin); /* go directly to the source */
				m_flSequenceSpeed = GetChaseSpeed();
				return;
			} else {
				input_angles = vectoangles(m_useLastAtPosition - origin);
				input_angles[0] = 0;
				input_angles[1] = fixAngleDelta(input_angles[1]);
				input_angles[2] = 0;
				_LerpTurnToYaw(input_angles[1]);
			}
		} else {
			m_useLastAtPosition = vecParent;
		}

		if (m_bFollowGrouping == false)
			return;

		/* Trace again to see if another hostage is in our path and if so
		 * follow them instead, this makes pathing easier */
		traceline(origin, /*mins, maxs,*/ m_useLastAtPosition, FALSE, this);
		if (trace_ent.classname == classname) {
			ncTalkMonster que = (ncTalkMonster)trace_ent;
			if (que.m_useFollowChain == m_followingEntity) {
				if (trace_ent != this) {
					m_useFollowChain = trace_ent;
				}
			}
		}
	}
}

void
ncTalkMonster::PanicFrame(void)
{
	float bestYaw = 0.0f;
	float best_fraction = 0.0f;
	float secondBest = 0.0f;

	m_iFlags |= MONSTER_METPLAYER;
	input_movevalues = [240, 0, 0];

	if (m_useFollowTraceTime < time) {
		for (float yaw = -180.0f; yaw < 180.0f; yaw += 1.0f) {
			makevectors([0, yaw, 0]);
			tracebox(origin, mins, maxs, origin + (v_forward * 1024), FALSE, this);

			if (trace_startsolid) {
				bestYaw = random(0, 360);
				break;
			}

			if (trace_fraction > best_fraction) {
				best_fraction = trace_fraction;
				bestYaw = yaw;
			}
		}

		angles[1] = fixAngleDelta(bestYaw + random(-25, 25));
		input_angles[1] = angles[1];
		v_angle[1] = angles[1];
		m_useFollowTraceTime = time + 0.5f + random();
	}


	if (m_sentenceNext > time)
		return;

	TalkPanic();
}

void
ncTalkMonster::FollowChain(void)
{
	/* Deal with a hostage being rescued when it's following someone else */
	if (m_useFollowChain.classname == classname) {
		if (m_useFollowChain.solid == SOLID_NOT) {
			m_useFollowChain = m_followingEntity;
		}
	}
	/* Deal with the hostage losing its rescuer (death) */
	if (m_followingEntity.health <= 0) {
		m_followingEntity = world;
	}
}

void
ncTalkMonster::RunAI(void)
{
	if (GetMovetype() == MOVETYPE_NONE) {
		return;
	}

	if (InScriptedSequence() == false) {
		ThinkSchedules();
	}

	SeeThink();
	AttackThink();

#if 0
	if (m_followingEntity != world && m_iNodes <= 0) {
		m_eLookAt = m_followingEntity;
		FollowPlayer();
	} else {
		if (random() < 0.5) {
			TalkPlayerAsk();
		} else {
		}
	}
#endif
}

void
ncTalkMonster::Respawn(void)
{
	super::Respawn();

	RouteClear();
	m_followingEntity = world;
	m_useFollowChain = world;
	PlayerUse = OnPlayerUse;

	if (m_bFollowOnUse) {
		m_iFlags |= MONSTER_CANFOLLOW;
	}
}

void
ncTalkMonster::OnPlayerUse(void)
{
	if (m_iFlags & MONSTER_FEAR)
		return;

	/* can't press use any non-allies */
	if (!(m_iFlags & MONSTER_CANFOLLOW)) {
		TalkDenyFollow();
		return;
	}

	if ((m_followingEntity == world)) {
		if (!(m_iFlags & MONSTER_USED)) {
			m_iFlags |= MONSTER_USED;
		}

		TalkFollow();
		m_followingEntity = eActivator;
		m_useFollowChain = m_followingEntity;
		m_useLastAtPosition = m_followingEntity.origin;
	} else {
		TalkUnfollow();
		m_followingEntity = world;
		RouteClear();
	}
}

void
ncTalkMonster::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "UnUseSentence":
		m_talkUnfollow = strcat("!", ReadString(setValue));
		break;
	case "UseSentence":
		m_talkFollow = strcat("!", ReadString(setValue));
		break;

	/* entityDef */
	case "talk_answer":
		m_talkAnswer = ReadString(setValue);
		break;
	case "talk_ask":
		m_talkAsk = ReadString(setValue);
		break;
	case "talk_ally_shot":
		m_talkAllyShot = ReadString(setValue);
		break;
	case "talk_greet":
		m_talkGreet = ReadString(setValue);
		break;
	case "talk_idle":
		m_talkIdle = ReadString(setValue);
		break;
	case "talk_panic":
		m_talkPanic = ReadString(setValue);
		break;
	case "talk_hearing":
		m_talkHearing = ReadString(setValue);
		break;
	case "talk_smelling":
		m_talkSmelling = ReadString(setValue);
		break;
	case "talk_stare":
		m_talkStare = ReadString(setValue);
		break;
	case "talk_survived":
		m_talkSurvived = ReadString(setValue);
		break;
	case "talk_wounded":
		m_talkWounded = ReadString(setValue);
		break;
	case "talk_alert":
		m_talkAlert = ReadString(setValue);
		break;
	case "talk_player_ask":
		m_talkPlayerAsk = ReadString(setValue);
		break;
	case "talk_player_greet":
		m_talkPlayerGreet = ReadString(setValue);
		break;
	case "talk_player_idle":
		m_talkPlayerIdle = ReadString(setValue);
		break;
	case "talk_player_wounded1":
		m_talkPlayerWounded1 = ReadString(setValue);
		break;
	case "talk_player_wounded2":
		m_talkPlayerWounded2 = ReadString(setValue);
		break;
	case "talk_player_wounded3":
		m_talkPlayerWounded3 = ReadString(setValue);
		break;
	case "talk_unfollow":
		m_talkUnfollow = ReadString(setValue);
		break;
	case "talk_follow":
		m_talkFollow = ReadString(setValue);
		break;
	case "talk_stop_follow":
		m_talkStopFollow = ReadString(setValue);
		break;
	case "talk_deny_follow":
		m_talkDenyFollow = ReadString(setValue);
		break;
	case "follow_on_use":
		m_bFollowOnUse = ReadBool(setValue);
		break;

	case "follow_dist":
		m_flFollowDistance = ReadFloat(setValue);
		break;
	case "follow_maxdist":
		m_flMaxFollowDistance = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

float
ncTalkMonster::SendEntity(entity ePEnt, float flChanged)
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
	SENDENTITY_FLOAT(v_angle[0], MONFL_CHANGED_ANGLES_X)
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
	SENDENTITY_SHORT(m_geomsetField, MONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[0], MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[1], MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[2], MONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	SENDENTITY_BYTE(m_renderMode, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderFX, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderColor[0], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[1], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[2], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderAmount, MONFL_CHANGED_RENDERAMT)
	SENDENTITY_FLOAT(bonecontrol1, MONFL_CHANGED_HEADYAW)
	SENDENTITY_FLOAT(subblendfrac, MONFL_CHANGED_HEADYAW)
	SENDENTITY_FLOAT(frame1time, MONFL_CHANGED_HEADYAW)

	return (1);
}

#else

/*
============
ncTalkMonster::SentenceSample

whatever comes out of the 'mouth',
============
*/
void
ncTalkMonster::SentenceSample(string sample)
{
	sound(this, CHAN_VOICE, sample, 1.0, ATTN_NORM, 100, SOUNDFLAG_FOLLOW);
}

/*
============
ncTalkMonster::ProcessWordQue

Handles the sentences word que
============
*/
void
ncTalkMonster::ProcessWordQue(void)
{
	if (time < 1 || !m_iSentenceCount) {
		return;
	}

	if (m_flSentenceTime > time) {
		return;
	}

	SentenceSample(m_pSentenceQue[m_iSentencePos].m_strSnd);

	ncMonsterLog("Speaking sentence sample %S", m_pSentenceQue[m_iSentencePos].m_strSnd);
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
ncTalkMonster::Sentence

we'll pass it a sentences.txt word (e.g. !BA_TEST) and start queing it
============
*/
void
ncTalkMonster::Sentence(string msg)
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


	SndEntLog("Saying %S", msg);
}

float
ncTalkMonster::predraw(void)
{
	//float render;
	//render = super::predraw();

	/* TODO: this is from ncRenderableEntity, shoul make these nonvirtual methods */
	{
	RenderFXPass();
	RenderDebugSkeleton();

	processmodelevents(modelindex, frame, m_modelEventTime,
		frame1time, HandleAnimEvent);
	} /* TODO end */

	/* mouth flapping action */
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;

	m_modelEventTime = frame1time;
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

	/* subblendfrac == -1 == up, 0.99 is down */
	subblendfrac = bound(-0.99, v_angle[0] / 45, 0.99);

#if 0
	if (autocvar_boney1 != 0.0f)
		bonecontrol1 = autocvar_boney1;
	if (autocvar_boney2 != 0.0f)
		bonecontrol2 = autocvar_boney2;
	if (autocvar_boney3 != 0.0f)
		bonecontrol3 = autocvar_boney3;
	if (autocvar_boney4 != 0.0f)
		bonecontrol4 = autocvar_boney4;
	if (autocvar_boney5 != 0.0f)
		bonecontrol5 = autocvar_boney5;

	if (autocvar_subblendfrac != 0.0f)
		subblendfrac = autocvar_subblendfrac;
	if (autocvar_subblend2frac != 0.0f)
		subblend2frac = autocvar_subblend2frac;

	if (autocvar_basesubblendfrac != 0.0f)
		basesubblendfrac = autocvar_basesubblendfrac;
	if (autocvar_basesubblend2frac != 0.0f)
		basesubblend2frac = autocvar_basesubblend2frac;
	if (autocvar_baseframe != 0.0f)
		frame = autocvar_baseframe;
#endif

	RenderAxialScale();

#if 0
	/* has the current top frame changed? */
	if (frame != frame2) {
		/* we're done lerping */
		if (lerpfrac <= 0.0f) {
			frame2 = frame;
			lerpfrac = 0.0f;
		}

		lerpfrac = max(0.0, lerpfrac - (frametime * 5.0));
	} else {
		/* make sure we're set up for next lerp */
		lerpfrac = 1.0f;
		frame2time = frame1time;
	}

	/* are we inside of an interpolation? */
	if (baseframe != baseframe2) {
		/* we're done lerping */
		if (baselerpfrac <= 0.0f) {
			baseframe2 = baseframe;
			baselerpfrac = 0.0f;
		}

		baselerpfrac = max(0.0, baselerpfrac - (frametime * 5.0));
		//printf("baselerpfrac: %f\n", baselerpfrac);
	} else {
		/* make sure we're set up for next lerp */
		baselerpfrac = 1.0f;
		baseframe2time = baseframe1time;
	}
#endif

	addentity(this);

	_RenderDebugViewCone();
	RenderGLQuakeShadow();

	return (PREDRAW_NEXT);
}

/*
============
ncTalkMonster::ReceiveEntity
============
*/
void
ncTalkMonster::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	READENTITY_FLOAT(v_angle[0], MONFL_CHANGED_ANGLES_X)
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
	READENTITY_SHORT(m_geomsetField, MONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[0], MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[1], MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[2], MONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	READENTITY_BYTE(m_renderMode, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderFX, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderColor[0], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[1], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[2], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderAmount, MONFL_CHANGED_RENDERAMT)
	READENTITY_FLOAT(bonecontrol1, MONFL_CHANGED_HEADYAW)
	READENTITY_FLOAT(subblendfrac, MONFL_CHANGED_HEADYAW)
	READENTITY_FLOAT(frame1time, MONFL_CHANGED_HEADYAW)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & MONFL_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);

	if (flChanged & MONFL_CHANGED_BODY)
		_UpdateGeomset();
	if (flChanged & MONFL_CHANGED_MODELINDEX) {
		_ModelChanged();
		_UpdateBoneCount();
	}
}

void
ncTalkMonster_ParseSentence(void)
{
	entity ent;
	ncTalkMonster targ;
	string sentence;
	float e;

	/* parse packets */
	e = readentitynum();
	sentence = Sentences_GetString(readint());

	ent = findfloat(world, entnum, e);

	if (ent) {
		if (ent.classname != "speaker" && ent.declclass != "ncTalkMonster" && ent.classname != "ncTalkMonster" && ent.classname != "ambient_generic") {
			ncError("Entity %d not a ncTalkMonster!", e);
		} else {
			targ = (ncTalkMonster)ent;
			targ.Sentence(sentence);
		}
	} else {
		ncError("Entity %d not in PVS", e);
	}
}
#endif

#ifdef CLIENT
void
ncTalkMonster_ReadEntity(bool new)
{
	ncTalkMonster me = (ncTalkMonster)self;
	if (new) {
		spawnfunc_ncTalkMonster();
	}
	me.ReceiveEntity(new, readfloat());
}
#endif
