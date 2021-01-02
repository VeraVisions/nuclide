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
	vector m_vecOrigin;
	float m_flRadius;	 /* used for picking the closest waypoint. aka proximity weight. also relaxes routes inside the area. */
	struct wpneighbour_s
	{
		int m_iNode;
		float m_flCost;
		int m_iFlags;
	} *m_pNeighbour;
	int m_numNeighbours;
} waypoint_t;

static waypoint_t *g_pWaypoints;
static int g_iWaypoints;

static int g_waylink_status;
var int g_way1 = -1;
var int g_way2 = -1;

static void
Way_WipeWaypoints(void)
{
	for (int i = 0; i < g_iWaypoints; i++) {
		memfree(g_pWaypoints[i].m_pNeighbour);
	}

	memfree(g_pWaypoints);
	g_iWaypoints = 0;
}

static void
Way_LinkNodes(waypoint_t *wp, waypoint_t *w2)
{
	int w2n = w2 - g_pWaypoints;

	/* don't bother if we're already linked */
	for (int i = 0i; i < wp->m_numNeighbours; i++) {
		if (wp->m_pNeighbour[i].m_iNode == w2n) {
			return;
		}
	}

	int idx = wp->m_numNeighbours++;
	wp->m_pNeighbour = memrealloc(wp->m_pNeighbour, sizeof(*wp->m_pNeighbour), idx, wp->m_numNeighbours);
	local struct wpneighbour_s *n = wp->m_pNeighbour+idx;
	n->m_iNode = w2n;
	n->m_flCost = vlen(w2->m_vecOrigin - wp->m_vecOrigin);
	n->m_iFlags = 0;
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
		if (vlen(wp->m_vecOrigin - g_pWaypoints[i].m_vecOrigin) > autocvar_nav_linksize) {
			continue;
		}

		//not going to use the full player size because that makes steps really messy.
		//however, we do need a little size, for sanity's sake
		tracebox(wp->m_vecOrigin, '-16 -16 0', '16 16 32', g_pWaypoints[i].m_vecOrigin, TRUE, world);

		//light of sight blocked, don't try autolinking.
		if (trace_fraction < 1) {
			continue;
		}

		Way_LinkNodes(wp, &g_pWaypoints[i]);
		Way_LinkNodes(&g_pWaypoints[i], wp);
	}
}

void
Way_CreateNode(entity ePlayer, int iAutoLink)
{
	int iID = g_iWaypoints++;
	g_pWaypoints = memrealloc(g_pWaypoints, sizeof(waypoint_t), iID, g_iWaypoints);
	waypoint_t *n = g_pWaypoints + iID;
	n->m_vecOrigin = ePlayer.origin;
	n->m_pNeighbour = __NULL__;
	n->m_numNeighbours = 0;
	n->m_flRadius = autocvar_nav_radius;

	if (iAutoLink == 1) {
		Way_AutoLink(n);
	} else {
		if (iID != 0) {
			if (iAutoLink == 0) {
				Way_LinkNodes(n, &g_pWaypoints[iID-1]);
				Way_LinkNodes(&g_pWaypoints[iID-1], n);
			} else if (iAutoLink == -1) {
				Way_LinkNodes(&g_pWaypoints[iID-1], n);
			} else if (iAutoLink == -2) {
				Way_LinkNodes(n, &g_pWaypoints[iID-1]);
			}
		}
	}
}

void
Way_DeleteNode(int iID)
{
	if (iID < 0i || iID >= g_iWaypoints) {
		print("Way_DeleteNode: invalid waypoint\n");
		return;
	}

	//wipe the waypoint
	memfree(g_pWaypoints[iID].m_pNeighbour);
	memcpy(g_pWaypoints + iID, g_pWaypoints + iID + 1, (g_iWaypoints - (iID + 1)) * sizeof(*g_pWaypoints));
	g_iWaypoints--;

	//clean up any links to it.
	for (int i = 0; i < g_iWaypoints; i++) {
		for (int j = 0; j < g_pWaypoints[i].m_numNeighbours;) {
			int l = g_pWaypoints[i].m_pNeighbour[j].m_iNode;
			if (l == iID) {
				memcpy(g_pWaypoints[i].m_pNeighbour+j, g_pWaypoints[i].m_pNeighbour+j+1, (g_pWaypoints[i].m_numNeighbours-(j+1))*sizeof(*g_pWaypoints[i].m_pNeighbour));
				g_pWaypoints[i].m_numNeighbours--;
				continue;
			} else if (l > iID) {
				g_pWaypoints[i].m_pNeighbour[j].m_iNode = l-1;
			}
			j++;
		}
	}
}

void
Way_SetRadius(int iID, float flRadValue)
{
	if (iID < 0i || iID >= g_iWaypoints) {
		print("Way_SetRadius: invalid waypoint\n");
		return;
	}
	g_pWaypoints[iID].m_flRadius = flRadValue;
}

int
Way_FindClosestNode(vector vecOrigin)
{
	
	/* -1 for no nodes anywhere... */
	int r = -1i;
	float flBestDist = COST_INFINITE;

	for (int i = 0i; i < g_iWaypoints; i++) {
		float fDist = vlen(g_pWaypoints[i].m_vecOrigin - vecOrigin) - g_pWaypoints[i].m_flRadius;
		if (fDist < flBestDist) {
			/* within the waypoint's radius */
			if (fDist < 0) {
				flBestDist = fDist;
				r = i;
			} else {
				/* outside the waypoint, make sure its valid. */
				traceline(vecOrigin, g_pWaypoints[i].m_vecOrigin, TRUE, world);
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
Way_FlagJump(void)
{
	if (g_waylink_status == 0) {
		g_way1 = Way_FindClosestNode(self.origin);
		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = Way_FindClosestNode(self.origin);
		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			for (int b = 0i; b < g_pWaypoints[g_way1].m_numNeighbours; b++) {
				if (g_pWaypoints[g_way1].m_pNeighbour[b].m_iNode == g_way2) {
					g_pWaypoints[g_way1].m_pNeighbour[b].m_iFlags |= LF_JUMP;
					env_message_single(self, "^2Jump-linked the two points!\n");
				}
			}
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
Way_FlagCrouch(void)
{
	if (g_waylink_status == 0) {
		g_way1 = Way_FindClosestNode(self.origin);
		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = Way_FindClosestNode(self.origin);
		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			for (int b = 0i; b < g_pWaypoints[g_way1].m_numNeighbours; b++) {
				if (g_pWaypoints[g_way1].m_pNeighbour[b].m_iNode == g_way2) {
					g_pWaypoints[g_way1].m_pNeighbour[b].m_iFlags |= LF_CROUCH;
					env_message_single(self, "^2Crouch-linked the two points!\n");
				}
			}
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
Way_FlagWalk(void)
{
	if (g_waylink_status == 0) {
		g_way1 = Way_FindClosestNode(self.origin);
		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = Way_FindClosestNode(self.origin);
		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			for (int b = 0i; b < g_pWaypoints[g_way1].m_numNeighbours; b++) {
				if (g_pWaypoints[g_way1].m_pNeighbour[b].m_iNode == g_way2) {
					g_pWaypoints[g_way1].m_pNeighbour[b].m_iFlags |= LF_WALK;
					env_message_single(self, "^2Walk-linked the two points!\n");
				}
			}
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
Way_HelperSpawns()
{
	for (entity a = world; (a = find(a, ::classname, "info_player_deathmatch"));) {
		Way_CreateNode(a, TRUE);
	}
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
Way_SaveFile(string filename)
{
	filestream file;

	if (!g_iWaypoints) {
		env_message_single(self, "^1ERROR: Tried to save empty waypoints.\n");
		return;
	}

	file = fopen(filename, FILE_WRITE);

	if (file < 0) {
		print("Way_SaveFile: unable to open ", filename, "\n");
		return;
	}

	fputs(file, sprintf("%i\n", g_iWaypoints));

	for (int i = 0i; i < g_iWaypoints; i++) {
		fputs(file, sprintf("%v %f %i\n", g_pWaypoints[i].m_vecOrigin, g_pWaypoints[i].m_flRadius, g_pWaypoints[i].m_numNeighbours));
		
		for(int j = 0i; j < g_pWaypoints[i].m_numNeighbours; j++) {
			fputs(file, sprintf(" %i %f %x\n", g_pWaypoints[i].m_pNeighbour[j].m_iNode, g_pWaypoints[i].m_pNeighbour[j].m_flCost, (float)g_pWaypoints[i].m_pNeighbour[j].m_iFlags));
		}
	}

	fclose(file);
}

void
Way_ReadFile(string strFile)
{
	float file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("Way_ReadFile: unable to open ", strFile, "\n");
		return;
	}

	Way_WipeWaypoints();

	tokenize(fgets(file));
	g_iWaypoints = stoi(argv(0));
	g_pWaypoints = memalloc(sizeof(*g_pWaypoints) * g_iWaypoints);

	for (int i = 0i; i < g_iWaypoints; i++) {
		tokenize(fgets(file));
		g_pWaypoints[i].m_vecOrigin[0] = stof(argv(0));
		g_pWaypoints[i].m_vecOrigin[1] = stof(argv(1));
		g_pWaypoints[i].m_vecOrigin[2] = stof(argv(2));
		g_pWaypoints[i].m_flRadius = stof(argv(3));
		g_pWaypoints[i].m_numNeighbours = stoi(argv(4));
		g_pWaypoints[i].m_pNeighbour = memalloc(sizeof(*g_pWaypoints[i].m_pNeighbour) * g_pWaypoints[i].m_numNeighbours);
		
		for (int j = 0i; j < g_pWaypoints[i].m_numNeighbours; j++) {
			tokenize(fgets(file));
			g_pWaypoints[i].m_pNeighbour[j].m_iNode = stoi(argv(0));
			g_pWaypoints[i].m_pNeighbour[j].m_flCost = stof(argv(1));
			g_pWaypoints[i].m_pNeighbour[j].m_iFlags = stoh(argv(2));
		}
	}
	fclose(file);
}


void
Way_ConnectOne(void)
{
	if (g_waylink_status == 0) {
		g_way1 = Way_FindClosestNode(self.origin);
		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = Way_FindClosestNode(self.origin);
		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			Way_LinkNodes(&g_pWaypoints[g_way1], &g_pWaypoints[g_way2]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
Way_ConnectTwo(void)
{
	if (g_waylink_status == 0) {
		g_way1 = Way_FindClosestNode(self.origin);
		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = Way_FindClosestNode(self.origin);
		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			Way_LinkNodes(&g_pWaypoints[g_way1], &g_pWaypoints[g_way2]);
			Way_LinkNodes(&g_pWaypoints[g_way2], &g_pWaypoints[g_way1]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
Way_Cmd(void)
{
	if (!self) {
		return;
	}

	switch (argv(1)) {
	case "goto":
		Way_GoToPoint( self );
		break;
	case "autolink":
		Way_AutoLink(Way_FindClosestNode(self.origin));
		break;
	case "connect1":
		Way_ConnectOne();
		break;
	case "connect2":
		Way_ConnectTwo();
		break;
	case "add":
		Way_CreateNode( self, 1 );
		break;
	case "addchain":
		Way_CreateNode( self, 0 );
		break;
	case "addsingle":
		Way_CreateNode( self, -3 );
		break;
	case "addltn":
		Way_CreateNode( self, -1 );
		break;
	case "addntl":
		Way_CreateNode( self, -2 );
		break;
	case "addspawns":
		Way_HelperSpawns();
		break;
	case "delete":
		Way_DeleteNode( Way_FindClosestNode( self.origin ) );
		break;
	case "purge":
		Way_WipeWaypoints();
		break;
	case "radius":
		Way_SetRadius( Way_FindClosestNode( self.origin ), stof( argv( 2 ) ) );
		break;
	case "radiushack":
		for (int i = 0i; i < g_iWaypoints; i++) {
			g_pWaypoints[i].m_flRadius = autocvar_nav_radius;
		}
		break;
	case "linkjump":
		Way_FlagJump();
		break;
	case "linkcrouch":
		Way_FlagCrouch();
		break;
	case "linkwalk":
		Way_FlagWalk();
		break;
	case "save":
		Way_SaveFile( argv( 2 ) );
		break;
	case "load":
		Way_ReadFile( argv( 2 ) );
		break;
	}
}
void
Way_DrawDebugInfo(void)
{
	if (!g_iWaypoints) {
		return;
	}

	int iNearest = Way_FindClosestNode(self.origin);
	makevectors(self.v_angle);
	R_BeginPolygon("", 0, 0);
	
	for (int i = 0i; i < g_iWaypoints; i++) {
		waypoint_t *w = g_pWaypoints + i;
		vector org = w->m_vecOrigin;
		vector rgb = [1,1,1];

		if (iNearest == i) {
			rgb = [0,1,0];
		}

		R_PolygonVertex(org + v_right * 4 - v_up * 4, [1,1], rgb, 1);
		R_PolygonVertex(org - v_right * 4 - v_up * 4, [0,1], rgb, 1);
		R_PolygonVertex(org - v_right * 4 + v_up * 4, [0,0], rgb, 1);
		R_PolygonVertex(org + v_right * 4 + v_up * 4, [1,0], rgb, 1);
		R_EndPolygon();
	}

	R_BeginPolygon("", 1, 0);
	for (int i = 0i; i < g_iWaypoints; i++) {
		waypoint_t *w = g_pWaypoints+i;
		vector org = w->m_vecOrigin;
		vector rgb = [1,1,1];

		for (int j = 0i; j < w->m_numNeighbours; j++) {
			int k = w->m_pNeighbour[j].m_iNode;
			int fl = w->m_pNeighbour[j].m_iFlags;

			if (k < 0i || k >= g_iWaypoints) {
				break;
			}

			waypoint_t *w2 = &g_pWaypoints[k];

			if (fl & LF_JUMP) {
				vector middle;
				middle = (w2->m_vecOrigin + org) / 2;
				R_PolygonVertex(org + [0,0,1], [0,1], [1,1,0], 1);
				R_PolygonVertex(middle + [0,0,32], [0,1], [0.5,0.5,0], 1);
				R_EndPolygon();
				R_PolygonVertex(middle + [0,0,32], [0,1], [0.5,0.5,0], 1);
				R_PolygonVertex(w2->m_vecOrigin + [0,0,1], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_CROUCH) {
				R_PolygonVertex(org + [0,0,-1], [0,1], [0,0,1], 1);
				R_PolygonVertex(w2->m_vecOrigin + [0,0,-1], [1,1], [0,0,1], 1);
				R_EndPolygon();
			}

			R_PolygonVertex(org, [0,1], [1,0,1], 1);
			R_PolygonVertex(w2->m_vecOrigin, [1,1], [0,1,0], 1);
			R_EndPolygon();
		}
	}

	if (g_way1 >= 0) {
		R_PolygonVertex(g_pWaypoints[g_way1]->m_vecOrigin, [0,1], [0,1,0], 1);
		R_PolygonVertex(self.origin, [1,1], [0,1,0], 1);
		R_EndPolygon();
	}

	R_BeginPolygon("", 0, 0);
	for (int i = 0i; i < g_iWaypoints; i++) {
		vector rgb;
		waypoint_t *w = g_pWaypoints + i;
		vector org = w->m_vecOrigin;

		if (iNearest == i) {
			rgb = [0,1,0];
		} else {
			rgb = [0.5,0,1.0];
		}

		if (w->m_flRadius) {
			for(int j = 0; j < 16; j++) {
				float theta = 2.0f * M_PI * j / 16;
				vector p = (v_right * sin(theta)) + (v_up * cos(theta));
				R_PolygonVertex(org + (p * w->m_flRadius), [1,1], rgb, 0.1f);

			}
			R_EndPolygon();
			for(int j = 0; j < 16; j++) {
				float theta = 2.0f * M_PI * j / 16;
				R_PolygonVertex(org + [sin(theta), cos(theta)] * w->m_flRadius, [1,1], rgb, 0.2f);

			}
			R_EndPolygon();
		}
	}
}
