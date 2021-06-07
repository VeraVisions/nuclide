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

class func_lod:CBaseEntity
{
	void(void) func_lod;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
};

float
func_lod::SendEntity(entity a, float b)
{
	return (0);
}

void
func_lod::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "Solid":
	case "solid":
		solid = stoi(strValue) == 1 ? SOLID_NOT : SOLID_BSP;
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
	}
}

void
func_lod::func_lod(void)
{
	CBaseEntity::CBaseEntity();
	SetMovetype(MOVETYPE_PUSH);
	SetModel(model);
	SetOrigin(origin);
}
