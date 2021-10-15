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
	if (g_breakmodel) {
		memfree(g_breakmodel);
	}

	g_propdata_count = 0;
	g_hashpropdata = 0;
	g_breakmodel_count = 0;
	g_hashbreakmodel = 0;
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
	case "breakable_particle":
		g_propdata[i].breakable_particle = argv(1);
		break;
	case "breakable_model":
		g_propdata[i].breakable_model = argv(1);
		break;
	case "breakable_count":
		g_propdata[i].breakable_count = stoi(argv(1));
		break;
	}
}

void
BreakModel_ParseField(int i, int a)
{
	if (a == 2) {
		g_breakmodel[i].data = sprintf("%s%S %S\n", g_breakmodel[i].data, argv(0), argv(1)); 
	}
};

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
		} else if (braced == 1 && key != "BreakableModels") {
			/* name/identifer of our message */
			t_name = strtolower(key);
			
			if (t_name == "prop_data") {
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
		if (PropData_Parse(index, line, modelname) == TRUE) {
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

int
PropData_Load(string type)
{
	int index;

	if (!type)
		return -1;

	type = strtolower(type);

	index = (int)hash_get(g_hashpropdata, type, -1);

	if (index < 0) {
		crossprint(sprintf("^1 PropData_Load: type %s is not defined\n", type));
		return -1;
	} else {
		return index;
	}
}

/* stripped down ParseLine that just counts how many slots we have to allocate */
void
PropData_CountLine(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;
	static int inmodel = FALSE;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		braced--;

		/* move out of BreakableModels */
		if (inmodel  == TRUE && braced == 1)
			inmodel = FALSE;

		t_name = "";

		/* done */
		if (braced == 0)
			return;
		break;
	default:
		if (key == "") {
			break;
		} else if (braced == 2 && t_name != "" && inmodel == FALSE) {
			
		} else if (braced == 3 && t_name != "" && inmodel == TRUE) {
			
		} else if (braced == 1) {
			/* BreakableModels get parsed differently */
			if (key == "BreakableModels") {
				inmodel = TRUE;
			} else {
				g_propdata_count++;
			}
		} else if (braced == 2 && inmodel == TRUE) {
			g_breakmodel_count++;
		}
	}
	return;
}

int
PropData_ParseLine(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;
	static int inmodel = FALSE;
	static int i_p = -1;
	static int i_b = -1;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		braced--;

		/* move out of BreakableModels */
		if (inmodel == TRUE && braced == 1)
			inmodel = FALSE;

		t_name = "";

		/* done */
		if (braced == 0)
			return (1);
		break;
	default:
		if (key == "") {
			break;
		} else if (braced == 2 && t_name != "" && inmodel == FALSE) {
			PropData_ParseField(i_p, c);
		} else if (braced == 3 && t_name != "" && inmodel == TRUE) {
			BreakModel_ParseField(i_b, c);
		} else if (braced == 1) {
			/* BreakableModels get parsed differently */
			if (key == "BreakableModels") {
				inmodel = TRUE;
			} else {
				i_p++;
				g_propdata[i_p].name = strtolower(key);
				t_name = g_propdata[i_p].name;
				hash_add(g_hashpropdata, g_propdata[i_p].name, (int)i_p);
			}
		} else if (braced == 2 && inmodel == TRUE) {
			i_b++;
			g_breakmodel[i_b].name = strtolower(key);
			t_name = g_breakmodel[i_b].name;
			hash_add(g_hashbreakmodel, g_breakmodel[i_b].name, (int)i_b);
		}
	}
	return (0);
}

void
PropData_Init(void)
{

	filestream fh;
	string line;
	int index;

	/* remove old data */
	PropData_Shutdown();

	index = g_propdata_count;

	/* create the hash-table if it doesn't exist */
	if (!g_hashpropdata) {
		g_hashpropdata = hash_createtab(2, HASH_ADD);
		g_hashbreakmodel = hash_createtab(2, HASH_ADD);
	}

	/* Defaults go here */

	fh = fopen("scripts/propdata.txt", FILE_READ);
	if (fh < 0) {
		print("^1[PROPDATA] Can't find propdata.txt\n");
		return;
	}

	/* count content */
	while ((line = fgets(fh))) {
		PropData_CountLine(line);
	}

	/* alocate our stuff */
	g_propdata = (propdata_t *)memalloc(sizeof(propdata_t) * g_propdata_count);
	g_breakmodel = (breakmodel_t *)memalloc(sizeof(breakmodel_t) * g_breakmodel_count);

	fseek(fh, 0);

	while ((line = fgets(fh))) {
		/* when we found it, quit */
		PropData_ParseLine(line);
	}
	fclose(fh);
}

/* we can only tokenize one thing at a time, so we save the type for the current
   entity away for later, so we can parse it properly by then when we've exited the
   SpawnKey loop. Using a global will save us some memory at least */
void
PropData_SetStage(string type)
{
	g_curPropData = type;
}

int
PropData_Finish(void)
{
	string toload = g_curPropData;
	g_curPropData = __NULL__;

	if (toload) {
		return PropData_Load(toload);
	} else {
		return -1;
	}

}

/* BreakModel related helper API */
void
BreakModel_Spawn(vector smins, vector smaxs, vector dir, float speed, int count, string type)
{
	int index;
	index = (int)hash_get(g_hashbreakmodel, type, -1);

	if (index < 0) {
		crossprint(sprintf("^1 BreakModel_Spawn: type %s is not defined\n", type));
		return;
	}

	float x = tokenize(g_breakmodel[index].data);
	int modelcount = x / 2;

	for (int i = 0; i < count; i++) {
		vector endpos;
		string mname;
		float fadetime;
		entity gib;
		int r;

		/* pick a model between 0 and num) */
		r = floor(random(0, modelcount));

		/* two entries, always have to skip by 2 */
		mname = argv((r * 2));
		fadetime = stof(argv((r * 2) + 1));

		endpos[0] = smins[0] + ( random() * ( smaxs[0] - smins[0] ) );
		endpos[1] = smins[1] + ( random() * ( smaxs[1] - smins[1] ) );
		endpos[2] = smins[2] + ( random() * ( smaxs[2] - smins[2] ) );

		gib = spawn();
		setmodel(gib, mname);
		setsize(gib, [0,0,0], [0,0,0]);
		setorigin(gib, endpos);
		makevectors(dir);
		gib.velocity = v_forward * speed;
		gib.avelocity = vectoangles(gib.velocity);
		gib.movetype = MOVETYPE_BOUNCE;

		#ifdef CLIENT
			gib.drawmask = MASK_ENGINE;
		#endif
	}
}
