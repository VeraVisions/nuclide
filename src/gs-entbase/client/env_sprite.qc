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

class env_sprite:NSRenderableEntity
{
	float framerate;
	int loops;
	int maxframe; 
	string m_strMaterial;

	virtual float(void) predraw;
	virtual void(float,float) ReceiveEntity;
	virtual void(void) think;
};

float
env_sprite::predraw(void)
{
	if (!m_strMaterial) {
		return super::predraw();
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vector vecPlayer = pSeat->m_vecPredictedOrigin;
	makevectors(view_angles);
	makevectors(vectoangles(origin - vecPlayer));
	vector forg = origin + (v_forward * -16);
	vector fsize = [64,64];

	traceline(origin, vecPlayer, MOVE_WORLDONLY, this);

	if (trace_fraction < 1.0)
		return (PREDRAW_NEXT);

	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], m_vecRenderColor, 1.0);
	R_EndPolygon();

	addentity(this);

	return (PREDRAW_NEXT);
}

void
env_sprite::think(void)
{
	if (frame >= (maxframe-1)) {
		if (loops == 0) {
			remove(this);
		} else {
			frame = 0;
		}
	} else {
		frame += 1;
	}

	nextthink = time + (1 / framerate);
}

void
env_sprite::ReceiveEntity(float flNew, float flChanged)
{
	origin[0] = readcoord();
	origin[1] = readcoord();
	origin[2] = readcoord();
	modelindex = readfloat();
	framerate = readfloat();
	scale = readfloat();
	m_strMaterial = readstring();

#ifdef GS_RENDERFX
	m_iRenderFX = readbyte();
	m_iRenderMode = readbyte();
	m_vecRenderColor[0] = readfloat();
	m_vecRenderColor[1] = readfloat();
	m_vecRenderColor[2] = readfloat();
	m_flRenderAmt = readfloat();
#endif

	drawmask = MASK_ENGINE;
	nextthink = time + (1 / framerate);
	maxframe = modelframecount(modelindex);
	loops = 1; /* repeats */
	setorigin(this, origin);
}

/* make sure we're not spawning on the client-side */
void
env_sprite::env_sprite(void)
{
	isCSQC = false;
}

void
EnvSprite_ParseEvent(void)
{
	env_sprite spr = spawn(env_sprite);
	spr.origin[0] = readcoord();
	spr.origin[1] = readcoord();
	spr.origin[2] = readcoord();
	spr.modelindex = readfloat();
	spr.framerate = readfloat();
	spr.scale = readfloat();
	spr.m_strMaterial = readstring();

#ifdef GS_RENDERFX
	spr.m_iRenderFX = readbyte();
	spr.m_iRenderMode = readbyte();
	spr.m_vecRenderColor[0] = readfloat();
	spr.m_vecRenderColor[1] = readfloat();
	spr.m_vecRenderColor[2] = readfloat();
	spr.m_flRenderAmt = readfloat();
#endif

	spr.drawmask = MASK_ENGINE;
	spr.nextthink = time + (1 / spr.framerate);
	spr.maxframe = modelframecount(spr.modelindex);
	spr.loops = 0; /* does not repeat */
	setorigin(spr, spr.origin);
}
