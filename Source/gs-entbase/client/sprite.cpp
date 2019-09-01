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

class sprite
{
	float framerate;
	int loops;
	int maxframe; 
	
	virtual void() think;
};

void sprite::think(void)
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
	
void Sprite_Animated(void)
{
	spawnfunc_sprite();
	sprite me = (sprite)self;
	me.origin[0] = readcoord();
	me.origin[1] = readcoord();
	me.origin[2] = readcoord();
	me.modelindex = readfloat();
	me.framerate = readfloat();
	me.scale = readfloat();
	me.alpha = readfloat();
	me.effects = readfloat();
	me.colormod[0] = readfloat();
	me.colormod[1] = readfloat();
	me.colormod[2] = readfloat();
	me.drawmask = MASK_ENGINE;
	me.nextthink = time + (1 / me.framerate);
	me.maxframe = modelframecount(me.modelindex);
	me.loops = 1; /* repeats */
	setorigin(me, me.origin);
}

void Sprite_ParseEvent(void)
{
	sprite spr = spawn(sprite);
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
