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

/*QUAKED func_illusionary (0 .5 .8) ?
"targetname"    Name

Brush that lets light to pass through it and is non-solid.
On idTech 2 BSPs, it will change texture variants when triggered.

Trivia:
This entity was introduced in Quake (1996).
*/

class func_illusionary:CBaseEntity
{
	void(void) func_illusionary;

	virtual void(void) Use;
};

void func_illusionary::func_illusionary(void)
{
	CBaseEntity::CBaseEntity();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_NOT);
	SetModel(model);
	SetOrigin(origin);

	// TODO: Add support for (skin) -1 = Empty, -7 = Volumetric light
	if (skin < 0) {
		SetSkin(0);
	}
}

void func_illusionary::Use(void)
{
	SetSkin(1-skin);
}
