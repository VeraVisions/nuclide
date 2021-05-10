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

class
CBaseNPC:CBaseEntity
{
	int body;
	float frame_last;

	virtual float() predraw;
	virtual void(float flChanged) ReceiveEntity;
};

float
CBaseNPC::predraw(void)
{
#ifdef GS_RENDERFX
	RenderFXPass();
#endif

	if (lerpfrac > 0) {
		lerpfrac -= frametime * 5;
		if (lerpfrac < 0) {
			lerpfrac = 0;
		}
	}

	if (frame != frame_last) {
		frame2time = frame1time;
		frame2 = frame_last;
		frame_last = frame;
		lerpfrac = 1.0f;
		frame1time = 0.0f;
	}

	frame2time += clframetime;
	frame1time += clframetime;
	

	ProcessWordQue();

	addentity(this);
	return (PREDRAW_NEXT);
}

void
CBaseNPC::ReceiveEntity(float fl)
{
	if (fl & NPC_MODELINDEX)
		modelindex = readshort();
	if (fl & NPC_ORIGIN_X)
		origin[0] = readcoord();
	if (fl & NPC_ORIGIN_Y)
		origin[1] = readcoord();
	if (fl & NPC_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & NPC_ANGLES_X)
		angles[0] = readfloat();
	if (fl & NPC_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & NPC_ANGLES_Z)
		angles[2] = readfloat();
	if (fl & NPC_VELOCITY_X)
		velocity[0] = readcoord();
	if (fl & NPC_VELOCITY_Y)
		velocity[1] = readcoord();
	if (fl & NPC_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & NPC_FRAME)
		frame = readbyte();
	if (fl & NPC_SKIN)
		skin = readbyte();

	if (fl & NPC_BODY) {
		body = readbyte();
		setcustomskin(this, "", sprintf("geomset 1 %i\n", body));
	}

	setorigin(this, origin);
}

void
CBaseNPC::CBaseNPC(void)
{
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	customphysics = Empty;
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
}
