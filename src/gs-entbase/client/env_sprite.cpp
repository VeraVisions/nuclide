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

class env_sprite:CBaseEntity
{
	float framerate;
	int loops;
	int maxframe; 

	virtual void() Init;
	virtual void() Initialized;
	virtual void(float flChanged) ReadEntity;
	virtual void() think;
};

void env_sprite::think(void)
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

void env_sprite::ReadEntity(float flChanged)
{
	origin[0] = readcoord();
	origin[1] = readcoord();
	origin[2] = readcoord();
	modelindex = readfloat();
	framerate = readfloat();
	scale = readfloat();
	alpha = readfloat();
	effects = readfloat();
	colormod[0] = readfloat();
	colormod[1] = readfloat();
	colormod[2] = readfloat();
	drawmask = MASK_ENGINE;
	nextthink = time + (1 / framerate);
	maxframe = modelframecount(modelindex);
	loops = 1; /* repeats */
	setorigin(this, origin);
}

/* make sure we're not spawning on the client-side */
void env_sprite::Init(void)
{
}
void env_sprite::Initialized(void)
{
}
void env_sprite::env_sprite(void)
{
}

void EnvSprite_ParseEvent(void)
{
	env_sprite spr = spawn(env_sprite);
	spr.origin[0] = readcoord();
	spr.origin[1] = readcoord();
	spr.origin[2] = readcoord();
	spr.modelindex = readfloat();
	spr.framerate = readfloat();
	spr.scale = readfloat();
	spr.alpha = readfloat();
	spr.effects = readfloat();
	spr.colormod[0] = readfloat();
	spr.colormod[1] = readfloat();
	spr.colormod[2] = readfloat();
	spr.drawmask = MASK_ENGINE;
	spr.nextthink = time + (1 / spr.framerate);
	spr.maxframe = modelframecount(spr.modelindex);
	spr.loops = 0; /* does not repeat */
	setorigin(spr, spr.origin);
}
