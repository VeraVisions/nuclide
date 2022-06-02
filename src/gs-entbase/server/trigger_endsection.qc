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

/*QUAKED trigger_endsection (0 .5 .8) ?
This trigger shuts down the server.
Useful for when a singleplayer game ends, as it takes you to the main menu.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class trigger_endsection:NSBrushTrigger
{
	void(void) trigger_endsection;

	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
};

void
trigger_endsection::Trigger(entity act, int state)
{
	if (GetMaster() == FALSE)
		return;

	localcmd("disconnect\n");
}

void
trigger_endsection::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_endsection::trigger_endsection(void)
{
}
