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

/*QUAKED trigger_camera (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"angles"        Sets the pitch, yaw and roll angles of the camera
"target"        Which entity we're aiming at. Overrides angles.
"wait"          How long to hold onto the target.

Causes the activators first-person camera to switch to the view of this entity.

Trivia:
This entity was introduced in Half-Life (1998).
*/

class trigger_camera:CBaseTrigger
{
	string m_strMoveTo;
	float m_flDelay;
	float m_flWait;

	void(void) trigger_camera;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
trigger_camera::Trigger(entity act, int state)
{
	UseTargets(act, TRIG_TOGGLE, m_flDelay);

	if (m_strMoveTo) {
		entity e = find(world, ::targetname, m_strMoveTo);
		if (e) {
			angles = vectoangles(e.origin - origin);
		}
	}

	Client_TriggerCamera(act, origin, angles, m_flWait);
	//eActivator.view2 = this;

	dprint(sprintf("^2trigger_camera::^3Trigger^7: Camera at %v, %v, for %f sec/s requested\n", 
		origin, angles, m_flWait));
}

void
trigger_camera::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "moveto":
		m_strMoveTo = strValue;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_camera::trigger_camera(void)
{
	CBaseTrigger::CBaseTrigger();
}
