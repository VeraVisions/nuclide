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

/*! \brief Server-Entity: Player Movement Inhibitor */
/*!QUAKED trigger_playerfreeze (.5 .5 .5) (-8 -8 -8) (8 8 8)
# OVERVIEW
Trigger that freezes all clients, until it is triggered again.
Freezing a player means they're unable to move, they can still look around.

# KEYS
- "targetname" : Name
- "killtarget" : Target to remove when triggered.

# NOTES
Ideas: Add ability to supress looking around, firing weapons, using items
and so on.

# TRIVIA
This entity was introduced in Opposing Force (1999).

@ingroup serverentity
@ingroup pointentity
*/
class
trigger_playerfreeze:ncBrushTrigger
{
public:
	void trigger_playerfreeze(void);
	
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void customphysics(void);
};

void
trigger_playerfreeze::trigger_playerfreeze(void)
{
}

void
trigger_playerfreeze::Respawn(void)
{
	SetValue(0i);
}

void
trigger_playerfreeze::Trigger(entity act, triggermode_t state)
{
	int value = GetValue(this);

	if (GetMaster(act) == false) {
		return;
	}

	value = 1 - value;

	if (value == 0) {
		SetValue(0i);
		EntLog("Unfreezing players.");

		/* force unfreeze */
		for (entity f = world; (f = next.Player(f));) {
			f.m_nuclideFlags &= ~VFL_FROZEN;
		}
	} else {
		SetValue(1i);
		EntLog("Freezing players.");
	}
}

void
trigger_playerfreeze::customphysics(void)
{
	if (GetValue(this) == 0) {
		return;
	}

	/* some games might unset this flag every single frame */
	for (entity f = world; (f = next.Player(f));) {
		f.m_nuclideFlags |= VFL_FROZEN;
	}
}
