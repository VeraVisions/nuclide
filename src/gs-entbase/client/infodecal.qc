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

/*QUAKED env_cubemap (0 0 1) (-8 -8 -8) (8 8 8)
"scale"    Texture dimension at which to render the cubemap. Default is '32'.

Specifies a location for which a cubemap will be generated when the 
buildcubemaps console command is executed.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

class
infodecal:CBaseEntity
{
	decal m_decChild;
	string m_strTexture;

	void(void) infodecal;
	virtual void(string, string) SpawnKey;
	virtual float(void) predraw;
};

float
infodecal::predraw(void)
{
	if (!m_decChild) {
		m_decChild = spawn(decal);
		m_decChild.Place(origin, m_strTexture);
		remove(this);
	}
	return PREDRAW_NEXT;
}

void
infodecal::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "material":
	case "texture":
		m_strTexture = strtolower(strKey);
		break;
	case "targetname":
		targetname = strKey;
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void
infodecal::infodecal(void)
{
	Init();

	if (targetname) {
		remove(this);
		return;
	}

	drawmask = MASK_ENGINE;
}
