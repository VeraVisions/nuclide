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
infodecal:ncEntity
{
public:
	void infodecal(void);
	virtual void SpawnKey(string, string);
	virtual float predraw(void);
	virtual bool CanSpawn(bool);
	virtual void Spawned(void);

private:
	ncDecal m_decChild;
	string m_strTexture;
};

void
infodecal::infodecal(void)
{
	drawmask = MASK_ENGINE;
	m_decChild = __NULL__;
	m_strTexture = __NULL__;
	scale = 1.0f;
}

float
infodecal::predraw(void)
{
	if (!m_decChild) {
		m_decChild = spawn(ncDecal);
		m_decChild.PlaceAtScale(origin, m_strTexture, scale);
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
infodecal::Spawned(void)
{
	super::Spawned();

	/* if it has a targetname, it can't be made client-side only */
	if (STRING_SET(targetname)) {
		Destroy();
	}

	/* yup, we have to get this bit from the material. */
	string vmtFile = strcat("materials/", m_strTexture, ".vmt");

	if (fileExists(vmtFile) == true) {
		string lineFeed;
		filestream vmtHandle = fopen(vmtFile, FILE_READ);

		if (vmtHandle < 0) {
			return;
		}

		while ((lineFeed = fgets(vmtHandle))) {
			int c = (int)tokenize_console(lineFeed);

			if (argv(0) == "$decalscale") {
				scale = ReadFloat(argv(1));
			}
		}

		fclose(vmtHandle);
	}
}
