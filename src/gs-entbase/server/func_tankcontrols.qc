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

/*! \brief Server-Entity: func_tankmortar Controller */
/*!QUAKED func_tankcontrols (0 .5 .8) ?
# OVERVIEW
Brush that marks the usable region of a func_tankmortar, in order
to gain control.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_tankcontrols:ncBrushTrigger
{
public:
	void func_tankcontrols(void);
	
	virtual void PlayerUse(void);

};

void
func_tankcontrols::func_tankcontrols(void)
{
}

void
func_tankcontrols:: PlayerUse(void)
{
	entity f;
	ncVehicle tank;

	tank = __NULL__;

	if (!(eActivator.flags & FL_CLIENT)) {
		return;
	}

	for (f = world; (f = find(f, ::targetname, target));) {
		/* we found the right entity */
		if (f.classname == "func_tank" || f.classname == "func_tankmortar") {
			tank = (ncVehicle)f;
		}
	}

	if (tank) {
		if (!tank.m_eDriver)
			tank.PlayerEnter((ncPlayer)eActivator);
		else if (tank.m_eDriver == eActivator)
			tank.PlayerLeave((ncPlayer)eActivator);
	}
}
