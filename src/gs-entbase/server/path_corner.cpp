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

/*QUAKED path_corner (1 0 0) (-8 -8 -8) (8 8 8) PC_WAIT PC_TELEPORT PC_FIREONCE
"targetname"    Name
"target"        Next node.
"message"       Target to trigger when a train passes this node.
"speed"         New speed for passing train.
"yaw_speed"     New yaw rotation for passing train. Currently unused.
"wait"          Waiting time until we go to the next node.

Node entities used for func_trains and func_guntargets.

When the PC_WAIT flag is set, the train will stop moving once it's passed this
node. The train will have to be triggered again for it to continue moving.
This is useful for elevators.

When the PC_TELEPORT flag is set, the train passing this node will immediately
teleport to the position of the next node (target).

With the PC_FIREONCE flag set, it'll only fire its target (message) once.
*/

#ifdef DEVELOPER
var int autocvar_dev_cornerspeed = 0;
#endif

enumflags {
	PC_WAIT,
	PC_TELEPORT,
	PC_FIREONCE
};

class path_corner:CBaseTrigger
{
	int m_iFired;
	float m_flSpeed;
	float m_flYawSpeed;
	float m_flWait;

	void() path_corner;
	virtual void() Trigger;
	virtual void() Respawn;
};

void
path_corner::Trigger(void)
{
	entity a;

	if ((spawnflags & PC_FIREONCE) && (m_iFired)) {
		return;
	}

	for (a = world; (a = find(a, CBaseTrigger::m_strTargetName, m_strMessage));) {
		CBaseTrigger trigger = (CBaseTrigger)a;
		trigger.Trigger();
		m_iFired = TRUE;
	}
}

void
path_corner::Respawn(void)
{
#ifdef DEVELOPER
	if (autocvar_dev_cornerspeed != 0) {
		m_flSpeed = autocvar_dev_cornerspeed;
	}
#endif

	m_iFired = FALSE;
}

void
path_corner::path_corner(void)
{
	CBaseTrigger::CBaseTrigger();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		case "yaw_speed":
			m_flYawSpeed = stof(argv(i+1));
			break;
		case "wait":
			m_flWait = stof(argv(i+1));
			break;
		case "message":
			m_strMessage = argv(i+1);
			break;
		default:
			break;
		}
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}
	if (!m_flWait) {
		m_flWait = 1.0f;
	}
}
