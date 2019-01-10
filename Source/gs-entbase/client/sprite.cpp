/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

.float framerate;

void Sprite_AnimateThink(void)
{
	if( self.frame >= self.maxframe ) {
		if (self.health == 1) {
			remove(self);
		} else {
			self.frame = 0;
		}
	} else {
		self.frame += 1;
	}

	self.nextthink = time + ( 1 / self.framerate );
}
	
void Sprite_Animated(void)
{
	self.origin_x = readcoord();
	self.origin_y = readcoord();
	self.origin_z = readcoord();
	self.modelindex = readfloat();
	self.framerate = readfloat();
	self.scale = readfloat();
	self.alpha = readfloat();
	self.effects = readfloat();
	self.colormod[0] = readfloat();
	self.colormod[1] = readfloat();
	self.colormod[2] = readfloat();
	self.think = Sprite_AnimateThink;
	self.drawmask = MASK_ENGINE;
	self.nextthink = time + ( 1 / self.framerate );
	self.maxframe = modelframecount( self.modelindex );
	self.health = 0; /* repeats */
	setorigin(self, self.origin);
}

void Sprite_ParseEvent(void)
{
	entity sprite = spawn();
	sprite.origin[0] = readcoord();
	sprite.origin[1] = readcoord();
	sprite.origin[2] = readcoord();
	sprite.modelindex = readfloat();
	sprite.framerate = readfloat();
	sprite.scale = readfloat();
	sprite.alpha = readfloat();
	sprite.effects = readfloat();
	sprite.colormod[0] = readfloat();
	sprite.colormod[1] = readfloat();
	sprite.colormod[2] = readfloat();
	sprite.think = Sprite_AnimateThink;
	sprite.drawmask = MASK_ENGINE;
	sprite.nextthink = time + ( 1 / self.framerate );
	sprite.maxframe = modelframecount( self.modelindex );
	sprite.health = 1; /* does not repeat */
	setorigin(sprite, self.origin);
}
