/*
 * Copyright (c) 2025 Vera Visions LLC.
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

/* Helper functions for tasks/nav */
vector
ncNavInfo::PositionOfClosestNode(vector pointOrigin)
{
	float bestDistance = MAX_DISTANCE;
	int bestNodeID = -1;

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
		float nodeDistance = distanceSquared(nodePosition, pointOrigin);

		if (nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindCoverFromEnemy(ncActor targetEnemy)
{
	float bestDistance = MAX_DISTANCE;
	int bestNodeID = -1i;

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
		float nodeRadius = g_nodeGraph[i].m_nodeRadius;
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

	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindBackFromPosition(vector targetPosition, vector eulerDirection)
{
	float bestDistance = MAX_DISTANCE;
	int bestNodeID = -1;
	vector forwardDir = anglesToForward(eulerDirection);

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
		float nodeRadius = g_nodeGraph[i].m_nodeRadius;
		float nodeDistance = distanceSquared(nodePosition, targetPosition);
		traceline(targetPosition, nodePosition, MOVE_NORMAL, world);

		if (trace_fraction < 1.0 && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindCoverFromEnemyNearNode(ncActor targetEnemy, vector targetNode)
{
	float bestDistance = MAX_DISTANCE;
	int bestNodeID = -1;

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
		float nodeDistance = distanceSquared(nodePosition, targetNode);

		traceline(targetEnemy.origin, nodePosition, MOVE_NORMAL, targetEnemy);

		if (trace_fraction < 1.0 && nodeDistance < bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindCoverFromEnemyFarNode(ncActor targetEnemy, vector targetNode)
{
	float bestDistance = 0;
	int bestNodeID = -1;

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
		float nodeDistance = distanceSquared(nodePosition, targetNode);

		traceline(targetEnemy.origin, nodePosition, MOVE_NORMAL, targetEnemy);

		if (trace_fraction < 1.0 && nodeDistance > bestDistance) {
			bestDistance = nodeDistance;
			bestNodeID = i;
		}
	}

	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindCoverFromPosition(entity traceEntity, vector targetOrigin)
{
	float bestDistance = MAX_DISTANCE;
	int bestNodeID = -1i;

#if 0
	if (g_nodeCount <= 0i) {
		return ncNavInfo::FindEmptySpotNearPosition(world, targetOrigin, 512.0, 4096.0f);
	}
#endif

	for (int i = 0; i < g_nodeCount; i++) {
		vector nodePosition = g_nodeGraph[i].m_origin;
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

	ncError("%v",  (g_nodeGraph[bestNodeID].m_origin));
	return (g_nodeGraph[bestNodeID].m_origin);
}

vector
ncNavInfo::FindEmptySpotNearPosition(entity traceEntity, vector position, float minRadius, float maxRadius)
{
	float bestYaw = 0.0f;
	float bestDist = 0.0f;
	vector testAngle = g_vec_null;
	vector testPos = g_vec_null;

	for (float yawTest = 0.0f; yawTest < 360.0f; yawTest += 10.0f) {
		float distSquared;
		testAngle = traceEntity.angles = [0, yawTest, 0];
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
		testAngle = [0, bestYaw, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		testPos = position + (v_forward * dist);
		tracebox(testPos, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);

		if (!trace_startsolid) {
			return (testPos);
		}
	}

	return (g_vec_null);
}

vector
ncNavInfo::FindEmptySpotAwayFromPosition(entity traceEntity, vector position, float minRadius, float maxRadius)
{
	float bestYaw = 0.0f;
	float bestDist = 0.0f;
	vector testAngle = g_vec_null;
	vector testPos = g_vec_null;

	for (float yawTest = 0.0f; yawTest < 360.0f; yawTest += 10.0f) {
		float distSquared;
		testAngle = traceEntity.angles = [0, yawTest, 0];
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
		testAngle = [0, bestYaw, 0];
		testAngle[0] = testAngle[2] = 0.0f;
		makevectors(testAngle);
		testPos = position + (v_forward * dist);
		tracebox(testPos, traceEntity.mins, traceEntity.maxs, testPos, MOVE_NORMAL, traceEntity);

		if (!trace_startsolid) {
			return (testPos);
		}
	}


	return (g_vec_null);
}
