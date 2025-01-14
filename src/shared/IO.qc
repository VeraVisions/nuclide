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

void
ncIO::ncIO(void)
{
#ifdef SERVER
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			Destroy();
			return;
		}
	}

	/* null all of them */
	m_strOnTrigger =
	m_strOnUser1 =
	m_strOnUser2 =
	m_strOnUser3 =
	m_strOnUser4 = __NULL__;
#else
	owner = __NULL__;
	chain = __NULL__;
	isCSQC = TRUE;
	effects |= EF_NOSHADOW;
#endif
	m_strEditorIcon = "gfx/icon16/bullet_purple";
	isActor = false;
}

void
ncIO::Respawn(void)
{
	// Respawn code goes here...
}

void
ncIO::Spawned(void)
{
#ifdef SERVER
	if (STRING_SET(m_strOnUser1))
		m_strOnUser1 = CreateOutput(m_strOnUser1);
	if (STRING_SET(m_strOnUser2))
		m_strOnUser2 = CreateOutput(m_strOnUser2);
	if (STRING_SET(m_strOnUser3))
		m_strOnUser3 = CreateOutput(m_strOnUser3);
	if (STRING_SET(m_strOnUser4))
		m_strOnUser4 = CreateOutput(m_strOnUser4);
#endif

	_isWeapon = false;
	_isItem = false;
}

void
ncIO::OnRemoveEntity(void)
{
}

void
ncIO::Destroy(void)
{
	if (wasfreed(this)) {
		return;
	}

	if (OnRemoveEntity) {
		OnRemoveEntity();
	}

	customphysics = __NULL__;
	modelindex = 0;
	solid = 0;
	movetype = 0;
	classname = 0;
	think = __NULL__;
	nextthink = 0.0f;
	identity = 1;
	_isWeapon = false;
	_isItem = false;
	removed = true;
	remove(this);
}

string
ncIO::GetDefString(string keyName)
{
	return ReadString(EntityDef_GetKeyValue(declclass, keyName));
}

vector
ncIO::GetDefVector(string keyName)
{
	return stov(GetDefString(keyName));
}

float
ncIO::GetDefFloat(string keyName)
{
	return stof(GetDefString(keyName));
}

bool
ncIO::GetDefBool(string keyName)
{
	return stof(GetDefString(keyName)) ? true : false;
}

int
ncIO::GetDefInt(string keyName)
{
	return (int)stoi(GetDefString(keyName));
}

/** Returns the framegroup for a given activity. */
float
ncIO::GetSubDefAct(string subDef, string activityName)
{
	return Activities_GetSequenceForEntityDef((ncEntity)this, activityName, subDef);
}

float
ncIO::GetDefAct(string activityName)
{
	return Activities_GetSequenceForEntity((ncEntity)this, activityName);
}

string
ncIO::GetSubDefString(string subDef, string keyName)
{
	string fireDefString = EntityDef_GetKeyValue(subDef, keyName);
	string fireValue = ReadString(fireDefString);

	/* if not in FireInfo, check classname Def */
	if (fireValue == "") {
		fireValue = GetDefString(keyName);
	}

	return (fireValue);
}

vector
ncIO::GetSubDefVector(string subDef, string keyName)
{
	return stov(GetSubDefString(subDef, keyName));
}

float
ncIO::GetSubDefFloat(string subDef, string keyName)
{
	return stof(GetSubDefString(subDef, keyName));
}

bool
ncIO::GetSubDefBool(string subDef, string keyName)
{
	return stof(GetSubDefString(subDef, keyName)) ? true : false;
}

int
ncIO::GetSubDefInt(string subDef, string keyName)
{
	return (int)stoi(GetSubDefString(subDef, keyName));
}


bool
ncIO::ReadBool(string inputString)
{
	if (inputString && inputString != "")
		return stof(ReadString(inputString)) ? true : false;
	return false;
}
float
ncIO::ReadFloat(string inputString)
{
	if (inputString && inputString != "")
		return stof(ReadString(inputString));
	return 0.0f;
}
int
ncIO::ReadInt(string inputString)
{
	if (inputString && inputString != "")
		return stoi(ReadString(inputString));
	return 0i;
}
string
ncIO::ReadString(string inputString)
{
	if (inputString && inputString != "") {
		return unpackStringCommand(inputString);
	}

	return "";
}
vector
ncIO::ReadVector(string inputString)
{
	if (inputString && inputString != "")
		return stov(ReadString(inputString));
	return g_vec_null;
}
entity
ncIO::ReadEntity(string inputString)
{
	if (inputString && inputString != "") {
		float num = stof(inputString);

		if (num)
			return edict_num(num);
	}
	return __NULL__;
}

bool
ncIO::GetSpawnBool(string keyName)
{
	return stof(GetSpawnString(keyName)) ? true : false;
}

float
ncIO::GetSpawnFloat(string keyName)
{
	return stof(GetSpawnString(keyName));
}

int
ncIO::GetSpawnInt(string keyName)
{
	return stoi(GetSpawnString(keyName));
}

string
ncIO::GetSpawnString(string keyName)
{
	for (int i = 1; i < (tokenize(m_strSpawnData) - 1); i += 2) {
		string key = argv(i);
		string value = argv(i+1);

		if (key == keyName) {
			return ReadString(argv(i+1));
		}
	}

	return ReadString(EntityDef_GetKeyValue(declclass, keyName));
}

vector
ncIO::GetSpawnVector(string keyName)
{
	return stov(GetSpawnString(keyName));
}

entity
ncIO::GetSpawnEntity(string keyName, entity startEntity)
{
	string targetName = GetSpawnString(keyName);
	return find(startEntity, ::targetname, targetName);
}

#ifdef SERVER
/* Input/Output system */
void
ncIO::UseOutput(entity act, string outname)
{
	if (!STRING_SET(outname)) {
		return;
	}

	for (entity f = world; (f = find(f, ::targetname, outname));) {
		ncOutput op = (ncOutput)f;

		NSError("Target: %s", op.m_strTarget);
		NSError("Input: %s", op.m_strInput);
		NSError("Data Message: %s", op.m_strData);
		NSError("Delay: %f", op.m_flDelay);
		NSError("Uses: %i", op.m_iCount);

		/* no more tries and not -1 (infinite) */
		if (op.m_iCount == 0) {
			continue;
		}

		op.ScheduleOutput(act);
	}
}

string
ncIO::CreateOutput(string outmsg)
{
	string outname = "";
	static int outID = 0i;

	if (!STRING_SET(outmsg)) {
		error("Cannot assign EMPTY contents to CreateOutput!");
	}

	/* vanilla trigger and/or reuse */
	if (tokenizebyseparator(outmsg, ",") <= 5) {
		return outmsg;
	}

	outname = sprintf("output_%i", outID);
	outID += 1i;

	/* to make sure tokenize 'remembers' to tell us about the commonly
	   empty data string, we prepared the output string beforehand to
	   at least contain a _ symbol after the comma separator... now
	   we gotta clip that away using substring(). messy, but that's the
	   only way to keep them at 5 argv() calls per output */
	for (float i = 1; i < tokenizebyseparator(outmsg, ","); i+=5) {
		string ourTarget = substring(argv(i), 1,-1);
		string ourInput = substring(argv(i+1), 1,-1);
		string ourData = substring(argv(i+2), 1,-1);
		float ourDelay = stof(substring(argv(i+3), 1,-1));
		int ourCount = (int)stoi(substring(argv(i+4), 1,-1));
		ncOutput new_minion = spawn(ncOutput);

		new_minion.owner = this;
		new_minion.classname = "triggerminion";
		new_minion.targetname = outname;
		new_minion.m_strTarget = ourTarget;
		new_minion.m_strInput = ourInput;
		new_minion.m_strData = ourData;
		new_minion.m_flDelay = ourDelay;
		new_minion.m_iOldCount = new_minion.m_iCount = ourCount;

		/* print final debug output */
		NSLog("^2%s::CreateOutput report:", classname);
		NSLog("%d Name: %s", num_for_edict(new_minion), outname);
		NSLog("Owner: %s (%d)", new_minion.owner.classname, num_for_edict(new_minion.owner));
		NSLog("Target: %s", new_minion.m_strTarget);
		NSLog("Input: %s", new_minion.m_strInput);
		NSLog("Data Message: %s", new_minion.m_strData);
		NSLog("Delay: %f", new_minion.m_flDelay);
		NSLog("Uses: %i", new_minion.m_iCount);
	}

	/* return the name that'll act as the trigger for all outputs */
	return outname;
}

bool
ncIO::CheckOutput(string strOut)
{
	for (entity f = world; (f = find(f, ::targetname, strOut));) {
		ncOutput op = (ncOutput)f;

		if (op.nextthink != 0.0f)
			return false;
	}

	return true;
}

string
ncIO::PrepareOutput(string strOut, string strValue)
{
	strValue = strreplace(",", ",_", strValue);
	strOut = strcat(strOut, ",_", strValue);
	return strOut;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
ncIO::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "FireUser1":
		UseOutput(eAct, m_strOnUser1);
		break;
	case "FireUser2":
		UseOutput(eAct, m_strOnUser2);
		break;
	case "FireUser3":
		UseOutput(eAct, m_strOnUser3);
		break;
	case "FireUser4":
		UseOutput(eAct, m_strOnUser4);
		break;
	default:
		if (strData != "") {
			EntWarning("%S receives unknown input %S from %s (%d) with data %S", 
				classname, strInput, eAct.classname, num_for_edict(eAct), strData);
		} else {
			EntWarning("%S receives unknown input %S from %s (%d)", 
				classname, strInput, eAct.classname, num_for_edict(eAct));
		}
	}
}

void
ncIO::SaveBool(float handle, string key, bool value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%d\"\n", key, value));
}
void
ncIO::SaveFloat(float handle, string key, float value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}
void
ncIO::SaveInt(float handle, string key, int value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%i\"\n", key, value));
}
void
ncIO::SaveString(float handle, string key, string value)
{
	//if (value && value != "")
		fputs(handle, sprintf("%S %S\n", key, value));
}
void
ncIO::SaveVector(float handle, string key, vector value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%v\"\n", key, value));
}
void
ncIO::SaveEntity(float handle, string key, entity targ)
{
	float value = num_for_edict(targ);

	//if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}

void
ncIO::Save(float handle)
{
	/* all the stock Quake fields the engine is aware of */
	SaveFloat(handle, "modelindex", modelindex);
	SaveVector(handle, "absmin", absmin);
	SaveVector(handle, "absmax", absmax);
	SaveFloat(handle, "ltime", ltime);
	SaveFloat(handle, "movetype", movetype);
	SaveFloat(handle, "solid", solid);
	SaveVector(handle, "origin", origin);
	SaveVector(handle, "oldorigin", oldorigin);
	SaveVector(handle, "velocity", velocity);
	SaveVector(handle, "angles", angles);
	SaveVector(handle, "avelocity", avelocity);
	SaveVector(handle, "punchangle", punchangle);
	//SaveString(handle, "classname", classname);
	SaveString(handle, "model", model);
	SaveFloat(handle, "frame", frame);
	SaveFloat(handle, "skin", skin);
	SaveFloat(handle, "effects", effects);
	SaveVector(handle, "mins", mins);
	SaveVector(handle, "maxs", maxs);
	SaveVector(handle, "size", size);
	SaveString(handle, "touch", getentityfieldstring(findentityfield("touch"), this));
	SaveString(handle, "use", getentityfieldstring(findentityfield("use"), this));
	SaveString(handle, "think", getentityfieldstring(findentityfield("think"), this));
	SaveString(handle, "blocked", getentityfieldstring(findentityfield("blocked"), this));
	SaveFloat(handle, "nextthink", nextthink);
	SaveEntity(handle, "groundentity", groundentity);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "frags", frags);
	SaveFloat(handle, "weapon", weapon);
	SaveString(handle, "weaponmodel", weaponmodel);
	SaveFloat(handle, "weaponframe", weaponframe);
	SaveFloat(handle, "currentammo", currentammo);
	SaveFloat(handle, "items", items);
	SaveFloat(handle, "takedamage", takedamage);
	SaveEntity(handle, "chain", chain);
	SaveFloat(handle, "deadflag", deadflag);
	SaveVector(handle, "view_ofs", view_ofs);
	SaveFloat(handle, "button0", button0);
	SaveFloat(handle, "button1", button1);
	SaveFloat(handle, "button2", button2);
	SaveFloat(handle, "impulse", impulse);
	SaveFloat(handle, "fixangle", fixangle);
	SaveVector(handle, "v_angle", v_angle);
	SaveFloat(handle, "idealpitch", idealpitch);
	SaveString(handle, "netname", netname);
	SaveEntity(handle, "enemy", enemy);
	SaveFloat(handle, "flags", flags);
	SaveFloat(handle, "colormap", colormap);
	SaveFloat(handle, "team", team);
	SaveFloat(handle, "max_health", max_health);
	SaveFloat(handle, "teleport_time", teleport_time);
	SaveFloat(handle, "armortype", armortype);
	SaveFloat(handle, "armorvalue", armorvalue);
	SaveFloat(handle, "waterlevel", waterlevel);
	SaveFloat(handle, "watertype", watertype);
	SaveFloat(handle, "ideal_yaw", ideal_yaw);
	SaveFloat(handle, "yaw_speed", yaw_speed);
	SaveEntity(handle, "aiment", aiment);
	SaveEntity(handle, "goalentity", goalentity);
	SaveFloat(handle, "spawnflags", spawnflags);
	SaveString(handle, "target", target);
	SaveString(handle, "targetname", targetname);
	SaveFloat(handle, "dmg_take", dmg_take);
	SaveFloat(handle, "dmg_save", dmg_save);
	SaveEntity(handle, "dmg_inflictor", dmg_inflictor);
	SaveEntity(handle, "owner", owner);
	SaveVector(handle, "movedir", movedir);
	SaveString(handle, "message", message);
	SaveFloat(handle, "sounds", sounds);
	SaveString(handle, "noise", noise);
	SaveString(handle, "noise1", noise1);
	SaveString(handle, "noise2", noise2);
	SaveString(handle, "noise3", noise3);

	/* FTEQW relevant fields */
	SaveFloat(handle, "dimension_solid", dimension_solid);
	SaveFloat(handle, "dimension_hit", dimension_hit);
	SaveFloat(handle, "frame1time", frame1time);
	SaveFloat(handle, "basebone", basebone);
	SaveFloat(handle, "baseframe", baseframe);
	SaveFloat(handle, "drawflags", drawflags);
	SaveString(handle, "customphysics", getentityfieldstring(findentityfield("customphysics"), this));
	SaveString(handle, "SendEntity", getentityfieldstring(findentityfield("SendEntity"), this));
	SaveFloat(handle, "viewzoom", viewzoom);
	SaveFloat(handle, "uniquespawnid", uniquespawnid);

	/* Nuclide global fields */
	SaveFloat(handle, "jumptime", jumptime);
	SaveFloat(handle, "identity", identity);
	SaveFloat(handle, "iBleeds", iBleeds);

	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
	SaveString(handle, "m_strOnUser1", m_strOnUser1);
	SaveString(handle, "m_strOnUser2", m_strOnUser2);
	SaveString(handle, "m_strOnUser3", m_strOnUser3);
	SaveString(handle, "m_strOnUser4", m_strOnUser4);
	SaveString(handle, "m_strModelEventCB", m_strModelEventCB);
	SaveString(handle, "m_strSpawnData", m_strSpawnData);
	SaveString(handle, "m_strEditorIcon", m_strEditorIcon);
}
void
ncIO::Restore(string strKey, string strValue)
{
	switch (strKey) {
	/* START: all the stock Quake fields the engine is aware of */
	case "modelindex":
		modelindex = ReadFloat(strValue);
		break;
	case "absmin":
		absmin = ReadVector(strValue);
		break;
	case "absmax":
		absmax = ReadVector(strValue);
		break;
	case "ltime":
		ltime = ReadFloat(strValue);
		break;
	case "movetype":
		movetype = ReadFloat(strValue);
		break;
	case "solid":
		solid = ReadFloat(strValue);
		break;
	case "origin":
		origin = ReadVector(strValue);
		setorigin(this, origin);
		break;
	case "oldorigin":
		oldorigin = ReadVector(strValue);
		break;
	case "velocity":
		velocity = ReadVector(strValue);
		break;
	case "angles":
		angles = ReadVector(strValue);
		break;
	case "avelocity":
		avelocity = ReadVector(strValue);
		break;
	case "punchangle":
		punchangle = ReadVector(strValue);
		break;
	/*case "classname":
		classname = ReadString(strValue);
		break; */
	case "model":
		model = ReadString(strValue);
		setmodel(this, model);
		break;
	case "frame":
		frame = ReadFloat(strValue);
		break;
	case "skin":
		skin = ReadFloat(strValue);
		break;
	case "effects":
		effects = ReadFloat(strValue);
		break;
	case "mins":
		mins = ReadVector(strValue);
		setsize(this, mins, maxs);
		break;
	case "maxs":
		maxs = ReadVector(strValue);
		setsize(this, mins, maxs);
		break;
	case "size":
		size = ReadVector(strValue);
		break;
	case "touch":
		touch = externvalue(-1, strValue);
		break;
	case "use":
		use = externvalue(-1, strValue);
		break;
	case "think":
		think = externvalue(-1, strValue);
		break;
	case "blocked":
		blocked = externvalue(-1, strValue);
		break;
	case "nextthink":
		nextthink = ReadFloat(strValue);
		break;
	case "groundentity":
		groundentity = ReadEntity(strValue);
		break;
	case "health":
		health = ReadFloat(strValue);
		break;
	case "frags":
		frags = ReadFloat(strValue);
		break;
	case "weapon":
		weapon = ReadFloat(strValue);
		break;
	case "weaponmodel":
		weaponmodel = ReadString(strValue);
		break;
	case "weaponframe":
		weaponframe = ReadFloat(strValue);
		break;
	case "currentammo":
		currentammo = ReadFloat(strValue);
		break;
	case "items":
		items = ReadFloat(strValue);
		break;
	case "takedamage":
		takedamage = ReadFloat(strValue);
		break;
	case "chain":
		chain = ReadEntity(strValue);
		break;
	case "deadflag":
		deadflag = ReadFloat(strValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(strValue);
		break;
	case "button0":
		button0 = ReadFloat(strValue);
		break;
	case "button1":
		button1 = ReadFloat(strValue);
		break;
	case "button2":
		button2 = ReadFloat(strValue);
		break;
	case "impulse":
		impulse = ReadFloat(strValue);
		break;
	case "fixangle":
		fixangle = ReadFloat(strValue);
		break;
	case "v_angle":
		v_angle = ReadVector(strValue);
		break;
	case "idealpitch":
		idealpitch = ReadFloat(strValue);
		break;
	case "netname":
		netname = ReadString(strValue);
		break;
	case "enemy":
		enemy = ReadEntity(strValue);
		break;
	case "flags":
		flags = ReadFloat(strValue);
		break;
	case "colormap":
		colormap = ReadFloat(strValue);
		break;
	case "team":
		team = ReadFloat(strValue);
		break;
	case "max_health":
		max_health = ReadFloat(strValue);
		break;
	case "teleport_time":
		teleport_time = ReadFloat(strValue);
		break;
	case "armortype":
		armortype = ReadFloat(strValue);
		break;
	case "armorvalue":
		armorvalue = ReadFloat(strValue);
		break;
	case "waterlevel":
		waterlevel = ReadFloat(strValue);
		break;
	case "watertype":
		watertype = ReadFloat(strValue);
		break;
	case "ideal_yaw":
		ideal_yaw = ReadFloat(strValue);
		break;
	case "yaw_speed":
		yaw_speed = ReadFloat(strValue);
		break;
	case "aiment":
		aiment = ReadEntity(strValue);
		break;
	case "goalentity":
		goalentity = ReadEntity(strValue);
		break;
	case "spawnflags":
		spawnflags = ReadFloat(strValue);
		break;
	case "target":
		target = ReadString(strValue);
		break;
	case "targetname":
		targetname = ReadString(strValue);
		break;
	case "dmg_take":
		dmg_take = ReadFloat(strValue);
		break;
	case "dmg_save":
		dmg_save = ReadFloat(strValue);
		break;
	case "dmg_inflictor":
		dmg_inflictor = ReadEntity(strValue);
		break;
	case "owner":
		owner = ReadEntity(strValue);
		break;
	case "movedir":
		movedir = ReadVector(strValue);
		break;
	case "message":
		message = ReadString(strValue);
		break;
	case "sounds":
		sounds = ReadFloat(strValue);
		break;
	case "noise":
		noise = ReadString(strValue);
		break;
	case "noise1":
		noise1 = ReadString(strValue);
		break;
	case "noise2":
		noise2 = ReadString(strValue);
		break;
	case "noise3":
		noise3 = ReadString(strValue);
		break;

	/* FTEQW relevant fields */
	case "dimension_solid":
		dimension_solid = ReadFloat(strValue);
		break;
	case "dimension_hit":
		dimension_hit = ReadFloat(strValue);
		break;
	case "frame1time":
		frame1time = ReadFloat(strValue);
		break;
	case "basebone":
		basebone = ReadFloat(strValue);
		break;
	case "baseframe":
		baseframe = ReadFloat(strValue);
		break;
	case "drawflags":
		drawflags = ReadFloat(strValue);
		break;
	case "customphysics":
		customphysics = externvalue(-1, strValue);
		break;
	case "SendEntity":
		SendEntity = externvalue(-1, strValue);
		break;
	case "viewzoom":
		viewzoom = ReadFloat(strValue);
		break;
	case "uniquespawnid":
		uniquespawnid = ReadFloat(strValue);
		break;

	/* Nuclide global fields */
	case "jumptime":
		jumptime = ReadFloat(strValue);
		break;
	case "identity":
		identity = ReadFloat(strValue);
		break;
	case "iBleeds":
		iBleeds = ReadFloat(strValue);
		break;

	/* END: all the stock Quake fields the engine is aware of */
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	case "m_strOnUser1":
		m_strOnUser1 = ReadString(strValue);
		break;
	case "m_strOnUser2":
		m_strOnUser2 = ReadString(strValue);
		break;
	case "m_strOnUser3":
		m_strOnUser3 = ReadString(strValue);
		break;
	case "m_strOnUser4":
		m_strOnUser4 = ReadString(strValue);
		break;
	case "m_strModelEventCB":
		m_strModelEventCB = ReadString(strValue);
		break;
	case "m_strSpawnData":
		m_strSpawnData = ReadString(strValue);
		break;
	case "m_strEditorIcon":
		m_strEditorIcon = ReadString(strValue);
		break;
	}
}

void
ncIO::RestoreComplete( void ) {
	/* this is where we can handle anything post-loading */
}

void
ncIO::TransitionComplete( void ) {
	/* this is where we can handle anything post-loading */
}

void
ncIO::ParentUpdate(void)
{

}
#endif

void
ncIO::SpawnKey(string strKey, string strValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "classname":
		break;
	case "spawnflags":
		spawnflags = ReadFloat(strValue);
		break;
	case "mins":
		mins = ReadVector(strValue);
		break;
	case "maxs":
		maxs = ReadVector(strValue);
		break;
	case "target":
		target = strValue;
		break;
	case "targetname":
		targetname = strValue;
		break;
	case "editor_icon":
		m_strEditorIcon = ReadString(strValue);
		break;
#ifdef SERVER
	/* Input/Output system */
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	case "OnUser1":
		m_strOnUser1 = PrepareOutput(m_strOnUser1, strValue);
		break;
	case "OnUser2":
		m_strOnUser2 = PrepareOutput(m_strOnUser2, strValue);
		break;
	case "OnUser3":
		m_strOnUser3 = PrepareOutput(m_strOnUser3, strValue);
		break;
	case "OnUser4":
		m_strOnUser4 = PrepareOutput(m_strOnUser4, strValue);
		break;
#endif
	default:
#ifdef SERVER
		EntLog("%s has unknown key %S with value %S",
		      classname, strKey, strValue);
#endif
		break;
	}
}


/* FIXME: Why do we need to declare this?! */
#ifdef CSQC
noref .float ltime;
#endif

float
ncIO::GetTime(void)
{
	return (movetype == MOVETYPE_PUSH) ? ltime : time;
}


void
ncIO::DebugBool(string key, bool value)
{
	EntLog("%S \"%d\"", key, value);
}
void
ncIO::DebugFloat(string key, float value)
{
	EntLog("%S \"%f\"", key, value);
}
void
ncIO::DebugInt(string key, int value)
{
	EntLog("%S \"%i\"", key, value);
}
void
ncIO::DebugString(string key, string value)
{
	EntLog("%S %S", key, value);
}
void
ncIO::DebugVector(string key, vector value)
{
	EntLog("%S \"%v\"", key, value);
}
void
ncIO::DebugEntity(string key, entity targ)
{
	float value = num_for_edict(targ);
	EntLog("%S \"%f\"", key, value);
}
void
ncIO::SetEditorIcon(string newIcon)
{
	m_strEditorIcon = strcat("gfx/icon16/", newIcon);
}

float
ncIO::GetNextThinkTime(void)
{
	return (nextthink);
}

bool
ncIO::IsThinking(void)
{
	return (nextthink > GetTime()) ? (true) : (false);
}

void
ncIO::ReleaseThink(void)
{
	think = __NULL__;
	nextthink = 0.0f;
}

void
ncIO::ThinkBusy(float busyTime)
{
	static void ThinkBusy_Done(void) {
		/* Guess we're done here... */
	}
	ScheduleThink(ThinkBusy_Done, busyTime);
}

void
ncIO::SetThink(void (void) func)
{
	think = func;
}

void
ncIO::SetNextThink(float fl)
{
	float flTime = GetTime() + fl;

	/* HACK: to make sure things happen post-spawn */
	if (flTime < 0.1f) {
		flTime = 0.1f;
	}

	if (flTime >= 0) {
		nextthink = flTime;
	} else {
		EntError("%s sets bogus nextthink value %f", classname, flTime);
	}
}

void
ncIO::ScheduleThink(void (void) func, float fl)
{
	SetThink(func);
	SetNextThink(fl);
}
