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

var int autocvar_r_skipGlows = 0;
var int autocvar_r_skipLensFlares = 0;

/*!QUAKED env_glow (1 .5 0) (-8 -8 -8) (8 8 8) EVGLOW_ORIENT
# OVERVIEW
Glare/glow orb effect like the flares in 1997's Unreal.

# KEYS
- "targetname" : Name
- "shader" : Material to use for the glare/glow effect.
- "model" : Sprite model to use for the glare/glow (idTech 2 BSPs only)
- "scale" : Scale multiplier.
- "rendercolor" : Material color override in RGB8.
- "renderamt" : Material alpha override in A8.
- "rendermode" : Render Mode
- "renderfx" : Render FX

# SPAWNFLAGS
- EVGLOW_ORIENT (1) : Glow is an oriented sprite when set.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class env_glow:NSRenderableEntity
{
public:
	void env_glow(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#else
	float m_flMaxAlpha;
	vector m_vecSize;
	vector m_vecRotate;
	virtual float predraw(void);
	virtual void postdraw(void);
	virtual void RendererRestarted(void);
	nonvirtual bool IsVisible(vector);
	nonvirtual void RenderGlow(vector, vector);
	nonvirtual void RenderNormal(vector, vector);
	virtual void ReceiveEntity(float,float);
#endif

private:
	NETWORKED_STRING(m_strMaterial)
};

void
env_glow::env_glow(void)
{
	m_strMaterial = __NULL__;
#ifdef CLIENT
	m_flMaxAlpha = 1.0f;
#endif
}

#ifdef SERVER
void
env_glow::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "material":
	case "shader":
		model = __NULL__;
		m_strMaterial = strKey;
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
env_glow::Respawn(void)
{
	if (!model && !m_strMaterial) {
		NSEntWarning("no model specified");
		Destroy();
		return;
	}

	SetModel(GetSpawnModel());
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	AddEffects(EF_NOSHADOW);

	SetRenderFX(GetSpawnRenderFX());
	SetRenderMode(GetSpawnRenderMode());
	SetRenderAmt(GetSpawnRenderAmt());
	SetRenderColor(GetSpawnRenderColor());

/*
	if (HasSpawnFlags(1)) {
		hitcontentsmaski = CONTENTBIT_SOLID;
		decal_pickwall(this, origin);
		angles = vectoangles(g_tracedDecal.normal * -1);
	}
*/
}
void
env_glow::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SPRITE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, SPRITE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, SPRITE_CHANGED_ORIGIN)
	EVALUATE_FIELD(modelindex, SPRITE_CHANGED_MODELINDEX)
	EVALUATE_FIELD(scale, SPRITE_CHANGED_SCALE)
	EVALUATE_FIELD(m_iRenderMode, SPRITE_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, SPRITE_CHANGED_RENDERFX)
	EVALUATE_VECTOR(m_vecRenderColor, 0, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, SPRITE_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_strMaterial, SPRITE_CHANGED_MATERIAL)
}

float
env_glow::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	/* strings are expensive. */
	if (!m_strMaterial)
		flChanged &= ~SPRITE_CHANGED_MATERIAL;

	WriteByte(MSG_ENTITY, ENT_GLOW);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_FLOAT(modelindex, SPRITE_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(scale, SPRITE_CHANGED_SCALE)
	SENDENTITY_BYTE(m_iRenderMode, SPRITE_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, SPRITE_CHANGED_RENDERFX)
	SENDENTITY_COLOR(m_vecRenderColor[0], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[1], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[2], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_flRenderAmt, SPRITE_CHANGED_RENDERAMT)
	SENDENTITY_STRING(m_strMaterial, SPRITE_CHANGED_MATERIAL)

	return (1);
}
#else
bool
env_glow::IsVisible(vector vecPlayer)
{
	entity oother = other;

	if (autocvar_r_skipGlows)
		return (false);

	if (checkpvs(vecPlayer, this) == FALSE)
		return (false);

	other = world;
	traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);
	other = oother;

	/* If we can't trace against the player, or are two close, fade out */
	if (trace_fraction < 1.0f || vlen(origin - vecPlayer) < 128)
		m_flMaxAlpha = m_flMaxAlpha - frametime;
	else
		m_flMaxAlpha = m_flMaxAlpha + frametime;

	m_flMaxAlpha = bound(0.0f, m_flMaxAlpha, 1.0f);

	if (m_flMaxAlpha <= 0.0f)
		return (false);

	return (true);
}

void env_sun_lensflare(vector, float, vector);
void
env_glow::postdraw(void)
{
	if (GetRenderMode() == RM_GLOW)
		if (!autocvar_r_skipLensFlares)
			env_sun_lensflare(origin, m_flMaxAlpha, m_vecRenderColor);
}

void
env_glow::RendererRestarted(void)
{
	if (!modelindex && m_strMaterial) {
		precache_pic(m_strMaterial);
		m_vecSize = drawgetimagesize(m_strMaterial) / 2;
	} else {
		model = modelnameforindex(modelindex);
		m_strMaterial = spriteframe(model, 0, 0.0f);
		m_vecSize = drawgetimagesize(m_strMaterial) / 2;
		//NSEntWarning("%S %d %S %v", model, modelindex, m_strMaterial, m_vecSize);
	}
}

void
env_glow::RenderGlow(vector forg, vector fsize)
{
	float alphaTint = GetRenderAmt();
	vector renderColor = m_vecRenderColor;

#ifndef FTE_QUADFIX
	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], renderColor * alphaTint, m_flMaxAlpha);
	R_EndPolygon();
#else
	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor * alphaTint, m_flMaxAlpha);
	R_EndPolygon();
	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor * alphaTint, m_flMaxAlpha);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], renderColor * alphaTint, m_flMaxAlpha);
	R_EndPolygon();
#endif
}

void
env_glow::RenderNormal(vector forg, vector fsize)
{
	float alphaTint = GetRenderAmt();
	vector renderColor = GetRenderColor();

#ifndef FTE_QUADFIX
	R_BeginPolygon(m_strMaterial, 0, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], renderColor, alphaTint);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor, alphaTint);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor, alphaTint);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], renderColor, alphaTint);
	R_EndPolygon();
#else
	R_BeginPolygon(m_strMaterial, 0, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], renderColor, alphaTint);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor, alphaTint);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor, alphaTint);
	R_EndPolygon();
	R_BeginPolygon(m_strMaterial, 0, 0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor, alphaTint);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor, alphaTint);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], renderColor, alphaTint);
	R_EndPolygon();
#endif
}

float
env_glow::predraw(void)
{
	vector forg = g_vec_null;
	vector fsize = g_vec_null;
	vector vecPlayer = g_view.GetCameraOrigin();
	vector vecAngle = g_view.GetCameraAngle();
	float flDist = vlen(vecPlayer - origin);

	/* HACK: GoldSrc does this */
	if (GetRenderMode() == RM_GLOW)
		scale = 1.0f;

	if (GetRenderMode() == RM_GLOW) {
		if (IsVisible(vecPlayer) == false)
			return (PREDRAW_NEXT);

		/* Scale the glow somewhat with the players distance */
		fsize = m_vecSize * scale;
		fsize *= bound(1, flDist / 256, 4);
	}

	/* Nudge this slightly towards the camera */
	makevectors(vectoangles(origin - vecPlayer));
	forg = origin + (v_forward * -16);

	if (HasSpawnFlags(1)) {
		vector above;
		makevectors(angles);
		above = origin + (v_forward * 16);

		/* we're aiming right down */
		if (above[2] > origin[2])
			makevectors(angles + [0, m_vecRotate[2],0]);
		else
			makevectors(angles + [0,0, m_vecRotate[2]]);
	} else {
		makevectors(vecAngle + [0, m_vecRotate[1], m_vecRotate[2]]);
	}

	if (GetRenderMode() == RM_GLOW)
		RenderGlow(forg, fsize);
	else if (GetRenderMode() == RM_ADDITIVE)
		RenderGlow(forg, m_vecSize * scale);
	else
		RenderNormal(forg, m_vecSize * scale);

	return (PREDRAW_NEXT);
}

void
env_glow::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SPRITE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], SPRITE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], SPRITE_CHANGED_ORIGIN)
	READENTITY_FLOAT(modelindex, SPRITE_CHANGED_MODELINDEX)
	READENTITY_FLOAT(scale, SPRITE_CHANGED_SCALE)
	READENTITY_BYTE(m_iRenderMode, SPRITE_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, SPRITE_CHANGED_RENDERFX)
	READENTITY_COLOR(m_vecRenderColor[0], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[1], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[2], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_flRenderAmt, SPRITE_CHANGED_RENDERAMT)
	READENTITY_STRING(m_strMaterial, SPRITE_CHANGED_MATERIAL)

	if (flNew)
		RendererRestarted();

	drawmask = MASK_GLOWS;
	setsize(this, g_vec_null, g_vec_null);
	setorigin(this, origin);
}
#endif