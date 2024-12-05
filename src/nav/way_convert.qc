/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

/** Data holding a FoxBot Waypoint File Header */
typedef struct
{
	/* 8 bytes */
	int type1;
	int type2;

	int versionNumber;
	int extraFlags;
	int numNodes;

	/* 32 bytes */
	int mapname1;
	int mapname2;
	int mapname3;
	int mapname4;
	int mapname5;
	int mapname6;
	int mapname7;
	int mapname8;
} fb_header;

#define FBFL_TEAM1				0x00000001
#define FBFL_TEAM2				0x00000002
#define FBFL_TEAMSPECIFIC		0x00000004
#define FBFL_CROUCH				0x00000008
#define FBFL_LADDER				0x00000010
#define FBFL_LIFT				0x00000020
#define FBFL_WALK				0x00000040
#define FBFL_HEALTH				0x00000080
#define FBFL_ARMOR				0x00000100
#define FBFL_AMMO				0x00000200
#define FBFL_SNIPER				0x00000400
#define FBFL_GOALITEM			0x00000800
#define FBFL_GOAL				0x00001000
#define FBFL_SENTRY				0x00002000
#define FBFL_AIMING				0x00004000
#define FBFL_JUMP				0x00008000
#define FBFL_DETPACKSEAL		0x00010000
#define FBFL_PATHCHECK			0x00020000
#define FBFL_UNUSED1			0x00040000
#define FBFL_UNUSED2			0x00080000
#define FBFL_UNUSED3			0x00100000
#define FBFL_UNUSED4			0x00200000
#define FBFL_UNUSED5			0x00400000
#define ITEM_UNUSED6			0x00800000
#define FBFL_PIPETRAP			0x01000000
#define FBFL_DETPACKCLEAR		0x02000000
#define FBFL_TELEENTER			0x04000000
#define FBFL_CONCJUMP			0x08000000
#define FBFL_SENTRY_180			0x10000000
#define FBFL_DEFEND				0x20000000
#define FBFL_TELEEXIT			0x40000000
#define FBFL_DELETED			0x80000000

static int
Way_FBFlagsToNC(int inputFlags)
{
	int outFlags = 0i;

	if (inputFlags & FBFL_JUMP)
		outFlags |= LF_JUMP;

	if (inputFlags & FBFL_WALK)
		outFlags |= LF_WALK;

	if (inputFlags & FBFL_CROUCH)
		outFlags |= LF_CROUCH;

	if (inputFlags & FBFL_AIMING)
		outFlags |= LF_AIM;

	if (inputFlags & FBFL_LADDER)
		outFlags |= LF_AIM;

	return (outFlags);
}

/* Reads a FB waypoint file.

These are binary files and contain a lot of type sizes that we don't
have access to in QC. So we cannot just fread() into a struct.

The only flag between nodes is seemingly JUMP (1), however the
individual nodes themselves have defining info flags too including
ones for using buttons and ladders. Ideally we'd want to re-interpret
those into linkflags.
 */
bool
Way_ReadFBFile(string strFile, bool flush)
{
	int startId = 0i;
	int offSet = 0i;
	fb_header fbHeader;
	int *nodeFlags;

	filestream file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("Way_ReadFile: unable to open ", strFile, "\n");
		return (false);
	}

	fread(file, (void*)&fbHeader, sizeof(fb_header));

	if (flush) {
		Nodes_Flush();
		g_iNodes = fbHeader.numNodes;
		g_pNodes = memalloc(sizeof(*g_pNodes) * g_iNodes);
	} else {
		int oldSize = g_iNodes;
		int newSize = g_iNodes + fbHeader.numNodes;
		g_pNodes = (node_t *)memreallocOld(g_pNodes, sizeof(node_t), oldSize, newSize);
		g_iNodes = newSize;
		startId = oldSize;
		offSet = oldSize;
	}

	print(sprintf("FB Waypoints Version %i, %i nodes\n", fbHeader.versionNumber, fbHeader.numNodes));

	nodeFlags = (int *)memalloc(sizeof(int) * fbHeader.numNodes);

	/* create the nodes */
	for (int i = startId; i < g_iNodes; i++) {
		int iData = 0i;
		float flData = 0.0f;

		fread(file, (void*)&nodeFlags[i], 4); /* flags */
		fread(file, (void*)&iData, 4); /* script flags, should be 1 byte but it's padded. */

		fread(file, (void*)&flData, 4); /* origin x */
		g_pNodes[i].m_vecOrigin[0] = flData;
		fread(file, (void*)&flData, 4); /* origin y */
		g_pNodes[i].m_vecOrigin[1] = flData;
		fread(file, (void*)&flData, 4); /* origin z */
		g_pNodes[i].m_vecOrigin[2] = flData;
	}

	/* create the links */
	for (int i = startId; i < g_iNodes; i++) {
		int iData = 0i;
		fread(file, (void*)&iData, 2); /* neighbour count */
		//print(sprintf("%i neighbours\n", iData));

		g_pNodes[i].m_numNeighbours = iData;
		g_pNodes[i].m_pNeighbour = memalloc(sizeof(*g_pNodes[i].m_pNeighbour) * g_pNodes[i].m_numNeighbours);
		
		for (int j = 0i; j < g_pNodes[i].m_numNeighbours; j++) {
			fread(file, (void*)&iData, 2); /* neighbour index */
			g_pNodes[i].m_pNeighbour[j].m_iNode = offSet + iData;
			g_pNodes[i].m_pNeighbour[j].m_flCost = -1;
			g_pNodes[i].m_pNeighbour[j].m_iFlags = Way_FBFlagsToNC(nodeFlags[offSet + iData]);
		}
	}

	memfree(nodeFlags);
	fclose(file);
	return (true);
}

/** Data holding a PODBot Waypoint File Header */
typedef struct
{
	/* 8 bytes */
	int type1;
	int type2;
	int versionNumber;
	int numNodes;
	/* 32 bytes */
	int mapname1;
	int mapname2;
	int mapname3;
	int mapname4;
	int mapname5;
	int mapname6;
	int mapname7;
	int mapname8;
	/* 32 bytes */
	int author1;
	int author2;
	int author3;
	int author4;
	int author5;
	int author6;
	int author7;
	int author8;
} pb_header;

#define PBFL_USEBUTTON		0x00000001i
#define PBFL_ELEVATOR		0x00000002i
#define PBFL_CROUCH			0x00000004i
#define PBFL_CROSSING		0x00000008i
#define PBFL_GOAL			0x00000010i
#define PBFL_LADDER			0x00000020i
#define PBFL_RESCUE			0x00000040i
#define PBFL_CAMP			0x00000080i

static int
Way_PBFlagsToNC(int inputFlags)
{
	int outFlags = 0i;

	if (inputFlags & 1)
		outFlags |= LF_JUMP;

	return (outFlags);
}

/* Reads a PB version 5, 6, 7 file.

These are binary files and contain a lot of type sizes that we don't
have access to in QC. So we cannot just fread() into a struct.

The only flag between nodes is seemingly JUMP (1), however the
individual nodes themselves have defining info flags too including
ones for using buttons and ladders. Ideally we'd want to re-interpret
those into linkflags.
 */
bool
Way_ReadPBFile(string strFile, bool flush)
{
	int startId = 0i;
	int offSet = 0i;
	pb_header pbHeader;

	filestream file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("Way_ReadFile: unable to open ", strFile, "\n");
		return (false);
	}

	fread(file, (void*)&pbHeader, sizeof(pb_header));

	if (flush) {
		Nodes_Flush();
		g_iNodes = pbHeader.numNodes;
		g_pNodes = memalloc(sizeof(*g_pNodes) * g_iNodes);
	} else {
		int oldSize = g_iNodes;
		int newSize = g_iNodes + pbHeader.numNodes;
		g_pNodes = (node_t *)memreallocOld(g_pNodes, sizeof(node_t), oldSize, newSize);
		g_iNodes = newSize;
		startId = oldSize;
		offSet = oldSize;
	}

	print(sprintf("PB Waypoints Version %i, %i nodes\n", pbHeader.versionNumber, pbHeader.numNodes));

	for (int i = startId; i < g_iNodes; i++) {
		int neighbours = 0i;
		int index[8];
		float cost[8];
		int nFlags[8];
		int iData = 0i;
		float flData = 0.0f;

		/* make them all invalid */
		for (int n = 0i; n < 8i; n++) {
			index[n] = 65535;
		}

		if (pbHeader.versionNumber == 7) {
			fread(file, (void*)&iData, 4); /* number */
			fread(file, (void*)&iData, 4); /* flags */
			fread(file, (void*)&flData, 4); /* origin x */
			g_pNodes[i].m_vecOrigin[0] = flData;
			fread(file, (void*)&flData, 4); /* origin y */
			g_pNodes[i].m_vecOrigin[1] = flData;
			fread(file, (void*)&flData, 4); /* origin z */
			g_pNodes[i].m_vecOrigin[2] = flData;
			fread(file, (void*)&flData, 4); /* radius */
			g_pNodes[i].m_flRadius = flData;
			fread(file, (void*)&flData, 4); /* camp start x */
			fread(file, (void*)&flData, 4); /* camp start y */
			fread(file, (void*)&flData, 4); /* camp end x */
			fread(file, (void*)&flData, 4); /* camp end y */
			fread(file, (void*)&index[0], 2); /* index 1 */
			fread(file, (void*)&index[1], 2); /* index 2 */
			fread(file, (void*)&index[2], 2); /* index 3 */
			fread(file, (void*)&index[3], 2); /* index 4 */
			fread(file, (void*)&index[4], 2); /* index 5 */
			fread(file, (void*)&index[5], 2); /* index 6 */
			fread(file, (void*)&index[6], 2); /* index 7 */
			fread(file, (void*)&index[7], 2); /* index 8 */
			fread(file, (void*)&nFlags[0], 2); /* nFlags 1 */
			fread(file, (void*)&nFlags[1], 2); /* nFlags 2 */
			fread(file, (void*)&nFlags[2], 2); /* nFlags 3 */
			fread(file, (void*)&nFlags[3], 2); /* nFlags 4 */
			fread(file, (void*)&nFlags[4], 2); /* nFlags 5 */
			fread(file, (void*)&nFlags[5], 2); /* nFlags 6 */
			fread(file, (void*)&nFlags[6], 2); /* nFlags 7 */
			fread(file, (void*)&nFlags[7], 2); /* nFlags 8 */
			fread(file, (void*)&flData, 4); /* velocity 1 x */
			fread(file, (void*)&flData, 4); /* velocity 1 y */
			fread(file, (void*)&flData, 4); /* velocity 1 z */
			fread(file, (void*)&flData, 4); /* velocity 2 x */
			fread(file, (void*)&flData, 4); /* velocity 2 y */
			fread(file, (void*)&flData, 4); /* velocity 2 z */
			fread(file, (void*)&flData, 4); /* velocity 3 x */
			fread(file, (void*)&flData, 4); /* velocity 3 y */
			fread(file, (void*)&flData, 4); /* velocity 3 z */
			fread(file, (void*)&flData, 4); /* velocity 4 x */
			fread(file, (void*)&flData, 4); /* velocity 4 y */
			fread(file, (void*)&flData, 4); /* velocity 4 z */
			fread(file, (void*)&flData, 4); /* velocity 5 x */
			fread(file, (void*)&flData, 4); /* velocity 5 y */
			fread(file, (void*)&flData, 4); /* velocity 5 z */
			fread(file, (void*)&flData, 4); /* velocity 6 x */
			fread(file, (void*)&flData, 4); /* velocity 6 y */
			fread(file, (void*)&flData, 4); /* velocity 6 z */
			fread(file, (void*)&flData, 4); /* velocity 7 x */
			fread(file, (void*)&flData, 4); /* velocity 7 y */
			fread(file, (void*)&flData, 4); /* velocity 7 z */
			fread(file, (void*)&flData, 4); /* velocity 8 x */
			fread(file, (void*)&flData, 4); /* velocity 8 y */
			fread(file, (void*)&flData, 4); /* velocity 8 z */
			fread(file, (void*)&iData, 4); /* distance 1 */
			cost[0] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 2 */
			cost[1] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 3 */
			cost[2] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 4 */
			cost[3] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 5 */
			cost[4] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 6 */
			cost[5] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 7 */
			cost[6] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 8 */
			cost[7] = (float)iData;
			fread(file, (void*)&iData, 4); /* pointer */
		} else if (pbHeader.versionNumber == 6) {
			fread(file, (void*)&iData, 4); /* number */
			fread(file, (void*)&iData, 4); /* flags */
			fread(file, (void*)&flData, 4); /* origin x */
			g_pNodes[i].m_vecOrigin[0] = flData;
			fread(file, (void*)&flData, 4); /* origin y */
			g_pNodes[i].m_vecOrigin[1] = flData;
			fread(file, (void*)&flData, 4); /* origin z */
			g_pNodes[i].m_vecOrigin[2] = flData;
			fread(file, (void*)&flData, 4); /* radius */
			g_pNodes[i].m_flRadius = flData;
			fread(file, (void*)&flData, 4); /* camp start x */
			fread(file, (void*)&flData, 4); /* camp start y */
			fread(file, (void*)&flData, 4); /* camp end x */
			fread(file, (void*)&flData, 4); /* camp end y */
			fread(file, (void*)&index[0], 2); /* index 1 */
			fread(file, (void*)&index[1], 2); /* index 2 */
			fread(file, (void*)&index[2], 2); /* index 3 */
			fread(file, (void*)&index[3], 2); /* index 4 */
			fread(file, (void*)&index[4], 2); /* index 5 */
			fread(file, (void*)&index[5], 2); /* index 6 */
			fread(file, (void*)&index[6], 2); /* index 7 */
			fread(file, (void*)&index[7], 2); /* index 8 */
			fread(file, (void*)&iData, 4); /* distance 1 */
			cost[0] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 2 */
			cost[1] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 3 */
			cost[2] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 4 */
			cost[3] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 5 */
			cost[4] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 6 */
			cost[5] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 7 */
			cost[6] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 8 */
			cost[7] = (float)iData;
			fread(file, (void*)&iData, 4); /* pointer */
		} else if (pbHeader.versionNumber == 5) {
			fread(file, (void*)&iData, 4); /* number */
			fread(file, (void*)&iData, 4); /* flags */
			fread(file, (void*)&flData, 4); /* origin x */
			g_pNodes[i].m_vecOrigin[0] = flData;
			fread(file, (void*)&flData, 4); /* origin y */
			g_pNodes[i].m_vecOrigin[1] = flData;
			fread(file, (void*)&flData, 4); /* origin z */
			g_pNodes[i].m_vecOrigin[2] = flData;
			fread(file, (void*)&flData, 4); /* radius */
			g_pNodes[i].m_flRadius = flData;
			fread(file, (void*)&flData, 4); /* camp start x */
			fread(file, (void*)&flData, 4); /* camp start y */
			fread(file, (void*)&flData, 4); /* camp end x */
			fread(file, (void*)&flData, 4); /* camp end y */
			fread(file, (void*)&index[0], 2); /* index 1 */
			fread(file, (void*)&index[1], 2); /* index 2 */
			fread(file, (void*)&index[2], 2); /* index 3 */
			fread(file, (void*)&index[3], 2); /* index 4 */
			fread(file, (void*)&iData, 4); /* distance 1 */
			cost[0] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 2 */
			cost[1] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 3 */
			cost[2] = (float)iData;
			fread(file, (void*)&iData, 4); /* distance 4 */
			cost[3] = (float)iData;
			fread(file, (void*)&iData, 4); /* pointer */
		}

		/* check for valid neighbours */
		for (int n = 0i; n < 8i; n++) {
			if (index[n] != 65535) /* -1 */
				neighbours++;
		}

		g_pNodes[i].m_numNeighbours = neighbours;
		g_pNodes[i].m_pNeighbour = memalloc(sizeof(*g_pNodes[i].m_pNeighbour) * g_pNodes[i].m_numNeighbours);
		
		for (int j = 0i; j < g_pNodes[i].m_numNeighbours; j++) {
			g_pNodes[i].m_pNeighbour[j].m_iNode = offSet + index[j];
			g_pNodes[i].m_pNeighbour[j].m_flCost = cost[j];
			g_pNodes[i].m_pNeighbour[j].m_iFlags = Way_PBFlagsToNC(nFlags[j]);
		}
	}
	fclose(file);
	return (true);
}



/* Reads a Jumbot file.

Plaintext that's simple to parse, however does not store any node
connections. That's because Jumbot was specific to Half-Life and
the AI was smart enough to know how to navigate using only those
helper points.

We count all lines until we hit the end character '$' and then parse
each line - which contains the info: [id] [flag] ([position])

We then link those in linear order. There's probably better ways of
doing that so that'll be an area of research.
*/
bool
Way_ReadJumbotFile(string strFile, bool flush)
{
	int startId = 0i;
	int offSet = 0i;
	int nodeCount = 0i;
	string line;

	filestream file = fopen(strFile, FILE_READ);
	if (file < 0) {
		print("Way_ReadFile: unable to open ", strFile, "\n");
		return (false);
	}

	/* read the number of waypoints */
	while ((line = fgets(file))) {
		if (line != "$") {
			nodeCount++;
		}
	}
	fseek(file, 0);

	print(sprintf("Jumpbot Waypoints Version %i, %i nodes\n", 1i, nodeCount));

	if (flush) {
		Nodes_Flush();
		g_iNodes = nodeCount;
		g_pNodes = memalloc(sizeof(*g_pNodes) * g_iNodes);
	} else {
		int oldSize = g_iNodes;
		int newSize = g_iNodes + nodeCount;
		g_pNodes = (node_t *)memreallocOld(g_pNodes, sizeof(node_t), oldSize, newSize);
		g_iNodes = newSize;
		startId = oldSize;
		offSet = oldSize;
	}

	for (int i = startId; i < g_iNodes; i++) {
		float length = strlen(argv(5));
		line = fgets(file);
		tokenize(line);
		g_pNodes[i].m_vecOrigin[0] = stof(argv(3));
		g_pNodes[i].m_vecOrigin[1] = stof(argv(4));
		g_pNodes[i].m_vecOrigin[2] = stof(argv(5));
		g_pNodes[i].m_flRadius = 32.0f;

		if (i > startId) {
			NodeEdit_LinkNodes(&g_pNodes[i], &g_pNodes[i-1]);
			NodeEdit_LinkNodes(&g_pNodes[i-1], &g_pNodes[i]);
		}
	}

	fclose(file);
	return (true);
}
