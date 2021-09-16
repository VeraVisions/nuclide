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

/*QUAKED func_tankcontrols (0 .5 .8) ?
Brush that marks the usable region of a func_tankmortar, in order
to gain control.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class func_tankcontrols:CBaseTrigger
{
	void(void) func_tankcontrols;

	virtual void(void) OnPlayerUse;
	virtual void(void) Respawn;
};

void
func_tankcontrols::OnPlayerUse(void)
{
	entity f;
	CBaseVehicle tank;

	tank = __NULL__;

	if (!(eActivator.flags & FL_CLIENT)) {
		return;
	}

	for (f = world; (f = find(f, ::targetname, target));) {
		/* we found the right entity */
		if (f.classname == "func_tank" || f.classname == "func_tankmortar") {
			tank = (CBaseVehicle)f;
		}
	}

	if (tank) {
		if (!tank.m_eDriver)
			tank.PlayerEnter((base_player)eActivator);
		else if (tank.m_eDriver == eActivator)
			tank.PlayerLeave((base_player)eActivator);
	}
}

void
func_tankcontrols::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	PlayerUse = OnPlayerUse;

#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif
}

void
func_tankcontrols::func_tankcontrols(void)
{
	CBaseTrigger::CBaseTrigger();
}
