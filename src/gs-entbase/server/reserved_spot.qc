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

/*! \brief Server-Entity: Reserved Player Spot */
/*!QUAKED reserved_spot (0 .5 .8) ?
# OVERVIEW
A clip for anything but players. Effectively preventing anything from
going near this spot.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup brushentity
*/
class
reserved_spot:ncEntity
{
public:
	void reserved_spot(void);

	virtual void Respawn(void);
};

void
reserved_spot::reserved_spot(void)
{

}

void
reserved_spot::Respawn(void)
{
	super::Respawn();
	ClearAngles();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	SetSkin(-17); /* undocumented MONSTERCLIP */
	Hide();
}
