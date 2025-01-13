/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/* link two nodes together */
static void
Node_Link(node_t *n1, node_t *n2)
{
	local struct neighbour_s *n;
	int w2n = n2 - g_pNodes;

	for (int i = 0; i < n1->m_numNeighbours; i++) {
		if (n1->m_pNeighbour[i].m_iNode == w2n) {
			return;
		}
	}

	int idx = n1->m_numNeighbours ++;
	n1->m_pNeighbour = (neighbour_s *)memreallocOld(n1->m_pNeighbour, \
											sizeof(*n1->m_pNeighbour), \
											idx, n1->m_numNeighbours);

	n = n1->m_pNeighbour +idx;
	n->m_iNode = w2n;
	n->m_flCost = vlen(n2->m_vecOrigin - n1->m_vecOrigin);
	n->m_iFlags = 0i;
}


/* loop through already existing nodes, test against them and link */
static void
Node_AutoLink(node_t *new, entity nodeEntity)
{
	int x = new - g_pNodes;

	for (int i = 0; i < g_iNodes; i++) {
		/* don't link to ourselves... */
		if (i == x) {
			continue;
		}

		/* can't use full player size, because steps = messy */
		tracebox(
			new->m_vecOrigin,
			[-16, -16, -16],
			[16, 16, 16],
			g_pNodes[i].m_vecOrigin,
			MOVE_NORMAL,
			nodeEntity
		);

		/* HACK!: work around c0a0e where info_nodes are blocked by the train */
		if (trace_ent.movetype == MOVETYPE_PUSH) {
			tracebox(
				new->m_vecOrigin,
				[-16, -16, -16],
				[16, 16, 16],
				g_pNodes[i].m_vecOrigin,
				MOVE_NORMAL,
				trace_ent
			);
		}

		/* line of sight blocked */
		if (trace_fraction < 1.0f) {
			continue;
		}

		Node_Link(new, &g_pNodes[i]);
		Node_Link(&g_pNodes[i], new);
	}
}

static void
Nodes_InsertNodeForClassname(string classn)
{
	for (entity a = world; (a = find(a, ::classname, classn));) {
		int iID = g_iNodes++;
		g_pNodes = (node_t *)memreallocOld(g_pNodes, sizeof(node_t), iID, g_iNodes);
		node_t *n = g_pNodes + iID;

		a.solid = SOLID_BBOX;
		a.movetype = MOVETYPE_WALK;
		setsize(a, [-16,-16,-16], [16,16,16]);
		setorigin_safe(a, a.origin);

		n->m_vecOrigin = a.origin;
		n->m_pNeighbour = __NULL__;
		n->m_numNeighbours = 0;
		n->m_flRadius = 32;
		Node_AutoLink(n, a);

		/* reset it to stupid attributes. */
		a.solid = SOLID_NOT;
		a.movetype = MOVETYPE_NONE;
		setsize(a, [0,0,0], [0,0,0]);
	}
}

bool
Nodes_Available(void)
{
	return (g_iNodes) > 0i ? true : false;
}

static void
Nodes_BuildFromEnts(void)
{
	NSLog("Rebuilding node tree...");

	/* run through the ents and rebuild the tree */
	Nodes_InsertNodeForClassname("info_node");

#if 0
	Nodes_InsertNodeForClassname("scripted_sequence");
#endif

	/* last resort */
	if (g_iNodes == 0)
		Nodes_InsertNodeForClassname("info_player_start");
	if (g_iNodes == 0)
		Nodes_InsertNodeForClassname("info_player_deathmatch");

	NSLog("%i possible nodes found in %s", g_iNodes, mapname);

	if (g_iNodes) {
		NSLog("saving nodes nodes for %s", mapname);
		NodeEdit_SaveFile(sprintf("%s.way", mapname));
	} else {
		NSLog("no node data found for %s", mapname);
	}
}

void
NodeHints_Init(void)
{
	info_hint pinchPoint;

	for (int i = 0; i < g_iNodes; i++) {
		/* is this a pinch point? */
		if (g_pNodes[i].m_numNeighbours == 2) {
			pinchPoint = spawn(info_hint);
			pinchPoint.Spawn();
			pinchPoint.m_hintType = HINT_TACTICAL_PINCH;
			setorigin(pinchPoint, g_pNodes[i].m_vecOrigin);
		} else if (g_pNodes[i].m_numNeighbours > 4) {
			pinchPoint = spawn(info_hint);
			pinchPoint.Spawn();
			pinchPoint.m_hintType = HINT_TACTICAL_ENEMY_DISADVANTAGED;
			setorigin(pinchPoint, g_pNodes[i].m_vecOrigin);
		}
	}
}

/* generate node tree, used for AI movement/navigation */
void
Nodes_Init(void)
{
	InitStart();

	/* skip if present. TODO: check if they're out of date? */
	if (fileExists(sprintf("data/%s.way", mapname))) {
		NodeEdit_ReadFile(sprintf("data/%s.way", mapname), true);
	} else {
		Nodes_BuildFromEnts();
	}

	NodeHints_Init();

	InitEnd();
}

void
Nodes_Flush(void)
{
	NodeEdit_Flush();
}

/* Helper functions for tasks/nav */
vector
Nodes_PositionOfClosestNode(vector pointOrigin)
{
	float bestDistance = COST_INFINITE;
	int bestNodeID = -1;

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeDistance = distanceSquared(nodePosition, pointOrigin);

		if (nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindCoverFromEnemy(ncActor targetEnemy)
{
	float bestDistance = COST_INFINITE;
	int bestNodeID = -1i;

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeRadius = g_pNodes[i].m_flRadius;
		float nodeDistance = distanceSquared(nodePosition, targetEnemy.origin);
		traceline(targetEnemy.origin, nodePosition, MOVE_NORMAL, targetEnemy);

		if (trace_fraction < 1.0 && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	if (bestNodeID != -1i) {
		return g_vec_null;
	}

	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindBackFromPosition(vector targetPosition, vector eulerDirection)
{
	float bestDistance = COST_INFINITE;
	int bestNodeID = -1;
	vector forwardDir = anglesToForward(eulerDirection);

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeRadius = g_pNodes[i].m_flRadius;
		float nodeDistance = distanceSquared(nodePosition, targetPosition);
		traceline(targetPosition, nodePosition, MOVE_NORMAL, world);

		if (trace_fraction < 1.0 && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindCoverFromEnemyNearNode(ncActor targetEnemy, vector targetNode)
{
	float bestDistance = COST_INFINITE;
	int bestNodeID = -1;

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeDistance = distanceSquared(nodePosition, targetNode);

		traceline(targetEnemy.origin, nodePosition, MOVE_NORMAL, targetEnemy);

		if (trace_fraction < 1.0 && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindCoverFromEnemyFarNode(ncActor targetEnemy, vector targetNode)
{
	float bestDistance = 0;
	int bestNodeID = -1;

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeDistance = distanceSquared(nodePosition, targetNode);

		traceline(targetEnemy.origin, nodePosition, MOVE_NORMAL, targetEnemy);

		if (trace_fraction < 1.0 && nodeDistance > bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindCoverFromPosition(entity traceEntity, vector targetOrigin)
{
	float bestDistance = COST_INFINITE;
	int bestNodeID = -1i;

#if 0
	if (g_iNodes <= 0i) {
		return Nodes_FindEmptySpotNearPosition(world, targetOrigin, 512.0, 4096.0f);
	}
#endif

	for (int i = 0; i < g_iNodes; i++) {
		vector nodePosition = g_pNodes[i].m_vecOrigin;
		float nodeDistance = distanceSquared(nodePosition, traceEntity.origin);

		traceline(nodePosition, targetOrigin, MOVE_NORMAL, traceEntity);

		if ((trace_ent == world || trace_fraction < 1.0) && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	if (bestNodeID) {
		return (g_vec_null);
	}

	NSError("%v",  (g_pNodes[bestNodeID].m_vecOrigin));
	return (g_pNodes[bestNodeID].m_vecOrigin);
}

vector
Nodes_FindEmptySpotNearPosition(entity traceEntity, vector position, float minRadius, float maxRadius)
{
	float bestYaw = 0.0f;
	float bestDist = 0.0f;
	vector testAngle = g_vec_null;
	vector testPos = g_vec_null;

	for (float yawTest = 0.0f; yawTest < 360.0f; yawTest += 10.0f) {
		vector testPos;
		float distSquared;
		vector testAngle = traceEntity.angles = [0, yawTest, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		testPos = position + (v_forward * 2048.0f);
		tracebox(position, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);
		distSquared = distance(position, trace_endpos);

		if (distSquared > bestDist) {
			bestYaw = yawTest;
			bestDist = distSquared;
		}
	}

	/* cancel early */
	if (bestDist <= minRadius) {
		return (g_vec_null);
	}

	for (float dist = minRadius; dist < maxRadius; dist += ((maxRadius - minRadius) / 16.0f)) {
		vector testAngle = [0, bestYaw, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		vector testPos = position + (v_forward * dist);
		tracebox(testPos, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);

		if (!trace_startsolid) {
			return (testPos);
		}
	}
	

	return (g_vec_null);
}

vector
Nodes_FindEmptySpotAwayFromPosition(entity traceEntity, vector position, float minRadius, float maxRadius)
{
	float bestYaw = 0.0f;
	float bestDist = 0.0f;
	vector testAngle = g_vec_null;
	vector testPos = g_vec_null;

	for (float yawTest = 0.0f; yawTest < 360.0f; yawTest += 10.0f) {
		vector testPos;
		float distSquared;
		vector testAngle = traceEntity.angles = [0, yawTest, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		testPos = position + (v_forward * 2048.0f);
		tracebox(position, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);
		distSquared = distance(position, trace_endpos);

		if (distSquared > bestDist) {
			bestYaw = yawTest;
			bestDist = distSquared;
		}
	}

	/* cancel early */
	if (bestDist <= minRadius) {
		return (g_vec_null);
	}

	for (float dist = maxRadius; dist > minRadius; dist -= ((maxRadius - minRadius) / 16.0f)) {
		vector testAngle = [0, bestYaw, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		vector testPos = position + (v_forward * dist);
		tracebox(testPos, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);

		if (!trace_startsolid) {
			return (testPos);
		}
	}
	

	return (g_vec_null);
}

