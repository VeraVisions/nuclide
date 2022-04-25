/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
Teleportation volume. Teleports anything it touches to the position of
any entity set as the "target". Works best with info_teleport_destination.

-------- KEYS --------
"targetname" : Name
"target" : Which target to teleport to.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TRIGTELE_MONSTERS,
	TRIGTELE_NOCLIENTS
};

class trigger_teleport:NSBrushTrigger
{
	void(void) trigger_teleport;

	virtual void(entity) Touch;
	virtual void(void) Respawn;
};

void
trigger_teleport::Touch(entity eToucher)
{
	if (GetMaster() == FALSE)
		return;
	if (HasSpawnFlags(TRIGTELE_NOCLIENTS) && eToucher.flags & FL_CLIENT)
		return;
	if (!HasSpawnFlags(TRIGTELE_MONSTERS) && eToucher.flags & FL_MONSTER)
		return;

	if (eToucher.movetype != MOVETYPE_NONE) {
		eActivator = eToucher;
		entity eTarget = find(world, ::targetname, target);

		if (eTarget) {
			vector endpos = eTarget.origin + [0,0,16];
			setorigin(eToucher, endpos);
			dprint(sprintf("^2trigger_teleport::^3Touch^7: Teleported '%s' to `%v`\n", 
				eToucher.netname, endpos));
		} else {
			print(sprintf("^2trigger_teleport::^3Touch^7: Failed to teleport '%s'\n", 
				eToucher.netname));
		}
	}
}

void
trigger_teleport::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_teleport::trigger_teleport(void)
{
	super::NSBrushTrigger();
}

/*QUAKED info_teleport_destination (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name

Entity designed to designate a destination for a trigger_teleport.
*/
CLASSEXPORT(info_teleport_destination, info_notnull)
