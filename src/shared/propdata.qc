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

/*
#define PROPDATA_DYNAMIC

Your game can define PRODATA_DYNAMIC in its progs.src if you want an unpredictable amount of prop data.
Other than that, you can increase the value of PROPDATA_MAX.

We switched to up-front allocation because QCLIB fragments memory like hell as there's
no real garbage collector to speak of
*/

#ifndef PROPDATA_DYNAMIC
	#ifndef PROPDATA_MAX
		#define PROPDATA_MAX 128
	#endif
#endif

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
	case PROPINFO_SKIN:
		return (__variant)g_propdata[i].breakable_skin;
	case PROPINFO_MASS:
		return (__variant)g_propdata[i].mass;
	case PROPINFO_DAMPING_LINEAR:
		return (__variant)g_propdata[i].damping_linear;
	case PROPINFO_DAMPING_ANGULAR:
		return (__variant)g_propdata[i].damping_angular;
	case PROPINFO_INERTIA:
		return (__variant)g_propdata[i].inertia;
	case PROPINFO_VOLUME:
		return (__variant)g_propdata[i].volume;
	case PROPINFO_SURFACEPROP:
		return (__variant)g_propdata[i].surfaceprop;
	default:
		return __NULL__;
	}
}

void
PropData_ParseField(int i, int a)
{
	switch (argv(0)) {
	case "name":
		g_propdata[i].name = argv(1);
		break;
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
	case "breakable_skin":
		g_propdata[i].breakable_skin = stof(argv(1));
		break;
	case "mass":
		g_propdata[i].mass = stof(argv(1));
		break;
	case "damping":
		g_propdata[i].damping_linear = stof(argv(1));
		break;
	case "rotdamping":
		g_propdata[i].damping_angular = stof(argv(1));
		break;
	case "inertia":
		g_propdata[i].inertia = stof(argv(1));
		break;
	case "volume":
		g_propdata[i].volume = stof(argv(1));
		break;
	case "surfaceprop":
		g_propdata[i].surfaceprop = argv(1);
		break;
	}
}

void
BreakModel_ParseField(int i, int a)
{
	if (a == 2) {
		string mdl, fadetime;
		mdl = argv(0);
		fadetime = argv(1);
		g_breakmodel[i].data = sprintf("%s%S %S\n", g_breakmodel[i].data, mdl, fadetime);
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

/* specific to parsing strings from binary .phy files */
int
PropData_ParsePhyFile(int i, string line, string type)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0i;

	static string gibModel = "";
	static string gibFadeTime = "";

	c = tokenize(line);

	for (int x = 0i; x < c; x++) {
		key = argv(x);

		switch(key) {
		case "{":
			braced++;
			break;
		case "}":
			if (braced == 1i && t_name == "break") {
				int bID = g_breakmodel_count; /* !!! increment after loading phy file! */
				g_breakmodel[bID].modelindex = getmodelindex(type);
				g_breakmodel[bID].name = g_propdata[i].name;
				g_breakmodel[bID].data = sprintf("%s%S %S\n", g_breakmodel[bID].data, gibModel, gibFadeTime);
				hash_add(g_hashbreakmodel, g_breakmodel[bID].name, (int)bID);
				g_propdata[i].breakable_model = g_breakmodel[bID].name;
				g_propdata[i].breakable_count++;
				gibModel = "";
				gibFadeTime = 0.0f;
			}
			braced--;
			t_name = "";
			break;
		default:
			if (braced == 1i && t_name == "solid") {
				PropData_ParseField(i, c);
			} else if (braced == 1i && t_name == "break") {
				switch (key) {
				case "model":
					gibModel = strcat("models/", argv(x+1), ".mdl");
					break;
				case "fadetime":
					gibFadeTime = argv(x+1);
					break;
				}
			} else if (braced == 0i) {
				t_name = strtolower(key);
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

	if (!g_propdata_count)
		return -1;

	if (!modelname)
		return -1;

	if (substring(modelname, 0, 1) == "*")
		return -1;

	index = g_propdata_count;
	modelname = strtolower(modelname);

	//print("[PROPDATA] Loading model propdata ");
	//print(modelname);
	//print("\n");

	/* create the hash-table if it doesn't exist */
	if (!g_hashpropdata) {
		g_hashpropdata = hash_createtab(2, HASH_ADD);
	}

	/* check if it's already cached */
	{
		int cache;
		cache = (int)hash_get(g_hashpropdata, modelname, -1);
		
		if (cache >= 0)
			return cache;
	}

	g_propdata_count++;

#ifdef PROPDATA_DYNAMIC
	g_propdata = (propdata_t *)memrealloc(g_propdata, sizeof(propdata_t), index, g_propdata_count);
#else
	if (g_propdata_count >= PROPDATA_MAX) {
		NSError("PropData_ForModel: Reached PROPDATA_MAX (%d)", PROPDATA_MAX);
		return -1i;
	}
#endif

	/* Defaults go here */

	fh = fopen(strcat(modelname, ".propdata"), FILE_READ);
	if (fh < 0) {
		/* try the Source Engine version */
		fh = fopen(Util_ChangeExtension(modelname, "phy"), FILE_READ);

		if (fh < 0) {
			g_propdata_count--;
			NSWarning("No PropData for model %S", modelname);
			return -1;
		}

		int fileSize;
		int phyID;
		int numSolids;
		int fileSum;
		int filePos = 0i;
		int surfaceSize;

		filePos = fread(fh, (void*)&fileSize, 4i); /* header size, sanity check */

		if (fileSize != 16i) {
			error("Only .phy files from Source are supported.");
		}

		filePos = fread(fh, (void*)&phyID, 4i); /* some header id */
		filePos = fread(fh, (void*)&numSolids, 4i); /* read our number of solids. */
		filePos = fread(fh, (void*)&fileSum, 4i);

		//print(sprintf("num fileSize: %i\n", fileSize));
		//print(sprintf("num phyID: %i\n", phyID));
		//print(sprintf("num numSolids: %i\n", numSolids));
		//print(sprintf("num fileSum: %i\n", fileSum));

		/* HACK: We won't support ragdolls, for now. */
		if (numSolids > 1)
			return -1;

		/* we skip over all these to get to the bottom of the file */
		for (int i = 0i; i < numSolids; i++) {
			filePos = fread(fh, (void*)&surfaceSize, 4);
			filePos = fseek(fh, filePos + surfaceSize + 16);
		}

		/* now comes the propdata */
		while ((line = fgets(fh))) {
			//printf(line);
			//print("\n");
			PropData_ParsePhyFile(index, line, modelname);
		}

		/* push up the breakmodel count by one if we've written into it */
		{
			string breakModel = Prop_GetInfo(index, PROPINFO_BREAKMODEL);

			if (breakModel != "") {
				int bID = (int)hash_get(g_hashbreakmodel, Prop_GetInfo(index, PROPINFO_BREAKMODEL), -1);

				if (bID != -1) {
					if (g_breakmodel[bID].data) {
						g_breakmodel[bID].physics = true;
						g_breakmodel_count++;
					}
				}
			}
		}

		//print(sprintf("Added %S at id %i with name %S\n", modelname, index, g_propdata[index].name));
		hash_add(g_hashpropdata, modelname, (int)index);
		return index;

		//error(sprintf("phy file (size %i): size: %i id: %i numSolids: %i\n", fsize(fh), fileSize, phyID, numSolids));
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

	NSError("No type found for %s", modelname);
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
		NSError("PropData type %S is not defined.", type);
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

	InitStart();

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
		NSWarning("Missing file scripts/propdata.txt");
		InitEnd();
		return;
	}

	/* count content */
	while ((line = fgets(fh))) {
		PropData_CountLine(line);
	}

#ifdef PROPDATA_DYNAMIC
	/* alocate our stuff */
	g_propdata = (propdata_t *)memalloc(sizeof(propdata_t) * g_propdata_count);
	g_breakmodel = (breakmodel_t *)memalloc(sizeof(breakmodel_t) * g_breakmodel_count);
#else
	/* alocate our stuff */
	g_propdata = (propdata_t *)memalloc(sizeof(propdata_t) * PROPDATA_MAX);
	g_breakmodel = (breakmodel_t *)memalloc(sizeof(breakmodel_t) * PROPDATA_MAX);
	NSLog("...allocated %d bytes for prop data.", sizeof(propdata_t) * PROPDATA_MAX);
	NSLog("...allocated %d bytes for breakmodels.", sizeof(breakmodel_t) * PROPDATA_MAX);
#endif

	fseek(fh, 0);

	while ((line = fgets(fh))) {
		/* when we found it, quit */
		PropData_ParseLine(line);
	}
	fclose(fh);

	/* now let's precache all of our breakmodel units.
	   first we gotta interate through each cached breakmodel line */
	for (int i = 0; i < g_breakmodel_count; i++) {
		float x = tokenize(g_breakmodel[i].data);
		int r = (int)(x/2);

		/* now we're getting the individual 2-part segments (model, fadetime) */
		for (int b = 0; b < r; b++) {
			string mname = argv(b*2);
			int p = tokenizebyseparator(mname, "#"); /* special attribute character */

			/* either precache the first part, or whole part */
			if (p > 1) {
				mname = argv(0);
			}

			precache_model(mname);

			/* gotta tokenize our inputs again */
			x = tokenize(g_breakmodel[i].data);
		}

		/* We're making assumptions here, but most physics props have their
		   breakmodels defined along the model. */
		g_breakmodel[i].physics = false;
	}

	g_breakmodel_end = g_breakmodel_count;
	InitEnd();
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
#ifdef CLIENT
void
BreakModel_SpawnID(vector smins, vector smaxs, vector dir, float speed, int count, int index)
{
	float x = tokenize(g_breakmodel[index].data);
	int modelcount = x / 2;
	bool usePhysics = g_breakmodel[index].physics;

	//print(sprintf("breaking into %i models\n", modelcount));

	for (int i = 0; i < count; i++) {
		vector endpos;
		string mname;
		string fullline;
		float fadetime;
		NSDebris gib;
		int p;
		int bodygroup = 0;
		vector rendercolor = [1,1,1];
		float renderamt = 1.0f;
		float rendermode = RM_NORMAL;
		float renderfx = RFX_NORMAL;
		string impactDecal = __NULL__;

		/* two entries, always have to skip by 2 */
		if (modelcount < count) {
			int r = floor(random(0, modelcount));
			fullline = mname = argv((r * 2));
			fadetime = stof(argv((r * 2) + 1));

		} else {
			fullline = mname = argv((i * 2));
			fadetime = stof(argv((i * 2) + 1));
		}

		p = tokenizebyseparator(mname, "#");

		/* special char # detected to designate model submodel count */
		if (p > 1) {
			mname = argv(0);

			/* iterate over all the segments */
			for (int g = 1; g < p; g++) {
				string segment = argv(g);
				int m = tokenizebyseparator(segment, "=");

				/* check if there's an assignment */
				if (m == 2) {
					string key = argv(0);
					string value = argv(1);

					switch (key) {
					case "submodels":
						bodygroup = (int)floor(random(0, stof(value)));
						break;
					case "rendercolor":
						rendercolor = stov(value);
						break;
					case "renderamt":
						renderamt = stof(value);
						break;
					case "rendermode":
						rendermode = stof(value);
						break;
					case "renderfx":
						renderfx = stof(value);
						break;
					case "impactdecal":
						impactDecal = value;
						break;
					default:
						NSError("Unrecognized model attribute %S with value %S",
							key, value);
					}
				}

				/* start the line anew */
				p = tokenizebyseparator(fullline, "#");
			}
		}

		endpos[0] = smins[0] + ( random() * ( smaxs[0] - smins[0] ) );
		endpos[1] = smins[1] + ( random() * ( smaxs[1] - smins[1] ) );
		endpos[2] = smins[2] + ( random() * ( smaxs[2] - smins[2] ) );

		gib = spawn(NSDebris);
		gib.SetModel(mname);
		gib.SetBody(bodygroup);
		gib.SetRenderColor(rendercolor);
		gib.SetRenderAmt(renderamt);
		gib.SetRenderMode(rendermode);
		gib.SetRenderFX(renderfx);
		gib.SetSize([-8,-8,-8],[8,8,8]);
		gib.SetOrigin(endpos);
		gib.SetScale(1.0f);

		if (usePhysics == false) {
			makevectors(dir);
			gib.velocity = (v_forward * speed) * 0.75;
			gib.velocity[0] += (random() - 0.5) * (speed * 0.25);
			gib.velocity[1] += (random() - 0.5) * (speed * 0.25);
			gib.velocity[2] += (random() - 0.5) * (speed * 0.25);
			gib.SetAngularVelocity([300,300,300]);
			gib.SetMovetype(MOVETYPE_BOUNCE);
			gib.SetSolid(SOLID_NOT);
		} else {
			gib.SetMovetype(MOVETYPE_PHYSICS);
			gib.SetSolid(SOLID_NOT);
			gib.mass = 1.0f;
			gib.friction = 1.0f;
			gib.bouncefactor = 0.9f;
			gib.bouncestop = 0.1f / cvar("sv_gravity");
			gib.geomtype = GEOMTYPE_TRIMESH;
			gib.ApplyForceOffset(dir * speed, endpos);
		}

		gib.ScheduleThink(NSEntity::Destroy, fadetime);
		gib.SetImpactDecal(impactDecal);
		//print(sprintf("%S\n", mname));

		#ifdef CLIENT
			gib.drawmask = MASK_ENGINE;
		#endif

		/* re-calculate the tokenization */
		x = tokenize(g_breakmodel[index].data);
	}
}

void
BreakModel_Receive(void)
{
	vector smins, smaxs, dir;
	float speed;
	int count;
	int index;

	index = readbyte();
	smins[0] = readcoord();
	smins[1] = readcoord();
	smins[2] = readcoord();

	smaxs[0] = readcoord();
	smaxs[1] = readcoord();
	smaxs[2] = readcoord();

	dir[0] = readcoord();
	dir[1] = readcoord();
	dir[2] = readcoord();

	speed = readfloat();
	count = readbyte();

	/* sanity check */
	if (index >= g_breakmodel_count) {
		NSError("Unable to spawn breakmodel of id %i. Not cached on client. (Client knows of %i)", index, g_breakmodel_count);
		return;
	}

	NSLog("BreakModel: i: %i max: %i name: %S", index, g_breakmodel_count, g_breakmodel[index].name);

	BreakModel_SpawnID(smins, smaxs, dir, speed, count, index);
}

void
BreakModel_ReceiveClientData(void)
{
	int addToCount = readbyte();

	for (int i = 0; i < addToCount; i++) {
		string modelName = modelnameforindex(readshort());
		PropData_ForModel(modelName);
	}
}

#else
void
BreakModel_SendClientData(entity targetEnt)
{
	int extraCount = g_breakmodel_count - g_breakmodel_end;
	int startOffset = g_breakmodel_end;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BREAKMODELDATA);
	WriteByte(MSG_MULTICAST, g_breakmodel_count - g_breakmodel_end);

	//print(sprintf("%i %i\n", g_breakmodel_end, g_breakmodel_count));

	for (int i = g_breakmodel_end; i < g_breakmodel_count; i++) {
		WriteShort(MSG_MULTICAST, g_breakmodel[i].modelindex);
	}

	msg_entity = targetEnt;
	multicast(g_vec_null, MULTICAST_ONE_R);
}

void
BreakModel_Spawn(vector smins, vector smaxs, vector dir, float speed, int count, string type)
{
	int index;
	vector pvsPosition;
	index = (int)hash_get(g_hashbreakmodel, type, -1);

	if (index == -1)
		return;

	pvsPosition = (smins + ( 0.5 * ( smaxs - smins )));

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BREAKMODEL);
	WriteByte(MSG_MULTICAST, index);
	WriteCoord(MSG_MULTICAST, smins[0]);
	WriteCoord(MSG_MULTICAST, smins[1]);
	WriteCoord(MSG_MULTICAST, smins[2]);
	WriteCoord(MSG_MULTICAST, smaxs[0]);
	WriteCoord(MSG_MULTICAST, smaxs[1]);
	WriteCoord(MSG_MULTICAST, smaxs[2]);
	WriteCoord(MSG_MULTICAST, dir[0]);
	WriteCoord(MSG_MULTICAST, dir[1]);
	WriteCoord(MSG_MULTICAST, dir[2]);
	WriteFloat(MSG_MULTICAST, speed);
	WriteByte(MSG_MULTICAST, count);
	multicast(pvsPosition, MULTICAST_PVS);
}

void
BreakModel_Entity(NSSurfacePropEntity target, vector dir, float speed)
{
	string type = Prop_GetInfo(target.m_iPropData, PROPINFO_BREAKMODEL);
	int count = Prop_GetInfo(target.m_iPropData, PROPINFO_BREAKCOUNT);
	int index = (int)hash_get(g_hashbreakmodel, type, -1);
	vector pos = target.GetOrigin();

	if not (index)
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BREAKMODEL);
	WriteByte(MSG_MULTICAST, index);
	WriteCoord(MSG_MULTICAST, pos[0] + target.mins[0]);
	WriteCoord(MSG_MULTICAST, pos[1] + target.mins[1]);
	WriteCoord(MSG_MULTICAST, pos[2] + target.mins[2]);
	WriteCoord(MSG_MULTICAST, pos[0] + target.maxs[0]);
	WriteCoord(MSG_MULTICAST, pos[1] + target.maxs[1]);
	WriteCoord(MSG_MULTICAST, pos[2] + target.maxs[2]);
	WriteCoord(MSG_MULTICAST, dir[0]);
	WriteCoord(MSG_MULTICAST, dir[1]);
	WriteCoord(MSG_MULTICAST, dir[2]);
	WriteFloat(MSG_MULTICAST, speed);
	WriteByte(MSG_MULTICAST, count);
	multicast(pos, MULTICAST_PVS);
}
#endif
