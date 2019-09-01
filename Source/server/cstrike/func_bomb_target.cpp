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

class func_bomb_target:CBaseTrigger
{
	void() func_bomb_target;
	virtual void() touch;
	virtual void() Respawn;
};

void func_bomb_target::touch(void)
{
	if (iBombPlanted == TRUE) {
		return;
	}

	/* This will be cleared every frame inside SV_RunClientCommand */
	if ((other.classname == "player") && (other.team == TEAM_T)) {
		other.fInBombZone = TRUE;
	}
}

void func_bomb_target::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void func_bomb_target::func_bomb_target(void)
{
	func_bomb_target::Respawn();
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
	iBombZones++;
}
