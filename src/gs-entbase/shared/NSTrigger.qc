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

#ifdef SERVER
/* legacy trigger architecture */
void
NSTrigger::Trigger(entity act, int state)
{
	dprint(sprintf("^2%s::^3Input^7: Triggerd by %s with no consequence\n", 
		this.classname, act.classname));
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
		dprint(sprintf("^2%s::^3UseTargets^7: Triggering `%s`\n", 
			this.classname, target));

		NSTrigger eTimer = spawn(NSTrigger);
		eTimer.owner = act;
		eTimer.think = Entities_UseTargets_Think;
		eTimer.target = target;
		eTimer.nextthink = time + fDelay;
		eTimer.health = state;  /* ugly */
	} else {
		for (entity f = world; (f = find(f, ::targetname, target));) {
			NSTrigger trigger = (NSTrigger)f;

			dprint(sprintf("^2%s::^3UseTargets^7:" \
			       "Triggering %s `%s` from %s\n", \
			        this.classname, f.classname, \
			        trigger.targetname, act.classname));

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

int
NSTrigger::GetValue(void)
{
	return m_iValue;
}

int
NSTrigger::GetGlobalValue(string strName)
{
	for (int i = 0; i < (tokenize(cvar_string(CENVGLOBAL_CVAR))); i += 2) {
		if (argv(i) == strName) {
			return stoi(argv(i+1));
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
		/*dprint(sprintf("^2%s::^3GetMaster^7: No master, return success\n", 
		this.classname));*/
		return (1);
	}

	t = (NSTrigger)find(world, ::targetname, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		print(sprintf("^2%s::^3GetMaster^7: Invalid master (%s), return success\n", 
		this.classname, m_strMaster));
		return (1);
	}

	if (t.GetValue() == 1)
		print(sprintf("^2%s::^3GetMaster^7: %s learns %s ^2POSITIVE\n", 
		this.classname, targetname, m_strMaster));
	else
		print(sprintf("^2%s::^3GetMaster^7: %s learns %s ^1NEGATIVE\n", 
		this.classname, targetname, m_strMaster));
	
	return t.GetValue();
}

void
NSTrigger::Save(float handle)
{
	SaveString(handle, "target", target);
	SaveString(handle, "killtarget", m_strKillTarget);
	SaveString(handle, "message", m_strMessage);
	SaveString(handle, "master", m_strMaster);
	SaveInt(handle, "team_no", m_iTeam);
	SaveFloat(handle, "delay", m_flDelay);
	super::Save(handle);
}
void
NSTrigger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "target":
		target = ReadString(strValue);
		break;
	case "killtarget":
		m_strKillTarget = ReadString(strValue);
		break;
	case "message":
		m_strMessage = ReadString(strValue);
		break;
	case "master":
		m_strMaster = ReadString(strValue);
		break;
	case "team_no":
		m_iTeam = ReadInt(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

void
NSTrigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "target":
		target = strValue;
		break;
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
#endif
	default:
		NSIO::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSTrigger::NSTrigger(void)
{
	super::NSIO();
}
