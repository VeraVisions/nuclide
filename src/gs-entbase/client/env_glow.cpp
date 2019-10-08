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

/*QUAKED env_glow (1 0 0) (-8 -8 -8) (8 8 8)
"shader"        Material to use for the glare/glow effect.
"model"         Sprite model to use for the glare/glow (idTech 2 BSPs only)
"scale"         Scale multiplier.
"rendercolor"   Material color override in RGB8.
"renderamt"     Material alpha override in A8.

Client-side glare/glow orb effect like the flares in 1997's Unreal.
*/

class env_glow:CBaseEntity
{
	vector m_vecColor;
	float m_flAlpha;
	float m_flMaxAlpha;
	string m_strSprite;
	vector m_vecSize;
	float m_flScale;
	void() env_glow;
	virtual void() customphysics;
	virtual float() predraw;
	virtual void(string, string) SpawnKey;
};

float env_glow::predraw(void)
{
	vector vecPlayer;

#ifdef WASTES
	vecPlayer = viewClient.vecPlayerOrigin;
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	vecPlayer = pSeat->vPlayerOrigin;
#endif

	m_flAlpha = bound(0, m_flAlpha, 1.0f);

	if (m_flAlpha > 0) {
		vector forg;
		vector fsize;
		float falpha;
		
		/* Scale the glow somewhat with the players distance */
		fsize = m_vecSize * m_flScale;
		fsize *= vlen(vecPlayer - origin) / 256;
		
		/* Fade out when the player is starting to move away */
		falpha = 1 - bound(0, vlen(vecPlayer - origin) / 1024, 1);
		falpha *= m_flAlpha;
		
		/* Clamp the alpha by the glows' renderamt value */
		falpha = bound(0, falpha, m_flMaxAlpha);
		makevectors(view_angles);
		
		/* Nudge this slightly towards the camera */
		makevectors(vectoangles(origin - vecPlayer));
		forg = origin + (v_forward * -16);

		/* Project it, always facing the player */
		makevectors(view_angles);
		R_BeginPolygon(m_strSprite, 1, 0);
		R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
			[1,1], m_vecColor, falpha);
		R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
			[0,1], m_vecColor, falpha);
		R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
			[0,0], m_vecColor, falpha);
		R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
			[1,0], m_vecColor, falpha);
		R_EndPolygon();
		addentity(this);
	}

	return PREDRAW_NEXT;
}

void env_glow::customphysics(void)
{
	vector vecPlayer;

#ifdef WASTES
	vecPlayer = viewClient.vecPlayerOrigin;
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	vecPlayer = pSeat->vPlayerOrigin;
#endif

	if (checkpvs(vecPlayer, this) == FALSE) {
		m_flAlpha -= clframetime;
		return;
	}

	other = world;
	traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

	/* If we can't trace against the player, or are two close, fade out */
	if (trace_fraction < 1.0f || vlen(origin - vecPlayer) < 128) {
		m_flAlpha -= clframetime; 
		return;
	}

	m_flAlpha += clframetime; 
}

void env_glow::env_glow(void)
{
	m_flScale = 1.0f;
	m_flMaxAlpha = 1.0f;
	m_vecColor = [1,1,1];
	drawmask = MASK_ENGINE;
	setorigin(this, origin);
	Init();
}

void env_glow::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "shader":
		m_strSprite = strKey;
		precache_pic(m_strSprite);
		m_vecSize = drawgetimagesize(m_strSprite) / 2;
		break;
	case "model":
		m_strSprite = sprintf("%s_0.tga", strKey);
		m_vecSize = drawgetimagesize(m_strSprite) / 2;
		break;
	case "scale":
		m_flScale = stof(strKey);
		break;
	case "rendercolor":
	case "rendercolour":
		m_vecColor = stov(strKey) / 255;
		break;
	case "renderamt":
		m_flMaxAlpha = stof(strKey) / 255;
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}
