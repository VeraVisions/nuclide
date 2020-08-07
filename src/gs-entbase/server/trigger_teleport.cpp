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

/*QUAKED trigger_teleport (0 .5 .8) ?
"targetname"    Name
"target"        Which target to teleport to.

Teleportation volume. Teleports anything it touches to the position of
any entity set as the "target". Works best with info_teleport_destination.
*/

enumflags
{
	TRIGTELE_MONSTERS,
	TRIGTELE_NOCLIENTS
};

class trigger_teleport:CBaseTrigger
{
	void(void) trigger_teleport;

	virtual void(void) touch;
};

void
trigger_teleport::touch(void)
{
	if (GetMaster() == FALSE)
		return;
	if (spawnflags & TRIGTELE_NOCLIENTS && other.flags & FL_CLIENT)
		return;
	if (!(spawnflags & TRIGTELE_MONSTERS) && other.flags & FL_MONSTER)
		return;

	if (other.health > 0 || other.solid == SOLID_SLIDEBOX) {
		eActivator = other;
		entity eTarget = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

		if (eTarget) {
			vector endpos = eTarget.origin + [0,0,16];
			setorigin(other, endpos);
			dprint(sprintf("^2trigger_teleport::^3touch^7: Teleported '%s' to `%v`\n", 
				other.netname, endpos));
		} else {
			print(sprintf("^2trigger_teleport::^3touch^7: Failed to teleport '%s'\n", 
				other.netname));
		}
	}
}

void
trigger_teleport::trigger_teleport(void)
{
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
}

/*QUAKED info_teleport_destination (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name

Entity designed to designate a destination for a trigger_teleport.
*/
CLASSEXPORT(info_teleport_destination, info_notnull)
