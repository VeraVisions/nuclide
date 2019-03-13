/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

//.float bonecontrol1; //Half-Life model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol2; //Half-Life model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol3; //Half-Life model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol4; //Half-Life model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol5; //Half-Life model format bone controller. This typically affects the mouth.
//.float subblendfrac; //Weird animation value specific to Half-Life models. On player models, this typically affects the spine's pitch.
//.float basesubblendfrac; // legs part.
.float subblend2frac; // Up/Down

// TODO: This needs to be redone.
#ifdef CSTRIKE
string sPModels[CS_WEAPON_COUNT - 1] = {
	"models/p_knife.mdl",
	"models/p_usp.mdl",
	"models/p_glock18.mdl",
	"models/p_deagle.mdl",
	"models/p_p228.mdl",
	"models/p_elite.mdl",
	"models/p_fiveseven.mdl",
	"models/p_m3.mdl",
	"models/p_xm1014.mdl",
	"models/p_mp5.mdl",
	"models/p_p90.mdl",
	"models/p_ump45.mdl",
	"models/p_mac10.mdl",
	"models/p_tmp.mdl",
	"models/p_ak47.mdl",
	"models/p_sg552.mdl",
	"models/p_m4a1.mdl",
	"models/p_aug.mdl",
	"models/p_scout.mdl",
	"models/p_awp.mdl",
	"models/p_g3sg1.mdl",
	"models/p_sg550.mdl",
	"models/p_m249.mdl",
	"models/p_c4.mdl",
	"models/p_flashbang.mdl",
	"models/p_hegrenade.mdl",
	"models/p_smokegrenade.mdl"
};
#endif

void player::gun_offset(void)
{
	vector v1, v2;

	/* Set it to something consistent */
	this.p_model.angles = this.angles;

	/* Updates the v_ globals for the player hand bone angle */
	gettaginfo(this, this.p_hand_bone);

	/* Create angles from the v_ matrix */
	v1 = vectoangles(v_right, v_up);

	/* Updates the v_ globals for the weapon hand bone angle */
	gettaginfo(this.p_model, this.p_model_bone); 
	v2 = vectoangles(v_right, v_up);

	/* The difference is applied */
	this.p_model.angles = this.angles + (v1 - v2);

	/* Fix the origin */
	setorigin(this.p_model, this.origin);
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

	this.subblend2frac = this.pitch / 90;

	/* Only bother updating the model if the weapon has changed */
	if (this.lastweapon != this.activeweapon) {
		if (this.activeweapon) {
		#ifdef CSTRIKE
			setmodel(this.p_model, sPModels[this.weapon - 1]);
		#endif
		} else {
			setmodel(this.p_model, "");
		}
		this.lastweapon = this.activeweapon;
	    	
		/* Update the bone index of the current p_ model so we can calculate the offset
		 * and get the weapon bone ID for the current player model */
		this.p_hand_bone = gettagindex(this, "Bip01 R Hand");
		this.p_model_bone = gettagindex(this.p_model, "Bip01 R Hand");
	}

	Animation_PlayerUpdate();
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
	/* Handle the flashlights... */
	if (flags & FL_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (this.entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = [pitch, angles[1], angles[2]];
		} else {
			src = getproperty(VF_ORIGIN);
			ang = getproperty(VF_CL_VIEWANGLES);
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), FALSE, self);
			
		if (serverkeyfloat("*bspversion") == 30) {
			dynamiclight_add(trace_endpos + (v_forward * -2), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
		}
	}

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
