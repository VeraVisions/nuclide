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

enum
{ 
	USE_TOGGLE,
	USE_CONTINOUS
};

class CBaseTrigger:CBaseEntity
{
	int m_strGlobalState;
	string m_strKillTarget;
	string m_strMessage;
	string m_strMaster;
	int m_iUseType;
	int m_iTeam;

	void(void) CBaseTrigger;
	virtual void(void) Trigger;
	virtual void(void) UseTargets;
	virtual int(void) GetValue;
	virtual int(void) GetMaster;
	virtual void(float) UseTargets_Delay;
	virtual void(void) InitBrushTrigger;
	virtual void(void) InitPointTrigger;
};

void
CBaseTrigger::UseTargets(void)
{
	for (entity eFind = world; (eFind = find(eFind, CBaseTrigger::m_strTargetName, m_strTarget));) {
		CBaseTrigger trigger = (CBaseTrigger) eFind;
		dprint(sprintf("^2%s::^3UseTargets^7: Triggering %s `%s`\n", 
			this.classname, eFind.classname, trigger.m_strTargetName));
		if (trigger.Trigger != __NULL__) {
			trigger.Trigger();
		}
	}

	/* hack: check to see if this is a sound file */
	/*if (whichpack(m_strMessage)) {
		print(m_strMessage);
		print("\n");
	} else {
		if (m_strMessage && eActivator.flags & FL_CLIENT) {
			centerprint(eActivator, m_strMessage);
		}
	}*/

	if (m_strKillTarget) {
		entity eKill = find(world, CBaseTrigger::m_strTargetName, m_strKillTarget);
		if (eKill) {
			remove(eKill);
		}
	}
}

int
CBaseTrigger::GetValue(void)
{
	return TRUE;
}

int
CBaseTrigger::GetMaster(void)
{
	CBaseTrigger t;

	/* default to success */
	if (!m_strMaster) {
		return TRUE;
	}

	t = (CBaseTrigger)find(world, CBaseTrigger::m_strTarget, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		return FALSE;
	}

	return t.GetValue();
}

void
CBaseTrigger::UseTargets_Delay (float fDelay)
{
	static void Entities_UseTargets_Delay_Think(void) {
		eActivator = self.owner;
		CBaseTrigger::UseTargets();
		remove(self);
	}

	dprint(sprintf("^2%s::^3UseTargets_Delay^7: Triggering `%s`\n", 
		this.classname, m_strTarget));

	CBaseTrigger eTimer = spawn(CBaseTrigger);
	eTimer.owner = eActivator;
	eTimer.think = Entities_UseTargets_Delay_Think;
	eTimer.m_strTarget = m_strTarget;
	eTimer.nextthink = time + fDelay;
}

void
CBaseTrigger::Trigger(void)
{
	
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
	setmodel(this, m_oldModel);
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSPTRIGGER;
	m_iRenderMode = RM_TRIGGER;
}

void
CBaseTrigger::CBaseTrigger(void)
{
	CBaseEntity::CBaseEntity();
	m_strMessage = "";

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "killtarget":
			m_strKillTarget = argv(i+1);
			break;
		case "message":
			m_strMessage = argv(i+1);
			break;
		case "master":
			m_strMaster = argv(i+1);
			break;
		case "team_no":
			m_iTeam = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
}
