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
	identity = 1;
#ifdef SERVER
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			Destroy();
			return;
		}
	}

	/* null all of them */
	m_outputOnSpawn =
	m_outputOnKilled =
	m_outputOnTrigger =
	m_outputOnUser1 =
	m_outputOnUser2 =
	m_outputOnUser3 =
	m_outputOnUser4 = __NULL__;
#else
	owner = __NULL__;
	chain = __NULL__;
	isCSQC = TRUE;
	effects |= EF_NOSHADOW;
#endif

	_isActor = false;
	_isItem = false;
	_isPlayer = false;
	_isWeapon = false;
}

void
ncIO::Respawn(void)
{
	// Respawn code goes here...
}

void
ncIO::ReloadCachedAttributes(void)
{
}

void
ncIO::Spawned(void)
{
#ifdef SERVER
	if (STRING_SET(m_outputOnSpawn))
		m_outputOnSpawn = CreateOutput(m_outputOnSpawn);
	if (STRING_SET(m_outputOnKilled))
		m_outputOnKilled = CreateOutput(m_outputOnKilled);
	if (STRING_SET(m_outputOnTrigger))
		m_outputOnKilled = CreateOutput(m_outputOnTrigger);
	if (STRING_SET(m_outputOnUser1))
		m_outputOnUser1 = CreateOutput(m_outputOnUser1);
	if (STRING_SET(m_outputOnUser2))
		m_outputOnUser2 = CreateOutput(m_outputOnUser2);
	if (STRING_SET(m_outputOnUser3))
		m_outputOnUser3 = CreateOutput(m_outputOnUser3);
	if (STRING_SET(m_outputOnUser4))
		m_outputOnUser4 = CreateOutput(m_outputOnUser4);
#endif

	_isWeapon = false;
	_isItem = false;

#ifdef SERVER
	UseOutput(this, m_outputOnSpawn);
#endif
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

#ifdef SERVER
	UseOutput(this, m_outputOnKilled);
#endif

	_isActor = false;
	_isItem = false;
	_isPlayer = false;
	_isWeapon = false;
	chain =
	owner = __NULL__;
	spawnclass =
	classname =
	declclass = __NULL__;
	identity = 0;
	modelindex = 0;
	movetype = 0;
	solid = 0;
	removed = true;
	customphysics =
	think = __NULL__;
	nextthink = 0.0f;
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

	return __NULL__;
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
	for (int i = 1; i < (tokenize(m_rawSpawnData) - 1); i += 2) {
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

		EntLog("Sent Output Message:\n\tTarget: %s\n"\
			"\tInput: %s\n"\
			"\tData Message: %s\n"\
			"\tDelay: %f\n"\
			"\tUses: %i", op.m_strTarget, op.m_strInput, op.m_strData, op.m_flDelay, op.m_iCount);

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
		ncLog("^2%s::CreateOutput report:", classname);
		ncLog("%d Name: %s", num_for_edict(new_minion), outname);
		ncLog("Owner: %s (%d)", new_minion.owner.classname, num_for_edict(new_minion.owner));
		ncLog("Target: %s", new_minion.m_strTarget);
		ncLog("Input: %s", new_minion.m_strInput);
		ncLog("Data Message: %s", new_minion.m_strData);
		ncLog("Delay: %f", new_minion.m_flDelay);
		ncLog("Uses: %i", new_minion.m_iCount);
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
ncIO::PrepareOutput(string strOut, string setValue)
{
	setValue = strreplace(",", ",_", setValue);
	strOut = strcat(strOut, ",_", setValue);
	return strOut;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
ncIO::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "FireUser1":
		UseOutput(eAct, m_outputOnUser1);
		break;
	case "FireUser2":
		UseOutput(eAct, m_outputOnUser2);
		break;
	case "FireUser3":
		UseOutput(eAct, m_outputOnUser3);
		break;
	case "FireUser4":
		UseOutput(eAct, m_outputOnUser4);
		break;
	default:
		if (strData != "") {
			if (STRING_SET(targetname)) {
			EntWarning("%s %S unhandled input %S from %s (%d) with data %S",
				classname, targetname, strInput, eAct.classname, num_for_edict(eAct), strData);
			} else {
			EntWarning("%s unhandled input %S from %s (%d) with data %S",
				classname, strInput, eAct.classname, num_for_edict(eAct), strData);
			}
		} else {
			if (STRING_SET(targetname)) {
			EntWarning("%s %S unhandled input %S from %s (%d)",
				classname, targetname, strInput, eAct.classname, num_for_edict(eAct));
			} else {
			EntWarning("%s unhandled input %S from %s (%d)",
				classname, strInput, eAct.classname, num_for_edict(eAct));
			}
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
	/* spawn info */
	SaveFloat(handle, "spawnflags", spawnflags);
	SaveBool(handle, "_mapspawned", _mapspawned);
	SaveFloat(handle, "identity", identity);
	SaveFloat(handle, "ltime", ltime);

	/* pvs info */
	SaveVector(handle, "origin", origin);
	SaveFloat(handle, "pvsflags", pvsflags);
}

void
ncIO::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "spawnflags":
		spawnflags = ReadFloat(setValue);
		break;
	case "_mapspawned":
		_mapspawned = ReadBool(setValue);
		break;
	case "identity":
		identity = ReadFloat(setValue);
		break;
	case "pvsflags":
		pvsflags = ReadFloat(setValue);
		break;
	case "ltime":
		ltime = ReadFloat(setValue);
		break;
	case "origin":
		origin = ReadVector(setValue);
		setorigin(this, origin);
		break;
	case "pvsflags":
		pvsflags = ReadFloat(setValue);
		break;
	default:
		EntWarning("Can't restore field %S with value %s", keyName, setValue);
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

void
ncIO::SetSendFlags(float flSendFlags)
{
#ifdef SERVER
	SendFlags |= flSendFlags;
#endif
}

#endif

#ifdef CLIENT
void
ncIO::_ReceiveComplete(float flNew, float flChanged)
{

}
#endif


void
ncIO::Relink(void)
{
	setorigin(this, origin);
}


void
ncIO::SpawnKey(string keyName, string setValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (keyName) {
	case "classname":
		break;
	case "spawnflags":
		spawnflags = ReadFloat(setValue);
		break;
	case "mins":
		mins = ReadVector(setValue);
		break;
	case "maxs":
		maxs = ReadVector(setValue);
		break;
	case "target":
		target = setValue;
		break;
	case "targetname":
		targetname = setValue;
		break;
#ifdef SERVER
	case "script_gametype":
		m_gameModeFilter = ReadString(setValue);
		break;
	/* Input/Output system */
	case "OnSpawn":
		m_outputOnSpawn = PrepareOutput(m_outputOnSpawn, setValue);
		break;
	case "OnKilled":
		m_outputOnKilled = PrepareOutput(m_outputOnKilled, setValue);
		break;
	case "OnTrigger":
		m_outputOnTrigger = PrepareOutput(m_outputOnTrigger, setValue);
		break;
	case "OnUser1":
		m_outputOnUser1 = PrepareOutput(m_outputOnUser1, setValue);
		break;
	case "OnUser2":
		m_outputOnUser2 = PrepareOutput(m_outputOnUser2, setValue);
		break;
	case "OnUser3":
		m_outputOnUser3 = PrepareOutput(m_outputOnUser3, setValue);
		break;
	case "OnUser4":
		m_outputOnUser4 = PrepareOutput(m_outputOnUser4, setValue);
		break;
#endif
	default:
#ifdef SERVER
		/*EntLog("%s has unknown key %S with value %S",
		      classname, keyName, setValue);*/
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
