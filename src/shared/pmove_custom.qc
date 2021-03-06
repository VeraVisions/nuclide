/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

#ifdef CUSTOMPLAYERPHYSICS
void
PMoveCustom_Init(void)
{
	
}

#ifdef SERVER
/* we need to network our changes everytime cvars are updated */
void
PMoveCustom_UpdateVar(string info, string cv)
{
	float d = cvar(cv);
	if (serverkeyfloat(info) != d) {
		readcmd(sprintf("serverinfo %s %d\n", info, d));
	}
}

void
PMoveCustom_StartFrame(void)
{
	PMoveCustom_UpdateVar("phy_stepheight", "sv_stepheight");
	PMoveCustom_UpdateVar("phy_airstepheight", "sv_airstepheight");
	PMoveCustom_UpdateVar("phy_friction", "sv_friction");
	PMoveCustom_UpdateVar("phy_edgefriction", "sv_edgefriction");
	PMoveCustom_UpdateVar("phy_stopspeed", "sv_stopspeed");
	PMoveCustom_UpdateVar("phy_gravity", "sv_gravity");
	PMoveCustom_UpdateVar("phy_airaccelerate", "sv_airaccelerate");
	PMoveCustom_UpdateVar("phy_wateraccelerate", "sv_wateraccelerate");
	PMoveCustom_UpdateVar("phy_accelerate", "sv_accelerate");
	PMoveCustom_UpdateVar("phy_maxspeed", "sv_maxspeed");
}
#endif

/* pointcontents reimplementation, only way we can effectively trace 
 * against ladders and liquids that are defined in the game-logic.
 */
int
PMoveCustom_Contents(vector org)
{
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = -1;
	traceline(org, org, TRUE, self);
	self.hitcontentsmaski = oldhitcontents;
	return trace_endcontentsi;
}

/* used for trigger_gravity type entities */
float
PMoveCustom_Gravity(entity ent)
{
	if (ent.gravity) {
		return serverkeyfloat("phy_gravity") * ent.gravity; 
	} else {
		return serverkeyfloat("phy_gravity");
	}
}

/* figure out where we are in the geometry. void, solid, liquid, etc. */
void
PMoveCustom_Categorize(void)
{
	int contents;

	tracebox(self.origin, self.mins, self.maxs, self.origin - [0,0,1], MOVE_NORMAL, self);

	if (!trace_startsolid) {
		if ((trace_fraction < 1) && (trace_plane_normal[2] > 0.7)) {
			self.flags |= FL_ONGROUND;
			self.groundentity = trace_ent;

			if (self.groundentity) {
				self.basevelocity += self.groundentity.velocity;
			}
		} else {
			self.flags &= ~FL_ONGROUND;
		}
	}

	self.flags &= ~FL_WATERJUMP;

	/*if (self.basevelocity[2] > 0)
		self.flags &= ~FL_ONGROUND;*/

	/* ladder content testing */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBIT_FTELADDER;
	tracebox(self.origin, self.mins, self.maxs, self.origin, MOVE_NORMAL, self);
	self.hitcontentsmaski = oldhitcontents;

	if (trace_endcontentsi & CONTENTBIT_FTELADDER) {
		self.flags |= FL_ONLADDER;
	} else {
		self.flags &= ~FL_ONLADDER;
	}

	contents = PMoveCustom_Contents(self.origin + self.mins + [0,0,1]);

	if (contents & CONTENTBIT_WATER) {
		contents = CONTENT_WATER;
	} else if (contents & CONTENTBIT_SLIME) {
		contents = CONTENT_SLIME;
	} else if (contents & CONTENTBIT_LAVA) {
		contents = CONTENT_LAVA;
	}

	/* how far underwater are we? */
	if (contents < CONTENT_SOLID && !(self.flags & FL_ONLADDER)) {
		self.watertype = contents;
		if (PMoveCustom_Contents(self.origin + (self.mins + self.maxs) * 0.5) 
			& CONTENTBITS_FLUID)
		{
			if (PMoveCustom_Contents(self.origin + self.maxs - [0,0,1])
				& CONTENTBITS_FLUID)
			{
				self.waterlevel = 3;
			} else {
				self.waterlevel = 2;
			}
		} else {
			self.waterlevel = 1;
		}
	} else {
		self.watertype = CONTENT_EMPTY;
		self.waterlevel = 0;
	}
}

void
PMoveCustom_AccelToss(float move_time, float premove)
{
	self.velocity[2] = self.velocity[2] - (PMoveCustom_Gravity(self) * move_time);
}

void
PMoveCustom_AccelWater(float move_time, float premove)
{
	float flFriction;
	float wish_speed;
	vector vecWishVel;

	self.flags &= ~FL_ONGROUND;

	if (input_movevalues == [0,0,0]) {
		vecWishVel = [0,0,-60]; // drift towards bottom
	} else {
		vecWishVel = v_forward * input_movevalues[0];
		vecWishVel += v_right * input_movevalues[1];
		vecWishVel += v_up * input_movevalues[2];
	}

	wish_speed = vlen(vecWishVel);

	if (wish_speed > self.maxspeed) {
		wish_speed = self.maxspeed;
	}

	wish_speed = wish_speed * 0.7;

	// water friction
	if (self.velocity != [0,0,0]) {
		flFriction = vlen(self.velocity) * (1 - move_time * serverkeyfloat("phy_friction"));
		if (flFriction > 0) {
			self.velocity = normalize(self.velocity) * flFriction;
		} else {
			self.velocity = [0,0,0];
		}
	} else {
		flFriction = 0;
	}

	// water acceleration
	if (wish_speed <= flFriction) {
		return;
	}

	flFriction = min(wish_speed - flFriction, serverkeyfloat("phy_wateraccelerate") * wish_speed * move_time);
	self.velocity = self.velocity + normalize(vecWishVel) * flFriction;
}

void
PMoveCustom_AccelLadder(float move_time, float premove, vector wish_dir, float wish_speed)
{
	vector vPlayerVector;

	makevectors(input_angles);
	vPlayerVector = v_forward;
	vPlayerVector = (vPlayerVector * 240);

	if (input_movevalues[0] > 0) {
		self.velocity = vPlayerVector;
	} else {
		self.velocity = [0,0,0];
	}
}

void
PMoveCustom_AccelFriction(float move_time, float premove, vector wish_dir, float wish_speed)
{
	float flApplyFriction;
	float flFriction;
	vector vecTemp;

	flApplyFriction = serverkeyfloat("phy_friction");

	/* per frame basis friction modifier */
	if (self.friction != 0.0f) {
		flApplyFriction /= self.friction;
		self.friction = 0.0f;
	}

	/* apply friction */
	if (self.velocity[0] || self.velocity[1]) {
		vecTemp = self.velocity;
		vecTemp[2] = 0;
		flFriction = vlen(vecTemp);

		// if the leading edge is over a dropoff, increase friction
		vecTemp = self.origin + normalize(vecTemp) * 16 + [0,0,1] * PHY_HULL_MIN[2];
		traceline(vecTemp, vecTemp + [0,0,-34], TRUE, self);

		// apply friction
		if (trace_fraction == 1.0) {
			if (flFriction < serverkeyfloat("phy_stopspeed")) {
				flFriction = 1 - move_time * (serverkeyfloat("phy_stopspeed") / flFriction) * flApplyFriction * serverkeyfloat("phy_edgefriction");
			} else {
				flFriction = 1 - move_time * flApplyFriction * serverkeyfloat("phy_edgefriction");
			}
		} else {
			if (flFriction < serverkeyfloat("phy_stopspeed")) {
				flFriction = 1 - move_time * (serverkeyfloat("phy_stopspeed") / flFriction) * flApplyFriction;
			} else {
				
				flFriction = 1 - move_time * flApplyFriction;
			}
		}

		if (flFriction < 0) {
			self.velocity = [0,0,0];
		} else {
			self.velocity = self.velocity * flFriction;
		}
	}

	// acceleration
	flFriction = wish_speed - (self.velocity * wish_dir);
	if (flFriction > 0) {
		self.velocity += wish_dir * min(flFriction, serverkeyfloat("phy_accelerate") * move_time * wish_speed);
	}
}

void
PMoveCustom_AccelGravity(float move_time, float premove, vector wish_dir, float wish_speed)
{
	float flFriction;

	/* apply gravity */
	self.velocity[2] = self.velocity[2] - (PMoveCustom_Gravity(self) * move_time);

	if (wish_speed < 30) {
		flFriction = wish_speed - (self.velocity * wish_dir);
	} else {
		flFriction = 30 - (self.velocity * wish_dir);
	}

	if (flFriction > 0) {
		float fric;
		fric = min(flFriction, serverkeyfloat("phy_airaccelerate") * wish_speed * move_time);
		self.velocity += wish_dir * fric;
	}
}

/* two-pass acceleration */
void
PMoveCustom_Acceleration(float move_time, float premove)
{
	vector vecWishVel;
	vector wish_dir;
	float wish_speed;

	self.jumptime -= move_time;
	self.teleport_time -= move_time;

	makevectors(input_angles);

	/* figure out where we are in the world */
	PMoveCustom_Categorize();

	/* everything but MOVETYPE_NOCLIP has acceleration */
	if (self.movetype != MOVETYPE_NOCLIP) {
		if (self.movetype == MOVETYPE_TOSS) {
			PMoveCustom_AccelToss(move_time, premove);
			return;
		}

		if (self.waterlevel >= 2) {
			PMoveCustom_AccelWater(move_time, premove);
			return;
		}
	}

	/*if (self.teleport_time > 0 && input_movevalues[0] < 0) {
		vecWishVel = v_right * input_movevalues[1];
	} else */ {
		/* on the ground, only yaw matters in terms of direction */
		if (self.flags & FL_ONGROUND) {
			makevectors(input_angles[1] * [0,1,0]);
		}
		vecWishVel = v_forward * input_movevalues[0] + v_right * input_movevalues[1];
	}

	if (self.movetype != MOVETYPE_WALK) {
		vecWishVel[2] += input_movevalues[2];
	} else {
		vecWishVel[2] = 0;
	}

	wish_dir = normalize(vecWishVel);
	wish_speed = vlen(vecWishVel);

	if (wish_speed > self.maxspeed) {
		wish_speed = self.maxspeed;
	}

	if (self.movetype == MOVETYPE_NOCLIP) {
		self.flags &= ~FL_ONGROUND;
		self.velocity = wish_dir * wish_speed;
	} else {
		if (self.flags & FL_ONLADDER) {
			PMoveCustom_AccelLadder(move_time, premove, wish_dir, wish_speed);
		} else if (self.flags & FL_ONGROUND) {
			PMoveCustom_AccelFriction(move_time, premove, wish_dir, wish_speed);
		} else {
			PMoveCustom_AccelGravity(move_time, premove, wish_dir, wish_speed);
		}
	}
}

/* touch other solid entities */
void
PMoveCustom_DoTouch(entity tother)
{
	entity oself = self;
	if (tother.touch) {
		other = self;
		self = tother;
		self.touch();
	}
	self = oself;
}

/* bounce us back off a place normal */
static void
PMoveCustom_Rebound(vector normal)
{
	self.velocity = self.velocity - normal * (self.velocity * normal);

	if (normal[2] > 0.7) {
		self.groundentity = trace_ent;
		self.flags |= FL_ONGROUND;
	}
}

/* brute force unstuck function */
float
PMoveCustom_Fix_Origin(void)
{
	float x, y, z;
	vector norg, oorg = self.origin;

	for (z = 0; z < 3; z++) {
		norg[2] = oorg[2] + ((z==2)?-1:z)*0.0125;
		for (x = 0; x < 3; x++) {
			norg[0] = oorg[0] + ((x==2)?-1:x)*0.0125;
			for (y = 0; y < 3; y++) {
				norg[1] = oorg[1] + ((y==2)?-1:y)*0.0125;

				tracebox(norg, self.mins, self.maxs, norg, MOVE_NORMAL, self);
				if (!trace_startsolid) {
					self.origin = norg;
					return (1);
				}
			}
		}
	}
	return (0);
}

/* move the player based on the given acceleration */
void
PMoveCustom_Move(void)
{
	vector dest;
	vector saved_plane;
	float stepped;
	float move_time;
	int i;

	/* no friction for the deceased */
	if (self.movetype == MOVETYPE_NOCLIP) {
		self.origin = self.origin + self.velocity * input_timelength;
		return;
	}

	/* hacky attempt at base-velocity, this needs to be cleared/wiped at the end */
	if (!(self.flags & FL_ONGROUND)) {
		self.basevelocity[2] = 0;
	}
	self.velocity += self.basevelocity;

	/* we need to bounce off surfaces (in order to slide along them), 
	 * so we need at 2 attempts */
	for (i = 3, move_time = input_timelength; move_time > 0 && i; i--) {
		dest = self.origin + (self.velocity * move_time);

		tracebox(self.origin, self.mins, self.maxs, dest, MOVE_NORMAL, self);

		if (trace_startsolid) {
			if (!PMoveCustom_Fix_Origin()) {
				return;
			}
			continue;
		}

		self.origin = trace_endpos;

		if (trace_fraction > 1) {
			break;
		}
		saved_plane = trace_plane_normal;
		move_time -= move_time * trace_fraction;

		if (move_time) {
			/* step up if we can */
			trace_endpos = self.origin;

			if (self.flags & FL_ONGROUND) {
				trace_endpos[2] += serverkeyfloat("phy_stepheight");
			} else {
				trace_endpos[2] += serverkeyfloat("phy_airstepheight");
			}

			tracebox(self.origin, self.mins, self.maxs, trace_endpos, MOVE_NORMAL, self);
			stepped = trace_endpos[2] - self.origin[2];

			float roof_fraction = trace_fraction;
			vector roof_plane_normal = trace_plane_normal;

			dest = trace_endpos + self.velocity*move_time;
			dest[2] = trace_endpos[2]; /*only horizontally*/

			/* move forwards */
			tracebox(trace_endpos, self.mins, self.maxs, dest, MOVE_NORMAL, self);

			/* if we got anywhere, make this raised-step move count */
			if (trace_fraction != 0) {
				float fwfrac = trace_fraction;
				vector fwplane = trace_plane_normal;

				/* move down */
				dest = trace_endpos;
				dest[2] -= stepped + 1;
				tracebox(trace_endpos, self.mins, self.maxs, dest, MOVE_NORMAL, self);

				if (trace_fraction < 1 && trace_plane_normal[2] > 0.7f) {
					move_time -= move_time * fwfrac;
					/* bounce off the ceiling */
					if (roof_fraction < 1) {
						PMoveCustom_Rebound(roof_plane_normal);
					}
					if (trace_fraction < 1) {
						PMoveCustom_Rebound(trace_plane_normal);
					} else if (fwfrac < 1) {
						PMoveCustom_Rebound(fwplane);
					}
					self.origin = trace_endpos;
					continue;
				}
			}
		}

		/* stepping failed, just bounce off */
		PMoveCustom_Rebound(saved_plane);
		PMoveCustom_DoTouch(trace_ent);
	}

	/* touch whatever is below */
	if (self.flags & FL_ONGROUND) {
		dest = self.origin;
		dest[2] -= serverkeyfloat("phy_stepheight");
		tracebox(self.origin, self.mins, self.maxs, dest, MOVE_NORMAL, self);
		if (trace_fraction >= 1) {
			return;
		}
		/*if (trace_startsolid) {
			if (!PMoveCustom_Fix_Origin()) {
				return;
			}
		}*/
		PMoveCustom_DoTouch(trace_ent);
		self.groundentity = trace_ent;
	}

	/* make sure that the basevelocity we've applied is discarded by next frame */
	self.velocity -= self.basevelocity;
}

/* this is called for when we want to run the custom QC player physics */
void
PMoveCustom_RunPlayerPhysics(entity target)
{
	entity oldself = self;
	self = target;

	/* call accelerate before and after the actual move, 
	 * with half the move each time. this reduces framerate dependence. 
	 * and makes controlling jumps slightly easier */
	PMoveCustom_Acceleration(input_timelength / 2, TRUE);
	PMoveCustom_Move();
	PMoveCustom_Acceleration(input_timelength / 2, FALSE);

	/* NOTE: should clip to network precision here if lower than a float */
	self.angles = input_angles;
	self.angles[0] *= -0.333;

	/* clear base-velocity and ground-entity */
	self.basevelocity = [0,0,0];
	self.groundentity = __NULL__;

	/* activate any SOLID_TRIGGER entities */
	touchtriggers();
	self = oldself;
}
#endif 
