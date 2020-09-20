/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* modern trigger architecture */
void
CBaseTrigger::UseOutput(entity act, string outname)
{
	for (entity f = world; (f = find(f, ::targetname, outname));) {
		CBaseOutput op = (CBaseOutput)f;
		/* no more tries and not -1 (infinite) */
		if (op.m_iCount == 0) {
			return;
		}

		op.m_eActivator = act;
		op.think = CBaseOutput::TriggerOutput;
		op.nextthink = time + op.m_flDelay;
	}
}

/* input is a 4-5 parameter, commar separated string, output is the targetname
   of a minion entity that'll handle the triggering (and counting down of uses)
   as defined in the Source Input/Output specs */
string
CBaseTrigger::CreateOutput(string outmsg)
{
	static int outcount = 0;
	float c;

	if (!outmsg)
		return "";

	string outname = sprintf("output_%i\n", outcount);
	outcount++;

	c = tokenizebyseparator(outmsg, ",");
	for (float i = 1; i < c; i+=5) {
		CBaseOutput new_minion = spawn(CBaseOutput);

		new_minion.classname = "triggerminion";
		new_minion.targetname = outname;
		new_minion.m_strTarget = substring(argv(i), 1,-1);
		new_minion.m_strInput = substring(argv(i+1), 1,-1);
		new_minion.m_strData = substring(argv(i+2), 1,-1);
		new_minion.m_flDelay = stof(substring(argv(i+3), 1,-1));
		new_minion.m_iCount = stoi(substring(argv(i+4), 1,-1));
		new_minion.m_iOldCount = new_minion.m_iCount;
	}

	/* print final debug output */
	for (entity f = world; (f = find(f, ::targetname, outname));) {
		CBaseOutput new_minion = (CBaseOutput)f;
		print(sprintf("^2%s::OnTrigger report:\n", classname));
		print(sprintf("Target: %s\n", new_minion.m_strTarget));
		print(sprintf("Input: %s\n", new_minion.m_strInput));
		print(sprintf("Data Message: %s\n", new_minion.m_strData));
		print(sprintf("Delay: %f\n", new_minion.m_flDelay));
		print(sprintf("Uses: %i\n\n", new_minion.m_iCount));
	}

	/* return the minion's name that'll act as the trigger */
	return outname;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
CBaseTrigger::Input(entity act, string intype, string data)
{
	if (data != "")
	dprint(sprintf("^2%s::^3Input^7: Receives input %s from %s with data %s\n", 
		this.classname, intype, act.classname, data));
	else
	dprint(sprintf("^2%s::^3Input^7: Receives input %s from %s\n", 
		this.classname, intype, act.classname));
}

/* legacy trigger architecture */
void
CBaseTrigger::Trigger(entity act, int state)
{
	dprint(sprintf("^2%s::^3Input^7: Triggerd by %s with no consequence\n", 
		this.classname, act.classname));
}

void
CBaseTrigger::UseTargets(entity act, int state)
{
	for (entity f = world; (f = find(f, ::targetname, target));) {
		CBaseTrigger trigger = (CBaseTrigger)f;
		dprint(sprintf("^2%s::^3UseTargets^7: Triggering %s `%s` from %s\n", 
			this.classname, f.classname, trigger.targetname, act.classname));
		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(act, state);
		}
	}

	/* hack: check to see if this is a sound file */
	/*if (whichpack(m_strMessage)) {
		print(m_strMessage);
		print("\n");
	} else {
		if (m_strMessage && act.flags & FL_CLIENT) {
			centerprint(act, m_strMessage);
		}
	}*/

	if (m_strKillTarget) {
		entity eKill = find(world, ::targetname, m_strKillTarget);
		if (eKill) {
			remove(eKill);
		}
	}
}

void
CBaseTrigger::UseTargets_Delay(entity act, int state, float fDelay)
{
	static void Entities_UseTargets_Delay_Think(void) {
		CBaseTrigger::UseTargets(self.owner, self.health); /* ugly */
		remove(self);
	}

	dprint(sprintf("^2%s::^3UseTargets_Delay^7: Triggering `%s`\n", 
		this.classname, target));

	CBaseTrigger eTimer = spawn(CBaseTrigger);
	eTimer.owner = act;
	eTimer.think = Entities_UseTargets_Delay_Think;
	eTimer.target = target;
	eTimer.nextthink = time + fDelay;
	eTimer.health = state;  /* ugly */
}

int
CBaseTrigger::GetValue(void)
{
	return m_iValue;
}

int
CBaseTrigger::GetMaster(void)
{
	CBaseTrigger t;

	/* default to success */
	if (!m_strMaster) {
		/*dprint(sprintf("^2%s::^3GetMaster^7: No master, return success\n", 
		this.classname));*/
		return TRUE;
	}

	t = (CBaseTrigger)find(world, ::target, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		/*dprint(sprintf("^2%s::^3GetMaster^7: Invalid master, return success\n", 
		this.classname));*/
		return TRUE;
	}

	/*if (t.GetValue() == 1)
		dprint(sprintf("^2%s::^3GetMaster^7: %s learns %s ^2POSITIVE\n", 
		this.classname, targetname, m_strMaster));
	else
		dprint(sprintf("^2%s::^3GetMaster^7: %s learns %s ^1NEGATIVE\n", 
		this.classname, targetname, m_strMaster));*/
	
	return t.GetValue();
}

void
CBaseTrigger::InitPointTrigger(void)
{
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	solid = SOLID_TRIGGER;
}

void
CBaseTrigger::InitBrushTrigger(void)
{
	SetModel(m_oldModel);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSPTRIGGER);
	SetRenderMode(RM_TRIGGER);
}

void CompilerTest(void)
{
	string outmsg = ",_control_retinal2,_BeginSequence,_,_0,_-1,_control_retinal3,_BeginSequence,_,_0,_-1,_control_retinal1,_BeginSequence,_,_0,_-1";

	string out_targetname;
	string out_name;
	string out_in;
	string out_data;
	float out_delay;
	int out_uses;
	float c;
	static int outcount = 0;

	out_targetname = sprintf("output_%i\n", outcount);
	outcount++;

	c = tokenizebyseparator(outmsg, ",");
	for (float i = 1; i < c; i+=5) {
		out_name = substring(argv(i), 1,-1);
		out_in = substring(argv(i+1), 1,-1);
		out_data =  substring(argv(i+2), 1,-1);
		out_delay = stof(substring(argv(i+3), 1,-1));
		out_uses = stoi(substring(argv(i+4), 1,-1));

		print(sprintf("%d: %s\n", i, out_name));
		print(sprintf("%d: %s\n", i, out_in));
		print(sprintf("%d: %s\n", i, out_data));
		print(sprintf("%d: %d\n", i, out_delay));
		print(sprintf("%d: %i\n", i, out_uses));
		
		CBaseOutput new_minion = spawn(CBaseOutput);
		new_minion.classname = "triggerminion";
		new_minion.targetname = out_targetname;
		new_minion.m_strTarget = out_name;
		new_minion.m_strInput = out_in;
		new_minion.m_strData = out_data;
		new_minion.m_flDelay = out_delay;
		new_minion.m_iCount = out_uses;
		new_minion.m_iOldCount = out_uses;
	}
}

void
CBaseTrigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "killtarget":
		m_strKillTarget = strValue;
		break;
	case "message":
		m_strMessage = strValue;
		break;
	case "master":
		m_strMaster = strValue;
		break;
	case "team_no":
		m_iTeam = stoi(strValue);
		break;
	case "delay":
		m_flDelay = stof(strValue);
		break;
	case "OnTrigger":
		strValue = strreplace(",", ",_", strValue);
		m_strOnTrigger = strcat(m_strOnTrigger, ",_", strValue);
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
CBaseTrigger::CBaseTrigger(void)
{
	CBaseEntity::CBaseEntity();

	m_strOnTrigger = CreateOutput(m_strOnTrigger);
}
