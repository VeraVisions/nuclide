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
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
CBaseTrigger::CBaseTrigger(void)
{
	CBaseEntity::CBaseEntity();
}
