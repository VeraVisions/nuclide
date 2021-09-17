/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

void
PropData_Shutdown(void)
{
	if (g_propdata) {
		memfree(g_propdata);
	}

	g_propdata_count = 0;
	g_hashpropdata = 0;
}

void
PropData_Init(void)
{
	PropData_Shutdown();
}

__variant
Prop_GetInfo(int i, int type)
{
	switch (type)
	{
	case PROPINFO_HEALTH:
		return (__variant)g_propdata[i].health;
	case PROPINFO_FLAGS:
		return (__variant)g_propdata[i].flags;
	case PROPINFO_DMG_BULLET:
		return (__variant)g_propdata[i].damage_bullets;
	case PROPINFO_DMG_MELEE:
		return (__variant)g_propdata[i].damage_melee;
	case PROPINFO_DMG_EXPLOSIVE:
		return (__variant)g_propdata[i].damage_explosive;
	case PROPINFO_EXPLOSIVE_DMG:
		return (__variant)g_propdata[i].explosive_damage;
	case PROPINFO_EXPLOSIVE_RADIUS:
		return (__variant)g_propdata[i].explosive_radius;
	case PROPINFO_BREAKMODEL:
		return (__variant)g_propdata[i].breakable_model;
	case PROPINFO_BREAKCOUNT:
		return (__variant)g_propdata[i].breakable_count;
	default:
		return __NULL__;
	}
}

void
PropData_ParseField(int i, int a)
{
	switch (argv(0)) {
	case "base":
		g_propdata[i].base = argv(1);
		break;
	case "blockLOS":
		g_propdata[i].flags |= PDFL_BLOCKLOS;
		break;
	case "AIWalkable":
		g_propdata[i].flags |= PDFL_AIWALKABLE;
		break;
	case "allow_static":
		g_propdata[i].flags |= PDFL_ALLOWSTATIC;
		break;
	case "dmg.bullets":
		g_propdata[i].damage_bullets = stof(argv(1));
		break;
	case "dmg.club":
		g_propdata[i].damage_melee = stof(argv(1));
		break;
	case "dmg.explosive":
		g_propdata[i].damage_explosive = stof(argv(1));
		break;
	case "health":
		g_propdata[i].health = stof(argv(1));
		break;
	case "explosive_damage":
		g_propdata[i].explosive_damage = stof(argv(1));
		break;
	case "explosive_radius":
		g_propdata[i].explosive_radius = stof(argv(1));
		break;
	case "breakable_model":
		g_propdata[i].breakable_model = argv(1);
		break;
	case "breakable_count":
		g_propdata[i].breakable_count = stof(argv(1));
		break;
	}
}

/* concerned with dealing with keeping track of braces and parsing lines */
int
PropData_Parse(int i, string line, string type)
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
		t_name = "";

		/* done */
		if (braced == 0)
			return (1);
		break;
	default:
		if (braced == 2 && t_name != "") {
			PropData_ParseField(i, c);
		} else if (braced == 1) {
			/* name/identifer of our message */
			t_name = strtolower(key);
			
			if (t_name == type) {
				/* I guess it's what we want */
				g_propdata[i].name = type;
			} else {
				/* not what we're looking for */
				t_name = "";
			}
		}
	}
	return (0);
}

/* goes through and looks for a specifically named propdata type inside the scripts dir */
int
PropData_Load(string type)
{
	searchhandle sh;
	filestream fh;
	string line;
	int index;

	if (!type)
		return -1;

	index = g_propdata_count;
	type = strtolower(type);

	/* create the hash-table if it doesn't exist */
	if (!g_hashpropdata) {
		g_hashpropdata = hash_createtab(2, HASH_ADD);
	}

	/* check if it's already cached */
	for (int i = 0; i < g_propdata_count; i++) {
		if (type == g_propdata[i].name) {
			return i;
		}
	}

	g_propdata_count++;
	g_propdata = (propdata_t *)memrealloc(g_propdata, sizeof(propdata_t), index, g_propdata_count);

	/* Defaults go here */

	sh = search_begin("scripts/propdata*.txt", TRUE, TRUE);

	for (int i = 0; i < search_getsize(sh); i++) {
		fh = fopen(search_getfilename(sh, i), FILE_READ);
		if (fh < 0) {
			continue;
		}

		while ((line = fgets(fh))) {
			/* when we found it, quit */
			if (PropData_Parse(index, line, type) == TRUE) {
				search_end(sh);
				fclose(fh);
				hash_add(g_hashpropdata, type, (int)index);
				return index;
			}
		}
		fclose(fh);
	}

	print("^1[PROPDATA] No type found for ");
	print(type);
	print("\n");

	search_end(sh);
	return -1;
}

/* goes through and looks for a specifically named propdata type inside the scripts dir */
int
PropData_ForModel(string modelname)
{
	filestream fh;
	string line;
	int index;

	if (!modelname)
		return -1;

	if (substring(modelname, 0, 1) == "*")
		return -1;

	index = g_propdata_count;
	modelname = strtolower(modelname);

	dprint("[PROPDATA] Loading model propdata ");
	dprint(modelname);
	dprint("\n");

	/* create the hash-table if it doesn't exist */
	if (!g_hashpropdata) {
		g_hashpropdata = hash_createtab(2, HASH_ADD);
	}

	/* check if it's already cached */
	for (int i = 0; i < g_propdata_count; i++) {
		if (modelname == g_propdata[i].name) {
			return i;
		}
	}

	g_propdata_count++;
	g_propdata = (propdata_t *)memrealloc(g_propdata, sizeof(propdata_t), index, g_propdata_count);

	/* Defaults go here */

	fh = fopen(strcat(modelname, ".propdata"), FILE_READ);
	if (fh < 0) {
		dprint(sprintf("Can't find propdata for model %s\n", modelname));
		return -1;
	}
	while ((line = fgets(fh))) {
		/* when we found it, quit */
		if (PropData_Parse(index, line, "prop_data") == TRUE) {
			fclose(fh);
			hash_add(g_hashpropdata, modelname, (int)index);
			return index;
		}
	}
	fclose(fh);

	dprint("^1[PROPDATA] No type found for ");
	dprint(modelname);
	dprint("\n");

	return -1;
}

/* we can only tokenize one thing at a time, so we save the type for the current
   entity away for later, so we can parse it properly by then when we've exited the
   SpawnKey loop. Using a global will save us some memory at least */
void
PropData_SetStage(string type)
{
	g_curPropData = type;
}

void
PropData_Finish(void)
{
	PropData_Load(g_curPropData);
	g_curPropData = "";
}
