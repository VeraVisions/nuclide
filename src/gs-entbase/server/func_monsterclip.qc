/*
 * Copyright (c) 2023 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/*! \brief Server-Entity: Monster Clip */
/*!QUAKED func_monsterclip (0 .5 .8) ?
# OVERVIEW
A clip isolated to monster entities, as long as they have a MONSTERCLIP
spawnflag set.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup brushentity
*/
class
func_monsterclip:NSEntity
{
public:
	void func_monsterclip(void);

	virtual void Respawn(void);
};

void
func_monsterclip::func_monsterclip(void)
{

}

void
func_monsterclip::Respawn(void)
{
	super::Respawn();
	ClearAngles();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	SetSkin(-17); /* undocumented MONSTERCLIP */
	Hide();
}