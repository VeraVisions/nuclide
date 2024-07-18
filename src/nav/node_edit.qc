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

static int g_waylink_status;
var int g_way1 = -1;
var int g_way2 = -1;

void
NodeEdit_LinkNodes(node_t *wp, node_t *w2)
{
	int w2n = w2 - g_pNodes;

	/* don't bother if we're already linked */
	for (int i = 0i; i < wp->m_numNeighbours; i++) {
		if (wp->m_pNeighbour[i].m_iNode == w2n) {
			return;
		}
	}

	int idx = wp->m_numNeighbours++;
	wp->m_pNeighbour = (neighbour_s *)memrealloc(wp->m_pNeighbour, sizeof(*wp->m_pNeighbour), idx, wp->m_numNeighbours);
	local struct neighbour_s *n = wp->m_pNeighbour+idx;
	n->m_iNode = w2n;
	n->m_flCost = vlen(w2->m_vecOrigin - wp->m_vecOrigin);
	n->m_iFlags = 0;
}

void
NodeEdit_UnlinkNodes(node_t *wp, node_t *w2)
{
	int w2n = w2 - g_pNodes;
	int nilled = 0;

	for (int i = 0i; i < wp->m_numNeighbours; i++) {
		if (wp->m_pNeighbour[i].m_iNode == w2n) {
			wp->m_pNeighbour[i].m_iNode = -1;
			wp->m_pNeighbour[i].m_flCost = 0;
			wp->m_pNeighbour[i].m_iFlags = 0;
			nilled = 1;
		}	
	}

	/* we nilled an entry, so let's recreate the neighbour list */
	if (nilled) {
		int new_neighbours = wp->m_numNeighbours - 1; /* one less. */
		neighbour_s *new = (neighbour_s *)memalloc(sizeof(*wp->m_pNeighbour) * new_neighbours);
		int b = 0;

		/* loop through all of our neighbours... */
		for (int i = 0i; i < wp->m_numNeighbours; i++) {
			if (wp->m_pNeighbour[i].m_iNode != -1) {
				new[b].m_iNode = wp->m_pNeighbour[i].m_iNode;
				new[b].m_flCost = wp->m_pNeighbour[i].m_flCost;
				new[b].m_iFlags = wp->m_pNeighbour[i].m_iFlags;
				b++;
			}
		}

		/* assign our new neighbour list to the old one, which will be freed. */
		wp->m_numNeighbours = new_neighbours;
		memfree(wp->m_pNeighbour);
		wp->m_pNeighbour = new;
	}
}

static void
NodeEdit_AutoLink(int wpidx)
{
	for (int i = 0i; i < g_iNodes; i++) {
		//don't link to ourself...
		if (i == wpidx) {
			continue;
		}

		//autolink distance cutoff.
		if (vlen(g_pNodes[wpidx].m_vecOrigin - g_pNodes[i].m_vecOrigin) > autocvar_nav_linksize) {
			continue;
		}

		//not going to use the full player size because that makes steps really messy.
		//however, we do need a little size, for sanity's sake
		tracebox(g_pNodes[wpidx].m_vecOrigin, '-16 -16 0', '16 16 32', g_pNodes[i].m_vecOrigin, TRUE, world);

		//light of sight blocked, don't try autolinking.
		if (trace_fraction < 1) {
			continue;
		}

		NodeEdit_LinkNodes(&g_pNodes[wpidx], &g_pNodes[i]);
		NodeEdit_LinkNodes(&g_pNodes[i], &g_pNodes[wpidx]);
	}
}

int
NodeEdit_FindClosestNode(vector vecOrigin)
{
	
	/* -1 for no nodes anywhere... */
	int r = -1i;
	float flBestDist = COST_INFINITE;

	for (int i = 0i; i < g_iNodes; i++) {
		float fDist = vlen(g_pNodes[i].m_vecOrigin - vecOrigin) - g_pNodes[i].m_flRadius;
		if (fDist < flBestDist) {
			/* within the waypoint's radius */
			if (fDist < 0) {
				flBestDist = fDist;
				r = i;
			} else {
				/* outside the waypoint, make sure its valid. */
				traceline(vecOrigin, g_pNodes[i].m_vecOrigin, TRUE, world);
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

static void
NodeEdit_CreateNode(entity ePlayer, int iAutoLink)
{
	int iNearest = NodeEdit_FindClosestNode(self.origin);
	int iID = g_iNodes++;
	g_pNodes = (node_t *)memrealloc(g_pNodes, sizeof(node_t), iID, g_iNodes);
	node_t *n = g_pNodes + iID;
	n->m_vecOrigin = ePlayer.origin;
	n->m_pNeighbour = __NULL__;
	n->m_numNeighbours = 0;
	n->m_flRadius = autocvar_nav_radius;

	if (iAutoLink == 1) {
		NodeEdit_AutoLink(iID);
	} else {
		if (iID != 0) {
			if (iAutoLink == 0) {
				NodeEdit_LinkNodes(n, &g_pNodes[iID-1]);
				NodeEdit_LinkNodes(&g_pNodes[iID-1], n);
			} else if (iAutoLink == -1) {
				NodeEdit_LinkNodes(&g_pNodes[iID-1], n);
			} else if (iAutoLink == -2) {
				NodeEdit_LinkNodes(n, &g_pNodes[iID-1]);
			} else if (iAutoLink == -4) {
				if (iNearest == -1i)
					return;

				NodeEdit_LinkNodes(n, &g_pNodes[iNearest]);
				NodeEdit_LinkNodes(&g_pNodes[iNearest], n);
			}
		}
	}
}

static void
NodeEdit_DeleteNode(int iID)
{
	if (iID < 0i || iID >= g_iNodes) {
		print("NodeEdit_DeleteNode: invalid waypoint\n");
		return;
	}

	//wipe the waypoint
	memfree(g_pNodes[iID].m_pNeighbour);
	memcpy(g_pNodes + iID, g_pNodes + iID + 1, (g_iNodes - (iID + 1)) * sizeof(*g_pNodes));
	g_iNodes--;

	//clean up any links to it.
	for (int i = 0; i < g_iNodes; i++) {
		for (int j = 0; j < g_pNodes[i].m_numNeighbours;) {
			int l = g_pNodes[i].m_pNeighbour[j].m_iNode;
			if (l == iID) {
				memcpy(g_pNodes[i].m_pNeighbour+j, g_pNodes[i].m_pNeighbour+j+1, (g_pNodes[i].m_numNeighbours-(j+1))*sizeof(*g_pNodes[i].m_pNeighbour));
				g_pNodes[i].m_numNeighbours--;
				continue;
			} else if (l > iID) {
				g_pNodes[i].m_pNeighbour[j].m_iNode = l-1;
			}
			j++;
		}
	}
}

static void
NodeEdit_SetRadius(int iID, float flRadValue)
{
	if (iID < 0i || iID >= g_iNodes) {
		print("NodeEdit_SetRadius: invalid waypoint\n");
		return;
	}
	g_pNodes[iID].m_flRadius = flRadValue;
}

static void
NodeEdit_LinkFlag(int linkFlag)
{
	if (g_waylink_status == 0) {
		g_way1 = NodeEdit_FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = NodeEdit_FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			NodeEdit_LinkNodes(&g_pNodes[g_way1], &g_pNodes[g_way2]);
			for (int b = 0i; b < g_pNodes[g_way1].m_numNeighbours; b++) {
				if (g_pNodes[g_way1].m_pNeighbour[b].m_iNode == g_way2) {
					g_pNodes[g_way1].m_pNeighbour[b].m_iFlags |= linkFlag;
					env_message_single(self, "^2Crouch-linked the two points!\n");
				}
			}
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

static void
NodeEdit_Unlink(void)
{
	if (g_waylink_status == 0) {
		g_way1 = NodeEdit_FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = NodeEdit_FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			NodeEdit_UnlinkNodes(&g_pNodes[g_way1], &g_pNodes[g_way2]);
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

static void
NodeEdit_UnlinkTwo(void)
{
	if (g_waylink_status == 0) {
		g_way1 = NodeEdit_FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = NodeEdit_FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			NodeEdit_UnlinkNodes(&g_pNodes[g_way1], &g_pNodes[g_way2]);
			NodeEdit_UnlinkNodes(&g_pNodes[g_way2], &g_pNodes[g_way1]);
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

static void
NodeEdit_HelperSpawns()
{
	for (entity a = world; (a = find(a, ::classname, "info_player_deathmatch"));) {
		NodeEdit_CreateNode(a, TRUE);
	}
}

static void
NodeEdit_GoToPoint(entity pl)
{
	vector vecSrc;
	makevectors(pl.v_angle);
	vecSrc = pl.origin + pl.view_ofs;
	traceline(vecSrc, vecSrc + (v_forward * 4096), FALSE, pl);
	print(sprintf("Telling all bots to go to %v\n", trace_endpos));

	for (entity a = world; (a = find(a, classname, "player"));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			NSBot targ;
			targ = (NSBot)a;
			targ.RouteClear();
			targ.RouteToPosition(pl.origin);
			print(sprintf("Told bot to go to %v\n", trace_endpos));
		}
	}
}

bool
NodeEdit_SaveFile(string filename)
{
	filestream file;

	if (!g_iNodes) {
		NSError("No nodes in map. Unable to say node graph.");
		return (false);
	}

	file = fopen(filename, FILE_WRITE);

	if (file < 0) {
		NSError("Unable to open %S for writing.", filename);
		return (false);
	}

	fputs(file, sprintf("%i\n", g_iNodes));

	for (int i = 0i; i < g_iNodes; i++) {
		fputs(file, sprintf("%v %f %i\n", g_pNodes[i].m_vecOrigin, g_pNodes[i].m_flRadius, g_pNodes[i].m_numNeighbours));
		
		for(int j = 0i; j < g_pNodes[i].m_numNeighbours; j++) {
			fputs(file, sprintf(" %i %f %i\n", g_pNodes[i].m_pNeighbour[j].m_iNode, g_pNodes[i].m_pNeighbour[j].m_flCost, g_pNodes[i].m_pNeighbour[j].m_iFlags));
		}
	}

	fclose(file);
	return (true);
}

void
NodeEdit_Flush(void)
{
	for (int i = 0i; i < g_iNodes; i++) {
		memfree(g_pNodes[i].m_pNeighbour);
	}

	memfree(g_pNodes);
	g_iNodes = 0i;
}

bool
NodeEdit_ReadFile(string strFile, bool flush)
{
	int startId = 0i;
	int offSet = 0i;

	filestream file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("NodeEdit_ReadFile: unable to open ", strFile, "\n");
		return (false);
	}

	/* read the number of waypoints */
	tokenize(fgets(file));

	if (flush) {
		NodeEdit_Flush();
		g_iNodes = (int)stoi(argv(0));
		g_pNodes = memalloc(sizeof(*g_pNodes) * g_iNodes);
	} else {
		int oldSize = g_iNodes;
		int newSize = g_iNodes + stoi(argv(0));
		g_pNodes = (node_t *)memrealloc(g_pNodes, sizeof(node_t), oldSize, newSize);
		g_iNodes = newSize;
		startId = oldSize;
		offSet = oldSize;
	}

	for (int i = startId; i < g_iNodes; i++) {
		tokenize(fgets(file));
		g_pNodes[i].m_vecOrigin[0] = stof(argv(0));
		g_pNodes[i].m_vecOrigin[1] = stof(argv(1));
		g_pNodes[i].m_vecOrigin[2] = stof(argv(2));
		g_pNodes[i].m_flRadius = stof(argv(3));
		g_pNodes[i].m_numNeighbours = stoi(argv(4));
		g_pNodes[i].m_pNeighbour = memalloc(sizeof(*g_pNodes[i].m_pNeighbour) * g_pNodes[i]. m_numNeighbours);
		
		for (int j = 0i; j < g_pNodes[i].m_numNeighbours; j++) {
			tokenize(fgets(file));
			g_pNodes[i].m_pNeighbour[j].m_iNode = offSet + stoi(argv(0));
			g_pNodes[i].m_pNeighbour[j].m_flCost = stof(argv(1));
			g_pNodes[i].m_pNeighbour[j].m_iFlags = stoi(argv(2));
		}
	}
	fclose(file);
	return (true);
}

static void
NodeEdit_ConnectOne(void)
{
	if (g_waylink_status == 0) {
		g_way1 = NodeEdit_FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = NodeEdit_FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			NodeEdit_LinkNodes(&g_pNodes[g_way1], &g_pNodes[g_way2]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

static void
NodeEdit_ConnectTwo(void)
{
	if (g_waylink_status == 0) {
		g_way1 = NodeEdit_FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = NodeEdit_FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			NodeEdit_LinkNodes(&g_pNodes[g_way1], &g_pNodes[g_way2]);
			NodeEdit_LinkNodes(&g_pNodes[g_way2], &g_pNodes[g_way1]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
NodeEdit_DrawDebugInfo(void)
{
	if (!g_iNodes) {
		return;
	}

	int iNearest = NodeEdit_FindClosestNode(self.origin);
		makevectors([-90, 0, 0]);
	
	for (int i = 0i; i < g_iNodes; i++) {
		node_t *w = g_pNodes + i;
		vector org = w->m_vecOrigin;
		vector rgb = [1,1,1];

		if (iNearest == i) {
			rgb = [0,1,0];
		}

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(org + v_right * 2 - v_up * 2, [1,1], rgb, 1);
		R_PolygonVertex(org - v_right * 2 - v_up * 2, [0,1], rgb, 1);
		R_EndPolygon();

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(org - v_right * 2 - v_up * 2, [0,1], rgb, 1);
		R_PolygonVertex(org - v_right * 2 + v_up * 2, [0,0], rgb, 1);
		R_EndPolygon();

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(org - v_right * 2 + v_up * 2, [0,0], rgb, 1);
		R_PolygonVertex(org + v_right * 2 + v_up * 2, [1,0], rgb, 1);
		R_EndPolygon();

		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(org + v_right * 2 + v_up * 2, [1,0], rgb, 1);
		R_PolygonVertex(org + v_right * 2 - v_up * 2, [1,1], rgb, 1);
		R_EndPolygon();
	}

	R_BeginPolygon("", 1, 0);
	for (int i = 0i; i < g_iNodes; i++) {
		node_t *w = g_pNodes+i;
		vector org = w->m_vecOrigin;
		vector rgb = [1,1,1];

		for (int j = 0i; j < w->m_numNeighbours; j++) {
			int k = w->m_pNeighbour[j].m_iNode;
			int fl = w->m_pNeighbour[j].m_iFlags;

			if (k < 0i || k >= g_iNodes) {
				break;
			}

			node_t *w2 = &g_pNodes[k];

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
				R_PolygonVertex(org + [0,0,-2], [0,1], [0,1,0], 1);
				R_PolygonVertex(w2->m_vecOrigin + [0,0,-2], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_WALK) {
				R_PolygonVertex(org + [0,0,-1], [0,1], [1,0,0], 1);
				R_PolygonVertex(w2->m_vecOrigin + [0,0,-1], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_AIM) {
				R_PolygonVertex(org + [0,0,4], [0,1], [0.25,0.25,1], 1);
				R_PolygonVertex(w2->m_vecOrigin + [0,0,4], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			R_PolygonVertex(org, [0,1], [1,0,1], 1);
			R_PolygonVertex(w2->m_vecOrigin, [1,1], [0,1,0], 1);
			R_EndPolygon();
		}
	}

	if (g_way1 >= 0) {
		R_PolygonVertex(g_pNodes[g_way1]->m_vecOrigin, [0,1], [0,1,0], 1);
		R_PolygonVertex(self.origin, [1,1], [0,1,0], 1);
		R_EndPolygon();
	}

	/* spheres need view angle */
	makevectors(self.v_angle);

	R_BeginPolygon("", 0, 0);
	for (int i = 0i; i < g_iNodes; i++) {
		vector rgb;
		node_t *w = g_pNodes + i;
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

static void
NodeEdit_LoadCurrentMapNavMesh(void)
{
	NodeEdit_ReadFile(sprintf("%s.way", mapname), true);
}

void
NodeEdit_Cmd(void)
{
	if (!self) {
		return;
	}

	switch (argv(1)) {
	case "goto":
		NodeEdit_GoToPoint(self);
		break;
	case "autolink":
		NodeEdit_AutoLink(NodeEdit_FindClosestNode(self.origin));
		break;
	case "connect1":
		NodeEdit_ConnectOne();
		break;
	case "connect2":
		NodeEdit_ConnectTwo();
		break;
	case "add":
		NodeEdit_CreateNode(self, 1);
		break;
	case "addchain":
		NodeEdit_CreateNode(self, 0);
		break;
	case "addsingle":
		NodeEdit_CreateNode(self, -3);
		break;
	case "addltn":
		NodeEdit_CreateNode(self, -1);
		break;
	case "addntl":
		NodeEdit_CreateNode(self, -2);
		break;
	case "addnear":
		NodeEdit_CreateNode(self, -4);
		break;
	case "addspawns":
		NodeEdit_HelperSpawns();
		break;
	case "delete":
		NodeEdit_DeleteNode(NodeEdit_FindClosestNode(self.origin));
		break;
	case "purge":
		Nodes_Flush();
		break;
	case "radius":
		NodeEdit_SetRadius(NodeEdit_FindClosestNode(self.origin), stof(argv(2)));
		break;
	case "radiushack":
		for (int i = 0i; i < g_iNodes; i++) {
			g_pNodes[i].m_flRadius = autocvar_nav_radius;
		}
		break;
	case "offset":
		for (int i = 0i; i < g_iNodes; i++) {
			g_pNodes[i].m_vecOrigin += stov(argv(2));
		}
		break;
	case "flipx":
		for (int i = 0i; i < g_iNodes; i++) {
			g_pNodes[i].m_vecOrigin[0] *= -1;
		}
	case "flipy":
		for (int i = 0i; i < g_iNodes; i++) {
			g_pNodes[i].m_vecOrigin[1] *= -1;
		}
		break;
	case "flipz":
		for (int i = 0i; i < g_iNodes; i++) {
			g_pNodes[i].m_vecOrigin[2] *= -1;
		}
		break;
	case "flag":
		NodeEdit_LinkFlag(stoi(argv(2)));
		break;
	case "unlink1":
		NodeEdit_Unlink();
		break;
	case "unlink2":
		NodeEdit_UnlinkTwo();
		break;
	case "move":
		vector p;
		int n = NodeEdit_FindClosestNode(self.origin);
		if (n >= 0) {
			p[0] = stof(argv(2));
			p[1] = stof(argv(3));
			p[2] = stof(argv(4));
			g_pNodes[n].m_vecOrigin += p;
		}
		break;
	case "movetopos":
		int nearest = NodeEdit_FindClosestNode(self.origin);
		if (nearest >= 0) {
			g_pNodes[nearest].m_vecOrigin = self.origin;
		}
		break;
	case "save":
		NodeEdit_SaveFile(argv(2));
		break;
	case "load":
		NodeEdit_ReadFile(argv(2), true);
		break;
	case "merge":
		NodeEdit_ReadFile(argv(2), false);
		break;
	case "loadpb":
		Way_ReadPBFile(argv(2), true);
		break;
	case "loadrich":
		Way_ReadJumbotFile(argv(2), true);
		break;
	case "loadfb":
		Way_ReadFBFile(argv(2), true);
		break;
	}
}

#ifdef NODE_DEBUG
#define SEQUENCE_RECT_COLOR [1.0,0.0,0.0]
#define NODE_RECT_COLOR [1.0,0.5,0.0]
#define NODE_RECT_ALPHA 1.0f
#define NODE_LINE_ALPHA 0.25f

/* draws debug graphics of our node tree */
var bool autocvar_r_renderEntityInfo = false;
void
SV_AddDebugPolygons(void)
{
	//NodeEdit_DrawDebugInfo();

	if (autocvar_r_renderEntityInfo) {
		makevectors(self.v_angle);

		for (entity s = world; (s = findfloat(s, ::identity, 1));) {
			NSEntity drawMe = (NSEntity)s;
			drawMe.DebugDraw();
		}
	}

	if (cvar("developer") != 1)
		return;

	if (!g_iNodes) {
		NodeEdit_LoadCurrentMapNavMesh();
	}

#if 1
	for (entity s = world; (s = find(s, ::classname, "func_tracktrain"));) {
		func_tracktrain train = (func_tracktrain)s;
		train.RenderDebugInfo();
	}
#endif
}
#endif

