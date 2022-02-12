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
	float r = fabs(flDist) % 2;

	if (r == 0)
		return (flDist);

	if (flDist < 0)
		return -(fabs(flDist) - r);
	else
		return (flDist + 2 - r);
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
	return (eLastSpot);
}

void
Bot_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
{
	bot b = (bot)ent;
	b.m_iNodes = numnodes;
	b.m_iCurNode = numnodes - 1;
	b.m_pRoute = nodelist;
	b.m_vecLastNode = dest;

	//dprint("Bot: Route calculated.\n");
	//dprint(sprintf("Bot: # of nodes: %i\n", bot.m_iNodes) );
	//dprint(sprintf("Bot: # current node: %i\n", bot.m_iCurNode) );
	//dprint(sprintf("Bot: # endpos: %v\n", dest));
}

vector
Route_SelectDestination(bot target)
{
	entity dest = world;

	if (target.health < 50) {
		entity temp;
		int bestrange = COST_INFINITE;
		int range;

		for (temp = world; (temp = findfloat(temp, ::botinfo, BOTINFO_HEALTH));) {
			range = vlen(temp.origin - target.origin);
			if ((range < bestrange) && (temp.solid == SOLID_TRIGGER)) {
				bestrange = range;
				dest = temp;
			}
		}

		if (dest) {
			//dprint("Route: Going for health!");
			return (dest.origin + [0,0,32]);
		}
	}

	dest = Route_SelectRandomSpot();
	target.m_eDestination = dest;
	return (dest.origin);
}
