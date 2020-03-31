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

/*QUAKED func_ladder (0 .5 .8) ?
"targetname"    Name

Ladder volume. Climb up ladders with this one simple brush.
*/

string g_laddersnd[] = {
	"player/pl_ladder1.wav",
	"player/pl_ladder2.wav",
	"player/pl_ladder3.wav",
	"player/pl_ladder4.wav"
};

class func_ladder:CBaseEntity
{
	void() func_ladder;

	virtual void() Respawn;
};


void func_ladder::Respawn(void)
{
	setmodel( this, m_oldModel );
	movetype = MOVETYPE_NONE;
	skin = CONTENT_LADDER;
	solid = SOLID_BSP;

#ifdef GS_DEVELOPER
	m_iRenderMode = RM_SOLID;
	m_flRenderAmt = 0.25f;
#else
	m_iRenderMode = RM_SOLID;
	m_flRenderAmt = 0.0f;
#endif
}

void func_ladder :: func_ladder ( void )
{
	setmodel( this, m_oldModel );
	movetype = MOVETYPE_NONE;
	skin = CONTENT_LADDER;
	solid = SOLID_BSP;
}
