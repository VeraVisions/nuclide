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

/* this has to match gs-entbase/server/light_dynamic.cpp! */
enumflags
{
	DLIGHTFL_CHANGED_ORIGIN,
	DLIGHTFL_CHANGED_ANGLES,
	DLIGHTFL_CHANGED_LIGHT,
	DLIGHTFL_CHANGED_INTENSITY,
	DLIGHTFL_CHANGED_INNERCONE,
	DLIGHTFL_CHANGED_CONE,
	DLIGHTFL_CHANGED_DISTANCE,
	DLIGHTFL_CHANGED_RADIUS,
	DLIGHTFL_CHANGED_STYLE,
	DLIGHTFL_CHANGED_STATE
};

class light_dynamic
{
	vector m_vecLight;
	float m_flIntensity;
	float m_flInnerCone;
	float m_flCone;
	float m_flDistance;
	float m_flRadius;
	float m_flStyle;
	int m_iState;

	void(void) light_dynamic;

	virtual void(float) ReceiveEntity;
	virtual float(void) predraw;
};

float
light_dynamic::predraw(void)
{
	if (!m_iState) {
		return PREDRAW_NEXT;
	}

	/* TODO: We need to handle the second cone light */
	dynamiclight_add(origin, m_flIntensity, m_vecLight, m_flStyle);

	addentity(this);
	return PREDRAW_NEXT;
}

void light_dynamic::ReceiveEntity(float flFlags)
{
	if (flFlags & DLIGHTFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	}

	if (flFlags & DLIGHTFL_CHANGED_ANGLES) {
		angles[0] = readcoord();
		angles[1] = readcoord();
		angles[2] = readcoord();
	}

	if (flFlags & DLIGHTFL_CHANGED_LIGHT) {
		m_vecLight[0] = readbyte() / 255;
		m_vecLight[1] = readbyte() / 255;
		m_vecLight[2] = readbyte() / 255;
	}

	if (flFlags & DLIGHTFL_CHANGED_INTENSITY)
		m_flIntensity = readfloat();
	if (flFlags & DLIGHTFL_CHANGED_INNERCONE)
		m_flInnerCone = readfloat();
	if (flFlags & DLIGHTFL_CHANGED_CONE)
		m_flCone = readfloat();
	if (flFlags & DLIGHTFL_CHANGED_DISTANCE)
		m_flDistance = readfloat();
	if (flFlags & DLIGHTFL_CHANGED_RADIUS)
		m_flRadius = readfloat();
	if (flFlags & DLIGHTFL_CHANGED_STYLE)
		m_flStyle = readbyte();
	if (flFlags & DLIGHTFL_CHANGED_STATE)
		m_iState = readbyte();

	classname = "light_dynamic";
	drawmask = MASK_ENGINE;
}

void light_dynamic::light_dynamic(void)
{
}
