/*
 * Copyright (c) 2024 Vera Visions LLC.
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

/*! \brief Server-Entity: Scriptable Alias Model */
/*!QUAKED script_model (1 0 0) (-16 -16 -16) (16 16 16) ORIENT_LOD NO_SHADOW  NO_STATIC_SHADOWS
# OVERVIEW
Upon being triggered, the entity will spawn item_food in its place in
the shape of a soda can.

# KEYS
- "targetname" : Name
- "model" : Path of the model.

# SPAWNFLAGS
- ORIENT_LOD (1) : Turn to player when lod models change
- NO_SHADOW (2) : Will cast no shadows.
- NO_STATIC_SHADOWS (4) : Will cast no lightmap shadows.

# TRIVIA
This entity was introduced in Call of Duty (2003).

@ingroup serverentity
@ingroup pointentity
*/
class
script_model:ncPointTrigger
{
public:
	void script_model(void);
	virtual void Trigger(entity, triggermode_t);
};

void
script_model::script_model(void)
{
	
}

void
script_model::Trigger(entity entityActivator, triggermode_t state)
{
	
}


