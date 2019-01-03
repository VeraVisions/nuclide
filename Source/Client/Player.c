/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/


void Player_PreUpdate(void);
void Player_ResetPrediction(void);

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
.float netflags;
.float netpmove_flags;

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

//.float bonecontrol1; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol2; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol3; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol4; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol5; //Halflife model format bone controller. This typically affects the mouth.
//.float subblendfrac; //Weird animation value specific to halflife models. On player models, this typically affects the spine's pitch.
//.float basesubblendfrac; // legs part.
.float subblend2frac; // Up/Down

void Player_Gun_Offset(void)
{
	vector v1, v2;
	self.eGunModel.angles = self.angles; // Set it to something consistent
	gettaginfo(self, self.fWeaponBoneID); // Updates the v_ globals for the player hand bone angle
	v1 = vectoangles(v_right, v_up); // Create angles from the v_ matrix
	gettaginfo(self.eGunModel, self.eGunModel.fWeaponBoneID); // Updates the v_ globals for the weapon hand bone angle
	v2 = vectoangles(v_right, v_up); 
	self.eGunModel.angles = self.angles + (v1 - v2); // The difference is applied
	
	// Fix the origin
	setorigin(self.eGunModel, self.origin); // Set it to something consistent
	vector vOffset = gettaginfo(self.eGunModel, self.eGunModel.fWeaponBoneID) - gettaginfo(self, self.fWeaponBoneID);
	setorigin(self.eGunModel, self.origin - vOffset);
}

void Player_Draw (void)
{
	if (!self.eGunModel) {
		self.eGunModel = spawn();
		self.eGunModel.classname = "pmodel";
		self.eGunModel.owner = self;
	}

	self.subblend2frac = self.flUpAngle;

	// Only bother updating the model if the weapon has changed
	if (self.fWeaponLast != self.weapon) {
		if (self.weapon) {
			setmodel(self.eGunModel, sPModels[self.weapon - 1]);
		} else {
			setmodel(self.eGunModel, "");
		}
		self.fWeaponLast = self.weapon;
	    	
		// Update the bone index of the current p_ model so we can calculate the offset
		// Get the weapon bone ID for the current player model
		self.fWeaponBoneID = gettagindex(self, "Bip01 R Hand");
		self.eGunModel.fWeaponBoneID = gettagindex(self.eGunModel, "Bip01 R Hand");
	}

	Animation_PlayerUpdate();
	/*makevectors([0, self.angles[1], 0]);
	float fDirection = dotproduct(self.velocity, v_forward);
	
	if (fDirection != 0)
	print(sprintf("fDirection: %d\n", fDirection));

	if (fDirection < 0) {
		self.baseframe1time -= clframetime;
		self.baseframe2time -= clframetime;
		self.frame2time -= clframetime;
		self.frame1time -= clframetime;
	} else {*/
		self.baseframe1time += clframetime;
		self.baseframe2time += clframetime;
		self.frame2time += clframetime;
		self.frame1time += clframetime;
	/*}*/
	self.bonecontrol5 = getplayerkeyfloat(self.entnum - 1, "voiploudness");

	makevectors([0, self.angles[1], 0]);
	float fCorrect = dotproduct(self.velocity, v_right);

	float a, s;
	if (self.velocity[0] == 0 && self.velocity[1] == 0) {
		a = 0;
		s = 0;
	} else {
		a = self.angles[1] - vectoyaw(self.velocity);
		s = vlen(self.velocity);
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
	self.subblendfrac = (a)/-120;

	/* Correct the legs */
	self.angles[1] -= a;
}

/*
=================
Player_PreDraw
=================
*/
void Player_DrawVoice(void)
{
	if (getplayerkeyfloat(self.entnum - 1, INFOKEY_P_VOIPSPEAKING)) {
		vector vpos = self.origin + [0,0,48];
		makevectors(view_angles);
		R_BeginPolygon("gfx/vgui/icntlk_pl");
		R_PolygonVertex(vpos + v_right*16 - v_up*16, '1 1', [1,1,1], 1);
		R_PolygonVertex(vpos - v_right*16 - v_up*16, '0 1', [1,1,1], 1);
		R_PolygonVertex(vpos - v_right*16 + v_up*16, '0 0', [1,1,1], 1);
		R_PolygonVertex(vpos + v_right*16 + v_up*16, '1 0', [1,1,1], 1);
		R_EndPolygon();
	}
}

/*
=================
Player_PreDraw

Runs as part of the addentities builtin.
Responsible for player appearance/interpolation.
=================
*/
float Player_PreDraw(void)
{
	/* Run animations regardless of rendering the player */
	Player_Draw();
	Player_Gun_Offset();

	if (autocvar_cl_thirdperson == TRUE || self.entnum != player_localentnum) {
		Player_DrawVoice();
		addentity(self);
		addentity(self.eGunModel);
	} else {
		removeentity(self);
		removeentity(self.eGunModel);
	}

	return PREDRAW_NEXT;
}

/*
=================
Player_Preupdate

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on (so any non-networked state updates locally).
=================
*/
void Player_PreUpdate(void)
{
	self.netorigin = self.origin;
	self.netvelocity = self.velocity;
	self.netflags = self.flags;
	self.netpmove_flags = self.pmove_flags;

	//we want to predict an exact copy of the data in the new packet
	/*for (; self.pmove_frame <= servercommandframe; self.pmove_frame++) {
		float flSuccess = getinputstate(self.pmove_frame);*/
	for ( int i = servercommandframe + 1; i <= clientcommandframe; i++ ) {
		float flSuccess = getinputstate( i );
		if (flSuccess == FALSE) {
			continue;
		}
		// Partial frames are the worst
		if (input_timelength == 0) {
			break;
		}
		QPhysics_Run(self);
	}
}

void Player_ResetPrediction(void)
{
	self.origin = self.netorigin;
	self.velocity = self.netvelocity;
	self.flags = self.netflags;
	self.pmove_flags = self.netpmove_flags;
	setorigin( self, self.origin );
	//self.pmove_frame = servercommandframe + 1;
}
