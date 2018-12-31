/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CTriggerCamera:CBaseTrigger
{
	float m_flWait;

	void() CTriggerCamera;
	virtual void() Trigger;
};

void CTriggerCamera::Trigger(void)
{
	if (m_strTarget) {
		entity e = find(world, CBaseTrigger::m_strTargetName, m_strTarget);
		if (e) {
			angles = vectoangles(e.origin - origin);
			angles_x *= -1;
		}
	}
	Client_TriggerCamera(eActivator, origin, angles, m_flWait);
}

void CTriggerCamera::CTriggerCamera(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "wait":
			m_flWait = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}

CLASSEXPORT(trigger_camera, CTriggerCamera)
