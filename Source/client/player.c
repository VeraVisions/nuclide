/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class player
{
	entity p_model;
	int p_hand_bone;
	int p_model_bone;

	vector netorigin;
	vector netvelocity;
	float netflags;
	
	float weapon;
	float lastweapon;

	float health;
	float armor;
	float pitch;
	float viewzoom;
	
	vector view_ofs;
	
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
};

//.float bonecontrol1; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol2; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol3; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol4; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol5; //Halflife model format bone controller. This typically affects the mouth.
//.float subblendfrac; //Weird animation value specific to halflife models. On player models, this typically affects the spine's pitch.
//.float basesubblendfrac; // legs part.
.float subblend2frac; // Up/Down

void player::gun_offset(void)
{
	vector v1, v2;
	this.p_model.angles = this.angles; // Set it to something consistent
	gettaginfo(this, this.p_hand_bone); // Updates the v_ globals for the player hand bone angle
	v1 = vectoangles(v_right, v_up); // Create angles from the v_ matrix
	gettaginfo(this.p_model, this.p_model_bone); // Updates the v_ globals for the weapon hand bone angle
	v2 = vectoangles(v_right, v_up); 
	this.p_model.angles = this.angles + (v1 - v2); // The difference is applied
	
	// Fix the origin
	setorigin(this.p_model, this.origin); // Set it to something consistent
	vector ofs = gettaginfo(this.p_model, this.p_model_bone) - gettaginfo(this, this.p_hand_bone);
	setorigin(this.p_model, this.origin - ofs);
}

void player::draw(void)
{
	if (!this.p_model) {
		this.p_model = spawn();
		this.p_model.classname = "pmodel";
		this.p_model.owner = this;
	}

	this.subblend2frac = this.pitch;

	// Only bother updating the model if the weapon has changed
	if (this.lastweapon != this.weapon) {
		if (this.weapon) {
			// FIXME: setmodel(this.p_model, sPModels[this.weapon - 1]);
		} else {
			setmodel(this.p_model, "");
		}
		this.lastweapon = this.weapon;
	    	
		// Update the bone index of the current p_ model so we can calculate the offset
		// Get the weapon bone ID for the current player model
		this.p_hand_bone = gettagindex(this, "Bip01 R Hand");
		this.p_model_bone = gettagindex(this.p_model, "Bip01 R Hand");
	}

	//Animation_PlayerUpdate();
	/*makevectors([0, this.angles[1], 0]);
	float fDirection = dotproduct(this.velocity, v_forward);
	
	if (fDirection != 0)
	print(sprintf("fDirection: %d\n", fDirection));

	if (fDirection < 0) {
		this.baseframe1time -= clframetime;
		this.baseframe2time -= clframetime;
		this.frame2time -= clframetime;
		this.frame1time -= clframetime;
	} else {*/
		this.baseframe1time += clframetime;
		this.baseframe2time += clframetime;
		this.frame2time += clframetime;
		this.frame1time += clframetime;
	/*}*/
	this.bonecontrol5 = getplayerkeyfloat(this.entnum - 1, "voiploudness");

	makevectors([0, this.angles[1], 0]);
	float fCorrect = dotproduct(this.velocity, v_right);

	float a, s;
	if (this.velocity[0] == 0 && this.velocity[1] == 0) {
		a = 0;
		s = 0;
	} else {
		a = this.angles[1] - vectoyaw(this.velocity);
		s = vlen(this.velocity);
		if (s < 100) {
			a *= s/100;
		}
	}
	s /= 400;
	
	/* Clamp */
	if (a < -180) {
		a += 360;
	}
	if (a > 180) {
		a -= 360;
	}
	if (a > 120) {
		a = 120;
	}
	if (a < -120) {
		a = -120;
	}

	/* Turn torso */
	this.subblendfrac = (a)/-120;

	/* Correct the legs */
	this.angles[1] -= a;
}

float player::predraw(void)
{
	/* Run animations regardless of rendering the player */
	draw();
	gun_offset();

	if (autocvar_cl_thirdperson == TRUE || this.entnum != player_localentnum) {
		Voice_Draw3D(this);
		addentity(this);
		addentity(this.p_model);
	} else {
		removeentity(this);
		removeentity(this.p_model);
	}

	return PREDRAW_NEXT;
}
