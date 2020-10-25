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

/*QUAKED func_ladder (0 .5 .8) ?
"targetname"    Name

Ladder volume. Climb up ladders with this one simple brush.

Trivia:
This entity was introduced in Half-Life (1998).
*/

class func_ladder:CBaseEntity
{
	virtual void(void) Respawn;
};

void func_ladder::Respawn(void)
{
	SetModel(m_oldModel);
	SetMovetype(MOVETYPE_NONE);
	SetSkin(CONTENT_LADDER);
	SetSolid(SOLID_BSP);
	SetRenderMode(RM_TRIGGER);
}
