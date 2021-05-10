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

void
CBaseNPC::WarnAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			CBaseNPC w = (CBaseNPC)b;
			w.m_iFlags |= MONSTER_METPLAYER;
			w.m_eFollowing = world;
			w.m_eFollowingChain = world;
		}
	}
}
void
CBaseNPC::StartleAllies(void)
{
	for (entity b = world; (b = find(b, ::classname, classname));) {
		if (vlen(b.origin - origin) < PLAYER_DETECT_RADIUS) {
			CBaseNPC w = (CBaseNPC)b;
			w.m_iFlags |= MONSTER_FEAR;
			w.m_eFollowing = world;
			w.m_eFollowingChain = world;
		}
	}
}

void
CBaseNPC::Sentence(string sentence)
{
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
CBaseNPC::TalkPlayerGreet(void)
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
CBaseNPC::TalkPlayerIdle(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;
	if (spawnflags & MSF_PREDISASTER)
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
CBaseNPC::TalkPlayerAsk(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;
	if (spawnflags & MSF_PREDISASTER)
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
CBaseNPC::TalkPlayerWounded1(void)
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
CBaseNPC::TalkPlayerWounded2(void)
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
CBaseNPC::TalkPlayerWounded3(void)
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
CBaseNPC::TalkPanic(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkPanic);
	m_flNextSentence = time + 2.5;
}


void
CBaseNPC::TalkUnfollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkUnfollow);
	m_flNextSentence = time + 10.0;
}

void
CBaseNPC::TalkFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkFollow);
	m_flNextSentence = time + 10.0;
}

void
CBaseNPC::TalkStopFollow(void)
{
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	Sentence(m_talkStopFollow);
	m_flNextSentence = time + 10.0;
}

void
CBaseNPC::FollowPlayer(void)
{
	v_angle = vectoangles(m_eFollowingChain.origin - origin);
	v_angle[0] = 0;
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = 0;

	/* Give up after 1024 units */
	if (vlen(m_eFollowingChain.origin - origin) > 1024) {
		m_eFollowing = world;
	} else if (vlen(m_eFollowingChain.origin - origin) > 64) {
		input_movevalues[0] = m_flChaseSpeed;

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
			CBaseNPC que = (CBaseNPC)trace_ent;
			if (que.m_eFollowingChain == m_eFollowing) {
				if (trace_ent != this) {
					m_eFollowingChain = trace_ent;
				}
			}
		}
	}
}

void
CBaseNPC::PanicFrame(void)
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
CBaseNPC::FollowChain(void)
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
CBaseNPC::Physics(void)
{
	float spvel;
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

			if (m_flAnimTime > time) {
				input_movevalues = [0,0,0];
			} else {
				spvel = vlen(velocity);

				if (spvel < 5) {
					SetFrame(AnimIdle());
				} else if (spvel <= 140) {
					SetFrame(AnimWalk());
				} else if (spvel <= 240) {
					SetFrame(AnimRun());
				}
			}
		}
		CheckRoute();
		WalkRoute();
		runstandardplayerphysics(this);
		SetOrigin(origin);
	}

	if (!(flags & FL_ONGROUND) && velocity[2] < -100) {
		m_iFlags |= MONSTER_FALLING;
	} else {
		m_iFlags &= ~MONSTER_FALLING;
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
CBaseNPC::Respawn(void)
{
	CBaseMonster::Respawn();
	m_eFollowing = world;
	m_eFollowingChain = world;
}

void
CBaseNPC::OnPlayerUse(void)
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
CBaseNPC::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "UnUseSentence":
		m_talkUnfollow = strcat("!", strValue);
		break;
	case "UseSentence":
		m_talkFollow = strcat("!", strValue);
		break;
	default:
		CBaseMonster::SpawnKey(strKey, strValue);
		break;
	}
}

void
CBaseNPC::Hide(void)
{
	m_eFollowing = world;
	CBaseMonster::Hide();
}

void
CBaseNPC::CBaseNPC(void)
{
	CBaseMonster::CBaseMonster();
	m_eFollowing = world;
}
