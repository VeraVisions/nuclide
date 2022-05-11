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

/*QUAKED game_player_equip (1 0 0) (-8 -8 -8) (8 8 8) GPEFL_TRIGGERONLY
Entity that emits items when triggered, or upon player spawn (MP-only).

-------- KEYS --------
"targetname" : Name
"master" : Team Master

-------- NOTES --------
When the flag GPEFL_TRIGGERONLY is set, the entity has to be triggered
in order to 'give' the activator the item. Otherwise it'll automatically
'give' every client its noted items upon spawning.
However, this only applies to Multiplayer games. In Singleplayer, the entity
will only work with GPEFL_TRIGGERONLY being set.

I say 'give' very loosely because the entity spawns the item in physical pickup
form above the player. As you can imagine, it's kind of wasteful but this is the
expected behaviour. Some modifications might depend on that...

I still need to implement the Team Master functionality.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	GPEFL_TRIGGERONLY
};

class game_player_equip:NSPointTrigger
{
	string m_strBuffer;

	void(void) game_player_equip;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;

	virtual void(string, vector) SpawnUnit;
};

void
game_player_equip::Save(float handle)
{
	SaveString(handle, "buffer", m_strBuffer);
	super::Save(handle);
}

void
game_player_equip::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "buffer":
		m_strBuffer = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
game_player_equip::SpawnUnit(string cname, vector org)
{
	static void game_player_equip_spawnunit(void) {
		/* these might get overwritten by the spawnfunction */
		vector neworg = self.origin;

		/* become the classname assigned */
		NSEntity t = (NSEntity)self;
		callfunction(self.classname);

		/* apply the saved values back */
		t.origin = t.GetSpawnOrigin() = neworg;

		/* spawn anew */
		t.Respawn();
	}

	entity unit = spawn();
	unit.classname = cname;
	unit.think = game_player_equip_spawnunit;
	unit.nextthink = time;
	unit.real_owner = this;
	setorigin(unit, org);
	NSLog("^2game_player_equip::^3Trigger^7: Spawning %s",
	       cname);
}

void
game_player_equip::Trigger(entity act, int state)
{
	int total, i, count, x;
	string cname;

	if (!(act.flags & FL_CLIENT)) {
		print("^1game_player_equip^7::^1Trigger: Activator not a client!\n");
		return;
	}

	/* loop through all catalogued entries */
	total = tokenizebyseparator(m_strBuffer, " ");

	for (i = 0; i < total; i+=2) {
		cname = argv(i);
		count = stoi(argv(i+1));

		for (x = 0; x < count; x++) {
			if (isfunction(strcat("spawnfunc_", cname))) {
				cname = strcat("spawnfunc_", cname);
				SpawnUnit(cname, act.origin);
			} else if (isfunction(cname)) {
				SpawnUnit(cname, act.origin);
			}
		}
	}
}

void
game_player_equip::SpawnKey(string strKey, string strValue)
{
	/* like multi_manager, we save non-field infos in the spawndata */
	switch (strKey) {
	case "{":
	case "}":
	case "classname":
	case "origin":
	case "targetname":
	case "spawnflags":
	case "angle":
	case "angles":
		break;
	default:
		m_strBuffer = sprintf("%s%s %s ", m_strBuffer, strKey, strValue);
	}
}

void
game_player_equip::game_player_equip(void)
{
	super::NSPointTrigger();
}
