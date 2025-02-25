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
 
int trace_surfaceflagsi;

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

/*! \brief Client-Entity: Sun Flare Controller */
/*!QUAKED env_sun (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW

Visual representation of where the sun is positioned in the sky.

![flares and glare, caused by an active env_sun entity](env_sun.jpg)

# KEYS
- "targetname" : Name
- "pitch" : Sun glow pitch.
- "angle" : Sun glow angle.
- "use_angles" : Use the 'angles' yaw value instead of the one from 'angle'.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup cliententity
@ingroup pointentity
*/
class env_sun:ncEntity
{
public:
	void env_sun(void);
	
	virtual void Spawned(void);
	virtual void postdraw(void);
	virtual float predraw(void);
	virtual void SpawnKey(string,string);
	virtual void RendererRestarted(void);
	virtual bool CanSpawn(bool);

private:
	vector m_vecLensPos;
	float m_flLensAlpha;
	bool m_useAngles;
	string m_mtrFlare1;
	string m_mtrFlare2;
	string m_mtrFlare3;
	string m_mtrFlare4;
	string m_mtrOverlay;
};

void
env_sun::env_sun(void)
{
	m_useAngles = false;
	isCSQC = true;
	angles = [-90, 0, 0];
	m_mtrFlare1 = "sfx/flare1";
	m_mtrFlare2 = "sfx/flare2";
	m_mtrFlare3 = "sfx/flare3";
	m_mtrFlare4 = "sfx/flare4";
	m_mtrOverlay = "sun/overlay";
}

void
env_sun::RendererRestarted(void)
{
	m_mtrFlare1 = precache_material(m_mtrFlare1);
	m_mtrFlare2 = precache_material(m_mtrFlare2);
	m_mtrFlare3 = precache_material(m_mtrFlare3);
	m_mtrFlare4 = precache_material(m_mtrFlare4);
	m_mtrOverlay = precache_material(m_mtrOverlay);
}

bool
env_sun::CanSpawn(bool clientSide)
{
	return true;
}

float
env_sun::predraw(void)
{
	return (PREDRAW_NEXT);
}

void
env_sun::postdraw(void)
{
	vector camPos = g_view.GetCameraOrigin();
	vector camAng = g_view.GetCameraAngle();

	if (!m_useAngles) {
		makevectors(m_vecLensPos);
	} else {
		vector ang;
		ang = m_vecLensPos;
		ang[1] = angles[1];
		makevectors(ang);
	}

	v_forward *= -1.0f;

	vector lens_pos = camPos + (v_forward * 16384.0f);
	vector lens_1 = project(lens_pos) - (FLARE_SIZE * 0.5f);

	makevectors(camAng);
	vector v = normalize(lens_pos - camPos);
	float flDot = v * v_forward;

	if (flDot < 0.15f) {
		return;
	} else {
		traceline(camPos, lens_pos, MOVE_NORMAL, this);

		if (Util_IsSky(trace_endpos) && flDot > 0.8f) {
			/* this never happens because the above trace fails. */
			m_flLensAlpha = bound(0.0, m_flLensAlpha + (clframetime * 2.0f), 1.0);
		} else {
			m_flLensAlpha = bound(0.0, m_flLensAlpha - (clframetime * 2.0f), 1.0);
		}
	}

	if (m_flLensAlpha <= 0.0f) {
		return;
	}

	makevectors(camAng);
	vector lens_m = project(camPos + (v_forward * 16384.0f)) - (FLARE_SIZE * 0.5f);
	vector c = (lens_1 - lens_m) * 1.5f;
	drawpic(lens_1, m_mtrFlare1, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.1f, m_mtrFlare2, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.2f, m_mtrFlare3, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.3f, m_mtrFlare4, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.4f, m_mtrFlare2, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.5f, m_mtrFlare3, FLARE_SIZE, [1,1,1] * m_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);

	float flGlare = bound(0.0, 1.0f - (vlen(c) * (1/400)), 1.0f) * m_flLensAlpha;
	drawpic(video_mins, m_mtrOverlay, g_vidsize, [1,1,1], flGlare, DRAWFLAG_ADDITIVE);
}

void
env_sun::Spawned(void)
{
	super::Spawned();

	setorigin(this, origin);

	if (m_useAngles || length(m_vecLensPos) <= 0) {
		makevectors(angles);
	} else {
		makevectors(m_vecLensPos);
	}

// 	printf("angles: %v; lens pos: %v; useAngles: %d\n", angles, m_vecLensPos, m_useAngles);

	//cvar_set("r_shadows_throwdirection", sprintf("%v", v_forward));
// 	breakpoint();
}

void
env_sun::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "pitch":
		m_vecLensPos[0] = -ReadFloat(strKey);
		break;
	case "angle":
		m_vecLensPos[1] = ReadFloat(strKey);
		break;
	case "use_angles":
		m_useAngles = ReadBool(strKey);
		break;
	case "mtr_flare1":
		m_mtrFlare1 = ReadString(strKey);
		break;
	case "mtr_flare2":
		m_mtrFlare2 = ReadString(strKey);
		break;
	case "mtr_flare3":
		m_mtrFlare3 = ReadString(strKey);
		break;
	case "mtr_flare4":
		m_mtrFlare4 = ReadString(strKey);
		break;
	case "mtr_overlay":
		m_mtrOverlay = ReadString(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
env_sun_lensflare(vector m_vecLensPos, float m_flLensAlpha, vector vecColor, bool isBlinding)
{
	vector lens_pos = project(m_vecLensPos);
	vector lens_1 = lens_pos - (FLARE_SIZE / 2);
	vector player_pos = g_view.GetCameraOrigin();;
	vector player_angle = g_view.GetCameraAngle();;

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
	test2 = g_vidsize / 2;
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
	
	if (isBlinding == false) {
		return;
	}

	m_flLensAlpha = bound(0.0, 1.0 - (vlen(c) / 100), 1.0f) * m_flLensAlpha;
	drawfill(video_mins, g_vidsize, vecColor, m_flLensAlpha * dist_alpha);
}
