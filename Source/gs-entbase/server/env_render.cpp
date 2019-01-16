/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags {
	SF_NORENDERFX,
	SF_NORENDERAMT,
	SF_NORENDERMODE,
	SF_NORENDERCOLOR
};

class env_render:CBaseTrigger
{
	virtual void() Trigger;
};

void env_render::Trigger(void)
{
	for (entity eFind = world; 
		(eFind = find(eFind, CBaseTrigger::m_strTargetName, m_strTarget));) {
		CBaseEntity trigger = (CBaseEntity) eFind;
		if (!(spawnflags & SF_NORENDERMODE)) {
			trigger.m_rendermode = m_rendermode;
		}
		if (!(spawnflags & SF_NORENDERCOLOR)) {
			trigger.m_rendercolor = m_rendercolor;
		}
		if (!(spawnflags & SF_NORENDERAMT)) {
			trigger.m_renderamt = m_renderamt;
		}
		trigger.RendermodeUpdate();
	}
}

