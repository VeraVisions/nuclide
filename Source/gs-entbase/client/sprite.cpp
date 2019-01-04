/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

.float framerate;

void Sprite_AnimateThink( void ) {
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
	
void Sprite_Animated( vector vPos, float fIndex, float fFPS, float fScale, float fAlpha, float fEffects ) {
	self.modelindex = fIndex;
	setorigin( self, vPos );
	self.scale = fScale;
	self.alpha = fAlpha;
	self.effects = fEffects;
	self.framerate = fFPS;
	self.think = Sprite_AnimateThink;
	self.drawmask = MASK_ENGINE;
	self.nextthink = time + ( 1 / self.framerate );
	self.maxframe = modelframecount( self.modelindex );
	self.health = 0; /* repeats */
}

void Sprite_ParseEvent(void)
{
	entity sprite = spawn();
	sprite.origin_x = readcoord();
	sprite.origin_y = readcoord();
	sprite.origin_z = readcoord();
	sprite.modelindex = readfloat();
	sprite.framerate = readfloat();
	sprite.scale = readfloat();
	sprite.alpha = readfloat();
	sprite.effects = readfloat();
	sprite.think = Sprite_AnimateThink;
	sprite.drawmask = MASK_ENGINE;
	sprite.nextthink = time + ( 1 / self.framerate );
	sprite.maxframe = modelframecount( self.modelindex );
	sprite.health = 1; /* does not repeat */
}
