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

#define BOTROUTE_DESTINATION	-1
#define BOTROUTE_END			-2

void SV_SendChat(entity sender, string msg, entity eEnt, float fType);

void
bot::ChatSay(string msg)
{
	SV_SendChat(this, msg, world, 0);
}

void
bot::ChatSayTeam(string msg)
{
	entity a;
	for (a = world; (a = find(a, ::classname, "player"));) { 
		if (a.team == this.team) {
			SV_SendChat(self, msg, a, 1);
		}
	}
}

void
bot::Pain(void)
{
	player::Pain();

	/* might as well target our attacker */
	m_eTarget = g_dmg_eAttacker;
}

void
bot::RouteClear(void)
{
	if (!m_iNodes)
		return;

	m_iCurNode = BOTROUTE_END;
	m_iNodes = 0;
	m_flNodeGiveup = 0.0f;
	memfree(m_pRoute);
}

void
bot::WeaponThink(void)
{
	/* clip empty */
	if (a_ammo1 == 0) {
		/* still got ammo left, reload! */
		if (a_ammo2 != 0) {
			input_buttons &= ~INPUT_BUTTON0;
			input_buttons |= INPUT_BUTTON4;
		} else {
			Weapons_SwitchBest(this);
		}
	}
}

void
bot::WeaponAttack(void)
{
	if (m_flAttackTime < time) {
		if (!m_iAttackMode) {
			input_buttons |= INPUT_BUTTON0; // Attack
		}
		m_flAttackTime = time + 0.1f;
	}
	m_iAttackMode = 1 - m_iAttackMode;
}

void
bot::BrainThink(int enemyvisible, int enemydistant)
{
	/* we had a target and it's now dead. now what? */
	if (m_eTarget && m_eTarget.health <= 0) {
		m_eTarget = __NULL__;
		RouteClear();
	} else if (m_eTarget && enemyvisible && enemydistant) {
		/* we can see the player, but are too far away, plot a route */
		route_calculate(this, m_eTarget.origin, 0, Bot_RouteCB);
	}
}

void
bot::UseButton(void)
{
#if 1
	float best;
	func_button best_button = __NULL__;

	best = COST_INFINITE;
	for (entity e = world; (e = find(e, ::classname, "func_button"));) {
		float dist;
		vector pos;
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));
		dist = vlen(origin - pos);

		if (dist < best) {
			best = dist;
			best_button = (func_button)e;
		}
	}

	if (best_button == __NULL__)
		return;

	best_button.Trigger(this, TRIG_TOGGLE);
	sound(this, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE);
#else
	float best;
	vector foo;

	best = COST_INFINITE;
	for (entity e = world; (e = find(e, ::classname, "func_button"));) {
		float dist;
		vector pos;
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));
		dist = vlen(origin - pos);

		if (dist < best) {
			best = dist;
			foo = pos;
		}
	}

	v_angle = vectoangles(origin - foo);
	Player_UseDown();
#endif
}

void
bot::SeeThink(void)
{
	if (m_eTarget)
		return;

	if (m_flSeeTime > time)
		return;

	if (autocvar_bot_pacifist)
		return;

	m_flSeeTime = time + 0.25f;

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		float flDot;

		if (!(w.flags & FL_CLIENT))
			continue;
		if (w.health <= 0)
			continue;

		/* ain't go hurt our brothers and sisters */
		if (Rules_IsTeamPlay() == TRUE)
			if (team == w.team)
				continue;

		/* first, is the potential enemy in our field of view? */
		makevectors(v_angle);
		vector v = normalize(w.origin - origin);
		flDot = v * v_forward;

		if (flDot < 90/180)
			continue;

		other = world;
		traceline(origin, w.origin, MOVE_OTHERONLY, this);

		if (trace_fraction == 1.0f) {
			m_eTarget = w;
			return;
		}
	}
}

void
bot::CheckRoute(void)
{
	float flDist;
	vector evenpos;
	float rad;

	if (!m_iNodes) {
		return;
	}

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		evenpos = m_vecLastNode - origin;
		rad = 64;
	} else {
		evenpos = m_pRoute[m_iCurNode].m_vecDest - origin;
		rad = m_pRoute[m_iCurNode].m_flRadius;
	}

	flDist = floor(vlen(evenpos));

	if (flDist <= rad) {
		dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: " \
			"%s reached node\n", this.targetname));
		m_iCurNode--;

		if (m_iCurNode >= 0) {
			if (m_pRoute[m_iCurNode].m_iFlags)
			print(sprintf("NODE FLAGS: %i\n", m_pRoute[m_iCurNode].m_iFlags));

			/* if a node is flagged as jumpy, jump! */
			if (m_pRoute[m_iCurNode].m_iFlags & LF_JUMP)
				input_buttons |= INPUT_BUTTON2;

			/* find the nearest usable item (func_button) and use them */
			if (m_pRoute[m_iCurNode].m_iFlags & LF_USER)
				UseButton();
		}

#if 0
		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				dprint("^2CBaseMonster::^3CheckRoute^7: " \
					"Walking directly to last node\n");
				m_iCurNode = -1;
			}
		}
#endif
	} else {
		traceline(origin + view_ofs, m_pRoute[m_iCurNode].m_vecDest, MOVE_NORMAL, this);

		/* we can't trace against our next waypoint... that should never happen */
		if (trace_fraction != 1.0f) {
			m_flNodeGiveup += frametime;
		} else {
			/* if we're literally stuck in a corner aiming at something we should
			 * not, also give up */
			if (flDist == m_flLastDist) {
				m_flNodeGiveup += frametime;
			} else {
				m_flNodeGiveup = bound(0, m_flNodeGiveup - frametime, 1.0);
			}
		}
	}

	m_flLastDist = flDist;

	/* after one second, also give up the route */
	if (m_flNodeGiveup >= 1.0f || m_iCurNode <= BOTROUTE_END) {
		RouteClear();
	} else if (m_flNodeGiveup >= 0.5f) {
		/* attempt a jump after half a second */
		input_buttons |= INPUT_BUTTON2;
	} else {
		/* entire way-link needs to be crouched. that's the law of the land */
		if (m_pRoute[m_iCurNode].m_iFlags & LF_CROUCH)
			input_buttons |= INPUT_BUTTON8;
	}
}

void
bot::CreateObjective(void)
{
	route_calculate(this, Route_SelectDestination(this), 0, Bot_RouteCB);
}

void
bot::RunAI(void)
{
	vector aimdir, aimpos;
	int enemyvisible, enemydistant;
	float flLerp;

	/* reset input frame */
	input_buttons = 0;
	input_movevalues = [0,0,0];
	input_angles = [0,0,0];

	/* attempt to respawn when dead */
	if (health <= 0) {
		RouteClear();
		WeaponAttack();
		m_eTarget = __NULL__;
		return;
	}

	/* freeze the bot */
	if (autocvar_bot_wait)
		return;

	/* create our first route */
	if (!m_iNodes && autocvar_bot_aimless == 0) {
		CreateObjective();

		dprint(sprintf("bot::RunAI: %s is calculating first bot route\n",
			this.netname));

		/* our route probably has not been processed yet */
		if (!m_iNodes) {
			return;
		}
	}

	WeaponThink();
	SeeThink();

	enemyvisible = FALSE;
	enemydistant = FALSE;

	if (m_eTarget != __NULL__) {
		traceline(origin + view_ofs, m_eTarget.origin, TRUE, this);
		enemyvisible = (trace_ent == m_eTarget || trace_fraction == 1.0f);

		if (vlen(trace_endpos - origin) > 1024) {
			enemydistant = TRUE;
		}

		if (enemyvisible) {
			WeaponAttack();
		}
	}
	
	BrainThink(enemyvisible, enemydistant);
	CheckRoute();

	if (m_iNodes) {
		vector vecNewAngles;
		vector vecDirection;

		if (!m_eTarget || !enemyvisible) {
			/* aim at the next node */
			if (m_iCurNode == BOTROUTE_DESTINATION)
				aimpos = m_vecLastNode;
			else {
				if (m_iCurNode > 0 && !(m_pRoute[m_iCurNode].m_iFlags & LF_AIM))
					aimpos = m_pRoute[m_iCurNode - 1].m_vecDest;
				else
					aimpos = m_pRoute[m_iCurNode].m_vecDest;
			}
		} else {
			/* aim towards the enemy */
			aimpos = m_eTarget.origin;
		}

		/* lerping speed, faster when we've got a target */
		if (m_eTarget && enemyvisible)
			flLerp = bound(0.0f, frametime * 45, 1.0f);
		else
			flLerp = bound(0.0f, frametime * 30, 1.0f);

		/* that's the old angle */
		makevectors(v_angle);
		vecNewAngles = v_forward;

		/* aimdir = new final angle */
		aimdir = vectoangles(aimpos - origin);
		makevectors(aimdir);

		/* slowly lerp towards the final angle */
		vecNewAngles[0] = Math_Lerp(vecNewAngles[0], v_forward[0], flLerp);
		vecNewAngles[1] = Math_Lerp(vecNewAngles[1], v_forward[1], flLerp);
		vecNewAngles[2] = Math_Lerp(vecNewAngles[2], v_forward[2], flLerp);

		/* make sure we're aiming tight */
		v_angle = vectoangles(vecNewAngles);
		v_angle[0] = Math_FixDelta(v_angle[0]);
		v_angle[1] = Math_FixDelta(v_angle[1]);
		v_angle[2] = Math_FixDelta(v_angle[2]);
		angles[0] = Math_FixDelta(v_angle[0]);
		angles[1] = Math_FixDelta(v_angle[1]);
		angles[2] = Math_FixDelta(v_angle[2]);
		input_angles = v_angle;

		/* now that aiming is sorted, we need to correct the movement */
		if ((m_eTarget && enemyvisible && !enemydistant) && vlen(aimpos - origin) > 256) {
			/* we are far away, inch closer */
			aimpos = m_eTarget.origin;
		} else {
			if (m_iCurNode <= BOTROUTE_DESTINATION)
				aimpos = m_vecLastNode;
			else
				aimpos = m_pRoute[m_iCurNode].m_vecDest;
		}

		/* now we'll set the movevalues relative to the input_angle */
		if ((m_iCurNode >= 0 && m_pRoute[m_iCurNode].m_iFlags & LF_WALK) || m_eTarget && enemyvisible && vlen(aimpos-origin) < 512)
			vecDirection = normalize(aimpos - origin) * 120;
		else
			vecDirection = normalize(aimpos - origin) * 240;

		makevectors(input_angles);
		input_movevalues = [v_forward * vecDirection, v_right * vecDirection, v_up * vecDirection];

		/* duck and stand still when our enemy is far away */
		if (m_eTarget && enemyvisible && vlen(aimpos-origin) > 512) {
			input_buttons |= INPUT_BUTTON8;
			input_movevalues = [0,0,0];
		}
	}

	/* press any buttons needed */
	button0 = input_buttons & INPUT_BUTTON0; // attack
	button2 = input_buttons & INPUT_BUTTON2; // jump
	button3 = input_buttons & INPUT_BUTTON3; // tertiary
	button4 = input_buttons & INPUT_BUTTON4; // reload
	button5 = input_buttons & INPUT_BUTTON5; // secondary
	button6 = input_buttons & INPUT_BUTTON6; // use
	button7 = input_buttons & INPUT_BUTTON7; // unused
	button8 = input_buttons & INPUT_BUTTON8; // duck
	movement = input_movevalues;
}

void
bot::PreFrame(void)
{
}

void
bot::PostFrame(void)
{
	/* we've picked something new up */
	if (m_iOldItems != g_items) {
		Weapons_SwitchBest(this);
		print(sprintf("%s is now using %s (%d)\n", netname, g_weapons[activeweapon].name, activeweapon));
		m_iOldItems = g_items;
	}
}

void
bot::bot(void)
{
	classname = "player";
	targetname = "_nuclide_bot_";
}
