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

/*!QUAKED trigger_endsection (.5 .5 .5) ?
# OVERVIEW
This trigger shuts down the server.
Useful for when a singleplayer game ends, as it takes you to the main menu.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
trigger_endsection:NSBrushTrigger
{
public:
	void trigger_endsection(void);
	
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);

};

void
trigger_endsection::trigger_endsection(void)
{
}

void
trigger_endsection::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_endsection::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	localcmd("disconnect\n");
}
