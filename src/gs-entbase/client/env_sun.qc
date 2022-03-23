/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
 
int trace_surfaceflagsi;

/*QUAKED env_sun (1 0 0) (-8 -8 -8) (8 8 8)
"targetname" : Name
"pitch" : Sun glow pitch.
"angle" : Sun glow angle.
"use_angles" : Use the 'angles' yaw value instead of the one from 'angle'.

STUB!

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

#define FLARE_SIZE [128,128]

int
Util_IsSky(vector pos)
{
	if (serverkeyfloat("*bspversion") == BSPVER_HL)
	if (getsurfacetexture(world, getsurfacenearpoint(world, pos)) == "sky") {
		return (1);
	}

	if (trace_surfaceflagsi & SURF_SKY) {
		return (1);
	}
	return (0);
}

class env_sun:NSEntity
{
	vector m_vecLensPos;
	float m_flLensAlpha;
	int m_iUseAngles;

	void(void) env_sun;
	virtual void(void) Init;
	virtual void(void) Initialized;
	virtual void(void) postdraw;
	virtual float(void) predraw;
	virtual void(string, string) SpawnKey;
	virtual void(void) RendererRestarted;
};

void
env_sun::RendererRestarted(void)
{
	precache_pic("textures/sfx/flare1");
	precache_pic("textures/sfx/flare2");
	precache_pic("textures/sfx/flare3");
	precache_pic("textures/sfx/flare4");
}

float
env_sun::predraw(void)
{
	return (PREDRAW_NEXT);
}

void
env_sun::postdraw(void)
{
	if (!m_iUseAngles)
		makevectors(m_vecLensPos);
	else {
		vector ang;
		ang = m_vecLensPos;
		ang[1] = angles[1];
		makevectors(ang);
	}

	v_forward *= -1;

	vector lens_pos = getproperty(VF_ORIGIN) + (v_forward * 16384);
	vector lens_1 = project(lens_pos) - (FLARE_SIZE / 2);

	makevectors(getproperty(VF_ANGLES));
	vector v = normalize(lens_pos - getproperty(VF_ORIGIN));
	float flDot = v * v_forward;

	if (flDot < 0.15) {
		return;
	} else {
		traceline(getproperty(VF_ORIGIN), lens_pos, TRUE, self);

		if (Util_IsSky(trace_endpos) && flDot > 0.8) {
			/* this never happens because the above trace fails. */
			m_flLensAlpha = bound(0.0, m_flLensAlpha + (clframetime * 2), 1.0);
		} else {
			m_flLensAlpha = bound(0.0, m_flLensAlpha - (clframetime * 2), 1.0);
		}
	}

	if (m_flLensAlpha <= 0.0f) {
		return;
	}

	makevectors(getproperty(VF_CL_VIEWANGLES));
	vector lens_m = project(getproperty(VF_ORIGIN) + (v_forward * 16384));
	vector c = (lens_1 - lens_m) * 1.5;
	drawpic(lens_1, "textures/sfx/flare1", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.1, "textures/sfx/flare2", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.2, "textures/sfx/flare3", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.3, "textures/sfx/flare4", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.4, "textures/sfx/flare2", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.5, "textures/sfx/flare3", FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
}

void
env_sun::Init(void)
{
	super::Init();
	setorigin(this, origin);
	drawmask = MASK_ENGINE;
}

void
env_sun::Initialized(void)
{
	makevectors(m_vecLensPos);
	m_vecLensPos = vectoangles(v_forward);
	localcmd(sprintf("r_shadows_throwdirection %v\n", v_forward));
}

void
env_sun::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "pitch":
		m_vecLensPos[0] = -stof(strKey);
		break;
	case "angle":
		m_vecLensPos[1] = stof(strKey);
		break;
	case "use_angles":
		m_iUseAngles = stoi(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
env_sun::env_sun(void)
{
	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, origin);
	Init();
}

void
env_sun_lensflare(vector m_vecLensPos, float m_flLensAlpha, vector vecColor)
{
	vector lens_pos = project(m_vecLensPos);
	vector lens_1 = lens_pos - (FLARE_SIZE / 2);
	vector player_pos = getproperty(VF_ORIGIN);
	vector player_angle = getproperty(VF_CL_VIEWANGLES);

	m_flLensAlpha *= 0.5f;

	if (m_flLensAlpha <= 0.0f) {
		return;
	}

{
	vector delta;
	float fov;

	makevectors(player_angle);
	delta = normalize (m_vecLensPos - player_pos);
	fov = delta * v_forward;

	/* we're in field-of-view */
	if (fov > 0.3) {
		traceline(player_pos, m_vecLensPos, TRUE, self);
		if (trace_fraction != 1.0) {
			return;
		}
	} else {
		return;
	}
}
	player_angle[0] *= -1;

	vector test1, test2;
	test1 = project(m_vecLensPos);
	test2 = video_res / 2;
	float dist_alpha = 1.0 - bound(0.0, vlen(player_pos - m_vecLensPos) / 1024, 1.0);

	vector c = (test2 - test1) * 1.25f;
	m_flLensAlpha = bound(0.0, 1.0 - (vlen(c) / 350), 1.0f) * m_flLensAlpha;
	m_flLensAlpha *= dist_alpha;
	dist_alpha = 1.0 - bound(0.0, vlen(player_pos - m_vecLensPos) / 512, 1.0);


	drawpic(lens_1, "textures/sfx/flare1", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.1, "textures/sfx/flare2", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.2, "textures/sfx/flare3", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.3, "textures/sfx/flare4", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.4, "textures/sfx/flare2", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.5, "textures/sfx/flare3", FLARE_SIZE, vecColor * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);

	m_flLensAlpha = bound(0.0, 1.0 - (vlen(c) / 100), 1.0f) * m_flLensAlpha;
	drawfill(video_mins, video_res, vecColor, m_flLensAlpha * dist_alpha);
}
