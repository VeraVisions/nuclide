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
NSTrigger::NSTrigger(void)
{
#ifdef SERVER
	m_oldstrTarget = __NULL__;
	m_strGlobalState = __NULL__;
	m_strKillTarget = __NULL__;
	m_strMessage = __NULL__;
	m_strMaster = __NULL__;
	m_iUseType = 0i;
	m_iTeam = 0i;
	m_iValue = 0i;
	m_flDelay = 0.0f;
#endif
}

#ifdef SERVER
/* legacy trigger architecture */
void
NSTrigger::Trigger(entity act, int state)
{
	NSLog("^2%s::^3Input^7: Triggerd by %s with no consequence", 
		classname, act.classname);
}

void
NSTrigger::UseTargets(entity act, int state, float fDelay)
{
	static void Entities_UseTargets_Think(void) {
		NSTrigger::UseTargets(self.owner, self.health, 0.0f);
		remove(self);
	}

	if (!target || target == "")
		return;

	if (fDelay > 0.0f) {
		NSLog("^2%s::^3UseTargets^7: Triggering `%s`", 
			classname, target);

		NSTrigger eTimer = spawn(NSTrigger);
		eTimer.owner = act;
		eTimer.think = Entities_UseTargets_Think;
		eTimer.target = target;
		eTimer.nextthink = time + fDelay;
		eTimer.health = state;  /* ugly */
	} else {
		if (m_strMessage) {
			env_message_single(act, m_strMessage);
		}

		for (entity f = world; (f = find(f, ::targetname, target));) {
			NSTrigger trigger = (NSTrigger)f;

			NSLog("^2%s::^3UseTargets^7:" \
			       "Triggering %s `%s` from %s", \
			        classname, f.classname, \
			        trigger.targetname, act.classname);

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(act, state);
			}
		}

		if (m_strKillTarget && m_strKillTarget != "") {
			entity eKill = find(world, ::targetname, m_strKillTarget);
			if (eKill) {
				remove(eKill);
			}
		}
	}
}

void
NSTrigger::SetTriggerTarget(string name)
{
	target = name;
}

int
NSTrigger::GetValue(void)
{
	return m_iValue;
}

globalstate_t
NSTrigger::GetGlobalValue(string strName)
{
	for (int i = 0; i < (tokenize(cvar_string(CENVGLOBAL_CVAR))); i += 2) {
		if (argv(i) == strName) {
			return stof(argv(i+1));
		}
	}
	return (0);
}

int
NSTrigger::GetMaster(void)
{
	NSTrigger t;

	/* default to success */
	if (!m_strMaster) {
		/*NSLog("^2%s::^3GetMaster^7: No master, return success", 
		classname));*/
		return (1);
	}

	t = (NSTrigger)find(world, ::targetname, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		NSLog("^2%s::^3GetMaster^7: Invalid master (%s), return success", 
		classname, m_strMaster);
		return (1);
	}

	if (t.GetValue() == 1)
		NSLog("^2%s::^3GetMaster^7: %s learns %s ^2POSITIVE", 
		classname, targetname, m_strMaster);
	else
		NSLog("^2%s::^3GetMaster^7: %s learns %s ^1NEGATIVE", 
		classname, targetname, m_strMaster);
	
	return t.GetValue();
}

string
NSTrigger::GetTriggerTarget(void)
{
	return target;
}

bool
NSTrigger::HasTriggerTarget(void)
{
	if not (target)
		return false;

	return true;
}

bool
NSTrigger::HasTargetname(void)
{
	if not (targetname)
		return false;

	return true;
}

void
NSTrigger::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_oldstrTarget", m_oldstrTarget);
	SaveString(handle, "m_strGlobalState", m_strGlobalState);
	SaveString(handle, "m_strKillTarget", m_strKillTarget);
	SaveString(handle, "m_strMessage", m_strMessage);
	SaveString(handle, "m_strMaster", m_strMaster);
	SaveInt(handle, "m_iUseType", m_iUseType);
	SaveInt(handle, "m_iTeam", m_iTeam);
	SaveInt(handle, "m_iValue", m_iValue);
	SaveFloat(handle, "m_flDelay", m_flDelay);
}
void
NSTrigger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_oldstrTarget":
		m_oldstrTarget = ReadString(strValue);
		break;
	case "m_strGlobalState":
		m_strGlobalState = ReadString(strValue);
		break;
	case "m_strKillTarget":
		m_strKillTarget = ReadString(strValue);
		break;
	case "m_strMessage":
		m_strMessage = ReadString(strValue);
		break;
	case "m_strMaster":
		m_strMaster = ReadString(strValue);
		break;
	case "m_iUseType":
		m_iUseType = ReadInt(strValue);
		break;
	case "m_iTeam":
		m_iTeam = ReadInt(strValue);
		break;
	case "m_iValue":
		m_iValue = ReadInt(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSTrigger::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Trigger":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super:: Input(eAct, strInput, strData);
	}
}
#endif

void
NSTrigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
#ifdef SERVER
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
	case "globalstate":
		m_strGlobalState = strValue;
		break;
#endif
	default:
		NSIO::SpawnKey(strKey, strValue);
		break;
	}
}
