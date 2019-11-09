/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

var int autocvar_rope_debug = FALSE;

class prop_rope:CBaseEntity
{
	string m_strShader;
	float m_flSag;
	float m_flSwingFactor;

	void() prop_rope;
	virtual float() predraw;
	virtual void(vector, vector, int) draw_segment;
	virtual void(string, string) SpawnKey;
};

void prop_rope::draw_segment(vector start, vector end, int flip)
{
	vector fsize = [2,2];
	vector lit1 = /*[0.1,0.1,0.1] */ getlight(start) / 255;
	vector lit2 = /*[0.1,0.1,0.1] */ getlight(end) / 255;

	if (autocvar_rope_debug == TRUE) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(start, [0,1], lit1, 1);
		R_PolygonVertex(end, [1,1], lit2, 1);
		R_EndPolygon();
		return;
	}

	makevectors(view_angles);

	vector tex1, tex2, tex3, tex4;
	vector eyepos = getproperty(VF_ORIGIN);
	vector dir = normalize(start-end);
	vector eyevector = normalize(start - eyepos);
	vector tangent = crossproduct(dir, eyevector);

	tex1 = start + tangent * fsize[0];
	tex2 = start - tangent * fsize[1];

	eyevector = normalize(end - eyepos);
	tangent = crossproduct(dir, eyevector);

	tex3 = end - tangent * fsize[0];
	tex4 = end + tangent * fsize[1];

	if (!flip) {
		R_BeginPolygon(m_strShader, 0, 0);
			R_PolygonVertex(tex1, [0,1], lit1, 1.0f);
			R_PolygonVertex(tex2, [1,1], lit1, 1.0f);

			R_PolygonVertex(tex3, [1,0], lit2, 1.0f);
			R_PolygonVertex(tex4, [0,0], lit2, 1.0f);
		R_EndPolygon();
	} else {
		R_BeginPolygon(m_strShader, 0, 0);
			R_PolygonVertex(tex1, [1,0], lit1, 1.0f);
			R_PolygonVertex(tex2, [0,0], lit1, 1.0f);

			R_PolygonVertex(tex3, [0,1], lit2, 1.0f);
			R_PolygonVertex(tex4, [1,1], lit2, 1.0f);
		R_EndPolygon();
	}
}

float prop_rope::predraw(void)
{
	vector pos1;
	vector pos2;
	float travel;
	float segments;
	float sc;

	if (checkpvs(getproperty(VF_ORIGIN), this) == FALSE) {
		return PREDRAW_NEXT;
	}

	entity x = find(world, CBaseEntity::targetname, target);

	if (!x) {
		print("prop_rope without target.\n");
		remove(this);
		return PREDRAW_NEXT;
	}

	/* draw the start/end without segments */
	if (autocvar_rope_debug == TRUE) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(x.origin, [1,1], [0,1,0], 1.0f);
		R_EndPolygon();
	}

	segments = 16;

	travel = vlen(origin - x.origin) / segments;

	sc = 0;
	pos1 = origin;
	for (float i = 0; i < segments / 2; i++) {
		float sag = cos(sc) * m_flSag;

		/* get the direction */
		makevectors(vectoangles(x.origin - origin));

		/* travel further and sag */
		pos2 = pos1 + (v_forward * travel) + (v_up * -sag) + ((v_right * sin(time)) * m_flSwingFactor);

		draw_segment(pos1, pos2, 0);
		pos1 = pos2;

		sc += (M_PI * (1 / segments));
	}

	sc = 0;
	pos1 = x.origin;
	for (float i = 0; i < segments / 2; i++) {
		float sag = cos(sc) * m_flSag;

		/* get the direction */
		makevectors(vectoangles(origin - x.origin));

		/* travel further and sag */
		pos2 = pos1 + (v_forward * travel) + (v_up * -sag) - ((v_right * sin(time)) * m_flSwingFactor);

		draw_segment(pos1, pos2, 1);
		pos1 = pos2;

		sc += (M_PI * (1 / segments));
	}

	addentity(this);
	return PREDRAW_NEXT;
}

void prop_rope::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "sag":
		m_flSag = stof(strKey);
		break;
	case "shader":
		m_strShader = strKey;
		precache_pic(m_strShader);
		break;
	case "swingfactor":
		m_flSwingFactor = stof(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void prop_rope::prop_rope(void)
{
	m_flSwingFactor = random();
	m_flSag = 15.0f;
	m_strShader = "textures/props/wire_default";
	drawmask = MASK_ENGINE;
	Init();
}
