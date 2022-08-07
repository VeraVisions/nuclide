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
	if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}
void
NSIO::SaveFloat(float handle, string key, float value)
{
	if (value)
		fputs(handle, sprintf("%S \"%f\"\n", key, value));
}
void
NSIO::SaveInt(float handle, string key, int value)
{
	if (value)
		fputs(handle, sprintf("%S \"%i\"\n", key, value));
}
void
NSIO::SaveString(float handle, string key, string value)
{
	if (value && value != "")
		fputs(handle, sprintf("%S %S\n", key, value));
}
void
NSIO::SaveVector(float handle, string key, vector value)
{
	if (value)
		fputs(handle, sprintf("%S \"%v\"\n", key, value));
}
void
NSIO::SaveEntity(float handle, string key, entity targ)
{
	float value = num_for_edict(targ);

	if (value)
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
	SaveFloat(handle, "nextthink", bound(0, (nextthink - time), nextthink));
	SaveString(handle, "think", getentityfieldstring(findentityfield("think"), this));
	SaveString(handle, "OnTrigger", m_strOnTrigger);
	SaveString(handle, "OnUser1", m_strOnUser1);
	SaveString(handle, "OnUser2", m_strOnUser2);
	SaveString(handle, "OnUser3", m_strOnUser3);
	SaveString(handle, "OnUser4", m_strOnUser4);
	SaveString(handle, "targetname", targetname);
}
void
NSIO::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "targetname":
		targetname = ReadString(strValue);
		break;
	case "nextthink":
		float nt = ReadFloat(strValue);

		if (nt)
			nextthink = time + stof(strValue);
		break;
	case "think":
		think = externvalue(-1, strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	case "OnUser1":
		m_strOnUser1 = ReadString(strValue);
		break;
	case "OnUser2":
		m_strOnUser2 = ReadString(strValue);
		break;
	case "OnUser3":
		m_strOnUser3 = ReadString(strValue);
		break;
	case "OnUser4":
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
