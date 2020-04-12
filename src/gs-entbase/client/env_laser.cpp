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

void(float radius, vector texcoordbias) R_EndPolygonRibbon = #0;

enumflags
{
	ENVLASER_CHANGED_ORIGIN,
	ENVLASER_CHANGED_ANGLES,
	ENVLASER_CHANGED_TEXTURE,
	ENVLASER_CHANGED_ENDTEXTURE,
	ENVLASER_CHANGED_STATE
};

class env_laser
{
	int m_iState;
	string m_strBeamTex;
	string m_strEndTex;

	void(void) env_laser;

	virtual void(void) Init;
	virtual void(void) Initialized;
	virtual void(float flChanged) ReadEntity;
	virtual float(void) predraw;
};

float env_laser::predraw(void)
{
	if (!m_iState) {
		return PREDRAW_NEXT;
	}

	R_BeginPolygon(m_strBeamTex, 0, 0);
		R_PolygonVertex(angles, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(origin, [0,1], [1,1,1], 1.0f);
	R_EndPolygonRibbon(2, [1,0]);

	addentity(this);
	return PREDRAW_NEXT;
}

void env_laser::ReadEntity(float flChanged)
{
	if (flChanged & ENVLASER_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & ENVLASER_CHANGED_ANGLES) {
		angles[0] = readcoord();
		angles[1] = readcoord();
		angles[2] = readcoord();
	}
	if (flChanged & ENVLASER_CHANGED_TEXTURE) {
		m_strBeamTex = sprintf("%s_0.tga", readstring());
	}
	if (flChanged & ENVLASER_CHANGED_ENDTEXTURE) {
		m_strEndTex = readstring();
	}
	if (flChanged & ENVLASER_CHANGED_STATE) {
		m_iState = readbyte();
	}

	drawmask = MASK_ENGINE;
	setorigin(this, origin);
}

void env_laser::Init(void)
{
}

void env_laser::Initialized(void)
{
}

void env_laser::env_laser(void)
{
}
