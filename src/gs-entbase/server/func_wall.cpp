/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED func_wall (0 .5 .8) ?
"targetname"    Name

Brush that lets light to pass through it.
On idTech 2 BSPs, it will change texture variants when triggered.
*/

class func_wall:CBaseTrigger
{
	void(void) func_wall;
	virtual void(void) Trigger;
};

void func_wall::func_wall(void)
{
	precache_model(model);
	//angles = [0,0,0];
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	SetModel(model);
	SetOrigin(origin);
	CBaseTrigger::CBaseTrigger();
}

void func_wall::Trigger(void)
{
	frame = 1 - frame;
}
