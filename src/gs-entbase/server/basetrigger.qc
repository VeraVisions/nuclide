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
	if (!outname)
		return;

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

/* input is a 5 parameter, commar separated string, output is the targetname
   of a minion entity that'll handle the triggering (and counting down of uses)
   as defined in the Source Input/Output specs */
string
CBaseTrigger::CreateOutput(string outmsg)
{
	static int outcount = 0;
	string outname = "";
	float c;

	if (!outmsg)
		return ("");

	outname = sprintf("output_%i\n", outcount);
	outcount++;

	/* to make sure tokenize 'remembers' to tell us about the commonly
	   empty data string, we prepared the output string beforehand to
	   at least contain a _ symbol after the comma separator... now
	   we gotta clip that away using substring(). messy, but that's the
	   only way to keep them at 5 argv() calls per output */
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

		/* print final debug output */
		dprint(sprintf("^2%s::CreateOutput report:\n", classname));
		dprint(sprintf("Target: %s\n", new_minion.m_strTarget));
		dprint(sprintf("Input: %s\n", new_minion.m_strInput));
		dprint(sprintf("Data Message: %s\n", new_minion.m_strData));
		dprint(sprintf("Delay: %f\n", new_minion.m_flDelay));
		dprint(sprintf("Uses: %i\n\n", new_minion.m_iCount));
	}

	/* return the name that'll act as the trigger for all outputs */
	return outname;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
CBaseTrigger::Input(entity eAct, string strInput, string strData)
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


/* legacy trigger architecture */
void
CBaseTrigger::Trigger(entity act, int state)
{
	dprint(sprintf("^2%s::^3Input^7: Triggerd by %s with no consequence\n", 
		this.classname, act.classname));
}

void
CBaseTrigger::UseTargets(entity act, int state, float fDelay)
{
	static void Entities_UseTargets_Think(void) {
		CBaseTrigger::UseTargets(self.owner, self.health, 0.0f);
		remove(self);
	}

	if (fDelay > 0.0f) {
		dprint(sprintf("^2%s::^3UseTargets^7: Triggering `%s`\n", 
			this.classname, target));

		CBaseTrigger eTimer = spawn(CBaseTrigger);
		eTimer.owner = act;
		eTimer.think = Entities_UseTargets_Think;
		eTimer.target = target;
		eTimer.nextthink = time + fDelay;
		eTimer.health = state;  /* ugly */
	} else {
		for (entity f = world; (f = find(f, ::targetname, target));) {
			CBaseTrigger trigger = (CBaseTrigger)f;

			dprint(sprintf("^2%s::^3UseTargets^7:" \
			       "Triggering %s `%s` from %s\n", \
			        this.classname, f.classname, \
			        trigger.targetname, act.classname));

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(act, state);
			}
		}

		if (m_strKillTarget) {
			entity eKill = find(world, ::targetname, m_strKillTarget);
			if (eKill) {
				remove(eKill);
			}
		}
	}
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
		return (1);
	}

	t = (CBaseTrigger)find(world, ::target, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		/*dprint(sprintf("^2%s::^3GetMaster^7: Invalid master, return success\n", 
		this.classname));*/
		return (1);
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
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetSolid(SOLID_TRIGGER);
}

void
CBaseTrigger::InitBrushTrigger(void)
{
	SetModel(m_oldModel);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSPTRIGGER);

#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif
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
	case "OnUser1":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser1 = strcat(m_strOnUser1, ",_", strValue);
		break;
	case "OnUser2":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser2 = strcat(m_strOnUser2, ",_", strValue);
		break;
	case "OnUser3":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser3 = strcat(m_strOnUser3, ",_", strValue);
		break;
	case "OnUser4":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser4 = strcat(m_strOnUser4, ",_", strValue);
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
	m_strOnUser1 = CreateOutput(m_strOnUser1);
	m_strOnUser2 = CreateOutput(m_strOnUser2);
	m_strOnUser3 = CreateOutput(m_strOnUser3);
	m_strOnUser4 = CreateOutput(m_strOnUser4);
}
