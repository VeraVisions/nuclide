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

class
ncNavInfo
{
public:
	nonvirtual vector PositionOfClosestNode(vector);

/** Returns the position of a spot that'll provide cover from the specified enemy.

@param targetEnemy The enemy to hide from.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindCoverFromEnemy(ncActor targetEnemy);

/** Returns the position of a spot that'll be behind where you're currently standing

@param targetPosition The position to back away from.
@param eulerDirection The direction we're looking in, in euler-angles.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindBackFromPosition(vector targetPosition, vector eulerDirection);


/** Returns the position of a spot that'll provide cover from the specified enemy, closest to a specified node.

@param targetEnemy The enemy to hide from.
@param nodePosition The position we should get closest to.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindCoverFromEnemyNearNode(ncActor targetEnemy, vector nodePosition);


/** Returns the position of a spot that'll provide cover from the specified enemy, furthest from a specified node.

@param targetEnemy The enemy to hide from.
@param nodePosition The position we should get as far away from as possible from.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindCoverFromEnemyFarNode(ncActor targetEnemy, vector nodePosition);


/** Returns the position of a spot that'll provide cover from the specified enemy.

@param traceEntity The entity which will be testing for collisions.
@param targetOrigin The spot to hide from.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindCoverFromPosition(entity traceEntity, vector targetOrigin);


/** Returns the position of a spot that is accessible within a specified position.

@param traceEntity The entity which will be testing for collisions.
@param targetOrigin The spot to be near.
@param minRadius The mininum distance / search radius from the targetOrigin.
@param maxRadius The maximum Radius in which we'll look for a free spot.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindEmptySpotNearPosition(entity traceEntity, vector position, float minRadius, float maxRadius);


/** Returns the position of a spot that is far away within a specified position.

@param traceEntity The entity which will be testing for collisions.
@param targetOrigin The spot to be near.
@param minRadius The mininum distance / search radius from the targetOrigin.
@param maxRadius The maximum Radius in which we'll look for a free spot.
@return Absolute position of a valid cover spot. */
	nonvirtual vector FindEmptySpotAwayFromPosition(entity traceEntity, vector position, float minRadius, float maxRadius);
};
