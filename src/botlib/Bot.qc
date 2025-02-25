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

#ifdef SERVER
/* default client side player movement values */
var float autocvar_bot_forwardspeed = 190;
var float autocvar_bot_sidespeed = 152;
var float autocvar_bot_backspeed = 133;

botstate_t
ncBot::GetState(void)
{
	return m_bsState;
}

void
ncBot::SetState(botstate_t state)
{
	m_bsState = state;
}

botpersonality_t
ncBot::GetPersonality(void)
{
	return m_bpPersonality;
}

float
ncBot::GetWalkSpeed(void)
{
	return 120;
}

float
ncBot::GetRunSpeed(void)
{
	return 240;
}

float
ncBot::GetForwardSpeed(void)
{
	return (autocvar_bot_forwardspeed);
}

float
ncBot::GetSideSpeed(void)
{
	return (autocvar_bot_sidespeed);
}

float
ncBot::GetBackSpeed(void)
{
	return (autocvar_bot_backspeed);
}

void
ncBot::RouteClear(void)
{
	super::RouteClear();
	m_flNodeGiveup = 0.0f;
}

void
ncBot::BrainThink(int enemyvisible, int enemydistant)
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
ncBot::UseButton(void)
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
		dist = distanceSquared(origin, pos);

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
ncBot::SeeThink(void)
{
	ncGameRules rules = (ncGameRules)g_grMode;

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
		flDot = vectorNormalize(w.origin - origin) * anglesToForward(v_angle);

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
ncBot::CheckRoute(void)
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
		BotEntLog("%s reached node", this.netname);
		m_iCurNode--;

		/* if we're inside an actual node (not a virtual one */
		if (m_iCurNode >= 0) {
			/* if a node is flagged as jumpy, jump! */
			if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_JUMP) {
				//input_buttons |= INPUT_JUMP;
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
				BotEntLog("Walking directly to last node.");
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
		BotEntLog("Taking too long! Giving up!");
		RouteClear();
	} else if (m_flNodeGiveup >= 0.5f) { /* attempt a jump after half a second */
		/* don't bother if it's too high (we're aiming at air... */
		if ((vecEndPos[2] - 32) < origin[2]) {
			input_buttons |= INPUT_JUMP;
		}
	} else {
		/* entire way-link needs to be crouched. that's the law of the land */
		if (Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_CROUCH || autocvar_bot_crouch)
			input_buttons |= INPUT_CROUCH;
	}
}

void
ncBot::CreateObjective(void)
{
	RouteToPosition(Route_SelectDestination(this));
}

void
ncBot::RunAI(void)
{
	vector aimDir, aimPos;
	bool enemyVisible, enemyDistant;
	float flLerp;

	/* reset input frame */
	input_buttons = 0;
	input_movevalues = [0,0,0];
	input_angles = [0,0,0];

	/* attempt to respawn when dead */
	if (IsAlive() == false) {
		RouteClear();
		WeaponAttack();
		SetEnemy(__NULL__);
		return;
	}

	/* DEVELOPER CVAR: freeze the bot */
	if (autocvar_bot_pause)
		return;

	/* create our first route */
	if (!m_iNodes && autocvar_bot_aimless == 0) {
		CreateObjective();

		BotEntLog("%S is calculating first bot route",
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
		vector vecNewAngles = g_vec_null;
		vector vecDirection = g_vec_null;

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
			aimPos = origin + anglesToForward(angles) * 128;
		}

		/* lerping speed, faster when we've got a target */
		if (m_eTarget && enemyVisible == true)
			flLerp = bound(0.0f, frametime * 45, 1.0f);
		else
			flLerp = bound(0.0f, frametime * 30, 1.0f);

		/* that's actually the old angle */
		vecNewAngles = anglesToForward(v_angle);

		/* aimDir = new final angle */
		aimDir = vectorToAngles(aimPos - origin);

		/* slowly lerp towards the final angle */
		vecNewAngles = vectorLerp(vecNewAngles, anglesToForward(aimDir), flLerp);

		/* make sure we're aiming tight */
		input_angles = angles = v_angle = vectorToAngles(vecNewAngles);

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
			} else {
				goRoute = true;
			}
		} else if (m_wtWeaponType == WPNTYPE_THROW) {
			if ((m_eTarget && enemyVisible && !enemyDistant) && m_flEnemyDist < 512) {
				aimPos = m_eTarget.origin;
			} else {
				goRoute = true;
			}
		} else {
			goRoute = true;
		}

		if (goRoute) {
			if (m_iCurNode <= BOTROUTE_DESTINATION) {
				aimPos = m_vecLastNode;
			} else {
				aimPos = m_pRoute[m_iCurNode].dest;
			}
		} else {
			RouteClear();
		}

		/* if there's a breakable in the way... */
		traceline(origin, aimPos, MOVE_NORMAL, this);

		/* Hackish: If there's a func_breakable in the way... */
		if (trace_ent.classname == "func_breakable") {
			ncEntity traceEnt = (ncEntity)trace_ent;
			ForceWeaponAttack(traceEnt.WorldSpaceCenter(), 1.0f);
		}

		/* make them walk when they need to. */
		if ((m_iCurNode >= 0 && Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_WALK) || shouldWalk)
			SetMoveSpeedScale(0.5f);
		else
			SetMoveSpeedScale(1.0f);

		vecDirection = vectorNormalize(aimPos - GetEyePos()) * g_pmoveVars.pm_walkspeed;
		makevectors(input_angles);
		input_movevalues = [v_forward * vecDirection, v_right * vecDirection, v_up * vecDirection];

		input_movevalues[2] = 0;

#if 1
		/* duck and stand still when our enemy seems strong */
		if (m_eTarget && enemyVisible && m_eTarget.health >= 75) {
			if (m_wtWeaponType == WPNTYPE_RANGED) {
				input_buttons |= INPUT_CROUCH;
				input_movevalues = [0,0,0];
			}
		}
#endif
	}

	/* press any buttons needed */
	button0 = input_buttons & INPUT_PRIMARY; // attack
	button2 = input_buttons & INPUT_JUMP; // jump
	button3 = input_buttons & INPUT_PRONE; // prone
	button4 = input_buttons & INPUT_RELOAD; // reload
	button5 = input_buttons & INPUT_SECONDARY; // secondary
	button6 = input_buttons & INPUT_USE; // use
	button7 = input_buttons & INPUT_SPRINT; // unused
	button8 = input_buttons & INPUT_CROUCH; // duck
	movement = input_movevalues;
}

void
ncBot::BotPreFrame(void)
{
}

void
ncBot::BotPostFrame(void)
{
}

void
ncBot::AddedItemCallback(ncItem newItem)
{
	if (isBot(this) == true) {
		SwitchToBestWeapon(false);
	} else {
		super::AddedItemCallback(newItem);
	}
}

void
ncBot::SetName(string nickname)
{
	if (autocvar_bot_prefix)
		SetInfoKey("name", sprintf("%s %s", autocvar_bot_prefix, nickname));
	else
		SetInfoKey("name", nickname);
}

void
ncBot::SetInfoKey(string strKey, string strValue)
{
	forceinfokey(this, strKey, strValue);
}

void
ncBot::SetInfoKeyFloat(string strKey, float floatValue)
{
	forceinfokey(this, strKey, ftos(floatValue));
}
#endif

string
ncBot::GetInfoKey(string strKey)
{
#ifdef SERVER
	return infokey(this, strKey);
#endif

#ifdef CLIENT
	return getplayerkeyvalue(entnum-1, strKey);
#endif
}


float
ncBot::GetInfoKeyFloat(string strKey)
{
#ifdef SERVER
	return infokeyf(this, strKey);
#endif

#ifdef CLIENT
	return getplayerkeyfloat(entnum-1, strKey);
#endif
}


void
ncBot::ncBot(void)
{
}

#ifdef SERVER
void
Bot_KickRandom(void)
{
	for (entity e = world;(e = find(e, ::classname, "player"));) {
		if (clienttype(e) == CLIENTTYPE_BOT) {
			dropclient(e);
			return;
		}
	}
}

void
bot_spawner_think(void)
{
	int clientCount = 0i;
	int botCount = 0i;
	int minClientsCvar = (int)cvar("bot_minClients");

	/* if -1, we are not managing _anything_ */
	if (minClientsCvar == -1i) {
		self.nextthink = time + 5.0f;
		return;
	}

	/* count total clients + bots */
	for (entity e = world;(e = find(e, ::classname, "player"));) {
		if (clienttype(e) == CLIENTTYPE_BOT) {
			clientCount++;
			botCount++;
		}else if (clienttype(e) == CLIENTTYPE_REAL) {
			clientCount++;
		}
	}

	/* add remove as necessary */
	if (clientCount < minClientsCvar) {
		BotProfile_AddRandom();
	} else if (clientCount > minClientsCvar) {
		if (botCount > 0i) {
			Bot_KickRandom();
		}
	}

	self.nextthink = time + 1.0f;
}

void
BotLib_Init(void)
{
	BotProfile_Init();

	/* this spawner manages the active bots */
	entity bot_spawner = spawn();
	bot_spawner.think = bot_spawner_think;
	bot_spawner.nextthink = time + 1.0f;
}
#endif
