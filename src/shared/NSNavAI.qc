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

void
NSNavAI::NSNavAI(void)
{
#ifdef SERVER
	m_iNodes = 0i;
	m_iCurNode = -1i;
	m_pRoute = __NULL__;
	m_vecLastNode = [0,0,0];
	m_vecTurnAngle = [0,0,0];

	for (int i = 0; i < MAX_AMMO_TYPES; i++)
		m_iAmmoTypes[i] = 0;
#endif
}

#ifdef SERVER
void
NSNavAI::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iNodes", m_iNodes);
	SaveInt(handle, "m_iCurNode", m_iCurNode);
	SaveVector(handle, "m_vecLastNode", m_vecLastNode);
	SaveVector(handle, "m_vecTurnAngle", m_vecTurnAngle);
}

void
NSNavAI::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iNodes":
		m_iNodes = ReadInt(strValue);
		break;
	case "m_iCurNode":
		m_iCurNode = ReadInt(strValue);
		break;
	case "m_vecLastNode":
		m_vecLastNode = ReadVector(strValue);
		break;
	case "m_vecTurnAngle":
		m_vecTurnAngle = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSNavAI::RestoreComplete(void)
{
	if (m_iNodes <= 0i)
		return;

	/* re-plot our route */
	RouteToPosition(m_vecLastNode);
}
#endif


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
		NSNavAI_Log("^2%s::^3CheckRoute^7: " \
			"%s reached node", classname, targetname);
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				NSNavAI_Log("^2%s::^3CheckRoute^7: Walking directly to last node at '%v'", \
					classname, m_vecLastNode);
				m_iCurNode = -1;
			}
		}
	}

	/* check if we can reach the node after the current one */
	if (m_iCurNode > 0 && m_iNodes > 3) { /* HACK: only bother when we have more than 3 nodes in the path... this works around an issue in c1a0d I'm unsure about */
		int iNextNode = (m_iCurNode - 1);
		vector vecNextNode = m_pRoute[iNextNode].dest;

		tracebox(origin, mins, maxs, vecNextNode, MOVE_NORMAL, this);

		/* it's accessible */
		if (!trace_startsolid && trace_fraction == 1.0f) {
			evenpos = vecNextNode;
			m_iCurNode = iNextNode;
			NSNavAI_Log("^2%s::^3CheckRoute^7: skipping to next node %i at '%v'", \
				classname, iNextNode, vecNextNode);
		}
	}

	/* reached the end of the line */
	if (m_iCurNode < -1) {
		RouteClear();
		RouteEnded();
		NSNavAI_Log("^2%s::^3CheckRoute^7: %s reached end", classname, targetname);
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
		RouteClear();
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
NSNavAI::RouteToPosition(vector destination)
{
	/* engine calls this upon successfully creating a route */
	static void RouteToPosition_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		NSNavAI p = (NSNavAI)ent;
		p.m_iNodes = numnodes;
		p.m_iCurNode = numnodes - 1;
		p.m_pRoute = nodelist;

		//traceline(p.origin, dest, MOVE_NORMAL, this);
		tracebox(p.origin, p.mins, p.maxs, dest, MOVE_NORMAL, this);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			NSNavAI_Log("^2%s::^3RouteToPosition^7: " \
				"Walking directly to last node", classname);
			p.m_iCurNode = -1;
		} else {
			NSNavAI_Log("^2%s::^3RouteToPosition^7: " \
				"Path obstructed, calculating route", classname);

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

	if (!g_nodes_present) {
		Nodes_Init();
		return;
	}

	/* still nothing... give up */
	if (!g_nodes_present) {
		return;
	}

	RouteClear();

	if (!m_iNodes) {
		route_calculate(this, destination, 0, RouteToPosition_RouteCB);
		m_vecLastNode = destination;
	}
}

void
NSNavAI::RouteClear(void)
{
	if (!m_iNodes)
		return;

	m_iCurNode = BOTROUTE_END;
	m_iNodes = 0;
	memfree(m_pRoute);
	print(sprintf("%s cleared his route.\n", netname));
}
#endif
