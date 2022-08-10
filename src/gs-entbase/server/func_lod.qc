/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

class
func_lod:NSEntity
{
	void(void) func_lod;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual float(entity, float) SendEntity;
};

void
func_lod::func_lod(void)
{
}

void
func_lod::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "Solid":
	case "solid":
		SetSolid(stoi(strValue) == 1 ? SOLID_NOT : SOLID_BSP);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_lod::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
}

float
func_lod::SendEntity(entity a, float b)
{
	return (0);
}
