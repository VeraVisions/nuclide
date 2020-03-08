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

/*QUAKED trigger_endsection (0 .5 .8) ?
"targetname"    Name

This trigger shuts down the server.
Useful for when a singleplayer game ends, as it takes you to the main menu.
*/

class trigger_endsection:CBaseTrigger
{
	void() trigger_endsection;

	virtual void() Trigger;
	virtual void() Respawn;
}

void trigger_endsection::Trigger ( void )
{
	localcmd( "disconnect\n" );
}

/* TODO: Make this redundant */
void trigger_endsection::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_endsection::trigger_endsection(void)
{
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
}
