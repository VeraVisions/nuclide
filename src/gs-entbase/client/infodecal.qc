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
infodecal:NSEntity
{
public:
	void infodecal(void);
	virtual void SpawnKey(string, string);
	virtual float predraw(void);
	virtual bool CanSpawn(bool);

private:
	decal m_decChild;
	string m_strTexture;
};

float
infodecal::predraw(void)
{
	if (!m_decChild) {
		m_decChild = spawn(decal);
		m_decChild.Place(origin, m_strTexture);
		Destroy();
	}
	return (PREDRAW_NEXT);
}

bool
infodecal::CanSpawn(bool clientSide)
{
	return true;
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
		super::SpawnKey(strField, strKey);
	}
}

void
infodecal::infodecal(void)
{
	if (targetname) {
		Destroy();
		return;
	}

	drawmask = MASK_ENGINE;
}
