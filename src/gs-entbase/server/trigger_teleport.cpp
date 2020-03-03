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

/*QUAKED trigger_teleport (0 .5 .8) ?
"targetname"    Name
"target"        Which target to teleport to.

Teleportation volume. Teleports anything it touches to the position of
any entity set as the "target". Works best with info_teleport_destination.
*/

class trigger_teleport:CBaseTrigger
{
	void() trigger_teleport;

	virtual void() touch;
	virtual void() Respawn;
};

void trigger_teleport::touch(void)
{
	if (other.health > 0 || other.solid == SOLID_SLIDEBOX) {
		eActivator = other;
		entity eTarget = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

		if (eTarget) {
			setorigin(other, eTarget.origin + [0,0,16]);
		}
	}
}

/* TODO: Make this redundant */
void trigger_teleport::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_teleport::trigger_teleport(void)
{
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
}

/*QUAKED info_teleport_destination (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name

Entity designed to designate a destination for a trigger_teleport.
*/
CLASSEXPORT(info_teleport_destination, info_notnull)
