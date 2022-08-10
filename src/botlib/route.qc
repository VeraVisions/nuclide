/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/*
* Begin calculating a route. 
* The callback function will be called once the route has finished being calculated. 
* The route must be memfreed once it is no longer needed. 
* The route must be followed in reverse order (ie: the first node that must be reached 
* is at index numnodes-1). If no route is available then the callback will be called with no nodes.
*/
int
Route_RoundDistance(float flDist)
{
	float r = fabs(flDist) % 2.0f;

	if (r == 0)
		return (flDist);

	if (flDist < 0)
		return -(fabs(flDist) - r);
	else
		return (flDist + 2.0f - r);
}


/* returns a botinfo point that's nearest to us */
entity
Route_SelectFarthest(float type, vector org, optional vector lastpoi = [0,0,0]) 
{
	entity temp;
	int bestrange = 0;
	int range;
	entity dest = __NULL__;

	for (temp = world; (temp = findfloat(temp, ::botinfo, type));) {
		range = vlen(temp.origin - org);

		if (lastpoi == temp.origin)
			continue;

		if ((range > bestrange) && (temp.solid != SOLID_NOT)) {
			bestrange = range;
			dest = temp;
		}
	}

	return dest;
}

/* returns a botinfo point that's nearest to us */
entity
Route_SelectNearest(float type, vector org, optional vector lastpoi = [0,0,0]) 
{
	entity temp;
	int bestrange = COST_INFINITE;
	int range;
	entity dest = __NULL__;

	for (temp = world; (temp = findfloat(temp, ::botinfo, type));) {
		range = vlen(temp.origin - org);

		if (lastpoi == temp.origin)
			continue;

		if ((range < bestrange) && (temp.solid != SOLID_NOT)) {
			bestrange = range;
			dest = temp;
		}
	}

	return dest;
}

/* returns a botinfo point belonging to our team */
entity
Route_SelectNearestTeam(float type, vector org, float tt) 
{
	entity temp;
	int bestrange = COST_INFINITE;
	int range;
	entity dest = __NULL__;

	for (temp = world; (temp = findfloat(temp, ::botinfo, type));) {
		if (temp.team != tt)
			continue;

		range = vlen(temp.origin - org);

		if ((range < bestrange) && (temp.solid != SOLID_NOT)) {
			bestrange = range;
			dest = temp;
		}
	}

	return dest;
}

/* returns a botinfo point belonging to the enemy team */
entity
Route_SelectNearestEnemyTeam(float type, vector org, float tt) 
{
	entity temp;
	int bestrange = COST_INFINITE;
	int range;
	entity dest = __NULL__;

	for (temp = world; (temp = findfloat(temp, ::botinfo, type));) {
		if (temp.team == tt)
			continue;

		range = vlen(temp.origin - org);

		if ((range < bestrange) && (temp.solid != SOLID_NOT)) {
			bestrange = range;
			dest = temp;
		}
	}

	return dest;
}


/*
================
Spawn_SelectRandom
================
*/
entity
Route_SelectRandom(string sEntname) 
{
	static entity eLastSpot;
	eLastSpot = find(eLastSpot, classname, sEntname);
	return (eLastSpot);
}

/*
================
Route_SelectRandomSpot
================
*/
entity
Route_SelectRandomSpot(void)
{
	static entity eLastSpot;
	eLastSpot = findfloat(eLastSpot, ::botinfo, BOTINFO_SPAWNPOINT);

	if (!eLastSpot)
		return (Route_SelectRandomSpot());

	return (eLastSpot);
}

vector
Route_SelectDestination(bot target)
{
	CGameRules rules;
	rules = (CGameRules)g_grMode;

	entity dest = world;

	if (rules.IsTeamplay()) {
		/* we have the goal item, so capture it */
		if (target.flags & FL_GOALITEM) {
			print(sprintf("%s going for capture\n", target.netname));
			dest = Route_SelectNearestTeam(BOTINFO_TEAM_GOALCAPTURE, target.origin, target.team);
			
			/* we may have to go to our teams' goal item then */
			if (!dest) {
				dest = Route_SelectNearestTeam(BOTINFO_TEAM_GOALITEM, target.origin, target.team);
			}
		} else {
			print(sprintf("%s hunting for goal item\n", target.netname));
			dest = Route_SelectNearestEnemyTeam(BOTINFO_TEAM_GOALITEM, target.origin, target.team);
		}

		if (dest != __NULL__) {
			target.m_vecLastPOI = dest.origin;
			return dest.origin + [0,0,32];
		}

		print(sprintf("%s can't figure out where to go for the goal\n", target.netname));
	}

	/* if we're low on health, look for health items */
	if (target.health < 50) {
		print(sprintf("%s going for health\n", target.netname));
		dest = Route_SelectNearest(BOTINFO_HEALTH, target.origin, target.m_vecLastPOI);

		if (dest != __NULL__) {
			target.m_vecLastPOI = dest.origin;
			return dest.origin + [0,0,32];
		}

		print(sprintf("%s can't figure out where to go for health\n", target.netname));
	}

	/* armor is always a good idea to have */
	if (random() < 0.25)
	if (target.armor < 50) {
		print(sprintf("%s going for armor\n", target.netname));
		dest = Route_SelectNearest(BOTINFO_ARMOR, target.origin, target.m_vecLastPOI);
		
		if (dest != __NULL__) {
			target.m_vecLastPOI = dest.origin;
			return dest.origin + [0,0,32];
		}

		print(sprintf("%s can't figure out where to go for armor\n", target.netname));
	}

	/* go for ammo, or weapon */
	if (random() < 0.25)
	if (!dest) {
		print(sprintf("%s going for ammo/weapon\n", target.netname));

		if (random() < 0.5)
			dest = Route_SelectFarthest(BOTINFO_WEAPON, target.origin, target.m_vecLastPOI);
		else
			dest = Route_SelectFarthest(BOTINFO_AMMO, target.origin, target.m_vecLastPOI);
		
		if (dest != __NULL__) {
			target.m_vecLastPOI = dest.origin;
			return dest.origin + [0,0,32];
		}

		print(sprintf("%s can't figure out where to go for ammo/weapon\n", target.netname));
	}

	if (random() < 0.25)
	if (!dest) {
		static entity but;
		but = find(but, ::classname, "func_button");

		if (but)
			return but.absmin + (0.5 * (but.absmax - but.absmin));
	}

	if (random() < 0.25)
	if (!dest) {
		static entity trig;
		trig = find(trig, ::classname, "trigger_multiple");

		if (trig)
			return trig.absmin + (0.5 * (trig.absmax - trig.absmin));
	}

	/* if all else fails... select a random spot */
	print(sprintf("%s found nothing, going for random PoI\n", target.netname));
	dest = Route_SelectRandomSpot();
	target.m_eDestination = dest;
	return (dest.origin);
}

int
Route_GetNodeFlags(nodeslist_t *node)
{
	int fl = node.linkflags;

	/* to avoid random buttons being pressed */
	if (fl < 0)
		return LF_DESTINATION;
	else
		return fl;
}

/* Get's a velocity vector with which we can successfully jump from one place to another */
vector
Route_GetJumpVelocity(vector vecFrom, vector vecTo, float flGravMod)
{
#if 1
	float flHeight, flGravity, flTime, flDistance, flDir;
	vector vecJump = [0,0,0];

	if (flGravMod <= 0.0)
		flGravMod = 1.0f;

	flGravity = serverkeyfloat("phy_gravity") * flGravMod;
	flHeight = vecTo[2] - vecFrom[2];

	if (flHeight <= 0)
		flHeight = vlen(vecTo - vecFrom) / 2;

	flTime = sqrt(flHeight / (flGravity * 0.5f));
	if (flTime <= 0) {
		return [0,0,0];
	}

	vecJump = vecTo - vecFrom;
	vecJump[2] = 0;
	flDistance = vlen(normalize(vecJump));

	flDir = flDistance / flTime;
	vecJump *= flDir;
	vecJump[2] = bound(240, flTime * flGravity, 512);

	print(sprintf("jumping from %v to %v at %v\n", vecFrom, vecTo, vecJump));
#else
	vector vecJump = [0,0,0];
	float flDist = vlen(vecTo - vecFrom);
	makevectors(vectoangles(vecTo - vecFrom));
	vecJump = v_forward * flDist;
	vecJump[2] = 280;
#endif
	return vecJump;
}
