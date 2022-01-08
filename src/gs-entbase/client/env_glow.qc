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

/*QUAKED env_glow (0 0.5 1) (-8 -8 -8) (8 8 8) EVGLOW_ORIENT
Client-side glare/glow orb effect like the flares in 1997's Unreal.

-------- KEYS --------
"shader" : Material to use for the glare/glow effect.
"model" : Sprite model to use for the glare/glow (idTech 2 BSPs only)
"scale" : Scale multiplier.
"rendercolor" : Material color override in RGB8.
"renderamt" : Material alpha override in A8.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class env_glow:NSEntity /* change to renderablentity? */
{
	vector m_vecColor;
	float m_flAlpha;
	float m_flMaxAlpha;
	string m_strSprite;
	vector m_vecSize;
	float m_flScale;

	vector m_vecOrientation;

	void(void) env_glow;

	virtual float() predraw;
	virtual void(string, string) SpawnKey;
	virtual void(void) RendererRestarted;
};

void
env_glow::RendererRestarted(void)
{
	if (!model && m_strSprite) {
		precache_pic(m_strSprite);
		m_vecSize = drawgetimagesize(m_strSprite) / 2;
	} else {
		precache_model(model);
		m_strSprite = spriteframe(model, 0, 0.0f);
		m_vecSize = drawgetimagesize(m_strSprite) / 2;
	}

	if (spawnflags & 1) {
		hitcontentsmaski = CONTENTBIT_SOLID;
		decal_pickwall(this, origin);
		m_vecOrientation = vectoangles(g_tracedDecal.normal * -1);
	}
}

float
env_glow::predraw(void)
{
	vector forg;
	vector fsize;
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE)
		return (PREDRAW_NEXT);

	other = world;
	traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

	/* If we can't trace against the player, or are two close, fade out */
	if (trace_fraction < 1.0f || vlen(origin - vecPlayer) < 128)
		m_flAlpha -= clframetime;
	else
		m_flAlpha += clframetime;

	m_flAlpha = bound(0.0f, m_flAlpha, 1.0f);

	if (m_flAlpha <= 0.0f)
		return (PREDRAW_NEXT);

	/* Scale the glow somewhat with the players distance */
	fsize = m_vecSize * m_flScale;
	fsize *= bound(1, vlen(vecPlayer - origin) / 256, 4);

	makevectors(view_angles);

	/* Nudge this slightly towards the camera */
	makevectors(vectoangles(origin - vecPlayer));
	forg = origin + (v_forward * -16);

	if (spawnflags & 1)
		makevectors(m_vecOrientation+[0,0,angles[2]]);
	else {
		makevectors(view_angles+[0,0,angles[2]]);
	}

#ifndef FTE_QUADFIX
	R_BeginPolygon(m_strSprite, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_EndPolygon();
#else
	R_BeginPolygon(m_strSprite, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_EndPolygon();
	R_BeginPolygon(m_strSprite, 1, 0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], m_vecColor * m_flMaxAlpha, m_flAlpha);
	R_EndPolygon();
#endif

	return (PREDRAW_NEXT);
}

void
env_glow::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "material":
	case "shader":
		model = __NULL__;
		m_strSprite = strKey;
		break;
	case "sprite":
	case "model":
		model = strKey;
		break;
	case "scale":
		m_flScale = stof(strKey);
		break;
	case "color":
		m_vecColor = stov(strKey);
		break;
	case "rendercolor":
	case "rendercolour":
		m_vecColor = stov(strKey) / 255;
		break;
	case "renderamt":
		m_flMaxAlpha = stof(strKey) / 255;
		break;
	case "rotate":
		angles[2] = stof(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
env_glow::env_glow(void)
{
	m_flScale = 1.0f;
	m_flMaxAlpha = 1.0f;
	m_vecColor = [1,1,1];
	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	effects &= ~EF_NOSHADOW;
	Init();

	RendererRestarted();
	setorigin(this, origin);
}
