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
ncNodeEditor::LinkNodes(graphNode_t *wp, graphNode_t *w2)
{
	int w2n = w2 - g_nodeGraph;

	/* don't bother if we're already linked */
	for (int i = 0i; i < wp->m_neighborCount; i++) {
		if (wp->m_neighborList[i].m_nodeID == w2n) {
			return;
		}
	}

	int idx = wp->m_neighborCount++;
	wp->m_neighborList = (neighbour_s *)memreallocOld(wp->m_neighborList, sizeof(*wp->m_neighborList), idx, wp->m_neighborCount);
	local struct neighbour_s *n = wp->m_neighborList+idx;
	n->m_nodeID = w2n;
	n->m_travelCost = vlen(w2->m_origin - wp->m_origin);
	n->m_travelFlags = 0;
}

void
ncNodeEditor::UnlinkNodes(graphNode_t *wp, graphNode_t *w2)
{
	int w2n = w2 - g_nodeGraph;
	int nilled = 0;

	for (int i = 0i; i < wp->m_neighborCount; i++) {
		if (wp->m_neighborList[i].m_nodeID == w2n) {
			wp->m_neighborList[i].m_nodeID = -1;
			wp->m_neighborList[i].m_travelCost = 0;
			wp->m_neighborList[i].m_travelFlags = 0;
			nilled = 1;
		}
	}

	/* we nilled an entry, so let's recreate the neighbour list */
	if (nilled) {
		int new_neighbours = wp->m_neighborCount - 1; /* one less. */
		neighbour_s *new = (neighbour_s *)memalloc(sizeof(*wp->m_neighborList) * new_neighbours);
		int b = 0;

		/* loop through all of our neighbours... */
		for (int i = 0i; i < wp->m_neighborCount; i++) {
			if (wp->m_neighborList[i].m_nodeID != -1) {
				new[b].m_nodeID = wp->m_neighborList[i].m_nodeID;
				new[b].m_travelCost = wp->m_neighborList[i].m_travelCost;
				new[b].m_travelFlags = wp->m_neighborList[i].m_travelFlags;
				b++;
			}
		}

		/* assign our new neighbour list to the old one, which will be freed. */
		wp->m_neighborCount = new_neighbours;
		memfree(wp->m_neighborList);
		wp->m_neighborList = new;
	}
}

void
ncNodeEditor::AutoLink(int wpidx)
{
	for (int i = 0i; i < g_nodeCount; i++) {
		//don't link to ourself...
		if (i == wpidx) {
			continue;
		}

		//autolink distance cutoff.
		if (vlen(g_nodeGraph[wpidx].m_origin - g_nodeGraph[i].m_origin) > autocvar_nav_linksize) {
			continue;
		}

		//not going to use the full player size because that makes steps really messy.
		//however, we do need a little size, for sanity's sake
		tracebox(g_nodeGraph[wpidx].m_origin, '-16 -16 0', '16 16 32', g_nodeGraph[i].m_origin, TRUE, world);

		//light of sight blocked, don't try autolinking.
		if (trace_fraction < 1) {
			continue;
		}

		ncNodeEditor::LinkNodes(&g_nodeGraph[wpidx], &g_nodeGraph[i]);
		ncNodeEditor::LinkNodes(&g_nodeGraph[i], &g_nodeGraph[wpidx]);
	}
}

int
ncNodeEditor::FindClosestNode(vector vecOrigin)
{

	/* -1 for no nodes anywhere... */
	int r = -1i;
	float flBestDist = MAX_DISTANCE;

	for (int i = 0i; i < g_nodeCount; i++) {
		float fDist = vlen(g_nodeGraph[i].m_origin - vecOrigin) - g_nodeGraph[i].m_nodeRadius;
		if (fDist < flBestDist) {
			/* within the waypoint's radius */
			if (fDist < 0) {
				flBestDist = fDist;
				r = i;
			} else {
				/* outside the waypoint, make sure its valid. */
				traceline(vecOrigin, g_nodeGraph[i].m_origin, TRUE, world);
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
ncNodeEditor::CreateNode(entity ePlayer, int iAutoLink)
{
	int iNearest = ncNodeEditor::FindClosestNode(ePlayer.origin);
	int iID = g_nodeCount++;
	g_nodeGraph = (graphNode_t *)memreallocOld(g_nodeGraph, sizeof(graphNode_t), iID, g_nodeCount);
	graphNode_t *n = g_nodeGraph + iID;
	n->m_origin = ePlayer.origin;
	n->m_neighborList = __NULL__;
	n->m_neighborCount = 0;
	n->m_nodeRadius = autocvar_nav_radius;

	if (iAutoLink == 1) {
		ncNodeEditor::AutoLink(iID);
	} else {
		if (iID != 0) {
			if (iAutoLink == 0) {
				ncNodeEditor::LinkNodes(n, &g_nodeGraph[iID-1]);
				ncNodeEditor::LinkNodes(&g_nodeGraph[iID-1], n);
			} else if (iAutoLink == -1) {
				ncNodeEditor::LinkNodes(&g_nodeGraph[iID-1], n);
			} else if (iAutoLink == -2) {
				ncNodeEditor::LinkNodes(n, &g_nodeGraph[iID-1]);
			} else if (iAutoLink == -4) {
				if (iNearest == -1i)
					return;

				ncNodeEditor::LinkNodes(n, &g_nodeGraph[iNearest]);
				ncNodeEditor::LinkNodes(&g_nodeGraph[iNearest], n);
			}
		}
	}
}

void
ncNodeEditor::DeleteNode(int iID)
{
	if (iID < 0i || iID >= g_nodeCount) {
		print("ncNodeEditor::DeleteNode: invalid waypoint\n");
		return;
	}

	//wipe the waypoint
	memfree(g_nodeGraph[iID].m_neighborList);
	memcpy(g_nodeGraph + iID, g_nodeGraph + iID + 1, (g_nodeCount - (iID + 1)) * sizeof(*g_nodeGraph));
	g_nodeCount--;

	//clean up any links to it.
	for (int i = 0; i < g_nodeCount; i++) {
		for (int j = 0; j < g_nodeGraph[i].m_neighborCount;) {
			int l = g_nodeGraph[i].m_neighborList[j].m_nodeID;
			if (l == iID) {
				memcpy(g_nodeGraph[i].m_neighborList+j, g_nodeGraph[i].m_neighborList+j+1, (g_nodeGraph[i].m_neighborCount-(j+1))*sizeof(*g_nodeGraph[i].m_neighborList));
				g_nodeGraph[i].m_neighborCount--;
				continue;
			} else if (l > iID) {
				g_nodeGraph[i].m_neighborList[j].m_nodeID = l-1;
			}
			j++;
		}
	}
}

void
ncNodeEditor::SetRadius(int iID, float flRadValue)
{
	if (iID < 0i || iID >= g_nodeCount) {
		print("ncNodeEditor::SetRadius: invalid waypoint\n");
		return;
	}
	g_nodeGraph[iID].m_nodeRadius = flRadValue;
}

void
ncNodeEditor::LinkFlag(int linkFlag)
{
	if (g_waylink_status == 0) {
		g_way1 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			ncNodeEditor::LinkNodes(&g_nodeGraph[g_way1], &g_nodeGraph[g_way2]);
			for (int b = 0i; b < g_nodeGraph[g_way1].m_neighborCount; b++) {
				if (g_nodeGraph[g_way1].m_neighborList[b].m_nodeID == g_way2) {
					g_nodeGraph[g_way1].m_neighborList[b].m_travelFlags |= linkFlag;
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
ncNodeEditor::Unlink(void)
{
	if (g_waylink_status == 0) {
		g_way1 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			ncNodeEditor::UnlinkNodes(&g_nodeGraph[g_way1], &g_nodeGraph[g_way2]);
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
ncNodeEditor::UnlinkTwo(void)
{
	if (g_waylink_status == 0) {
		g_way1 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^2Selected first waypoint!\n");
	} else if (g_waylink_status == 1) {
		g_way2 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			ncNodeEditor::UnlinkNodes(&g_nodeGraph[g_way1], &g_nodeGraph[g_way2]);
			ncNodeEditor::UnlinkNodes(&g_nodeGraph[g_way2], &g_nodeGraph[g_way1]);
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
ncNodeEditor::HelperSpawns()
{
	for (entity a = world; (a = find(a, ::classname, "info_player_deathmatch"));) {
		ncNodeEditor::CreateNode(a, TRUE);
	}
}

void
ncNodeEditor::GoToPoint(entity pl)
{
	vector vecSrc;
	makevectors(pl.v_angle);
	vecSrc = pl.origin + pl.view_ofs;
	traceline(vecSrc, vecSrc + (v_forward * 4096), FALSE, pl);
	print(sprintf("Telling all bots to go to %v\n", trace_endpos));

	for (entity a = world; (a = next.Player(a));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			ncBot targ;
			targ = (ncBot)a;
			targ.RouteClear();
			targ.RouteToPosition(pl.origin);
			print(sprintf("Told bot to go to %v\n", trace_endpos));
		}
	}
}

bool
ncNodeEditor::SaveFile(string filename)
{
	filestream file;

	if (!g_nodeCount) {
		ncError("No nodes in map. Unable to say node graph.");
		return (false);
	}

	file = fopen(filename, FILE_WRITE);

	if (file < 0) {
		ncError("Unable to open %S for writing.", filename);
		return (false);
	}

	fputs(file, sprintf("%i\n", g_nodeCount));

	for (int i = 0i; i < g_nodeCount; i++) {
		fputs(file, sprintf("%v %f %i\n", g_nodeGraph[i].m_origin, g_nodeGraph[i].m_nodeRadius, g_nodeGraph[i].m_neighborCount));

		for(int j = 0i; j < g_nodeGraph[i].m_neighborCount; j++) {
			fputs(file, sprintf(" %i %f %i\n", g_nodeGraph[i].m_neighborList[j].m_nodeID, g_nodeGraph[i].m_neighborList[j].m_travelCost, g_nodeGraph[i].m_neighborList[j].m_travelFlags));
		}
	}

	fclose(file);
	return (true);
}

void
ncNodeEditor::Flush(void)
{
	for (int i = 0i; i < g_nodeCount; i++) {
		memfree(g_nodeGraph[i].m_neighborList);
	}

	memfree(g_nodeGraph);
	g_nodeCount = 0i;
}

bool
ncNodeEditor::ReadFile(string strFile, bool flush)
{
	int startId = 0i;
	int offSet = 0i;

	filestream file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("ncNodeEditor::ReadFile: unable to open ", strFile, "\n");
		return (false);
	}

	/* read the number of waypoints */
	tokenize(fgets(file));

	if (flush) {
		ncNodeEditor::Flush();
		g_nodeCount = (int)stoi(argv(0));
		g_nodeGraph = memalloc(sizeof(*g_nodeGraph) * g_nodeCount);
	} else {
		int oldSize = g_nodeCount;
		int newSize = g_nodeCount + stoi(argv(0));
		g_nodeGraph = (graphNode_t *)memreallocOld(g_nodeGraph, sizeof(graphNode_t), oldSize, newSize);
		g_nodeCount = newSize;
		startId = oldSize;
		offSet = oldSize;
	}

	for (int i = startId; i < g_nodeCount; i++) {
		tokenize(fgets(file));
		g_nodeGraph[i].m_origin[0] = stof(argv(0));
		g_nodeGraph[i].m_origin[1] = stof(argv(1));
		g_nodeGraph[i].m_origin[2] = stof(argv(2));
		g_nodeGraph[i].m_nodeRadius = stof(argv(3));
		g_nodeGraph[i].m_neighborCount = stoi(argv(4));
		g_nodeGraph[i].m_neighborList = memalloc(sizeof(*g_nodeGraph[i].m_neighborList) * g_nodeGraph[i]. m_neighborCount);

		for (int j = 0i; j < g_nodeGraph[i].m_neighborCount; j++) {
			tokenize(fgets(file));
			g_nodeGraph[i].m_neighborList[j].m_nodeID = offSet + stoi(argv(0));
			g_nodeGraph[i].m_neighborList[j].m_travelCost = stof(argv(1));
			g_nodeGraph[i].m_neighborList[j].m_travelFlags = stoi(argv(2));
		}
	}
	fclose(file);
	return (true);
}

void
ncNodeEditor::ConnectOne(void)
{
	if (g_waylink_status == 0) {
		g_way1 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			ncNodeEditor::LinkNodes(&g_nodeGraph[g_way1], &g_nodeGraph[g_way2]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
ncNodeEditor::ConnectTwo(void)
{
	if (g_waylink_status == 0) {
		g_way1 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way1 == -1i)
			return;

		g_waylink_status = 1;
		env_message_single(self, "^21/2 nodes selected...    \n");
	} else if (g_waylink_status == 1) {
		g_way2 = ncNodeEditor::FindClosestNode(self.origin);

		if (g_way2 == -1i)
			return;

		g_waylink_status = 0;

		if (g_way1 != g_way2) {
			ncNodeEditor::LinkNodes(&g_nodeGraph[g_way1], &g_nodeGraph[g_way2]);
			ncNodeEditor::LinkNodes(&g_nodeGraph[g_way2], &g_nodeGraph[g_way1]);
			env_message_single(self, "^22/2 nodes selected, done!\n");
		} else {
			env_message_single(self, "^1Failed to link, the two points are the same!\n");
		}
		g_way1 = g_way2 = -1;
	}
}

void
ncNodeEditor::DrawDebugInfo(void)
{
	if (!g_nodeCount) {
		return;
	}

	int iNearest = ncNodeEditor::FindClosestNode(self.origin);
		makevectors([-90, 0, 0]);

	for (int i = 0i; i < g_nodeCount; i++) {
		graphNode_t *w = g_nodeGraph + i;
		vector org = w->m_origin;
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
	for (int i = 0i; i < g_nodeCount; i++) {
		graphNode_t *w = g_nodeGraph+i;
		vector org = w->m_origin;
		vector rgb = [1,1,1];

		for (int j = 0i; j < w->m_neighborCount; j++) {
			int k = w->m_neighborList[j].m_nodeID;
			int fl = w->m_neighborList[j].m_travelFlags;

			if (k < 0i || k >= g_nodeCount) {
				break;
			}

			graphNode_t *w2 = &g_nodeGraph[k];

			if (fl & LF_JUMP) {
				vector middle;
				middle = (w2->m_origin + org) / 2;
				R_PolygonVertex(org + [0,0,1], [0,1], [1,1,0], 1);
				R_PolygonVertex(middle + [0,0,32], [0,1], [0.5,0.5,0], 1);
				R_EndPolygon();
				R_PolygonVertex(middle + [0,0,32], [0,1], [0.5,0.5,0], 1);
				R_PolygonVertex(w2->m_origin + [0,0,1], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_CROUCH) {
				R_PolygonVertex(org + [0,0,-2], [0,1], [0,1,0], 1);
				R_PolygonVertex(w2->m_origin + [0,0,-2], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_WALK) {
				R_PolygonVertex(org + [0,0,-1], [0,1], [1,0,0], 1);
				R_PolygonVertex(w2->m_origin + [0,0,-1], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			if (fl & LF_AIM) {
				R_PolygonVertex(org + [0,0,4], [0,1], [0.25,0.25,1], 1);
				R_PolygonVertex(w2->m_origin + [0,0,4], [1,1], [0,0,0], 1);
				R_EndPolygon();
			}

			R_PolygonVertex(org, [0,1], [1,0,1], 1);
			R_PolygonVertex(w2->m_origin, [1,1], [0,1,0], 1);
			R_EndPolygon();
		}
	}

	if (g_way1 >= 0) {
		R_PolygonVertex(g_nodeGraph[g_way1]->m_origin, [0,1], [0,1,0], 1);
		R_PolygonVertex(self.origin, [1,1], [0,1,0], 1);
		R_EndPolygon();
	}

	/* spheres need view angle */
	makevectors(self.v_angle);

	R_BeginPolygon("", 0, 0);
	for (int i = 0i; i < g_nodeCount; i++) {
		vector rgb;
		graphNode_t *w = g_nodeGraph + i;
		vector org = w->m_origin;

		if (iNearest == i) {
			rgb = [0,1,0];
		} else {
			rgb = [0.5,0,1.0];
		}

		if (w->m_nodeRadius) {
			for(int j = 0; j < 16; j++) {
				float theta = 2.0f * M_PI * j / 16;
				vector p = (v_right * sin(theta)) + (v_up * cos(theta));
				R_PolygonVertex(org + (p * w->m_nodeRadius), [1,1], rgb, 0.1f);

			}
			R_EndPolygon();
			for(int j = 0; j < 16; j++) {
				float theta = 2.0f * M_PI * j / 16;
				R_PolygonVertex(org + [sin(theta), cos(theta)] * w->m_nodeRadius, [1,1], rgb, 0.2f);

			}
			R_EndPolygon();
		}
	}
}

void
ncNodeEditor::LoadCurrentMapNavMesh(void)
{
	ncNodeEditor::ReadFile(sprintf("%s.way", mapname), true);
}

void
ncNodeEditor::Cmd(void)
{
	if (!self) {
		return;
	}

	switch (argv(1)) {
	case "goto":
		ncNodeEditor::GoToPoint(self);
		break;
	case "autolink":
		ncNodeEditor::AutoLink(ncNodeEditor::FindClosestNode(self.origin));
		break;
	case "connect1":
		ncNodeEditor::ConnectOne();
		break;
	case "connect2":
		ncNodeEditor::ConnectTwo();
		break;
	case "add":
		ncNodeEditor::CreateNode(self, 1);
		break;
	case "addchain":
		ncNodeEditor::CreateNode(self, 0);
		break;
	case "addsingle":
		ncNodeEditor::CreateNode(self, -3);
		break;
	case "addltn":
		ncNodeEditor::CreateNode(self, -1);
		break;
	case "addntl":
		ncNodeEditor::CreateNode(self, -2);
		break;
	case "addnear":
		ncNodeEditor::CreateNode(self, -4);
		break;
	case "addspawns":
		ncNodeEditor::HelperSpawns();
		break;
	case "delete":
		ncNodeEditor::DeleteNode(ncNodeEditor::FindClosestNode(self.origin));
		break;
	case "purge":
		Nodes_Flush();
		break;
	case "radius":
		ncNodeEditor::SetRadius(ncNodeEditor::FindClosestNode(self.origin), stof(argv(2)));
		break;
	case "radiushack":
		for (int i = 0i; i < g_nodeCount; i++) {
			g_nodeGraph[i].m_nodeRadius = autocvar_nav_radius;
		}
		break;
	case "offset":
		for (int i = 0i; i < g_nodeCount; i++) {
			g_nodeGraph[i].m_origin += stov(argv(2));
		}
		break;
	case "flipx":
		for (int i = 0i; i < g_nodeCount; i++) {
			g_nodeGraph[i].m_origin[0] *= -1;
		}
	case "flipy":
		for (int i = 0i; i < g_nodeCount; i++) {
			g_nodeGraph[i].m_origin[1] *= -1;
		}
		break;
	case "flipz":
		for (int i = 0i; i < g_nodeCount; i++) {
			g_nodeGraph[i].m_origin[2] *= -1;
		}
		break;
	case "flag":
		ncNodeEditor::LinkFlag(stoi(argv(2)));
		break;
	case "unlink1":
		ncNodeEditor::Unlink();
		break;
	case "unlink2":
		ncNodeEditor::UnlinkTwo();
		break;
	case "move":
		vector p;
		int n = ncNodeEditor::FindClosestNode(self.origin);
		if (n >= 0) {
			p[0] = stof(argv(2));
			p[1] = stof(argv(3));
			p[2] = stof(argv(4));
			g_nodeGraph[n].m_origin += p;
		}
		break;
	case "movetopos":
		int nearest = ncNodeEditor::FindClosestNode(self.origin);
		if (nearest >= 0) {
			g_nodeGraph[nearest].m_origin = self.origin;
		}
		break;
	case "save":
		ncNodeEditor::SaveFile(argv(2));
		break;
	case "load":
		ncNodeEditor::ReadFile(argv(2), true);
		break;
	case "merge":
		ncNodeEditor::ReadFile(argv(2), false);
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
var bool autocvar_nav_visualize = false;
void
SV_AddDebugPolygons(void)
{
	if (autocvar_nav_visualize) {
		ncNodeEditor::DrawDebugInfo();
	}

	if (autocvar_r_renderEntityInfo) {
		makevectors(self.v_angle);

		for (entity s = world; (s = findfloat(s, ::identity, 1));) {
			ncEntity drawMe = (ncEntity)s;
			drawMe.DebugDraw();
		}
	}

	if (cvar("developer") != 1)
		return;

	if (!g_nodeCount) {
		ncNodeEditor::LoadCurrentMapNavMesh();
	}

#if 1
	for (entity s = world; (s = find(s, ::classname, "func_tracktrain"));) {
		func_tracktrain train = (func_tracktrain)s;
		train.RenderDebugInfo();
	}
#endif
}
#endif

