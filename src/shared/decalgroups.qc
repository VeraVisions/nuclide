/* Copyright (c) 2022, Vera Visions, L.L.C.  All rights reserved. */

#ifdef CLIENT
typedef struct
{
	string materials;
	int members;
} decalGroup_t;

decalGroup_t *g_decalgroup;
#endif

static int g_decalgroup_count;
var hashtable g_hashdecalgroup;

#ifdef CLIENT
static void
DecalGroups_CountLine(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		braced--;

		if (t_name)
				g_decalgroup_count++;

		t_name = "";
		break;
	default:
		/* new definition starts */
		if (c == 1 && braced == 0) {
			t_name = strtolower(line);
		}
	}
	return;
}
#endif

static void
DecalGroups_Parse(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;
	static int i;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		/* increase counter when done */
		if (t_name) {
			hash_add(g_hashdecalgroup, t_name, (int)i);
			g_decalgroup_count++;
			i++;
		}

		braced--;
		t_name = "";
		break;
	default:
		if (braced == 1 && t_name != "") {
		/* the server doesn't need to know any of this */
#ifdef CLIENT
			/* valid material + weight combo */
			if (c == 2) {
				if (g_decalgroup[i].members > 0)
					g_decalgroup[i].materials = strcat(g_decalgroup[i].materials, ";", argv(0));
				else
					g_decalgroup[i].materials = argv(0);

				g_decalgroup[i].members++;
			}
#endif
		} else if (braced == 0) {
			t_name = strtolower(line);
		}
	}
}

void
DecalGroups_Init(void)
{
	filestream fh;
	string line;

	g_decalgroup_count = 0i;
	print("--------- Initializing Decal Groups ----------\n");

	/* create the hash-table if it doesn't exist */
	if (!g_hashdecalgroup) {
		g_hashdecalgroup = hash_createtab(2, EV_STRING | HASH_REPLACE);
	}

	fh = fopen("scripts/decals.txt", FILE_READ);
	if (fh < 0) {
		print("^1[DECALS] Can't find scripts/decals.txt\n");
		return;
	}

#ifdef CLIENT
	/* count content */
	while ((line = fgets(fh))) {
		DecalGroups_CountLine(line);
	}

	/* alocate our stuff */
	g_decalgroup = (decalGroup_t *)memalloc(sizeof(decalGroup_t) * g_decalgroup_count);

	/* Defaults */
	for (int i = 0; i < g_decalgroup_count; i++) {
		g_decalgroup[i].materials = "";
		g_decalgroup[i].members = 0;
	}
#endif

	g_decalgroup_count = 0;
	fseek(fh, 0);

	while ((line = fgets(fh))) {
		/* when we found it, quit */
		DecalGroups_Parse(line);
	}

	fclose(fh);

#if 0
#ifdef CLIENT
	for (int i = 0; i < g_decalgroup_count; i++) {
		print(sprintf("%i (members: %i) %s\n", i, g_decalgroup[i].members, g_decalgroup[i].materials));
	}
#endif
#endif

	print(sprintf("decal groups initialized with %i entries.\n", g_decalgroup_count));
}

#ifdef CLIENT
void
DecalGroups_Precache(void)
{
	if (g_client_world_loaded == false)
		return;

	for (int i = 0; i < g_decalgroup_count; i++) {
		int c = tokenizebyseparator(g_decalgroup[i].materials, ";");

		for (int x = 0; x < c; x++) {
			Decal_Precache(argv(x));
		}
		
	}
}

void
DecalGroups_PlaceGroupID(int index, vector org)
{
	/* on the client we only need to go ahead and place the final decal */
	int r;

	/* get all materials of the group */
	tokenizebyseparator(g_decalgroup[index].materials, ";");

	/* pick a random one. TODO: respects weights */
	r = random(0, (float)g_decalgroup[index].members);

	/* place a single one. */
	Decals_Place(org, argv(r));
}
#endif

int
DecalGroups_NumForName(string group)
{
	return (int)hash_get(g_hashdecalgroup, group, -1);
}

void
DecalGroups_Place(string group, vector org)
{
	int index = -1i;

	if (g_decalgroup_count <= 0i) {
		return;
	}

	index = (int)hash_get(g_hashdecalgroup, strtolower(group), -1i);

	if (index == -1i) {
		return;
	}

#ifdef SERVER
	/* on the server we only need to tell the clients in the PVS
	   to go ahead and place a decal of id X at a certain position */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_DECALGROUP);
	WriteByte(MSG_MULTICAST, index);
	WriteCoord(MSG_MULTICAST, org[0]);
	WriteCoord(MSG_MULTICAST, org[1]);
	WriteCoord(MSG_MULTICAST, org[2]);
	multicast(org, MULTICAST_PVS);
#else
	DecalGroups_PlaceGroupID(index, org);
#endif
}

#ifdef CLIENT
void
DecalGroups_Receive(void)
{
	int index;
	vector org;

	index = readbyte();
	org[0] = readcoord();
	org[1] = readcoord();
	org[2] = readcoord();
	DecalGroups_PlaceGroupID(index, org);
}
#endif
