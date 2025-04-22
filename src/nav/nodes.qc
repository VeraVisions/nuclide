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
Node_Link(graphNode_t *n1, graphNode_t *n2)
{
	local struct neighbour_s *n;
	int w2n = n2 - g_nodeGraph;

	for (int i = 0; i < n1->m_neighborCount; i++) {
		if (n1->m_neighborList[i].m_nodeID == w2n) {
			return;
		}
	}

	int idx = n1->m_neighborCount ++;
	n1->m_neighborList = (neighbour_s *)memreallocOld(n1->m_neighborList, \
											sizeof(*n1->m_neighborList), \
											idx, n1->m_neighborCount);

	n = n1->m_neighborList +idx;
	n->m_nodeID = w2n;
	n->m_travelCost = vlen(n2->m_origin - n1->m_origin);
	n->m_travelFlags = 0i;
}


/* loop through already existing nodes, test against them and link */
static void
Node_AutoLink(graphNode_t *new, entity nodeEntity)
{
	int x = new - g_nodeGraph;

	for (int i = 0; i < g_nodeCount; i++) {
		/* don't link to ourselves... */
		if (i == x) {
			continue;
		}

		/* can't use full player size, because steps = messy */
		tracebox(
			new->m_origin,
			[-16, -16, -16],
			[16, 16, 16],
			g_nodeGraph[i].m_origin,
			MOVE_NORMAL,
			nodeEntity
		);

		/* HACK!: work around c0a0e where info_nodes are blocked by the train */
		if (trace_ent.movetype == MOVETYPE_PUSH) {
			tracebox(
				new->m_origin,
				[-16, -16, -16],
				[16, 16, 16],
				g_nodeGraph[i].m_origin,
				MOVE_NORMAL,
				trace_ent
			);
		}

		/* line of sight blocked */
		if (trace_fraction < 1.0f) {
			continue;
		}

		Node_Link(new, &g_nodeGraph[i]);
		Node_Link(&g_nodeGraph[i], new);
	}
}

static void
Nodes_InsertNodeForClassname(string classn)
{
	for (entity a = world; (a = find(a, ::classname, classn));) {
		int iID = g_nodeCount++;
		g_nodeGraph = (graphNode_t *)memreallocOld(g_nodeGraph, sizeof(graphNode_t), iID, g_nodeCount);
		graphNode_t *n = g_nodeGraph + iID;

		a.solid = SOLID_BBOX;
		a.movetype = MOVETYPE_WALK;
		setsize(a, [-16,-16,-16], [16,16,16]);
		setorigin_safe(a, a.origin);

		n->m_origin = a.origin;
		n->m_neighborList = __NULL__;
		n->m_neighborCount = 0;
		n->m_nodeRadius = 32;
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
	return (g_nodeCount) > 0i ? true : false;
}

static void
Nodes_BuildFromEnts(void)
{
	ncLog("Rebuilding node tree...");

	/* run through the ents and rebuild the tree */
	Nodes_InsertNodeForClassname("info_node");

#if 0
	Nodes_InsertNodeForClassname("scripted_sequence");
#endif

	/* last resort */
	if (g_nodeCount == 0)
		Nodes_InsertNodeForClassname("info_player_start");
	if (g_nodeCount == 0)
		Nodes_InsertNodeForClassname("info_player_deathmatch");

	ncLog("%i possible nodes found in %s", g_nodeCount, mapname);

	if (g_nodeCount > 0i) {
		ncLog("saving nodes nodes for %s", mapname);
		ncNodeEditor::SaveFile(sprintf("%s.way", mapname));
	} else {
		ncLog("no node data found for %s", mapname);
	}
}

void
NodeHints_Init(void)
{
	info_hint pinchPoint;

	for (int i = 0; i < g_nodeCount; i++) {
		/* is this a pinch point? */
		if (g_nodeGraph[i].m_neighborCount == 2) {
			pinchPoint = spawn(info_hint);
			pinchPoint.Spawn();
			pinchPoint.m_hintType = "pinchPoint";
			setorigin(pinchPoint, g_nodeGraph[i].m_origin);
		} else if (g_nodeGraph[i].m_neighborCount > 4) {
			pinchPoint = spawn(info_hint);
			pinchPoint.Spawn();
			pinchPoint.m_hintType = "disadvantaged";
			setorigin(pinchPoint, g_nodeGraph[i].m_origin);
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
		ncNodeEditor::ReadFile(sprintf("data/%s.way", mapname), true);
	} else {
		Nodes_BuildFromEnts();
	}

	NodeHints_Init();

	InitEnd();
}

void
Nodes_Flush(void)
{
	ncNodeEditor::Flush();
}
