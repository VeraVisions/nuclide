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
void Player_PostUpdate(void);

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
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

static float Player_Gun_PreDraw (void)
{
	self.entnum = self.owner.entnum; //so this entity gets its RF_EXTERNALMODEL flag rewritten as needed
	addentity(self);
	self.entnum = 0;	//so that findfloat won't find the wrong thing.
	return PREDRAW_NEXT;
}

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
		self.eGunModel.predraw = Player_Gun_PreDraw;
		self.eGunModel.drawmask = MASK_ENGINE;
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
	if (a < -180)
		a += 360;
	if (a > 180)
		a -= 360;

	if (a > 120)
		a = 120;
	if (a < -120)
		a = -120;
	//self.bonecontrol1 = self.bonecontrol2 = self.bonecontrol3 = self.bonecontrol4 = (a)/150;///4;
	self.angles[1] -= a;
	self.angles[0] = 0;
	self.subblendfrac = (a)/-120;
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
	Player_Draw();
	Player_Gun_Offset();
	addentity(self);
	return PREDRAW_NEXT;
}

/*
=================
Player_Predict

Runs before every frame is rendered.
Responsible for local player prediction.
=================
*/
void Player_Predict(void)
{
	// Don't predict if we're frozen/paused FIXME: FTE doesn't have serverkey_float yet!
	if (serverkey(SERVERKEY_PAUSESTATE) == "1" || ((getstati(STAT_GAMESTATE) == GAME_FREEZE) && (getstati(STAT_HEALTH) > 0))) {
		pSeat->vPlayerOrigin = self.origin;
		self.netorigin = pSeat->vPlayerOrigin;

		self.velocity = '0 0 0';
		self.netvelocity = self.velocity;
		self.netpmove_flags = 0;
	} else {
		Player_PreUpdate();
	}

	if (autocvar_cl_smoothstairs && self.flags & FL_ONGROUND) {
		pSeat->vPlayerOriginOld = pSeat->vPlayerOrigin;

		if ((self.jumptime <= 0) && (self.origin[2] - pSeat->vPlayerOriginOld[2] > 0)) {
			pSeat->vPlayerOriginOld[2] += clframetime * 150;

			if (pSeat->vPlayerOriginOld[2] > self.origin[2]) {
				pSeat->vPlayerOriginOld[2] = self.origin[2];
			}
			if (self.origin[2] - pSeat->vPlayerOriginOld[2] > 18) {
				pSeat->vPlayerOriginOld[2] = self.origin[2] - 18;
			}
			pSeat->vPlayerOrigin[2] += pSeat->vPlayerOriginOld[2] - self.origin[2];
		} else {
			pSeat->vPlayerOriginOld[2] = self.origin[2];
		}

		pSeat->vPlayerVelocity = self.velocity;
		pSeat->vPlayerOrigin = [self.origin[0], self.origin[1], pSeat->vPlayerOriginOld[2]];
	} else {
		pSeat->vPlayerOrigin = self.origin;
		pSeat->vPlayerVelocity = self.velocity;
	}

	Player_PostUpdate();
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
	self.netangles = self.angles;
	self.netvelocity = self.velocity;
	self.netpmove_flags = self.pmove_flags;

	if (getplayerkeyvalue(self.entnum - 1, "*spec") == "0") {
		self.movetype = MOVETYPE_WALK;
	} else {
		self.movetype = MOVETYPE_NOCLIP;
	}

	//we want to predict an exact copy of the data in the new packet
	/*for (; self.pmove_frame <= servercommandframe; self.pmove_frame++) {
		float flSuccess = getinputstate(self.pmove_frame);*/
	for (int i = servercommandframe + 1; i <= clientcommandframe; i++) {
		float flSuccess = getinputstate(i);
		if (flSuccess == FALSE) {
			continue;
		}

		// Partial frames are the worst
		if (input_timelength == 0) {
			break;
		}
		QPhysics_Run(self);
	}

	//we now have self.pmove_flags set properly...
	
	self.movetype = MOVETYPE_NONE;
}

void Player_PostUpdate(void)
{
	self.origin = self.netorigin;
	self.angles = self.netangles;
	self.velocity = self.netvelocity;
	self.pmove_flags = self.netpmove_flags;
	self.pmove_frame = servercommandframe + 1;
}
