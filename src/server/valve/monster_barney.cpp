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

/*QUAKED monster_barney (0 0.8 0.8) (-16 -16 0) (16 16 72)

Barney Calhoun

*/

enum {
	BARNEY_IDLE,
	BARNEY_WALK,
	BARNEY_RUN,
	BARNEY_DEAD
};

enum {
	BARNA_IDLE1,
	BARNA_IDLE2,
	BARNA_IDLE3,
	BARNA_IDLE4,
	BARNA_WALK,
	BARNA_RUN,
	BARNA_SHOOT1,
	BARNA_SHOOT2,
	BARNA_DRAW,
	BARNA_HOLSTER,
	BARNA_RELOAD,
	BARNA_TURNLEFT,
	BARNA_TURNRIGHT,
	BARNA_FLINCH_LA,
	BARNA_FLINCH_RA,
	BARNA_FLINCH_LL,
	BARNA_FLINCH_RL,
	BARNA_FLINCH_SML
};

enumflags
{
	BARNF_USED,
	BARNF_FEAR,
	BARNF_SEEN,
	BARNF_FALLING
};

string barney_snddie[] = {
	"barney/ba_die1.wav",
	"barney/ba_die1.wav",
	"barney/ba_die2.wav"
};

string barney_sndpain[] = {
	"barney/ba_pain1.wav",
	"barney/ba_pain1.wav",
	"barney/ba_pain1.wav"
};

class monster_barney:CBaseNPC
{
	vector m_vecLastUserPos;
	entity m_eUser;
	entity m_eRescuer;

	float m_flPainTime;
	float m_flChangePath;
	float m_flTraceTime;
	int m_iFlags;
	void() monster_barney;

	virtual void() touch;
	virtual void() Hide;
	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void() Physics;
	virtual void() WarnOthers;
};

void monster_barney::WarnOthers(void)
{
	for (entity b = world; (b = find(b, ::classname, "monster_barney"));) {
		if (vlen(b.origin - origin) < 512) {
			monster_barney sci = (monster_barney)b;
			sci.m_iFlags |= BARNF_SEEN;
			sci.m_eUser = world;
			sci.m_eRescuer = world;
		}
	}
}

void monster_barney::Physics(void)
{
	float spvel;
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	
	if (style != BARNEY_DEAD) {
	if (!(m_iFlags & BARNF_SEEN)) {
		for (entity b = world; (b = find(b, ::classname, "player"));) {
			/* Find players in a 256 unit radius */
			if (vlen(b.origin - origin) < 256) {
				/* If we can't physically see him, don't say hi. */
				traceline(origin, b.origin, FALSE, this);
				if (trace_ent != b) {
					continue;
				}

				Sentence(m_talkPlayerGreet);
				m_iFlags |= BARNF_SEEN;
				break;
			}
		}
	}
	
	/* Deal with a hostage being rescued when it's following someone else */
	if (m_eRescuer.classname == "monster_barney") {
		if (m_eRescuer.solid == SOLID_NOT) {
			m_eRescuer = m_eUser;
		}
	}
	/* Deal with the hostage losing its rescuer (death) */
	if (m_eUser.health <= 0) {
		m_eUser = world;
	}

	if (m_eUser!= world) {
		v_angle = vectoangles(m_eRescuer.origin - origin);
		v_angle[0] = 0;
		v_angle[1] = Math_FixDelta(v_angle[1]);
		v_angle[2] = 0;

		/* Give up after 1024 units */
		if (vlen(m_eRescuer.origin - origin) > 1024) {
			m_eUser = world;
		} else if (vlen(m_eRescuer.origin - origin) > 64) {
			input_movevalues[0] = 240;

			other = world;
			traceline(origin, /*mins, maxs, */m_eRescuer.origin, MOVE_OTHERONLY, this);

			/* Tracing failed, there's world geometry in the way */
			if (trace_fraction < 1.0f) {
				v_angle = vectoangles(m_vecLastUserPos - origin);
				v_angle[0] = 0;
				v_angle[1] = Math_FixDelta(v_angle[1]);
				v_angle[2] = 0;
			} else {
				m_vecLastUserPos = m_eRescuer.origin;
			}

			/* Trace again to see if another hostage is in our path and if so
			 * follow them instead, this makes pathing easier */
			traceline(origin, /*mins, maxs,*/ m_vecLastUserPos, FALSE, this);
			if (trace_ent.classname == "monster_barney") {
				monster_barney que = (monster_barney)trace_ent;
				if (que.m_eRescuer == m_eUser) {
					if (trace_ent != this) {
						m_eRescuer = trace_ent;
					}
				}
			}
		}
	} else if (m_iFlags & BARNF_FEAR) {
		m_iFlags |= BARNF_SEEN;
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
			float add;
			vector pos;

			pos = origin + [0,0,-18];
			if (random() < 0.5) {
				add = 45;
			} else {
				add = -45;
			}

			/* test every 45 degrees */
			for (int i = 0; i < 8; i++) {
				v_angle[1] = Math_FixDelta(v_angle[1] + add);
				makevectors(v_angle);
				traceline(pos, pos + (v_forward * 64), FALSE, this);
				if (trace_fraction >= 1.0f) {
					break;
				}
			}
			m_flChangePath = time + floor(random(2,10));
		}
	} else {
		//Sentence(m_talkPlayerIdle);
	}

	if (m_flPainTime > time) {
		input_movevalues = [0,0,0];
	} else {
		spvel = vlen(velocity);

		if (spvel < 5) {
			frame = BARNA_IDLE1;
		} else if (spvel <= 140) {
			frame = BARNA_WALK;
		} else if (spvel <= 240) {
			frame = BARNA_RUN;
		}
	}

	}

	input_angles = angles = v_angle;
	input_timelength = frametime;

	runstandardplayerphysics(this);
	Footsteps_Update();

	if (!(flags & FL_ONGROUND) && velocity[2] < -100) {
		m_iFlags |= BARNF_FALLING;
	} else {
		m_iFlags -= (flags & BARNF_FALLING);
	}
}

void monster_barney::touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void monster_barney::PlayerUse(void)
{
	if (m_iFlags & BARNF_FEAR) {
		return;
	}
	if ((m_eUser == world)) {
		if (!(m_iFlags & BARNF_USED)) {
			m_iFlags |= BARNF_USED;
		}

		Sentence(m_talkFollow);
		m_eUser = eActivator;
		m_eRescuer = m_eUser;
		m_vecLastUserPos = m_eUser.origin;
	} else {
		Sentence(m_talkUnfollow);
		m_eUser = world;
	}
}

void monster_barney::Pain(int iHitBody)
{
	
	WarnOthers();

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,barney_sndpain.length));
	Speak(barney_sndpain[rand]);

	frame = BARNA_FLINCH_LA + floor(random(0, 5));
	m_iFlags |= BARNF_FEAR;

	m_flPainTime = time + 0.25f;
}

void monster_barney::Death(int iHitBody)
{
	int r;
	r = floor(random(0,barney_snddie.length));
	Speak(barney_snddie[r]);

	WarnOthers();

	think = Respawn;
	nextthink = time + 10.0f;

	m_eUser = world;
	//customphysics = __NULL__;
	m_iFlags = 0x0;

	if (health < -50) {
		Gib();
		return;
	}

	flags &= ~FL_MONSTER;
	movetype = MOVETYPE_NONE;
	solid = SOLID_CORPSE;

	if (style != BARNEY_DEAD) {
		frame = 25 + floor(random(0, 6));
		style = BARNEY_DEAD;
	}
}

void monster_barney::Hide(void)
{
	setmodel(this, "");
	m_eUser = world;
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	customphysics = __NULL__;
}

void monster_barney::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);

	flags |= FL_MONSTER;
	setorigin(this, m_oldOrigin);
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	m_eUser = world;
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	style = BARNEY_IDLE;
	customphysics = Physics;
	frame = BARNA_IDLE1;
	SendFlags |= NPC_FRAME;
	health = 50;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	SendFlags = 0xff;
}

void monster_barney::monster_barney(void)
{
	for (int i = 0; i < barney_sndpain.length; i++) {
		precache_sound(barney_sndpain[i]);
	}
	for (int i = 0; i < barney_snddie.length; i++) {
		precache_sound(barney_snddie[i]);
	}

	m_talkAnswer = "!BA_ANSWER";
	m_talkAsk = "";
	m_talkAllyShot = "!BA_SCARED";
	m_talkGreet = "";
	m_talkIdle = "";
	m_talkSmelling = "!BA_SMELL";
	m_talkStare = "!BA_STARE";
	m_talkSurvived = "!BA_WOUND";
	m_talkWounded = "!BA_WOUND";

	m_talkPlayerAsk = "!BA_QUESTION";
	m_talkPlayerGreet = "!BA_HELLO";
	m_talkPlayerIdle = "!BA_IDLE";
	m_talkPlayerWounded1 = "!BA_CUREA";
	m_talkPlayerWounded2 = "!BA_CUREB";
	m_talkPlayerWounded3 = "!BA_CUREC";
	m_talkUnfollow = "!BA_WAIT";
	m_talkFollow = "!BA_OK";
	m_talkStopFollow = "!BA_STOP";

	model = "models/barney.mdl";
	netname = "Barney";
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}
