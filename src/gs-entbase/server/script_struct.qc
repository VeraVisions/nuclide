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

/*! \brief Server-Entity: FIXME: Unknown */
/*!QUAKED script_struct (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Unknown.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Call of Duty 2 (2005).

@ingroup serverentity
@ingroup pointentity
*/
class
script_struct:ncBrushTrigger
{
public:
	void script_struct(void);
	virtual void Trigger(entity, triggermode_t);
};

void
script_struct::script_struct(void)
{
	
}

void
script_struct::Trigger(entity entityActivator, triggermode_t state)
{
	
}

