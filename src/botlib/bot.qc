/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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
	super::RouteClear();
	m_flNodeGiveup = 0.0f;
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
		RouteToPosition(m_eTarget.origin);
	}
}

void
bot::UseButton(void)
{
	float bestDist;
	func_button bestButton = __NULL__;

	bestDist = COST_INFINITE;
	for (entity e = world; (e = find(e, ::classname, "func_button"));) {
		float dist;
		vector pos;
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));
		dist = vlen(origin - pos);

		if (dist < bestDist) {
			bestDist = dist;
			bestButton = (func_button)e;
		}
	}

	if (bestButton == __NULL__) {
		return;
	}

	bestButton.Trigger(this, TRIG_TOGGLE);
	StartSoundDef("Player.WeaponSelected", CHAN_ITEM, false);
}

void
bot::SeeThink(void)
{
	NSGameRules rules = (NSGameRules)g_grMode;

	/*if (m_eTarget)
		return; */

	if (m_flSeeTime > time) {
		return;
	}

	/* DEVELOPER CVAR: don't attack */
	if (autocvar_bot_dont_shoot) {
		return;
	}

	/* reaction time, in a way */
	switch (cvar("bot_skill")) {
	case 1:
		m_flSeeTime = time + 0.5f;
		break;
	case 2:
		m_flSeeTime = time + 0.25f;
		break;
	case 3:
		m_flSeeTime = time + 0.15f;
		break;
	default:
		m_flSeeTime = time + 1.0f;
	}

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		float flDot;

		/* is w a client? */
		if (!(w.flags & FL_CLIENT))
			continue;

		/* is w alive? */
		if (w.health <= 0)
			continue;

		/* ain't go hurt our brothers and sisters */
		if (rules.IsTeamplay() == true)
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
		vecEndPos = m_pRoute[m_iCurNode].dest;
		flRadius = m_pRoute[m_iCurNode].radius;
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
				velocity = Route_GetJumpVelocity(origin, m_pRoute[m_iCurNode].dest, gravity);
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
		if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_CROUCH || autocvar_bot_crouch)
			input_buttons |= INPUT_BUTTON8;
	}
}

void
bot::CreateObjective(void)
{
	RouteToPosition(Route_SelectDestination(this));
}

void
bot::RunAI(void)
{
	vector aimDir, aimPos;
	bool enemyVisible, enemyDistant;
	float flLerp;

	/* reset input frame */
	input_buttons = 0;
	input_movevalues = [0,0,0];
	input_angles = [0,0,0];

	/* attempt to respawn when dead */
	if (IsDead() == true) {
		RouteClear();
		WeaponAttack();
		SetEnemy(__NULL__);
		return;
	}

	/* DEVELOPER CVAR: freeze the bot */
	if (autocvar_bot_stop)
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

	enemyVisible = false;
	enemyDistant = false;

	if (m_eTarget != __NULL__) {
		traceline(GetEyePos(), m_eTarget.origin, MOVE_NORMAL, this);

		/* is it 'visible'? can we 'see' them? */
		enemyVisible = (trace_ent == m_eTarget || trace_fraction == 1.0f);

		/* if they're distant, remember that */
		if (m_flEnemyDist > 1024.0f) {
			enemyDistant = true;
		}

		/* attack if visible! */
		if (enemyVisible == true) {
			WeaponAttack();
		}
	} else if (m_flForceWeaponAttack > time) {
		WeaponAttack();
	}

	BrainThink(enemyVisible, enemyDistant);
	CheckRoute();

	aimPos = [0,0,0];

	/* if we've got a path (we always should) move the bot */
	if (m_iNodes) {
		bool goRoute = false;
		vector vecNewAngles;
		vector vecDirection;

		/* no enemy, or it isn't visible... then stare at nodes! */
		if (!m_eTarget || enemyVisible == false) {
			/* aim at the next node */
			if (m_iCurNode == BOTROUTE_DESTINATION)
				aimPos = m_vecLastNode;
			else {
				if (m_iCurNode > 0 && !(Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_AIM))
					aimPos = m_pRoute[m_iCurNode - 1].dest;
				else
					aimPos = m_pRoute[m_iCurNode].dest;
			}
		} else {
			/* aim towards the enemy */
			aimPos = m_eTarget.origin;
		}

		/* force bot to fire at a position if desired */
		if (m_flForceWeaponAttack > time)
			aimPos = m_vecForceWeaponAttackPos;

		/* aim ahead if aimPos is somehow invalid */
		if (aimPos == [0,0,0]) {
			makevectors(angles);
			aimPos = origin + v_forward * 128;
		}

		/* lerping speed, faster when we've got a target */
		if (m_eTarget && enemyVisible == true)
			flLerp = bound(0.0f, frametime * 45, 1.0f);
		else
			flLerp = bound(0.0f, frametime * 30, 1.0f);

		/* that's the old angle */
		makevectors(v_angle);
		vecNewAngles = v_forward;

		/* aimDir = new final angle */
		aimDir = vectoangles(aimPos - origin);
		makevectors(aimDir);

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

		bool shouldWalk = autocvar_bot_walk;

		if (m_wtWeaponType == WPNTYPE_RANGED) {
			if (m_eTarget) {
				other = world;
				tracebox(origin, m_eTarget.origin, mins, maxs, MOVE_OTHERONLY, this);

				/* walk _directly_ towards the enemy if we're less than 512 units away */
				if (trace_fraction >= 1.0 && m_eTarget && enemyVisible && m_eTarget.health < 50 && m_flEnemyDist < 512) {
					aimPos = m_eTarget.origin;
					goRoute = true;
				} else {
					goRoute = true;
				}
			} else {
				goRoute = true;
			}

			/* we should probably walk we're distant enough to be more accurate */
			if ((m_eTarget && enemyVisible && m_flEnemyDist < 512))
				shouldWalk = true;
		} else if (m_wtWeaponType == WPNTYPE_CLOSE) {
			/* move directly towards the enemy if we're 256 units away */
			if (m_eTarget && enemyVisible && m_flEnemyDist < 256) {
				/* we are far away, inch closer */
				aimPos = m_eTarget.origin;
				//printf("going to target\n");
			} else {
				goRoute = true;
			}
		} else if (m_wtWeaponType == WPNTYPE_THROW) {
			if ((m_eTarget && enemyVisible && !enemyDistant) && m_flEnemyDist < 512) {
				aimPos = m_eTarget.origin;
				//printf("going to target\n");
			} else {
				goRoute = true;
			}
		} else {
			goRoute = true;
		}

		if (goRoute) {
			if (m_iCurNode <= BOTROUTE_DESTINATION) {
				aimPos = m_vecLastNode;
				//printf("going to last node\n");
			} else {
				aimPos = m_pRoute[m_iCurNode].dest;
				//printf("going to next node\n");
			}
		} else {
			RouteClear();
		}

		/* if there's a breakable in the way... */
		traceline(origin, aimPos, MOVE_NORMAL, this);

		/* Hackish: If there's a func_breakable in the way... */
		if (trace_ent.classname == "func_breakable") {
			NSEntity traceEnt = (NSEntity)trace_ent;
			ForceWeaponAttack(traceEnt.WorldSpaceCenter(), 1.0f);
		}

		/* now we'll set the movevalues relative to the input_angle */
		if ((m_iCurNode >= 0 && Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_WALK) || shouldWalk)
			vecDirection = normalize(aimPos - origin) * GetWalkSpeed();
		else
			vecDirection = normalize(aimPos - origin) * GetRunSpeed();

		makevectors(input_angles);
		input_movevalues = [v_forward * vecDirection, v_right * vecDirection, v_up * vecDirection];
		input_movevalues[2] = 0;

#if 1
		/* duck and stand still when our enemy seems strong */
		if (m_eTarget && enemyVisible && m_eTarget.health >= 75) {
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
#ifndef NEW_INVENTORY
	/* we've picked something new up */
	if (m_iOldItems != g_items) {
		Weapons_SwitchBest(this);
		print(sprintf("%s is now using %s (%d)\n", netname, g_weapons[activeweapon].name, activeweapon));
		m_iOldItems = g_items;
	}
#endif
}

void
bot::SetName(string nickname)
{
	if (autocvar_bot_prefix)
		forceinfokey(this, "name", sprintf("%s %s", autocvar_bot_prefix, nickname));
	else
		forceinfokey(this, "name", nickname);
}

void
bot::bot(void)
{
	classname = "player";
	targetname = "_nuclide_bot_";
	forceinfokey(this, "*bot", "1");
}
