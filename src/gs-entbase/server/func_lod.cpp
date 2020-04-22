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

/*QUAKED func_lod (0 .5 .8) ?
"targetname"    Name

Brush that lets light to pass through it.
On idTech 2 BSPs, it will change texture variants when triggered.
*/

class func_lod:CBaseEntity
{
	void(void) func_lod;
	virtual float(entity, float) SendEntity;
};

float func_lod::SendEntity (entity a, float b)
{
	return FALSE;
}

void func_lod::func_lod(void)
{
	CBaseEntity::CBaseEntity();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "Solid":
		case "solid":
			solid = stoi(argv(i+1)) == 1 ? SOLID_NOT : SOLID_BSP;
			break;
		default:
			break;
		}
	}

	precache_model(model);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(model);
	SetOrigin(origin);
}
