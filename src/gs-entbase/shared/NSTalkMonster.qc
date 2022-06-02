/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
void
NSTalkMonster::Save(float handle)
{
	SaveString(handle, "talkAnswer", m_talkAnswer);
	SaveString(handle, "talkAsk", m_talkAsk);
	SaveString(handle, "talkAllyShot", m_talkAllyShot);
	SaveString(handle, "talkGreet", m_talkGreet);
	SaveString(handle, "talkIdle", m_talkIdle);
	SaveString(handle, "talkPanic", m_talkPanic);
	SaveString(handle, "talkHearing", m_talkHearing);
	SaveString(handle, "talkSmelling", m_talkSmelling);
	SaveString(handle, "talkStare", m_talkStare);
	SaveString(handle, "talkSurvived", m_talkSurvived);
	SaveString(handle, "talkWounded", m_talkWounded);
	SaveString(handle, "talkPlayerAsk", m_talkPlayerAsk);
	SaveString(handle, "talkPlayerGreet", m_talkPlayerGreet);
	SaveString(handle, "talkPlayerIdle", m_talkPlayerIdle);
	SaveString(handle, "talkPlayerWounded1", m_talkPlayerWounded1);
	SaveString(handle, "talkPlayerWounded2", m_talkPlayerWounded2);
	SaveString(handle, "talkPlayerWounded3", m_talkPlayerWounded3);
	SaveString(handle, "talkUnfollow", m_talkUnfollow);
	SaveString(handle, "talkFollow", m_talkFollow);
	SaveString(handle, "talkStopFollow", m_talkStopFollow);

	super::Save(handle);
}
void
NSTalkMonster::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "talkAnswer":
		m_talkAnswer = strValue;
		break;
	case "talkAsk":
		m_talkAsk = strValue;
		break;
	case "talkAllyShot":
		m_talkAllyShot = strValue;
		break;
	case "talkGreet":
		m_talkGreet = strValue;
		break;
	case "talkIdle":
		m_talkIdle = strValue;
		break;
	case "talkPanic":
		m_talkPanic = strValue;
		break;
	case "talkHearing":
		m_talkHearing = strValue;
		break;
	case "talkSmelling":
		m_talkSmelling = strValue;
		break;
	case "talkStare":
		m_talkStare = strValue;
		break;
	case "talkSurvived":
		m_talkSurvived = strValue;
		break;
	case "talkWounded":
		m_talkWounded = strValue;
		break;

	case "talkPlayerAsk":
		m_talkPlayerAsk = strValue;
		break;
	case "talkPlayerGreet":
		m_talkPlayerGreet = strValue;
		break;
	case "talkPlayerIdle":
		m_talkPlayerIdle = strValue;
		break;
	case "talkPlayerWounded1":
		m_talkPlayerWounded1 = strValue;
		break;
	case "talkPlayerWounded2":
		m_talkPlayerWounded2 = strValue;
		break;
	case "talkPlayerWounded3":
		m_talkPlayerWounded3 = strValue;
		break;
	case "talkUnfollow":
		m_talkUnfollow = strValue;
		break;
	case "talkFollow":
		m_talkFollow = strValue;
		break;
	case "talkStopFollow":
		m_talkStopFollow = strValue;
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
	if (style == MONSTER_DEAD)
		return;

	string seq = Sentences_GetSamples(sentence);

	if (seq == "")
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, seq);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void
NSTalkMonster::Speak(string sentence)
{
	if (style == MONSTER_DEAD)
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
	v_angle = vectoangles(m_eFollowingChain.origin - origin);
	v_angle[0] = 0;
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = 0;

	/* Give up after 1024 units */
	if (vlen(m_eFollowingChain.origin - origin) > 1024) {
		m_eFollowing = world;
	} else if (vlen(m_eFollowingChain.origin - origin) > 64) {
		input_movevalues[0] = GetChaseSpeed();

		other = world;
		traceline(origin, m_eFollowingChain.origin, MOVE_OTHERONLY, this);

		/* Tracing failed, there's world geometry in the way */
		if (trace_fraction < 1.0f) {
			v_angle = vectoangles(m_vecLastUserPos - origin);
			v_angle[0] = 0;
			v_angle[1] = Math_FixDelta(v_angle[1]);
			v_angle[2] = 0;
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
		v_angle[1] -= 180 + ((random() - 0.5) * 90);
		v_angle[1] = Math_FixDelta(v_angle[1]);
		m_flChangePath = time + floor(random(2,10));
		angles = input_angles = v_angle;
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
NSTalkMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_timelength = frametime;
	input_angles = v_angle;

	/* make sure we're forgetting about enemies and attack states in sequence */
	if (m_iSequenceState != SEQUENCESTATE_NONE) {
		m_eEnemy = __NULL__;
		m_iMState = MONSTER_IDLE;
	}

	/* override whatever we did above with this */
	if (m_iSequenceState == SEQUENCESTATE_ENDING) {
		input_angles = v_angle = angles = m_vecSequenceAngle;
		SetFrame(m_flSequenceEnd);
	} else {
		if (style != MONSTER_DEAD) {
			if (m_iSequenceState == SEQUENCESTATE_NONE) {
				SeeThink();
				AttackThink();
				TalkPlayerGreet();
				FollowChain();

				if (m_eFollowing != world) {
					FollowPlayer();
					input_angles = angles = v_angle;
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

			AnimationUpdate();
		}
		CheckRoute();
		WalkRoute();
		hitcontentsmaski = CONTENTBITS_MONSTER;

		if (CanCrouch())
			PMoveCustom_RunCrouchPhysics(this);
		else
			PMoveCustom_RunPlayerPhysics(this);

		SetOrigin(origin);
	}

	if (!(flags & FL_ONGROUND) && velocity[2] < -415) {
		if (!(m_iFlags & MSF_FALLING)) {
			FallNoise();
		}

		m_iFlags |= MSF_FALLING;
	} else {
		m_iFlags &= ~MSF_FALLING;
	}

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}

	m_flBaseTime = frame1time;
	frame1time += frametime;

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, Game_ServerModelEvent);
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

void
NSTalkMonster::Hide(void)
{
	m_eFollowing = world;
	NSMonster::Hide();
}

float
NSTalkMonster::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_TALKMONSTER);

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & BASEFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & BASEFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & BASEFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}
	if (fChanged & BASEFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & BASEFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & BASEFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & BASEFL_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
		WriteFloat(MSG_ENTITY, frame1time);
	}
	if (fChanged & BASEFL_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & BASEFL_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & BASEFL_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}
	if (fChanged & BASEFL_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (fChanged & BASEFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

#ifdef GS_RENDERFX
	if (fChanged & BASEFL_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}

	if (fChanged & BASEFL_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
	}
	if (fChanged & BASEFL_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
#else
	if (fChanged & BASEFL_CHANGED_ALPHA) {
		WriteFloat(MSG_ENTITY, alpha);
	}
#endif

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

	NSLog("^2NSEntity::^3ProcessWordQue^7: Speaking %s", m_pSentenceQue[m_iSentencePos].m_strSnd);
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
	float render;
	render = super::predraw();

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

	return render;
}

/*
============
NSTalkMonster::ReceiveEntity
============
*/
void
NSTalkMonster::ReceiveEntity(float flNew, float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
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
		setsize(this, mins, maxs);
	}
	if (flChanged & BASEFL_CHANGED_FRAME) {
		frame = readbyte();
		frame1time = readfloat();
		frame2time = frame1time;
	}
	if (flChanged & BASEFL_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & BASEFL_CHANGED_EFFECTS) {
		effects = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_BODY) {
		m_iBody = readbyte();
		setcustomskin(this, "", sprintf("geomset 1 %i\n", m_iBody));
	}
	if (flChanged & BASEFL_CHANGED_SCALE) {
		scale = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

#ifdef GS_RENDERFX
	if (flChanged & BASEFL_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
		m_iRenderFX = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_RENDERAMT) {
		m_flRenderAmt = readfloat();
	}
#else
	if (flChanged & BASEFL_CHANGED_ALPHA) {
		alpha = readfloat();
	}
#endif

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if (scale == 0.0)
		scale = 1.0f;

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
	sentence = readstring();

	ent = findfloat(world, entnum, e);

	if (ent) {
		if (ent.classname != "NSTalkMonster" && ent.classname != "ambient_generic")
		NSLog("^3 NSTalkMonster_ParseSentence ^7: Entity %d not a NSTalkMonster!", e);
		else {
			targ = (NSTalkMonster)ent;
			targ.Sentence(sentence);
			NSLog("^3 NSTalkMonster_ParseSentence ^7: Entity %d saying %s", e, sentence);
		}
	} else {
		NSLog("^3 NSTalkMonster_ParseSentence ^7: Entity %d not in PVS", e);
	}
}

#endif

void
NSTalkMonster::NSTalkMonster(void)
{
#ifdef SERVER
	m_eFollowing = world;
#endif
}


#ifdef CLIENT
void
NSTalkMonster_ReadEntity(float new)
{
	NSTalkMonster me = (NSTalkMonster)self;
	if (new) {
		spawnfunc_NSTalkMonster();
	}
	me.ReceiveEntity(new, readfloat());
}
#endif
