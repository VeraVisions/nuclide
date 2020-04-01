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

/*QUAKED monster_alien_slave (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Alien Slave

*/

enum {
	SLV_IDLE,
	SLV_IDLE2,
	SLV_IDLE3,
	SLV_CROUCH,
	SLV_WALK,
	SLV_WALK2,
	SLV_RUN,
	SLV_RIGHT,
	SLV_LEFT,
	SLV_JUMP,
	SLV_STAIRUP,
	SLV_ATTACK,
	SLV_ATTACKZAP,
	SLV_FLINCH,
	SLV_FLINCHLA,
	SLV_FLINCHRA,
	SLV_FLINCHL,
	SLV_FLINCHR,
	SLV_DIEHS,
	SLV_DIE,
	SLV_DIEBACK,
	SLV_DIEFORWARD,
	SLV_COLLAR,
	SLV_COLLAR2,
	SLV_PUSHUP,
	SLV_GRAB,
	SLV_UPDOWN,
	SLV_DOWNUP,
	SLV_JIBBER,
	SLV_JABBER
};

/* chat & idle sounds are handled via sentences.txt */

string slv_snddie[] = {
	"aslave/slv_die1.wav",
	"aslave/slv_die2.wav"
};

string slv_sndpain[] = {
	"aslave/slv_pain1.wav",
	"aslave/slv_pain2.wav"
};

class monster_alien_slave:CBaseNPC
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_alien_slave;
	
	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void(void) IdleChat;
	virtual void(void) Respawn;
};

void 
monster_alien_slave::IdleChat(void)
{
	if (m_flIdleTime > time) {
		return;
	}

	Sentence(m_talkIdle);

	m_flIdleTime = time + 5.0f + random(0,20);
}

void
monster_alien_slave::Pain(int iHitBody)
{
	CBaseNPC::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,slv_sndpain.length));
	Sound(slv_sndpain[rand]);
	frame = SLV_FLINCH + floor(random(0, 2));
	m_flPainTime = time + 0.25f;
}

void
monster_alien_slave::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				frame = SLV_DIEHS;
			} else {
				frame = SLV_DIEBACK;
			}
		} else {
			frame = SLV_DIE + floor(random(0, 3));
		}

		/* the sound */
		int rand = floor(random(0,slv_sndpain.length));
		Sound(slv_sndpain[rand]);
	}

	/* set the functional differences */
	CBaseNPC::Death(iHitBody);
}

void
monster_alien_slave::Respawn(void)
{
	CBaseNPC::Respawn();
	frame = SLV_IDLE;
}

void
monster_alien_slave::monster_alien_slave(void)
{
	for (int i = 0; i < slv_sndpain.length; i++) {
		precache_sound(slv_sndpain[i]);
	}

	m_talkAnswer = "";
	m_talkAsk = "";
	m_talkAllyShot = "";
	m_talkGreet = "SLV_ALERT";
	m_talkIdle = "!SLV_IDLE";
	m_talkSmelling = "";
	m_talkStare = "";
	m_talkSurvived = "";
	m_talkWounded = "";

	m_talkPlayerAsk = "";
	m_talkPlayerGreet = "!SLV_ALERT";
	m_talkPlayerIdle = "";
	m_talkPlayerWounded1 = "";
	m_talkPlayerWounded2 = "";
	m_talkPlayerWounded3 = "";
	m_talkUnfollow = "";
	m_talkFollow = "";
	m_talkStopFollow = "";

	netname = "Alien Slave";
	model = "models/islave.mdl";
	base_health = Skill_GetValue("islave_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
