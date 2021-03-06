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

var int autocvar_sh_scialert = FALSE;
var int autocvar_sh_scispeed = 40;
var int autocvar_sh_sciattack = TRUE;


enum
{
	SCIA_WALK,
	SCIA_WALKSCARED,
	SCIA_RUN,
	SCIA_RUNSCARED,
	SCIA_RUNLOOK,
	SCIA_180LEFT,
	SCIA_180RIGHT,
	SCIA_FLINCH,
	SCIA_PAIN,
	SCIA_PAINLEFT,
	SCIA_PAINRIGHT,
	SCIA_PAINLEGLEFT,
	SCIA_PAINLEGRIGHT,
	SCIA_IDLE1,
	SCIA_IDLE2,
	SCIA_IDLE3,
	SCIA_IDLE4,
	SCIA_IDLE5,
	SCIA_IDLE6,
	SCIA_SCARED_END,
	SCIA_SCARED1,
	SCIA_SCARED2,
	SCIA_SCARED3,
	SCIA_SCARED4,
	SCIA_PANIC,
	SCIA_FEAR1,
	SCIA_FEAR2,
	SCIA_CRY,
	SCIA_SCI1,
	SCIA_SCI2,
	SCIA_SCI3,
	SCIA_DIE_SIMPLE,
	SCIA_DIE_FORWARD1,
	SCIA_DIE_FORWARD2,
	SCIA_DIE_BACKWARD,
	SCIA_DIE_HEADSHOT,
	SCIA_DIE_GUTSHOT,
	SCIA_LYING1,
	SCIA_LYING2,
	SCIA_DEADSIT,
	SCIA_DEADTABLE1,
	SCIA_DEADTABLE2,
	SCIA_DEADTABLE3
};

class monster_scientist:CBaseNPC
{
	void(void) monster_scientist;

	virtual void(void) Respawn;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) OnPlayerUse;
	virtual void(void) TalkPanic;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;

	virtual int(void) AttackMelee;
	virtual void(void) AttackNeedle;
};

int
monster_scientist::AttackMelee(void)
{
	/* visual */
	AnimPlay(28);
	m_flAttackThink = m_flAnimTime;

	float r = random();

	if (r < 0.33)
		Sentence("!SC_CUREA");
	else if (r < 0.66)
		Sentence("!SC_CUREB");
	else
		Sentence("!SC_CUREC");

	/* functional */
	think = AttackNeedle;
	nextthink = 0.25f;
	return TRUE;
}

void
monster_scientist::AttackNeedle(void)
{
	traceline(origin, m_eEnemy.origin, FALSE, this);

	if (trace_fraction >= 1.0 || trace_ent.takedamage != DAMAGE_YES) {
		return;
	}

	Damage_Apply(trace_ent, this, 25, 0, 0);
	AnimPlay(30);
}

int
monster_scientist::AnimIdle(void)
{
	return SCIA_IDLE1;
}

int
monster_scientist::AnimWalk(void)
{
	return SCIA_WALK;
}

int
monster_scientist::AnimRun(void)
{
	return SCIA_RUN;
}

void
monster_scientist::TalkPanic(void)
{
	int r = floor(random(0,30));

	switch (r) {
	case 1:
		Sentence("!SC_SCARED1"); //scientist/stopattacking
		break;
	case 2:
		Sentence("!SC_SCARED2"); //scientist/youinsane
		break;
	case 3:
		Sentence("!SC_PLFEAR0"); //scientist/whatyoudoing
		break;
	case 4:
		Sentence("!SC_PLFEAR2"); //scientist/madness
		break;
	case 5:
		Sentence("!SC_PLFEAR3"); //scientist/noplease
		break;
	case 6:
		Sentence("!SC_PLFEAR4"); //scientist/getoutofhere
		break;
	case 7:
		Sentence("!SC_FEAR3"); //scientist/dontwantdie
		break;
	case 8:
		Sentence("!SC_FEAR4"); //scientist/getoutalive
		break;
	case 9:
		Sentence("!SC_FEAR5"); //scientist/startle3
		break;
	case 10:
		Sentence("!SC_FEAR6"); //scientist/startle4
		break;
	case 11:
		Sentence("!SC_FEAR7"); //scientist/startle5
		break;
	case 12:
		Sentence("!SC_FEAR8"); //scientist/startle6
		break;
	case 13:
		Sentence("!SC_FEAR9"); //scientist/startle7
		break;
	case 14:
		Sentence("!SC_FEAR10"); //scientist/startle8
		break;
	case 15:
		Sentence("!SC_FEAR11"); //scientist/startle9
		break;
	case 16:
		Sentence("!SC_FEAR12"); //scientist/startle1
		break;
	default:
		Sentence("!SC_SCREAM"); //scientist/sci_fear15
	}

	m_flNextSentence = time + 2.0 + random(0,3);
}

void
monster_scientist::Pain(void)
{
	if (autocvar_sh_sciattack)
		CBaseMonster::Pain();

	StartleAllies();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Speak(this, "monster_scientist.pain");

	frame = SCIA_FLINCH + floor(random(0, 6));
	m_flAnimTime = time + 0.25f;
	m_iFlags |= MONSTER_FEAR;
}

void
monster_scientist::Death(void)
{
	WarnAllies();

	if (style != MONSTER_DEAD) {
		SHMultiplayerRules rules = (SHMultiplayerRules)g_grMode;

		if (g_dmg_eAttacker.flags & FL_CLIENT)
			rules.ScientistKill((player)g_dmg_eAttacker, (entity)this);

		Plugin_PlayerObituary(g_dmg_eAttacker, this, g_dmg_iWeapon, g_dmg_iHitBody, g_dmg_iDamage);

		SetFrame(SCIA_DIE_SIMPLE + floor(random(0, 6)));
		Sound_Speak(this, "monster_scientist.die");
	}

	/* now mark our state as 'dead' */
	CBaseNPC::Death();
}

void
monster_scientist::OnPlayerUse(void)
{
	if (m_iFlags & MONSTER_FEAR)
		return;

	CBaseNPC::OnPlayerUse();
}

void
monster_scientist::Respawn(void)
{
	CBaseNPC::Respawn();
	m_iFlags |= MONSTER_CANFOLLOW;
	PlayerUse = OnPlayerUse;

	if (autocvar_sh_scialert) {
		m_iFlags |= MONSTER_FEAR;
	}
}

void
monster_scientist::monster_scientist(void)
{
	spawnflags |= MSF_MULTIPLAYER;

	Sound_Precache("monster_scientist.die");
	Sound_Precache("monster_scientist.pain");

	m_iBody = -1;
	for (int i = 1; i < (tokenize(__fullspawndata)-1); i += 2) {
		switch (argv(i)) {
		case "body":
			m_iBody = stoi(argv(i+1)) + 1;
			break;
		default:
			break;
		}
	}

	m_talkAsk = "!SC_QUESTION";
	m_talkPlayerAsk = "!SC_PQUEST";
	m_talkPlayerGreet = "!SC_PHELLO";
	m_talkPlayerIdle = "!SC_PIDLE";
	m_talkAnswer = "!SC_ANSWER";
	m_talkAllyShot = "!SC_PLFEAR";
	m_talkGreet = "";
	m_talkIdle = "!SC_IDLE";
	m_talkHearing = "!SC_HEAR";
	m_talkSmelling = "!SC_SMELL";
	m_talkStare = "!SC_STARE";
	m_talkSurvived = "!SC_WOUND";
	m_talkWounded = "!SC_MORTAL";
	m_talkUnfollow = "!SC_WAIT";
	m_talkFollow = "!SC_OK";
	m_talkStopFollow = "!SC_STOP";
	
	m_iBody = -1;

	if (autocvar_sh_sciattack)
		m_iAlliance = MAL_ALIEN;

	model = "models/scientist.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
	precache_model(m_oldModel);
	base_health = Skill_GetValue("scientist_health", 20);

	if (m_iBody == -1) {
		/* This stuff needs to be persistent because we can't guarantee that
		* the client-side geomset refresh happens. Don't shove this into Respawn */
		m_iBody = floor(random(1,5));
	}

	switch (m_iBody) {
		case 1:
			m_flPitch = 105;
			netname = "Walter";
			break;
		case 2:
			m_flPitch = 100;
			netname = "Einstein";
			break;
		case 3:
			m_flPitch = 95;
			netname = "Luther";
			skin = 1;
			break;
		default:
			m_flPitch = 100;
			netname = "Slick";
	}
}
