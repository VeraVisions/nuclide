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

typedef struct waypoint_s
{
	vector vecOrigin;
	float flRadius;	 /* used for picking the closest waypoint. aka proximity weight. also relaxes routes inside the area. */
	struct wpneighbour_s
	{
		int node;
		float linkcost;
		int iFlags;
	} *neighbour;
	int iNeighbours;
} waypoint_t;

static waypoint_t *g_pWaypoints;
static int g_iWaypoints;

static void
Way_WipeWaypoints(void)
{
	for (int i = 0; i < g_iWaypoints; i++) {
		memfree(g_pWaypoints[i].neighbour);
	}

	memfree(g_pWaypoints);
	g_iWaypoints = 0;
}

void
Way_DumpWaypoints(string filename)
{
	filestream file = fopen(filename, FILE_WRITE);

	if (file < 0) {
		print("RT_DumpWaypoints: unable to open ", filename, "\n");
		return;
	}

	fputs(file, sprintf("%i\n", g_iWaypoints));

	for (int i = 0i; i < g_iWaypoints; i++) {
		fputs(file, sprintf("%v %f %i\n", g_pWaypoints[i].vecOrigin, g_pWaypoints[i].flRadius, g_pWaypoints[i].iNeighbours));
		
		for(int j = 0i; j < g_pWaypoints[i].iNeighbours; j++) {
			fputs(file, sprintf(" %i %f %x\n", g_pWaypoints[i].neighbour[j].node, g_pWaypoints[i].neighbour[j].linkcost, (float)g_pWaypoints[i].neighbour[j].iFlags));
		}
	}

	fclose(file);
}

void
Way_ReadWaypoints(string strFile)
{
	float file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("Way_DumpWaypoints: unable to open ", strFile, "\n");
		return;
	}

	Way_WipeWaypoints();

	tokenize(fgets(file));
	g_iWaypoints = stoi(argv(0));
	g_pWaypoints = memalloc(sizeof(*g_pWaypoints) * g_iWaypoints);

	for (int i = 0i; i < g_iWaypoints; i++) {
		tokenize(fgets(file));
		g_pWaypoints[i].vecOrigin[0] = stof(argv(0));
		g_pWaypoints[i].vecOrigin[1] = stof(argv(1));
		g_pWaypoints[i].vecOrigin[2] = stof(argv(2));
		g_pWaypoints[i].flRadius = stof(argv(3));
		g_pWaypoints[i].iNeighbours = stoi(argv(4));
		g_pWaypoints[i].neighbour = memalloc(sizeof(*g_pWaypoints[i].neighbour) * g_pWaypoints[i].iNeighbours);
		
		for (int j = 0i; j < g_pWaypoints[i].iNeighbours; j++) {
			tokenize(fgets(file));
			g_pWaypoints[i].neighbour[j].node = stoi(argv(0));
			g_pWaypoints[i].neighbour[j].linkcost = stof(argv(1));
			g_pWaypoints[i].neighbour[j].iFlags = stoh(argv(2));
		}
	}
	fclose(file);
}

static void
Way_LinkWaypoints(waypoint_t *wp, waypoint_t *w2)
{
	int w2n = w2 - g_pWaypoints;
	for (int i = 0i; i < wp->iNeighbours; i++) {
		if (wp->neighbour[i].node == w2n) {
			return;
		}
	}
	
	int idx = wp->iNeighbours++;
	wp->neighbour = memrealloc(wp->neighbour, sizeof(*wp->neighbour), idx, wp->iNeighbours);
	local struct wpneighbour_s *n = wp->neighbour+idx;
	n->node = w2n;
	n->linkcost = vlen(w2->vecOrigin - wp->vecOrigin);
	n->iFlags = 0;
}

static void
Way_AutoLink(waypoint_t *wp)
{
	int wpidx = wp-g_pWaypoints;

	for (int i = 0i; i < g_iWaypoints; i++) {
		//don't link to ourself...
		if (i == wpidx) {
			continue;
		}

		//autolink distance cutoff.
		if (vlen(wp->vecOrigin - g_pWaypoints[i].vecOrigin) > autocvar(nav_linksize, 256, "Cuttoff distance between links")) {
			continue;
		}

		//not going to use the full player size because that makes steps really messy.
		//however, we do need a little size, for sanity's sake
		tracebox(wp->vecOrigin, '-16 -16 0', '16 16 32', g_pWaypoints[i].vecOrigin, TRUE, world);

		//light of sight blocked, don't try autolinking.
		if (trace_fraction < 1) {
			continue;
		}

		Way_LinkWaypoints(wp, &g_pWaypoints[i]);
		Way_LinkWaypoints(&g_pWaypoints[i], wp);
	}
}

void
Way_Waypoint_Create(entity ePlayer, int iAutoLink)
{
	int iID = g_iWaypoints++;
	g_pWaypoints = memrealloc(g_pWaypoints, sizeof(waypoint_t), iID, g_iWaypoints);
	waypoint_t *n = g_pWaypoints + iID;
	n->vecOrigin = ePlayer.origin;
	n->neighbour = __NULL__;
	n->iNeighbours = 0;

	if (iAutoLink == 1) {
		Way_AutoLink(n);
	} else {
		if (iID != 0) {
			if (iAutoLink == 0) {
				Way_LinkWaypoints(n, &g_pWaypoints[iID-1]);
				Way_LinkWaypoints(&g_pWaypoints[iID-1], n);
			} else if (iAutoLink -1) {
				Way_LinkWaypoints(&g_pWaypoints[iID-1], n);
			} else {
				Way_LinkWaypoints(n, &g_pWaypoints[iID-1]);
			}
		}
	}
}

void
Way_Waypoint_CreateSpawns()
{
	for (entity a = world; (a = find(a, ::classname, "info_player_deathmatch"));) {
		Way_Waypoint_Create(a, TRUE);
	}
}

void
Way_Waypoint_Delete(int iID)
{
	if (iID < 0i || iID >= g_iWaypoints) {
		print("RT_DeleteWaypoint: invalid waypoint\n");
		return;
	}

	//wipe the waypoint
	memfree(g_pWaypoints[iID].neighbour);
	memcpy(g_pWaypoints + iID, g_pWaypoints + iID + 1, (g_iWaypoints - (iID + 1)) * sizeof(*g_pWaypoints));
	g_iWaypoints--;

	//clean up any links to it.
	for (int i = 0; i < g_iWaypoints; i++) {
		for (int j = 0; j < g_pWaypoints[i].iNeighbours;) {
			int l = g_pWaypoints[i].neighbour[j].node;
			if (l == iID) {
				memcpy(g_pWaypoints[i].neighbour+j, g_pWaypoints[i].neighbour+j+1, (g_pWaypoints[i].iNeighbours-(j+1))*sizeof(*g_pWaypoints[i].neighbour));
				g_pWaypoints[i].iNeighbours--;
				continue;
			} else if (l > iID) {
				g_pWaypoints[i].neighbour[j].node = l-1;
			}
			j++;
		}
	}
}

void
Way_Waypoint_SetRadius(int iID, float flRadValue)
{
	if (iID < 0i || iID >= g_iWaypoints) {
		print("RT_Waypoint_SetRadius: invalid waypoint\n");
		return;
	}
	g_pWaypoints[iID].flRadius = flRadValue;
}

void
Way_Waypoint_MakeJump(int iID)
{
	if (iID < 0i || iID >= g_iWaypoints) {
		print("RT_Waypoint_SetRadius: invalid waypoint\n");
		return;
	}

	for (int j = 0i; j < g_pWaypoints[iID].iNeighbours; j++) {
		int iTarget = g_pWaypoints[iID].neighbour[j].node;
		
		for (int b = 0i; b < g_pWaypoints[iTarget].iNeighbours; b++) {
			if (g_pWaypoints[iTarget].neighbour[b].node == iID) {
				g_pWaypoints[iTarget].neighbour[b].iFlags = WP_JUMP;
			}
		}
	}
}

int
Way_FindClosestWaypoint(vector vecOrigin)
{
	
	/* -1 for no nodes anywhere... */
	int r = -1i;
	float flBestDist = COST_INFINITE;

	for (int i = 0i; i < g_iWaypoints; i++) {
		float fDist = vlen(g_pWaypoints[i].vecOrigin - vecOrigin) - g_pWaypoints[i].flRadius;
		if (fDist < flBestDist) {
			/* within the waypoint's radius */
			if (fDist < 0) {
				flBestDist = fDist;
				r = i;
			} else {
				/* outside the waypoint, make sure its valid. */
				traceline(vecOrigin, g_pWaypoints[i].vecOrigin, TRUE, world);
				if (trace_fraction == 1) {
					/* FIXME: sort them frst, to avoid traces? */
					flBestDist = fDist;
					r = i;
				}
			}
		}
	}
	return r;
}

void
Way_GoToPoint(entity pl)
{
	vector vecSrc;
	makevectors(pl.v_angle);
	vecSrc = pl.origin + pl.view_ofs;
	traceline(vecSrc, vecSrc + (v_forward * 4096), FALSE, pl);
	print(sprintf("Telling all bots to go to %v\n", trace_endpos));

	for (entity a = world; ( a = find( a, classname, "player" ) ); ) {
		if ( clienttype(a) != CLIENTTYPE_REAL ) {
			bot targ;
			targ = (bot)a;
			targ.RouteClear();
			route_calculate(targ, pl.origin, 0, Bot_RouteCB);
			print(sprintf("Told bot to go to %v\n", trace_endpos));
		}
	}
}

void
Way_DrawDebugInfo(void)
{
	if (!g_iWaypoints) {
		return;
	}

	int iNearest = Way_FindClosestWaypoint(self.origin);
	makevectors(self.v_angle);
	R_BeginPolygon("textures/dev/info_node", 0, 0);
	
	for (int i = 0i; i < g_iWaypoints; i++) {
		waypoint_t *w = g_pWaypoints + i;
		vector org = w->vecOrigin;
		vector rgb = [1,1,1];

		if (iNearest == i) {
			rgb = [0,1,0];
		}

		R_PolygonVertex(org + v_right * 8 - v_up * 8, '1 1', rgb, 1);
		R_PolygonVertex(org - v_right * 8 - v_up * 8, '0 1', rgb, 1);
		R_PolygonVertex(org - v_right * 8 + v_up * 8, [0,0], rgb,  1);
		R_PolygonVertex(org + v_right * 8 + v_up * 8, '1 0', rgb, 1);
		R_EndPolygon();
	}
	
	R_BeginPolygon("", 0, 0);
	for (int i = 0i; i < g_iWaypoints; i++) {
		waypoint_t *w = g_pWaypoints + i;
		vector org = w->vecOrigin;
		
		for (float j = 0; j < (2 * M_PI); j += (2 * M_PI) / 4) {
			R_PolygonVertex(org + [sin(j), cos(j)]*w->flRadius, '1 1', '0 0.25 0', 1);
		}
		R_EndPolygon();
	}

	R_BeginPolygon("", 1, 0);
	
	for (int i = 0i; i < g_iWaypoints; i++) {
		waypoint_t *w = g_pWaypoints+i;
		vector org = w->vecOrigin;
		vector rgb = [1,1,1];

		for (int j = 0i; j < w->iNeighbours; j++) {
			int k = w->neighbour[j].node;
			int fl = w->neighbour[j].iFlags;

			if (k < 0i || k >= g_iWaypoints) {
				break;
			}

			waypoint_t *w2 = &g_pWaypoints[k];

			if (fl & WP_JUMP) {
				R_PolygonVertex(org, [0,1], [1,0,0], 1);
				R_PolygonVertex(w2->vecOrigin, [1,1], [0,1,0], 1);
			} else {
				R_PolygonVertex(org, [0,1], [1,0,1], 1);
				R_PolygonVertex(w2->vecOrigin, [1,1], [0,1,0], 1);
			}
			R_EndPolygon();
		}
	}
}

void
Way_Cmd(void)
{
	switch (argv(1)) {
		case "goto":
		if ( !self ) {
			return;
		}
		Way_GoToPoint( self );
		break;
	case "add":
		if ( !self ) {
			return;
		}
		Way_Waypoint_Create( self, 1 );
		break;
	case "addchain":
		if ( !self ) {
			return;
		}
		Way_Waypoint_Create( self, 0 );
		break;
	case "addltn":
		if ( !self ) {
			return;
		}
		Way_Waypoint_Create( self, -1 );
		break;
	case "addntl":
		if ( !self ) {
			return;
		}
		Way_Waypoint_Create( self, -2 );
		break;
	case "addspawns":
		if ( !self ) {
			return;
		}
		Way_Waypoint_CreateSpawns();
		break;
	case "delete":
		if ( !self ) {
			return;
		}
		Way_Waypoint_Delete( Way_FindClosestWaypoint( self.origin ) );
		break;
	case "radius":
		if ( !self ) {
			return;
		}
		Way_Waypoint_SetRadius( Way_FindClosestWaypoint( self.origin ), stof( argv( 2 ) ) );
		break;
	case "makejump":
		if ( !self ) {
			return;
		}
		Way_Waypoint_MakeJump( Way_FindClosestWaypoint( self.origin ) );
		break;
	case "save":
		Way_DumpWaypoints( argv( 2 ) );
		break;
	case "load":
		Way_ReadWaypoints( argv( 2 ) );
		break;
	}
}
