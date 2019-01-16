/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

string g_laddersnd[] = {
	"player/pl_ladder1.wav",
	"player/pl_ladder2.wav",
	"player/pl_ladder3.wav",
	"player/pl_ladder4.wav"
};

class func_ladder:CBaseEntity
{
	void() func_ladder;
	virtual void() touch;
	virtual void(entity) Sound;
};

void func_ladder::Sound(entity target)
{
	int r;
	if ((target.velocity_z == 0) || (target.fStepTime > time)) {
		return;
	}
	r = floor(random() * g_laddersnd.length);
	sound(target, CHAN_BODY, g_laddersnd[r], 0.5, ATTN_IDLE);
	target.fStepTime = time + 0.4;
}

void func_ladder::touch(void)
{
 	if (other.classname != "player") {
		return;
	}

	vector vPlayerVector;
	makevectors(other.v_angle);
	vPlayerVector = v_forward;
	vPlayerVector = (vPlayerVector * 240);

	if (other.movement_x > 0) {
		other.velocity = vPlayerVector;
	} else {
		other.velocity = [0,0,0];
	}

	Sound(other);
}

void func_ladder :: func_ladder ( void )
{
	for (int i = 0; i < g_laddersnd.length; i++) {
		precache_sound(g_laddersnd[i]);
	}

	angles = [0,0,0];
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;
	setmodel(this, model);

#ifdef GS_DEVELOPER
	alpha = 0.5f;
	effects = EF_ADDITIVE;
#else
	alpha = 0.0001f;
	effects = EF_NODRAW;
#endif
}
