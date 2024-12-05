/*
 * Copyright (c) 2016-2020 Vera Visions LLC.
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

/*! @file nodes.h
    @brief Nodegraph loading/saving.
*/

/* parse info_node entities and convert them to FTE compatible routing data */
#define NODE_DEBUG
#define COST_INFINITE 99999

/** Data holding Node entries. */
typedef struct {
	vector m_vecOrigin;
	float m_flRadius;	 /* used for picking the closest waypoint. aka proximity weight. also relaxes routes inside the area. */
	struct neighbour_s
	{
		int m_iNode;
		float m_flCost;
		int m_iFlags;
	} *m_pNeighbour;
	int m_numNeighbours;
} node_t;

node_t *g_pNodes;
int g_iNodes;

/** @ingroup nav
 *
 *  @{
 */

void Nodes_Flush(void);
void Nodes_Init(void);
bool Nodes_Available(void);

vector Nodes_PositionOfClosestNode(vector);

/** Returns the position of a spot that'll provide cover from the specified enemy.

@param targetEnemy The enemy to hide from.
@return Absolute position of a valid cover spot. */
vector Nodes_FindCoverFromEnemy(ncActor targetEnemy);

/** Returns the position of a spot that'll be behind where you're currently standing

@param targetPosition The position to back away from.
@param eulerDirection The direction we're looking in, in euler-angles.
@return Absolute position of a valid cover spot. */
vector Nodes_FindBackFromPosition(vector targetPosition, vector eulerDirection);


/** Returns the position of a spot that'll provide cover from the specified enemy, closest to a specified node.

@param targetEnemy The enemy to hide from.
@param nodePosition The position we should get closest to.
@return Absolute position of a valid cover spot. */
vector Nodes_FindCoverFromEnemyNearNode(ncActor targetEnemy, vector nodePosition);


/** Returns the position of a spot that'll provide cover from the specified enemy, furthest from a specified node.

@param targetEnemy The enemy to hide from.
@param nodePosition The position we should get as far away from as possible from.
@return Absolute position of a valid cover spot. */
vector Nodes_FindCoverFromEnemyFarNode(ncActor targetEnemy, vector nodePosition);


/** Returns the position of a spot that'll provide cover from the specified enemy.

@param targetOrigin The spot to hide from.
@return Absolute position of a valid cover spot. */
vector Nodes_FindCoverFromPosition(vector targetOrigin);

/** @} */ // end of nav
