/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
*/

class trigger_camera:CBaseTrigger
{
	float m_flWait;

	void() trigger_camera;
	virtual void() Trigger;
};

void trigger_camera::Trigger(void)
{
	if (m_strTarget) {
		entity e = find(world, CBaseTrigger::m_strTargetName, m_strTarget);
		if (e) {
			angles = vectoangles(e.origin - origin);
			//angles[0] *= -1;
		}
	}

	Client_TriggerCamera(eActivator, origin, angles, m_flWait);

	dprint( sprintf( "^2trigger_camera::^3Trigger^7: Camera at %v, %v, for %f sec/s requested\n", 
		origin, angles, m_flWait ) );
}

void trigger_camera::trigger_camera(void)
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
