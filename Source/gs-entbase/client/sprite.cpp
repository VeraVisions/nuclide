/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class sprite
{
	float framerate;
	int loops;
	int maxframe; 
	
	virtual void() think;
};

void sprite::think(void)
{
	if (frame >= maxframe) {
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
	me.origin_x = readcoord();
	me.origin_y = readcoord();
	me.origin_z = readcoord();
	me.modelindex = readfloat();
	me.framerate = readfloat();
	me.scale = readfloat();
	me.alpha = readfloat();
	me.effects = readfloat();
	me.colormod[0] = readfloat();
	me.colormod[1] = readfloat();
	me.colormod[2] = readfloat();
	me.drawmask = MASK_ENGINE;
	me.nextthink = time + ( 1 / me.framerate );
	me.maxframe = modelframecount( me.modelindex );
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
	spr.nextthink = time + ( 1 / spr.framerate );
	spr.maxframe = modelframecount( spr.modelindex );
	spr.loops = 0; /* does not repeat */
	setorigin(spr, spr.origin);
}
