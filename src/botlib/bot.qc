/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

void SV_SendChat(entity sender, string msg, entity eEnt, float fType);

botstate_t
bot::GetState(void)
{
	return m_bsState;
}

void
bot::SetState(botstate_t state)
{
	m_bsState = state;
}

botpersonality_t
bot::GetPersonality(void)
{
	return m_bpPersonality;
}

float
bot::GetWalkSpeed(void)
{
	return 120;
}

float
bot::GetRunSpeed(void)
{
	return 240;
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
	print(sprintf("%s cleared his route.\n", netname));
}

void
bot::BrainThink(int enemyvisible, int enemydistant)
{
	/* we had a target and it's now dead. now what? */
	if (m_eTarget) {
		if (m_eTarget.health <= 0) {
			SetEnemy(__NULL__);
			RouteClear();
		}
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
	CGameRules rules = (CGameRules)g_grMode;

	/*if (m_eTarget)
		return; */

	if (m_flSeeTime > time)
		return;

	if (autocvar_bot_pacifist)
		return;

	m_flSeeTime = time + 0.25f;

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		float flDot;

		/* is w a client? */
		if (!(w.flags & FL_CLIENT))
			continue;

		/* is w alive? */
		if (w.health <= 0)
			continue;

		/* ain't go hurt our brothers and sisters */
		if (rules.IsTeamPlay() == TRUE)
			if (team == w.team)
				continue;

		/* first, is the potential enemy in our field of view? */
		makevectors(v_angle);
		vector v = normalize(w.origin - origin);
		flDot = v * v_forward;

		if (flDot < 90/180)
			continue;

		/* is it even physically able to be seen? */
		traceline(origin, w.origin, MOVE_NORMAL, this);

		/* break out if at all a valid trace */
		if (trace_ent == w) {
			SetEnemy(w);
			return;
		}
	}
}

void
bot::CheckRoute(void)
{
	float flDist;
	vector vecEndPos;
	float flRadius;

	if (!m_iNodes) {
		return;
	}

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		vecEndPos = m_vecLastNode;
		flRadius = 128; /* destination is not a node, therefore has a virtual radius */
	} else {
		vecEndPos = m_pRoute[m_iCurNode].m_vecDest;
		flRadius = m_pRoute[m_iCurNode].m_flRadius;
	}

	/* we need to have a sensible radius */
	if (flRadius <= 16)
		flRadius = 16.0f;

	/* we only check if we've moved anywhere on the X/Y axis */
	flDist = floor(vlen([vecEndPos[0],vecEndPos[1],origin[2]] - origin));

//	print(sprintf("%s node dist: %d; radius: %d\n", netname, flDist, rad));

	/* we're inside the radius */
	if (flDist <= flRadius) {
		NSLog("^2bot::^3CheckRoute^7: " \
			"%s reached node\n", this.targetname);
		m_iCurNode--;

		/* if we're inside an actual node (not a virtual one */
		if (m_iCurNode >= 0) {
			/* if a node is flagged as jumpy, jump! */
			if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_JUMP) {
				//input_buttons |= INPUT_BUTTON2;
				velocity = Route_GetJumpVelocity(origin, m_pRoute[m_iCurNode].m_vecDest, gravity);
			}

			/* find the nearest usable item (func_button) and use them */
			if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_USER)
				UseButton();
		}

#if 0
		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, vecEndPos, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				print("^2bot::^3CheckRoute^7: " \
					"Walking directly to last node\n");
				m_iCurNode = -1;
			}
		}
#endif
	} else { /* we're not near the node quite yet */
		traceline(origin, vecEndPos, MOVE_NORMAL, this);

		/* we can't trace against our next node... that should never happen */
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
		print("taking too long! giving up!\n");
		RouteClear();
	} else if (m_flNodeGiveup >= 0.5f) {
		/* attempt a jump after half a second */

		/* don't bother if it's too high (we're aiming at air... */
		if ((vecEndPos[2] - 32) < origin[2])
			input_buttons |= INPUT_BUTTON2;
	} else {
		/* entire way-link needs to be crouched. that's the law of the land */
		if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_CROUCH)
			input_buttons |= INPUT_BUTTON8;
	}
}

void
bot::NewRoute(vector pos)
{
	route_calculate(this, pos, 0, Bot_RouteCB);
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
		SetEnemy(__NULL__);
		return;
	}

	/* freeze the bot */
	if (autocvar_bot_wait)
		return;

	/* create our first route */
	if (!m_iNodes && autocvar_bot_aimless == 0) {
		CreateObjective();

		NSLog("bot::RunAI: %s is calculating first bot route",
			this.netname);

		/* our route probably has not been processed yet */
		if (!m_iNodes) {
			return;
		}
	}

	/* prepare our weapons for firing */
	WeaponThink();

	/* see if enemies are nearby */
	SeeThink();

	/* calculate enemy distance _once_ */
	if (m_eTarget) {
		m_flEnemyDist = vlen(origin - m_eTarget.origin);
	} else {
		m_flEnemyDist = -1;
	}

	enemyvisible = FALSE;
	enemydistant = FALSE;

	if (m_eTarget != __NULL__) {
		traceline(origin + view_ofs, m_eTarget.origin, TRUE, this);

		/* is it 'visible'? can we 'see' them? */
		enemyvisible = (trace_ent == m_eTarget || trace_fraction == 1.0f);

		/* if they're distant, remember that */
		if (m_flEnemyDist > 1024) {
			enemydistant = TRUE;
		}

		/* attack if visible! */
		if (enemyvisible) {
			WeaponAttack();
		}
	}

	BrainThink(enemyvisible, enemydistant);
	CheckRoute();

	aimpos = [0,0,0];

	/* if we've got a path (we always should) move the bot */
	if (m_iNodes) {
		float goroute = 0;
		vector vecNewAngles;
		vector vecDirection;

		/* no enemy, or it isn't visible... then stare at nodes! */
		if (!m_eTarget || !enemyvisible) {
			/* aim at the next node */
			if (m_iCurNode == BOTROUTE_DESTINATION)
				aimpos = m_vecLastNode;
			else {
				if (m_iCurNode > 0 && !(Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_AIM))
					aimpos = m_pRoute[m_iCurNode - 1].m_vecDest;
				else
					aimpos = m_pRoute[m_iCurNode].m_vecDest;
			}
		} else {
			/* aim towards the enemy */
			aimpos = m_eTarget.origin;
		}

		/* aim ahead if aimpos is somehow invalid */
		if (aimpos == [0,0,0]) {
			makevectors(angles);
			aimpos = origin + v_forward * 128;
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

		float shouldwalk = 0;

		if (m_wtWeaponType == WPNTYPE_RANGED) {
			other = world;

			if (m_eTarget) {
				tracebox(origin, m_eTarget.origin, mins, maxs, MOVE_OTHERONLY, this);
				/* walk _directly_ towards the enemy if we're less than 512 units away */
				if (trace_fraction >= 1.0 && m_eTarget && enemyvisible && m_eTarget.health < 50 && m_flEnemyDist < 512) {
					aimpos = m_eTarget.origin;
					goroute = 1;
				} else {
					goroute = 1;
				}
			} else {
				goroute = 1;
			}

			/* we should probably walk we're distant enough to be more accurate */
			if ((m_eTarget && enemyvisible && m_flEnemyDist < 512))
				shouldwalk = 1;
		} else if (m_wtWeaponType == WPNTYPE_CLOSE) {
			/* move directly towards the enemy if we're 256 units away */
			if (m_eTarget && enemyvisible && m_flEnemyDist < 256) {
				/* we are far away, inch closer */
				aimpos = m_eTarget.origin;
				//printf("going to target\n");
			} else {
				goroute = 1;
			}
		} else if (m_wtWeaponType == WPNTYPE_THROW) {
			if ((m_eTarget && enemyvisible && !enemydistant) && m_flEnemyDist < 512) {
				aimpos = m_eTarget.origin;
				//printf("going to target\n");
			} else {
				goroute = 1;
			}
		} else {
			goroute = 1;
		}

		if (goroute) {
			if (m_iCurNode <= BOTROUTE_DESTINATION) {
				aimpos = m_vecLastNode;
				//printf("going to last node\n");
			} else {
				aimpos = m_pRoute[m_iCurNode].m_vecDest;
				//printf("going to next node\n");
			}
		} else {
			RouteClear();
		}

		/* now we'll set the movevalues relative to the input_angle */
		if ((m_iCurNode >= 0 && Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_WALK) || shouldwalk)
			vecDirection = normalize(aimpos - origin) * GetWalkSpeed();
		else
			vecDirection = normalize(aimpos - origin) * GetRunSpeed();

		makevectors(input_angles);
		input_movevalues = [v_forward * vecDirection, v_right * vecDirection, v_up * vecDirection];
		input_movevalues[2] = 0;

#if 1
		/* duck and stand still when our enemy seems strong */
		if (m_eTarget && enemyvisible && m_eTarget.health >= 75) {
			if (m_wtWeaponType == WPNTYPE_RANGED) {
				input_buttons |= INPUT_BUTTON8;
				input_movevalues = [0,0,0];
			}
		}
#endif
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
	forceinfokey(this, "*bot", "1");
}
