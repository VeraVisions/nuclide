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

/* write current nodes to disk */
void
Nodes_Save(string filename)
{
	filestream wayfile = fopen(filename, FILE_WRITE);

	if (wayfile < 0) {
		return;
	}

	fputs(wayfile, sprintf("%i\n", g_iNodes));

	for (int i = 0; i < g_iNodes; i++) {
		fputs(
			wayfile,
			sprintf(
				"%v %f %i\n",
				g_pNodes[i].origin,
				g_pNodes[i].radius,
				g_pNodes[i].nb_count
			)
		);

		for(int j = 0; j < g_pNodes[i].nb_count; j++) {
			fputs(
				wayfile,
				sprintf(
					" %i %f %x\n",
					g_pNodes[i].nb[j].node,
					g_pNodes[i].nb[j].dist,
					(float)g_pNodes[i].nb[j].flags
				)
			);
		}
	}

	g_nodes_present = TRUE;
	fclose(wayfile);
}

void
Nodes_Load(string filename)
{
	float wayfile = fopen(filename, FILE_READ);

	if (wayfile < 0) {
		return;
	}

	/* wipe whatever we've got */
	for (int i = 0; i < g_iNodes; i++) {
		memfree(g_pNodes[i].nb);
	}
	memfree(g_pNodes);
	g_iNodes = 0;

	tokenize(fgets(wayfile));
	g_iNodes = stoi(argv(0));
	g_pNodes = memalloc(sizeof(*g_pNodes) * g_iNodes);

	for (int i = 0; i < g_iNodes; i++) {
		tokenize(fgets(wayfile));
		g_pNodes[i].origin[0] = stof(argv(0));
		g_pNodes[i].origin[1] = stof(argv(1));
		g_pNodes[i].origin[2] = stof(argv(2));
		g_pNodes[i].radius = stof(argv(3));
		g_pNodes[i].nb_count = stoi(argv(4));
		g_pNodes[i].nb = memalloc(sizeof(*g_pNodes[i].nb) * g_pNodes[i].nb_count);
		
		for (int j = 0; j < g_pNodes[i].nb_count; j++) {
			tokenize(fgets(wayfile));
			g_pNodes[i].nb[j].node = stoi(argv(0));
			g_pNodes[i].nb[j].dist = stof(argv(1));
			g_pNodes[i].nb[j].flags = stoh(argv(2));
		}
	}
	fclose(wayfile);
}

/* link two nodes together */
static void
Node_Link(node_t *n1, node_t *n2)
{
	int w2n = n2 - g_pNodes;
	for (int i = 0; i < n1->nb_count; i++) {
		if (n1->nb[i].node == w2n) {
			return;
		}
	}

	int idx = n1->nb_count++;
	n1->nb = (neighbour_s *)memrealloc(n1->nb, sizeof(*n1->nb), idx, n1->nb_count);
	local struct neighbour_s *n = n1->nb+idx;
	n->node = w2n;
	n->dist = vlen(n2->origin - n1->origin);
	n->flags = 0;
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
			new->origin,
			[-16, -16, -16],
			[16, 16, 16],
			g_pNodes[i].origin,
			MOVE_NORMAL,
			nodeEntity
		);

		/* HACK!: work around c0a0e where info_nodes are blocked by the train */
		if (trace_ent.movetype == MOVETYPE_PUSH) {
			tracebox(
				new->origin,
				[-16, -16, -16],
				[16, 16, 16],
				g_pNodes[i].origin,
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
		g_pNodes = (node_t *)memrealloc(g_pNodes, sizeof(node_t), iID, g_iNodes);
		node_t *n = g_pNodes + iID;

		a.solid = SOLID_BBOX;
		a.movetype = MOVETYPE_WALK;
		setsize(a, [-16,-16,-16], [16,16,16]);
		setorigin_safe(a, a.origin);

		n->origin = a.origin;
		n->nb = __NULL__;
		n->nb_count = 0;
		n->radius = 32;
		Node_AutoLink(n, a);

		/* reset it to stupid attributes. */
		a.solid = SOLID_NOT;
		a.movetype = MOVETYPE_NONE;
		setsize(a, [0,0,0], [0,0,0]);
	}
}

void
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
		Nodes_Save(sprintf("%s.way", mapname));
	} else {
		NSLog("no node data found for %s", mapname);
	}
}

/* generate node tree, used for AI movement/navigation */
void
Nodes_Init(void)
{
	InitStart();
	g_nodes_present = FALSE;

	/* skip if present. TODO: check if they're out of date? */
	if (FileExists(sprintf("data/%s.way", mapname))) {
		g_nodes_present = TRUE;
#ifdef NODE_DEBUG
		NSLog("loading existing nodes for %s", mapname);
		Nodes_Load(sprintf("%s.way", mapname));
#endif
	} else {
		Nodes_BuildFromEnts();
	}

	/* we don't need these any longer */
#ifndef NODE_DEBUG
	for (int i = 0; i < g_iNodes; i++) {
		memfree(g_pNodes[i].nb);
	}
	memfree(g_pNodes);
	g_iNodes = 0;
#endif

	InitEnd();
}

#ifdef NODE_DEBUG
#define SEQUENCE_RECT_COLOR [1.0,0.0,0.0]
#define NODE_RECT_COLOR [1.0,0.5,0.0]
#define NODE_RECT_ALPHA 1.0f
#define NODE_LINE_ALPHA 0.25f

/* draws debug graphics of our node tree */
void
SV_AddDebugPolygons(void)
{
	Way_DrawDebugInfo();

	if (cvar("developer") != 1)
		return;

	if (!g_iWaypoints) {
		Way_LoadCurrentMapNavMesh();
	}

#if 1
	for (entity s = world; (s = find(s, ::classname, "func_tracktrain"));) {
		func_tracktrain train = (func_tracktrain)s;
		train.RenderDebugInfo();
	}
#endif

	makevectors(self.v_angle);

	for (entity s = world; (s = findfloat(s, ::identity, 1));) {
		NSEntity drawMe = (NSEntity)s;
		drawMe.DebugDraw();
	}

	return;

	/* draw the rectangles */
	R_BeginPolygon("textures/dev/info_node", 0, 0);
	for (int i = 0; i < g_iNodes; i++) {
		node_t *w = g_pNodes + i;
		R_PolygonVertex(w->origin + v_right * 8 - v_up * 8, [1,1], NODE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(w->origin - v_right * 8 - v_up * 8, [0,1], NODE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(w->origin - v_right * 8 + v_up * 8, [0,0], NODE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(w->origin + v_right * 8 + v_up * 8, [1,0], NODE_RECT_COLOR, NODE_RECT_ALPHA);
		R_EndPolygon();
	}

	for (entity s = world; (s = find(s, ::classname, "path_track"));) {
		vector pos = s.origin;
		pos[2] += 32;
		R_BeginPolygon("textures/dev/path_track", 0, 0);
		R_PolygonVertex(pos + v_right * 24 - v_up * 24, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(pos - v_right * 24 - v_up * 24, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(pos - v_right * 24 + v_up * 24, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(pos + v_right * 24 + v_up * 24, [1,0], [1,1,1], 1.0f);
		R_EndPolygon();

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(s.origin, [0,1], [1,1,1], NODE_LINE_ALPHA);
		R_PolygonVertex(pos, [1,1], [1,1,1], NODE_LINE_ALPHA);
		R_EndPolygon();
	}

	for (entity s = world; (s = find(s, ::classname, "scripted_sequence"));) {
		vector pos = s.origin;
		pos[2] += 32;

		R_BeginPolygon("textures/dev/scripted_sequence", 0, 0);
		R_PolygonVertex(pos + v_right * 24 - v_up * 24, [1,1], SEQUENCE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(pos - v_right * 24 - v_up * 24, [0,1], SEQUENCE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(pos - v_right * 24 + v_up * 24, [0,0], SEQUENCE_RECT_COLOR, NODE_RECT_ALPHA);
		R_PolygonVertex(pos + v_right * 24 + v_up * 24, [1,0], SEQUENCE_RECT_COLOR, NODE_RECT_ALPHA);
		R_EndPolygon();

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(s.origin, [0,1], [1,1,1], NODE_LINE_ALPHA);
		R_PolygonVertex(pos, [1,1], [1,1,1], NODE_LINE_ALPHA);
		R_EndPolygon();
	}
}
#endif
