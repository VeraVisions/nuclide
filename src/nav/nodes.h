/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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
	
	Parse info_node type entities and convert them to FTE compatible routing data.
*/

/** Data holding Node entries. */
typedef struct {
	vector m_origin;
	float m_nodeRadius;	 /* used for picking the closest waypoint. aka proximity weight. also relaxes routes inside the area. */
	struct neighbour_s
	{
		int m_nodeID;
		float m_travelCost;
		int m_travelFlags;
	} *m_neighborList;
	int m_neighborCount;
} graphNode_t;

graphNode_t *g_nodeGraph;
int g_nodeCount;

/** @ingroup nav
 *
 *  @{
 */

void Nodes_Flush(void);
void Nodes_Init(void);
bool Nodes_Available(void);

/** @} */ // end of nav
