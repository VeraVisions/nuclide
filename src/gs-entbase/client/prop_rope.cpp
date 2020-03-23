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

/*QUAKED prop_rope (1 0 0) (-8 -8 -8) (8 8 8) ROPE_HALF
"sag"         Multiplier on how much sagginess will be applied to the rope.
"segments"    Number of total segments. Default is 16.
"material"    The texture to use on the rope.
"swingfactor" Multiplier on how much the rope swings about.

Client-side decorative entity. Connect the entity to a named info_notnull
and watch it swing around.

Set spawnflag to 1 (ROPE_HALF) to cut it off half-way. Useful for vertically
swinging ropes.
*/

#define ROPE_RIBBON

void(float radius, vector texcoordbias) R_EndPolygonRibbon = #0;

var int autocvar_rope_debug = FALSE;

class prop_rope:CBaseEntity
{
	string m_strShader;
	float m_flSag;
	float m_flSwingFactor;
	int m_iSegments;

	void() prop_rope;
	virtual float() predraw;
	virtual void(string, string) SpawnKey;

#ifndef ROPE_RIBBON
	virtual void(vector, vector, int) draw_segment;
#endif
};

#ifndef ROPE_RIBBON
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
#endif

float prop_rope::predraw(void)
{
	vector pos1;
	vector pos2;
	float travel;
	float segments;
	float sc;

	entity x = find(world, CBaseEntity::targetname, target);

	if (checkpvs(getproperty(VF_ORIGIN), this) == FALSE) {
		if (checkpvs(getproperty(VF_ORIGIN), x) == FALSE) {
			return PREDRAW_NEXT;
		}
	}

	if (!x) {
#ifdef GS_DEVELOPER
		print( sprintf( "%s::predraw: Unknown target '%s'\n", 
			this.classname, target ) );
#endif
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

	segments = m_iSegments;

	travel = vlen(origin - x.origin) / segments;

	sc = 0;
	pos1 = origin;
	for (float i = 0; i < segments / 2; i++) {
		float sag = cos(sc) * m_flSag;

		/* get the direction */
		makevectors(vectoangles(x.origin - origin));

		/* travel further and sag */
		pos2 = pos1 + (v_forward * travel) + (v_up * -sag) + ((v_right * sin(time)) * m_flSwingFactor);

#ifndef ROPE_RIBBON
		draw_segment(pos1, pos2, 0);
#else
		vector lit1 = /*[0.1,0.1,0.1] */ getlight(pos1) / 255;
		vector lit2 = /*[0.1,0.1,0.1] */ getlight(pos2) / 255;
		R_BeginPolygon(m_strShader, 0, 0);
			R_PolygonVertex(pos1, [0,0], lit1, 1.0f);
			R_PolygonVertex(pos2, [0,1], lit2, 1.0f);
		R_EndPolygonRibbon(2, [1,0]);
#endif
		pos1 = pos2;

		sc += (M_PI * (1 / segments));
	}

	/* only drawing one segment. */
	if (spawnflags & 1) {
		addentity(this);
		return PREDRAW_NEXT;
	}

	sc = 0;
	pos1 = x.origin;
	for (float i = 0; i < segments / 2; i++) {
		float sag = cos(sc) * m_flSag;

		/* get the direction */
		makevectors(vectoangles(origin - x.origin));

		/* travel further and sag */
		pos2 = pos1 + (v_forward * travel) + (v_up * -sag) - ((v_right * sin(time)) * m_flSwingFactor);

#ifndef ROPE_RIBBON
		draw_segment(pos1, pos2, 0);
#else
		vector lit1 = /*[0.1,0.1,0.1] */ getlight(pos1) / 255;
		vector lit2 = /*[0.1,0.1,0.1] */ getlight(pos2) / 255;

		R_BeginPolygon(m_strShader, 0, 0);
			R_PolygonVertex(pos1, [0,0], lit1, 1.0f);
			R_PolygonVertex(pos2, [0,1], lit2, 1.0f);
		R_EndPolygonRibbon(2, [-1,0]);
#endif
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
	case "segments":
		m_iSegments = stoi(strKey);
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
	m_iSegments = 16;
	m_strShader = "textures/props/wire_default";
	drawmask = MASK_ENGINE;
	Init();
}
