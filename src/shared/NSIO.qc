/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
NSIO::NSIO(void)
{
#ifdef SERVER
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			remove(this);
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
	isCSQC = TRUE;
	effects |= EF_NOSHADOW;
#endif

	/* called last */
	Init();
}

void
NSIO::Respawn(void)
{
	// Respawn code goes here...
}

void
NSIO::Init(void)
{
	/* annoylingly our starting offsets differ */
#ifdef CLIENT
	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2)
		SpawnKey(argv(i), argv(i+1));
#else
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2)
		SpawnKey(argv(i), argv(i+1));
#endif

#ifdef SERVER
	/* some entity might involuntarily call SpawnInit as part of being
	   a member of NSIO. So we need to make sure that it doesn't
	   inherit stuff from the last previously loaded entity */
	__fullspawndata = "";
#endif
	Spawned();

#ifdef SERVER
	/* we're loading entity data, don't call Respawn() */
	if (g_isloading == true)
		return;
#endif
	Respawn();
}

void
NSIO::Spawned(void)
{
#ifdef SERVER
	if (m_strOnUser1)
		m_strOnUser1 = CreateOutput(m_strOnUser1);
	if (m_strOnUser2)
		m_strOnUser2 = CreateOutput(m_strOnUser2);
	if (m_strOnUser3)
		m_strOnUser3 = CreateOutput(m_strOnUser3);
	if (m_strOnUser4)
		m_strOnUser4 = CreateOutput(m_strOnUser4);
#endif
}

#ifdef SERVER
/* Input/Output system */
void
NSIO::UseOutput(entity act, string outname)
{
	if (!outname)
		return;

	for (entity f = world; (f = find(f, ::targetname, outname));) {
		NSOutput op = (NSOutput)f;

		/* no more tries and not -1 (infinite) */
		if (op.m_iCount == 0) {
			return;
		}

		op.m_eActivator = act;
		op.think = NSOutput::TriggerOutput;
		op.nextthink = time + op.m_flDelay;
	}
}

/* input is a 5 parameter, commar separated string, output is the targetname
   of a minion entity that'll handle the triggering (and counting down of uses)
   as defined in the Source Input/Output specs */
string
NSIO::CreateOutput(string outmsg)
{
	static int outcount = 0;
	string outname = "";
	float c;

	if not (outmsg)
		error("Cannot assign EMPTY contents to CreateOutput!");

	outname = sprintf("output_%i", outcount);
	outcount++;

	/* to make sure tokenize 'remembers' to tell us about the commonly
	   empty data string, we prepared the output string beforehand to
	   at least contain a _ symbol after the comma separator... now
	   we gotta clip that away using substring(). messy, but that's the
	   only way to keep them at 5 argv() calls per output */
	c = tokenizebyseparator(outmsg, ",");
	for (float i = 1; i < c; i+=5) {
		NSOutput new_minion = spawn(NSOutput);

		new_minion.classname = "triggerminion";
		new_minion.targetname = outname;
		new_minion.m_strTarget = substring(argv(i), 1,-1);
		new_minion.m_strInput = substring(argv(i+1), 1,-1);
		new_minion.m_strData = substring(argv(i+2), 1,-1);
		new_minion.m_flDelay = stof(substring(argv(i+3), 1,-1));
		new_minion.m_iCount = stoi(substring(argv(i+4), 1,-1));
		new_minion.m_iOldCount = new_minion.m_iCount;

		/* print final debug output */
		NSLog("^2%s::CreateOutput report:", classname);
		NSLog("Target: %s", new_minion.m_strTarget);
		NSLog("Input: %s", new_minion.m_strInput);
		NSLog("Data Message: %s", new_minion.m_strData);
		NSLog("Delay: %f", new_minion.m_flDelay);
		NSLog("Uses: %i\n", new_minion.m_iCount);
	}

	/* return the name that'll act as the trigger for all outputs */
	return outname;
}

string
NSIO::PrepareOutput(string strOut, string strValue)
{
	strValue = strreplace(",", ",_", strValue);
	strOut = strcat(strOut, ",_", strValue);
	return strOut;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
NSIO::Input(entity eAct, string strInput, string strData)
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
		if (strData != "")
		print(sprintf("^2%s::^3Input^7: Receives input %s from %s with data %s\n", 
			this.classname, strInput, eAct.classname, strData));
		else
		print(sprintf("^2%s::^3Input^7: Receives input %s from %s\n", 
			this.classname, strInput, eAct.classname));
	}
}

void
NSIO::SaveBool(float handle, string key, bool value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}
void
NSIO::SaveFloat(float handle, string key, float value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}
void
NSIO::SaveInt(float handle, string key, int value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%i\"\n", key, value));
}
void
NSIO::SaveString(float handle, string key, string value)
{
	//if (value && value != "")
		fputs(handle, sprintf("%S %S\n", key, value));
}
void
NSIO::SaveVector(float handle, string key, vector value)
{
	//if (value)
		fputs(handle, sprintf("%S \"%v\"\n", key, value));
}
void
NSIO::SaveEntity(float handle, string key, entity targ)
{
	float value = num_for_edict(targ);

	//if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}

float
NSIO::ReadBool(string strValue)
{
	if (strValue && strValue != "")
		return stof(strValue);
	return __NULL__;
}
float
NSIO::ReadFloat(string strValue)
{
	if (strValue && strValue != "")
		return stof(strValue);
	return __NULL__;
}
int
NSIO::ReadInt(string strValue)
{
	if (strValue && strValue != "")
		return stoi(strValue);
	return __NULL__;
}
string
NSIO::ReadString(string strValue)
{
	if (strValue && strValue != "")
		return strValue;
	return __NULL__;
}
vector
NSIO::ReadVector(string strValue)
{
	if (strValue && strValue != "")
		return stov(strValue);
	return __NULL__;
}
entity
NSIO::ReadEntity(string strValue)
{
	if (strValue && strValue != "") {
		float num = stof(strValue);

		if (num)
			return edict_num(num);
	}
	return __NULL__;
}

void
NSIO::Save(float handle)
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
	SaveFloat(handle, "ammo_shells", ammo_shells);
	SaveFloat(handle, "ammo_nails", ammo_nails);
	SaveFloat(handle, "ammo_rockets", ammo_rockets);
	SaveFloat(handle, "ammo_cells", ammo_cells);
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

	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
	SaveString(handle, "m_strOnUser1", m_strOnUser1);
	SaveString(handle, "m_strOnUser2", m_strOnUser2);
	SaveString(handle, "m_strOnUser3", m_strOnUser3);
	SaveString(handle, "m_strOnUser4", m_strOnUser4);
}
void
NSIO::Restore(string strKey, string strValue)
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
	case "ammo_shells":
		ammo_shells = ReadFloat(strValue);
		break;
	case "ammo_nails":
		ammo_nails = ReadFloat(strValue);
		break;
	case "ammo_rockets":
		ammo_rockets = ReadFloat(strValue);
		break;
	case "ammo_cells":
		ammo_cells = ReadFloat(strValue);
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
	}
}
#endif

/*
============
NSIO::SpawnKey

note that the engine still likes to try and map key/value
pairs on its own, but we can at least undo some of that in
here if needed
============
*/
void
NSIO::SpawnKey(string strKey, string strValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "classname":
	case "spawnflags":
		break;
	case "targetname":
		targetname = strValue;
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
		NSLog("^3%s^7::SpawnKey:: Unknown key '%s' with value '%s'",
		      classname, strKey, strValue);
		break;
	}
}
