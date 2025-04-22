/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Level Transition Volume */
/*!QUAKED trigger_transition (.5 .5 .5) ?
# OVERVIEW
Defines level transition regions.
All entities touching this volume will carry across to the next level.

# KEYS
- "targetname" : Name

# NOTES
In order for this entity to work, one has to assign a working info_landmark entity to a trigger_changelevel, and give this entity the same targetname as said landmark.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
trigger_transition:ncBrushTrigger
{
public:
	void trigger_transition(void);

	/* overrides */
	virtual void Respawn(void);
};

void
trigger_transition::trigger_transition(void)
{
}

void
trigger_transition::Respawn(void)
{
	InitBrushTrigger();
	SetSolid(SOLID_NOT);
}
