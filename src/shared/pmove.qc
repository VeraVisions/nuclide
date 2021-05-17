/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
#define CUSTOMPLAYERPHYSICS
#ifndef PMOVE_STEPHEIGHT
	#define PMOVE_STEPHEIGHT 18
#endif

#ifndef PMOVE_AIRSTEPHEIGHT
	#define PMOVE_AIRSTEPHEIGHT 18
#endif

#ifndef PMOVE_FRICTION
	#define PMOVE_FRICTION 4
#endif

#ifndef PMOVE_EDGEFRICTION
	#define PMOVE_EDGEFRICTION 1
#endif

#ifndef PMOVE_STOPSPEED
	#define PMOVE_STOPSPEED 75
#endif

#ifndef PMOVE_GRAVITY
	#define PMOVE_GRAVITY 800
#endif

#ifndef PMOVE_AIRACCELERATE
	#define PMOVE_AIRACCELERATE 10
#endif

#ifndef PMOVE_WATERACCELERATE
	#define PMOVE_WATERACCELERATE 8
#endif

#ifndef PMOVE_ACCELERATE
	#define PMOVE_ACCELERATE 8
#endif

#ifndef PMOVE_MAXSPEED
	#define PMOVE_MAXSPEED 270
#endif

#ifndef PMOVE_STEP_WALKSPEED
	#define PMOVE_STEP_WALKSPEED 135
#endif

#ifndef PMOVE_STEP_RUNSPEED
	#define PMOVE_STEP_RUNSPEED 220
#endif

#ifndef PHY_VIEWPOS
	#define PHY_VIEWPOS [0,0,24]
#endif

#ifndef PHY_VIEWPOS_CROUCHED
	#define PHY_VIEWPOS_CROUCHED [0,0,12]
#endif


/* Those are constant for HL BSP and CANNOT be changed.
 * Blame Valve for purchasing a Quake II license but not
 * scrapping hull sizes for their .bsp format... 
 * however, you can offset them */
#ifndef PHY_HULL_MIN
	#define PHY_HULL_MIN [-16,-16,-36]
#endif

#ifndef PHY_HULL_MAX
	#define PHY_HULL_MAX [16,16,36]
#endif

#ifndef PHY_HULL_CROUCHED_MIN
	#define PHY_HULL_CROUCHED_MIN [-16,-16,-18]
#endif

#ifndef PHY_HULL_CROUCHED_MAX
	#define PHY_HULL_CROUCHED_MAX [16,16,18]
#endif

/* if they're undefined by a config, they'll be set by the game/mod default */
var float autocvar_sv_stepheight = PMOVE_STEPHEIGHT;
var float autocvar_sv_airstepheight = PMOVE_AIRSTEPHEIGHT;
var float autocvar_sv_friction = PMOVE_FRICTION;
var float autocvar_sv_edgefriction = PMOVE_EDGEFRICTION;
var float autocvar_sv_stopspeed = PMOVE_STOPSPEED;
var float autocvar_sv_gravity = PMOVE_GRAVITY;
var float autocvar_sv_airaccelerate = PMOVE_AIRACCELERATE;
var float autocvar_sv_wateraccelerate = PMOVE_WATERACCELERATE;
var float autocvar_sv_accelerate = PMOVE_ACCELERATE;
var float autocvar_sv_maxspeed = PMOVE_MAXSPEED;

/* FIXME: jumptime should use the time global, as time intervals are not
 * predictable - decrement it based upon input_timelength */

/* serverinfo keys are the only way both client and server are kept in sync
 * about physics variables. so none of the traditional cvars will work.
 * otherwise we could not have reliable prediction code for player movement.
 */
void
PMove_Init(void)
{
}

void
PMove_SetSize(entity targ)
{
	if (targ.flags & FL_CROUCHING)
		setsize(targ, PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
	else
		setsize(targ, PHY_HULL_MIN, PHY_HULL_MAX);
}

#ifdef SERVER
/* we need to network our changes everytime cvars are updated */
void
PMove_UpdateVar(string info, string cv)
{
	float d = cvar(cv);
	if (serverkeyfloat(info) != d) {
		readcmd(sprintf("serverinfo %s %d\n", info, d));
	}
}

void
PMove_StartFrame(void)
{
	PMove_UpdateVar("phy_stepheight", "sv_stepheight");
	PMove_UpdateVar("phy_airstepheight", "sv_airstepheight");
	PMove_UpdateVar("phy_friction", "sv_friction");
	PMove_UpdateVar("phy_edgefriction", "sv_edgefriction");
	PMove_UpdateVar("phy_stopspeed", "sv_stopspeed");
	PMove_UpdateVar("phy_gravity", "sv_gravity");
	PMove_UpdateVar("phy_airaccelerate", "sv_airaccelerate");
	PMove_UpdateVar("phy_wateraccelerate", "sv_wateraccelerate");
	PMove_UpdateVar("phy_accelerate", "sv_accelerate");
	PMove_UpdateVar("phy_maxspeed", "sv_maxspeed");
}
#endif

/* pointcontents reimplementation, only way we can effectively trace 
 * against ladders and liquids that are defined in the game-logic.
 */
int
PMove_Contents(vector org)
{
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = -1;
	traceline(org, org, TRUE, self);
	self.hitcontentsmaski = oldhitcontents;
	return trace_endcontentsi;
}

/* used for trigger_gravity type entities */
float
PMove_Gravity(entity ent)
{
	if (ent.gravity) {
		return serverkeyfloat("phy_gravity") * ent.gravity; 
	} else {
		return serverkeyfloat("phy_gravity");
	}
}

void
PMove_SetViewOfs(void)
{
	if (self.flags & FL_CROUCHING) {
		self.mins = PHY_HULL_CROUCHED_MIN;
		self.maxs = PHY_HULL_CROUCHED_MAX;
		self.view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		self.mins = PHY_HULL_MIN;
		self.maxs = PHY_HULL_MAX;
		self.view_ofs = PHY_VIEWPOS;
	}
}

/* figure out where we are in the geometry. void, solid, liquid, etc. */
void
PMove_Categorize(void)
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

	contents = PMove_Contents(self.origin + self.mins + [0,0,1]);

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
		if (PMove_Contents(self.origin + (self.mins + self.maxs) * 0.5) 
			& CONTENTBITS_FLUID)
		{
			if (PMove_Contents(self.origin + self.maxs - '0 0 1')
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


/* spammed whenever we're near a ledge, getting out of a pool or something */
void
PMove_CheckWaterJump(void)
{
	vector vStart;
	vector vEnd;

	makevectors(self.angles);
	vStart = self.origin;
	vStart[2] = vStart[2] + 8; 
	v_forward[2] = 0;
	normalize(v_forward);
	vEnd = vStart + (v_forward * 24);
	traceline(vStart, vEnd, TRUE, self);

	if (trace_fraction < 1) {
		vStart[2] = vStart[2] + self.maxs[2];
		vEnd = vStart + (v_forward * 24);
		//self.movedir = trace_plane_normal * -50;
		traceline(vStart, vEnd, TRUE, self);
		
		if (trace_fraction == 1) {
			self.flags |= FL_WATERJUMP;
			self.velocity[2] = 350;
			self.flags &= ~FL_JUMPRELEASED;
			return;
		}
	}
}

/* simple bounds check */
int
QPMove_IsStuck(entity eTarget, vector vOffset, vector vecMins, vector vecMaxs)
{
	vector bound;

	if (eTarget.solid != SOLID_SLIDEBOX) {
		return (0);
	}

	bound = eTarget.origin + vOffset;
	tracebox(bound, vecMins, vecMaxs, bound, MOVE_NORMAL, eTarget);
	return trace_startsolid;
}

void
PMove_AccelToss(float move_time, float premove)
{
	self.velocity[2] = self.velocity[2] - (PMove_Gravity(self) * move_time);
}

void
PMove_AccelMove(float move_time, float premove)
{
	int iFixCrouch = FALSE;
	if (input_buttons & INPUT_BUTTON8) {
		self.flags |= FL_CROUCHING;
	} else {
		// If we aren't holding down duck anymore and 'attempt' to stand up, prevent it
		if (self.flags & FL_CROUCHING) {
			if (QPMove_IsStuck(self, '0 0 36', PHY_HULL_MIN, PHY_HULL_MAX) == FALSE) {
				self.flags &= ~FL_CROUCHING;
				iFixCrouch = TRUE;
			}
		} else {
			self.flags &= ~FL_CROUCHING;
		}
	}

	if (self.flags & FL_CROUCHING) {
		setsize(self, PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
		self.view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		setsize(self, PHY_HULL_MIN, PHY_HULL_MAX);
		if (iFixCrouch && QPMove_IsStuck(self, [0,0,0], PHY_HULL_MIN, PHY_HULL_MAX)) {
			for (int i = 0; i < 36; i++) {
				self.origin[2] += 1;
				if (QPMove_IsStuck(self, [0,0,0], self.mins, self.maxs) == FALSE) {
					break;
				}
			}
		}
		setorigin(self, self.origin);
		self.view_ofs = PHY_VIEWPOS;
	}
}

void
PMove_AccelWater(float move_time, float premove)
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
PMove_AccelLadder(float move_time, float premove, vector wish_dir, float wish_speed)
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
PMove_AccelFriction(float move_time, float premove, vector wish_dir, float wish_speed)
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
		vecTemp = self.origin + normalize(vecTemp) * 16 + '0 0 1' * PHY_HULL_MIN[2];
		traceline(vecTemp, vecTemp + '0 0 -34', TRUE, self);

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
PMove_AccelGravity(float move_time, float premove, vector wish_dir, float wish_speed)
{
	float flFriction;

	/* apply gravity */
	self.velocity[2] = self.velocity[2] - (PMove_Gravity(self) * move_time);

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

void
PMove_AccelJump(float move_time, float premove)
{
	/* unset jump-key whenever it's not set */
	if (!(input_buttons & INPUT_BUTTON2)) {
		self.flags |= FL_JUMPRELEASED;
		return;
	}

	if (self.flags & FL_WATERJUMP)
		return;
	if (!(self.flags & FL_ONGROUND))
		return;
	if (!(self.flags & FL_JUMPRELEASED))
		return;

	if (input_buttons & INPUT_BUTTON2 && premove) {
		if (self.velocity[2] < 0) {
			self.velocity[2] = 0;
		}

		GamePMove_Jump((player)self);
		self.flags &= ~FL_ONGROUND;
		self.flags &= ~FL_JUMPRELEASED;
	}
}

/* two-pass acceleration */
void
PMove_Acceleration(float move_time, float premove)
{
	vector vecWishVel;
	vector wish_dir;
	float wish_speed;

	self.jumptime -= move_time;
	self.teleport_time -= move_time;

	makevectors(input_angles);

	/* figure out where we are in the world */
	PMove_Categorize();

	/* everything but MOVETYPE_NOCLIP has acceleration */
	if (self.movetype != MOVETYPE_NOCLIP) {
		if (self.movetype == MOVETYPE_TOSS) {
			PMove_AccelToss(move_time, premove);
			return;
		} else if (self.movetype == MOVETYPE_WALK) {
			PMove_AccelMove(move_time, premove);
		}

		if (self.waterlevel >= 2) {
			PMove_AccelWater(move_time, premove);
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
			PMove_AccelLadder(move_time, premove, wish_dir, wish_speed);
		} else if (self.flags & FL_ONGROUND) {
			PMove_AccelFriction(move_time, premove, wish_dir, wish_speed);
		} else {
			PMove_AccelGravity(move_time, premove, wish_dir, wish_speed);
		}
		PMove_AccelJump(move_time, premove);
	}
}

/* touch other solid entities */
void
PMove_DoTouch(entity tother)
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
PMove_Rebound(vector normal)
{
	self.velocity = self.velocity - normal * (self.velocity * normal);
}

/* brute force unstuck function */
float
PMove_Fix_Origin(void)
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
PMove_Move(void)
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
			if (!PMove_Fix_Origin()) {
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
						PMove_Rebound(roof_plane_normal);
					}
					if (trace_fraction < 1) {
						PMove_Rebound(trace_plane_normal);
					} else if (fwfrac < 1) {
						PMove_Rebound(fwplane);
					}
					self.origin = trace_endpos;
					continue;
				}
			}
		}

		/* stepping failed, just bounce off */
		PMove_Rebound(saved_plane);
		PMove_DoTouch(trace_ent);
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
			if (!PMove_Fix_Origin()) {
				return;
			}
		}*/
		PMove_DoTouch(trace_ent);
		self.groundentity = trace_ent;
	}

	/* make sure that the basevelocity we've applied is discarded by next frame */
	self.velocity -= self.basevelocity;
}

/* it all starts here, this function is called by both CLIENT and SERVER for
   obvious prediction purposes. The SERVER will usually do this in the
   Game_RunClientCommand function and the CLIENT will do so in both the
   prediction places of Predict_PreFrame and Player_ReceiveEntity */
void
PMove_Run(void)
{
	float punch;
	player pl = (player)self;

	float flFallVel = (self.flags & FL_ONGROUND) ? 0 : -self.velocity[2];

	/* maxspeed changes when crouching, TODO: make this game-specific */
	self.maxspeed = GamePMove_Maxspeed((player)self);

	/* when pressing the 'use' button, we also walk slower for precision */
	if (input_buttons & INPUT_BUTTON5) {
		input_movevalues *= 0.25;
	}

	if (pl.flags & FL_FROZEN || pl.movetype == MOVETYPE_NONE) {
		input_movevalues = [0,0,0];
		input_buttons &= ~INPUT_BUTTON2;
	}

	/* move camera up (noclip, fly) when holding jump */
	if (input_buttons & INPUT_BUTTON2) {
		input_movevalues[2] = 240;
	}
	/* move camera down (noclip, fly) when holding crouching */
	if (input_buttons & INPUT_BUTTON8) {
		input_movevalues[2] = -240;
	}

	/* establish which water elements we're dealing in */
	GamePMove_WaterMove(pl);

	/* we might need to apply extra-velocity to get out of water-volumes */
	if (self.waterlevel >= 2) {
		PMove_CheckWaterJump();
	}
	/* grappling hook stuff */
	if (pl.hook.skin == 1) {
		pl.velocity = (pl.hook.origin - pl.origin);
		pl.velocity = (pl.velocity * (1 / (vlen(pl.velocity) / 750)));
	}

	PMove_SetViewOfs();

	/* call accelerate before and after the actual move, 
	 * with half the move each time. this reduces framerate dependence. 
	 * and makes controlling jumps slightly easier */
#ifdef CUSTOMPLAYERPHYSICS
	PMove_Acceleration(input_timelength / 2, TRUE);
	PMove_Move();
	PMove_Acceleration(input_timelength / 2, FALSE);

	/* NOTE: should clip to network precision here if lower than a float */
	self.angles = input_angles;
	self.angles[0] *= -0.333;

	/* clear base-velocity and ground-entity */
	self.basevelocity = [0,0,0];
	self.groundentity = __NULL__;

	/* activate any SOLID_TRIGGER entities */
	touchtriggers();
#else
	PMove_AccelMove(input_timelength, FALSE);
	runstandardplayerphysics(self);
#endif

	if (self.waterlevel != 0) {
		flFallVel = 0;
	}

	if ((self.flags & FL_ONGROUND) && self.movetype == MOVETYPE_WALK) {
		GamePMove_Fall((player)self, flFallVel);
	}

	/* timers, these are predicted and shared across client and server */
	pl.w_attack_next = max(0, pl.w_attack_next - input_timelength);
	pl.w_idle_next = max(0, pl.w_idle_next - input_timelength);
	pl.weapontime += input_timelength;
	punch = max(0, 1.0f - (input_timelength * 4));
	pl.punchangle[0] *= punch;
	pl.punchangle[1] *= punch;
	pl.punchangle[2] *= punch;

	/* player animation code */
	Animation_TimerUpdate(pl, input_timelength);
	Animation_PlayerUpdate(pl);

	/* allow vehicles to prevent weapon logic from happening */
#ifdef SERVER
	Vehicle_Input();
#endif

	/* weapon/item logic of what the player controls */
	Game_Input();
}
