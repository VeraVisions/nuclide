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
prop_static:NSEntity
{
public:
	void prop_static(void);
	
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Spawned(void);

private:
	int m_iBody;
};

void
prop_static::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "modelscale":
		scale = stof(strValue);
		break;
	case "skin":
		skin = stof(strValue);
		break;
	case "body":
		m_iBody = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
prop_static::Respawn(void)
{
	makestatic(this);
}

void
prop_static::Spawned(void)
{
	super::Spawned();

	float skindata;
	solid = SOLID_NOT;
	setmodel(this, model);
	skindata = loadcustomskin("", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	applycustomskin(this, skindata);
	setorigin(this, origin);
	setsize(this, mins * scale, maxs * scale);
}

void
prop_static::prop_static(void)
{
	isCSQC = true;
}
