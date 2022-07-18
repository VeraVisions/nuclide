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

#ifdef SERVER
bool
NSNavAI::CanCrouch(void)
{
	return false;
}

void
NSNavAI::RouteEnded(void)
{

}

void
NSNavAI::CheckRoute(void)
{
	float flDist;
	vector evenpos;

	if (!m_iNodes)
		return;

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		evenpos = m_vecLastNode;
		evenpos[2] = origin[2];
	} else {
		evenpos = m_pRoute[m_iCurNode].dest;
		evenpos[2] = origin[2];
	}

	flDist = floor(vlen(evenpos - origin));

	if (flDist < 8) {
		NSLog("^2NSNavAI::^3CheckRoute^7: " \
			"%s reached node\n", this.targetname);
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				dprint("^2NSNavAI::^3CheckRoute^7: " \
					"Walking directly to last node\n");
				m_iCurNode = -1;
			}
		}
	}

	if (m_iCurNode < -1) {
		ClearRoute();
		RouteEnded();
		NSLog("^2NSNavAI::^3CheckRoute^7: %s reached end", this.targetname);

		
	}

	/* crouch attempt */
	if (CanCrouch()) {
		vector src;
		bool shouldcrouch = false;

		/* test up */
		src = origin + [0,0,24];
		makevectors(angles);
		traceline(src, src + v_forward * 128, MOVE_NORMAL, this);

		/* we hit something */
		if (trace_fraction < 1.0) {
			src = origin + [0,0, -8];
			traceline(src, src + v_forward * 128, MOVE_NORMAL, this);

			/* we can crouch here, so let's do it */
			if (trace_fraction >= 1.0)
				shouldcrouch = true;
		}

		/* entire way-link needs to be crouched. that's the law of the land */
		if (shouldcrouch || Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_CROUCH)
			input_buttons |= INPUT_BUTTON8;
	}

	/*if (flDist == m_flLastDist) {
		m_flNodeGiveup += frametime;
	} else {
		m_flNodeGiveup = bound(0, m_flNodeGiveup - frametime, 1.0);
	}

	m_flLastDist = flDist;

	if (m_flNodeGiveup >= 1.0f) {
		print(sprintf("NSNavAI::CheckNode: %s gave up route\n",
			this.netname));
		ClearRoute();
	}*/
}

vector
NSNavAI::GetRouteMovevalues(void)
{
	vector vecDirection;

	if (!m_iNodes)
		return [0,0,0];

	if (m_iCurNode < 0)
		vecDirection = normalize(m_vecLastNode - origin);
	else
		vecDirection = normalize(m_pRoute[m_iCurNode].dest - origin);

	makevectors(angles);
	return [v_forward * vecDirection, v_right * vecDirection, v_up * vecDirection];
}

vector
NSNavAI::GetRouteDirection(void)
{
	if (!m_iNodes)
		return angles;

	if (m_iCurNode < 0)
		return vectoangles(m_vecLastNode - origin);
	else
		return vectoangles(m_pRoute[m_iCurNode].dest - origin);
}

void
NSNavAI::NewRoute(vector destination)
{
	/* engine calls this upon successfully creating a route */
	static void NewRoute_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		NSNavAI p = (NSNavAI)ent;
		p.m_iNodes = numnodes;
		p.m_iCurNode = numnodes - 1;
		p.m_pRoute = nodelist;

		//traceline(p.origin, dest, MOVE_NORMAL, this);
		tracebox(p.origin, p.mins, p.maxs, dest, MOVE_NORMAL, this);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			dprint("^2NSNavAI::^3NewRoute^7: " \
				"Walking directly to last node\n");
			p.m_iCurNode = -1;
		} else {
			dprint("^2NSNavAI::^3NewRoute^7: " \
				"Path obstructed, calculating route\n");

			/* run through all nodes, mark the closest direct path possible */
			for (int i = 0; i < p.m_iNodes; i++) {
				vector vecDest = p.m_pRoute[i].dest;
				tracebox(p.origin, p.mins, p.maxs, vecDest, TRUE, p);
				//traceline(p.origin, vecDest, MOVE_NORMAL, this);

				if (trace_fraction == 1.0) {
					p.m_iCurNode = i;
					break;
				}
			}
		}
	}

	if (!g_nodes_present)
		return;

	ClearRoute();

	if (!m_iNodes) {
		route_calculate(this, destination, 0, NewRoute_RouteCB);
		m_vecLastNode = destination;
	}
}

void
NSNavAI::ClearRoute(void)
{
	if (m_iNodes) {
		m_iNodes = 0;
		memfree(m_pRoute);
	}
}

#endif

void
NSNavAI::NSNavAI(void)
{

}