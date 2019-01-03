/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

float input_timelength;
vector input_angles;
vector input_movevalues;
float input_buttons;

var float PHY_JUMP_CHAINWINDOW	= 0.5f; // maximum possible height from double/chain jump
var float PHY_JUMP_CHAIN		= 100; // decay over lifetime of window
var float PHY_JUMP_CHAINDECAY	= 50;

/*FIXME: jumptime should use the time global, as time intervals are not predictable - decrement it based upon input_timelength*/
.float jumptime;
.float waterlevel;
.float watertype;
.float teleport_time;
//int trace_endcontentsi;
.float maxspeed;
.vector view_ofs;

/*
=================
PMove_Init
=================
*/
void PMove_Init(void) {
	localcmd("serverinfo phy_stepheight 18\n");
	localcmd("serverinfo phy_airstepheight 18\n");
	localcmd("serverinfo phy_friction 4\n");
	localcmd("serverinfo phy_edgefriction 1\n");
	localcmd("serverinfo phy_accelerate 4\n");
	localcmd("serverinfo phy_stopspeed 75\n");
	localcmd("serverinfo phy_gravity 800\n");
	localcmd("serverinfo phy_maxspeed 240\n");
}

/*
=================
PMove_Categorize

	Figures out where we are in the game world.
	Whether we are in water, on the ground etc.
=================
*/
void PMove_Categorize(void)
{
	float contents;

	// Make sure
	if ((self.flags & FL_CROUCHING) /*&& !(self.flags & FL_ONLADDER)*/) {
		self.mins = VEC_CHULL_MIN;
		self.maxs = VEC_CHULL_MAX;
		self.view_ofs = VEC_PLAYER_CVIEWPOS;
	} else {
		self.mins = VEC_HULL_MIN;
		self.maxs = VEC_HULL_MAX;
		self.view_ofs = VEC_PLAYER_VIEWPOS;
	}

	tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 0.25', FALSE, self);

	if (!trace_startsolid) {
		if ((trace_fraction < 1) && (trace_plane_normal[2] > 0.7)) {
			self.flags |= FL_ONGROUND;
		} else {
			self.flags &= ~FL_ONGROUND;
		}
	}

	// Check water levels, boo
	contents = pointcontents(self.origin + self.mins + '0 0 1');
	
	//print(sprintf("Contents: %d\n", contents));

	// Ladder content testing
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBIT_FTELADDER;
	tracebox(self.origin, self.mins, self.maxs, self.origin, FALSE, self);
	self.hitcontentsmaski = oldhitcontents;

	/*if (trace_endcontentsi & CONTENTBIT_FTELADDER || iContents == CONTENT_LADDER) {
		self.flags |= FL_ONLADDER;
	} else {
		self.flags &= ~FL_ONLADDER;
	}*/

	if (contents < CONTENT_SOLID && contents != CONTENT_LADDER) {
		self.watertype = contents;
		if (pointcontents(self.origin + (self.mins + self.maxs) * 0.5) < CONTENT_SOLID) {
			if (pointcontents(self.origin + self.maxs - '0 0 1') < CONTENT_SOLID) {
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

/*
===========
PMove_WaterMove
============
*/
void PMove_WaterMove(void)
{
	if (self.movetype == MOVETYPE_NOCLIP) {
		return;
	}
	/*if (self.health < 0) {
		return;
	}*/

#if 0
	CPlayer plPlayer = (CPlayer)self;
	if (plPlayer.waterlevel != 3) {
		if (plPlayer.m_flAirFinished < time) {
			//sound (plPlayer, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		} else if (plPlayer.m_flAirFinished < time + 9) {
			//sound (plPlayer, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		}
		plPlayer.m_flAirFinished = time + 12;
		plPlayer.dmg = 2;
	} else if (plPlayer.m_flAirFinished < time) {
		if (plPlayer.m_flPainFinished < time) {
			plPlayer.dmg = plPlayer.dmg + 2;
			if (plPlayer.dmg > 15) {
				plPlayer.dmg = 10;
			}

			Damage_Apply(plPlayer, world, plPlayer.dmg, DAMAGE_DROWNING, WEAPON_NONE);
			plPlayer.m_flPainFinished = time + 1;
		}
	}
#endif

	if (!self.waterlevel){
		if (self.flags & FL_INWATER) {
#if 0
			//sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
#endif
			self.flags = self.flags - (self.flags & FL_INWATER);
		}
		return;
	}

#if 0
	if (plPlayer.watertype == CONTENT_LAVA) {
		if (plPlayer.m_flDamageTime < time) {
			plPlayer.m_flDamageTime = time + 0.2;
			Damage_Apply(plPlayer, world, 10*plPlayer.waterlevel, DAMAGE_BURN, WEAPON_NONE);
		}
	} else if (plPlayer.watertype == CONTENT_SLIME) {
		if (plPlayer.m_flDamageTime < time) {
			plPlayer.m_flDamageTime = time + 1;
			Damage_Apply(plPlayer, world, 4*plPlayer.waterlevel, DAMAGE_ACID, WEAPON_NONE);
		}
	}
#endif
	if (!(self.flags & FL_INWATER)) {
#if 0
		sound (self, CHAN_BODY, "player/land/slosh.wav", 1, ATTN_NORM);
		plPlayer.m_flDamageTime = 0;
#endif
		self.flags |= FL_INWATER;
	}

	if (!(self.flags & FL_WATERJUMP)) {
		self.velocity = self.velocity - 0.8 * self.waterlevel * frametime * self.velocity;
	}
}

void PMove_CheckWaterJump(void)
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
			//self.flags = self.flags | FL_WATERJUMP;
			self.velocity[2] = 350;
			self.flags &= ~FL_JUMPRELEASED;
			return;
		}
	}
}

int QPMove_IsStuck(entity eTarget, vector vOffset, vector vecMins, vector vecMaxs)
{
	if (eTarget.solid != SOLID_SLIDEBOX) {
		return FALSE;
	}
	tracebox(eTarget.origin + vOffset, vecMins, vecMaxs, eTarget.origin + vOffset, FALSE, eTarget);
	return trace_startsolid;
}

/*
=================
PMove_Run_Acceleration

	This function applies the velocity changes the player wishes to apply
=================
*/
void PMove_Run_Acceleration(float flMovetime, float flBefore)
{
	vector vecWishVel;
	vector vecWishDir;
	vector vecTemp;
	float flWishSpeed;
	float flFriction;
	float flJumptimeDelta;
	float flChainBonus;
	int iFixCrouch = FALSE;

	PMove_Categorize();

	// Update the timer
	self.jumptime -= flMovetime;
	self.teleport_time -= flMovetime;

	// Corpses
	if (self.movetype == MOVETYPE_TOSS) {
		self.velocity[2] = self.velocity[2] - (serverkeyfloat("phy_gravity") * flMovetime);
		return;
	}

	if (self.movetype == MOVETYPE_WALK) {
		// Crouching
		if (input_buttons & INPUT_BUTTON8 /*&& !(self.flags & FL_ONLADDER)*/) {
			self.flags |= FL_CROUCHING;
		} else {
			// If we aren't holding down duck anymore and 'attempt' to stand up, prevent it
			if (self.flags & FL_CROUCHING) {
				if (QPMove_IsStuck(self, '0 0 36', VEC_HULL_MIN, VEC_HULL_MAX) == FALSE) {
					self.flags &= ~FL_CROUCHING;
					iFixCrouch = TRUE;
				}
			} else {
				self.flags &= ~FL_CROUCHING;
			}
		}
		
		if (self.flags & FL_CROUCHING) {
			setsize(self, VEC_CHULL_MIN, VEC_CHULL_MAX);
			//input_movevalues *= 0.333f;
	#ifdef SSQC
			self.view_ofs = VEC_PLAYER_CVIEWPOS;
	#endif
		} else {
			setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
			if (iFixCrouch && QPMove_IsStuck(self, [0,0,0], VEC_HULL_MIN, VEC_HULL_MAX)) {
				for (int i = 0; i < 36; i++) {
					self.origin[2] += 1;
					if (QPMove_IsStuck(self, [0,0,0], self.mins, self.maxs) == FALSE) {
						break;
					}
				}
			}
			setorigin(self, self.origin);
	#ifdef SSQC
			self.view_ofs = VEC_PLAYER_VIEWPOS;
	#endif
		}
	}

	makevectors(input_angles);	
	// swim
	if (self.waterlevel >= 2) {
		if (self.movetype != MOVETYPE_NOCLIP) {
			self.flags = self.flags - (self.flags & FL_ONGROUND);

			if (input_movevalues == [0,0,0]) {
				vecWishVel = '0 0 -60'; // drift towards bottom
			} else {
				vecWishVel = v_forward * input_movevalues[0];
				vecWishVel += v_right * input_movevalues[1];
				vecWishVel += v_up * input_movevalues[2];
			}

			flWishSpeed = vlen(vecWishVel);
			
			if (flWishSpeed > self.maxspeed) {
				flWishSpeed = self.maxspeed;
			}
	
			flWishSpeed = flWishSpeed * 0.7;
	
			// water friction
			if (self.velocity != [0,0,0]) {
				flFriction = vlen(self.velocity) * (1 - flMovetime * serverkeyfloat("phy_friction"));
				if (flFriction > 0) {
					self.velocity = normalize(self.velocity) * flFriction;
				} else {
					self.velocity = [0,0,0];
				}
			} else {
				flFriction = 0;
			}
	
			// water acceleration
			if (flWishSpeed <= flFriction) {
				return;
			}
	
			flFriction = min(flWishSpeed - flFriction, serverkeyfloat("phy_accelerate") * flWishSpeed * flMovetime);
			self.velocity = self.velocity + normalize(vecWishVel) * flFriction;
			return;
		}
	}
	// hack to not let you back into teleporter
	if (self.teleport_time > 0 && input_movevalues[0] < 0) {
		vecWishVel = v_right * input_movevalues[1];
	} else {
		if (self.movetype == MOVETYPE_NOCLIP) {
		} else if (self.flags & FL_ONGROUND) {
			makevectors (input_angles[1] * [0,1,0]);
		}

		vecWishVel = v_forward * input_movevalues[0] + v_right * input_movevalues[1];
	}

	if (self.movetype != MOVETYPE_WALK) {
		vecWishVel[2] += input_movevalues[2];
	} else {
		vecWishVel[2] = 0;
	}
	
	vecWishDir = normalize(vecWishVel);
	flWishSpeed = vlen(vecWishVel);
	
	if (flWishSpeed > self.maxspeed) {
		flWishSpeed = self.maxspeed;
	}

	if (self.movetype == MOVETYPE_NOCLIP) {
		self.flags &= ~FL_ONGROUND;
		self.velocity = vecWishDir * flWishSpeed;
	} else {
		/*FIXME: pogostick*/
		if (self.flags & FL_ONGROUND)
		if (!(self.flags & FL_WATERJUMP))
		if (self.flags & FL_JUMPRELEASED)
		if (input_buttons & INPUT_BUTTON2 && flBefore) {
			if (self.velocity[2] < 0) {
				self.velocity[2] = 0;
			}

			if (self.waterlevel >= 2) {
				if (self.watertype == CONTENT_WATER) {
					self.velocity[2] = 100;
				} else if (self.watertype == CONTENT_SLIME) {
					self.velocity[2] = 80;
				} else {
					self.velocity[2] = 50;
				}
			} else {
				self.velocity[2] += 240;
			}

			if (self.jumptime > 0) {
				// time since last jump
				flJumptimeDelta = 0 - (self.jumptime - PHY_JUMP_CHAINWINDOW);
				//self.velocity[2] += PHY_JUMP_CHAIN;
				flChainBonus = PHY_JUMP_CHAIN - (((PHY_JUMP_CHAINWINDOW - (PHY_JUMP_CHAINWINDOW - flJumptimeDelta)) * 2) * PHY_JUMP_CHAINDECAY);
				self.velocity[2] += flChainBonus;
			}
			self.jumptime = PHY_JUMP_CHAINWINDOW;
			self.flags &= ~FL_ONGROUND;
			self.flags &= ~FL_JUMPRELEASED;
		}
		// not pressing jump, set released flag
		if (!(input_buttons & INPUT_BUTTON2)) {
			self.flags |= FL_JUMPRELEASED;
		}

		if (self.flags & FL_ONGROUND /*|| self.flags & FL_ONLADDER*/) {
			// friction
			if (self.velocity[0] || self.velocity[1]) {
				vecTemp = self.velocity;
				vecTemp[2] = 0;
				flFriction = vlen(vecTemp);

				// if the leading edge is over a dropoff, increase friction
				vecTemp = self.origin + normalize(vecTemp) * 16 + '0 0 1' * VEC_HULL_MIN[2];

				traceline(vecTemp, vecTemp + '0 0 -34', TRUE, self);

				// apply friction
				if (trace_fraction == 1.0) {
					if (flFriction < serverkeyfloat("phy_stopspeed")) {
						flFriction = 1 - flMovetime * (serverkeyfloat("phy_stopspeed") / flFriction) * serverkeyfloat("phy_friction") * serverkeyfloat("phy_edgefriction");
					} else {
						flFriction = 1 - flMovetime * serverkeyfloat("phy_friction") * serverkeyfloat("phy_edgefriction");
					}
				} else {
					if (flFriction < serverkeyfloat("phy_stopspeed")) {
						flFriction = 1 - flMovetime * (serverkeyfloat("phy_stopspeed") / flFriction) * serverkeyfloat("phy_friction");
					} else {
						flFriction = 1 - flMovetime * serverkeyfloat("phy_friction");
					}
				}

				if (flFriction < 0) {
					self.velocity = [0,0,0];
				} else {
					self.velocity = self.velocity * flFriction;
				}
			}

			/*if (self.flags & FL_ONLADDER) {
				vector vPlayerVector;

				makevectors(input_angles);
				vPlayerVector = v_forward;
				vPlayerVector = (vPlayerVector * 240);

				if (input_movevalues[0] > 0) {
					self.velocity = vPlayerVector;
				} else {
					self.velocity = [0,0,0];
				}
			}*/

			// acceleration
			flFriction = flWishSpeed - (self.velocity * vecWishDir);
			if (flFriction > 0) {
				self.velocity = self.velocity + vecWishDir * min(flFriction, serverkeyfloat("phy_accelerate") * flMovetime * flWishSpeed);
			}
		} else {
			/* apply gravity */
			self.velocity[2] = self.velocity[2] - (serverkeyfloat("phy_gravity") * flMovetime);

			if (flWishSpeed < 30) {
				flFriction = flWishSpeed - (self.velocity * vecWishDir);
			} else {
				flFriction = 30 - (self.velocity * vecWishDir);
			}

			if (flFriction > 0) {
				self.velocity = self.velocity + vecWishDir * (min(flFriction, serverkeyfloat("phy_accelerate")) * flWishSpeed * flMovetime);
			}
		}
	}

	/*if (self.gflags & GF_FROZEN) {
		self.velocity[0] = self.velocity[1] = 0;
	}*/
}

/*
=================
PMove_Rebound

	Calls somethings touch() function upon hit.
=================
*/
void PMove_DoTouch(entity tother)
{
	entity oself = self;
	if (tother.touch) {
		other = self;
		self = tother;
		self.touch();
	}
	self = oself;
}

/*
=================
PMove_Rebound

	This function 'bounces' off any surfaces that were hit
=================
*/
static void PMove_Rebound(vector vecNormal)
{
	self.velocity = self.velocity - vecNormal * (self.velocity * vecNormal);
}

/*
=================
PMove_Fix_Origin

	Incase BSP precision messes up, this function will attempt
	to correct the origin to stop it from being invalid.
=================
*/
float PMove_Fix_Origin(void)
{
	float x, y, z;
	vector norg, oorg = self.origin;
	
	for (z = 0; z < 3; z++) {
		norg[2] = oorg[2] + ((z==2)?-1:z)*0.0125;
		for (x = 0; x < 3; x++) {
			norg[0] = oorg[0] + ((x==2)?-1:x)*0.0125;
			for (y = 0; y < 3; y++) {
				norg[1] = oorg[1] + ((y==2)?-1:y)*0.0125;

				tracebox(norg, self.mins, self.maxs, norg, FALSE, self);
				if (!trace_startsolid) {
					//dprint("[PHYSICS] Unstuck\n");
					self.origin = norg;
					return TRUE;
				}
			}
		}
	}
	//dprint("[PHYSICS] Stuck\n");
	return FALSE;
}

/*
=================
PMove_Run_Move

	This function is responsible for moving the entity 
	forwards according to the various inputs/state.
=================
*/
void PMove_Run_Move(void)
{
	vector vecDestPos;
	vector vecSavePlane;
	float flStepped;
	float flMoveTime;
	int iAttempts;

	if (self.movetype == MOVETYPE_NOCLIP) {
		self.origin = self.origin + self.velocity * input_timelength;
		return;
	}

	// we need to bounce off surfaces (in order to slide along them), so we need at 2 attempts
	for (iAttempts = 3, flMoveTime = input_timelength; flMoveTime > 0 && iAttempts; iAttempts--) {
		vecDestPos = self.origin + (self.velocity * flMoveTime);
		tracebox(self.origin, self.mins, self.maxs, vecDestPos, FALSE, self);

		if (trace_startsolid) {
			if (!PMove_Fix_Origin()) {
				return;
			}
			continue;
		}

		self.origin = trace_endpos;

		if (trace_fraction < 1) {
			vecSavePlane = trace_plane_normal;
			flMoveTime -= flMoveTime * trace_fraction;

			if (flMoveTime) {
				// step up if we can
				trace_endpos = self.origin;

				if (self.flags & FL_ONGROUND) {
					trace_endpos[2] += serverkeyfloat("phy_stepheight");
				} else {
					trace_endpos[2] += serverkeyfloat("phy_airstepheight");
				}

				tracebox(self.origin, self.mins, self.maxs, trace_endpos, FALSE, self);
				flStepped = trace_endpos[2] - self.origin[2];

				float roof_fraction = trace_fraction;
				vector roof_plane_normal = trace_plane_normal;

				vecDestPos = trace_endpos + self.velocity*flMoveTime;
				vecDestPos[2] = trace_endpos[2]; /*only horizontally*/

				// move forwards
				tracebox(trace_endpos, self.mins, self.maxs, vecDestPos, FALSE, self);

				// if we got anywhere, make this raised-step move count
				if (trace_fraction != 0) {
					float fwfrac = trace_fraction;
					vector fwplane = trace_plane_normal;

					// move down
					vecDestPos = trace_endpos;
					vecDestPos[2] -= flStepped + 1;
					tracebox(trace_endpos, self.mins, self.maxs, vecDestPos, FALSE, self);

					if (trace_fraction < 1 && trace_plane_normal[2] > 0.7f) {
						flMoveTime -= flMoveTime * fwfrac;
						/* bounce off the ceiling if we hit it while airstepping */
						if (roof_fraction < 1) {
							PMove_Rebound(roof_plane_normal);
						}
						/* FIXME: you probably want this: && self.velocity[2] < 0 */
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

			//stepping failed, just bounce off
			PMove_Rebound(vecSavePlane);
			PMove_DoTouch(trace_ent);
		} else {
			break;
		}
	}

	if ((self.flags & FL_ONGROUND) && !(self.velocity[2] > 0)) {
		/* try to step down, only if there's something down there */
		vecDestPos = self.origin;
		vecDestPos[2] -= serverkeyfloat("phy_stepheight");
		tracebox(self.origin, self.mins, self.maxs, vecDestPos, FALSE, self);	//try going straight there
		if (trace_fraction >= 1) {
			return;
		}
		if (trace_startsolid) {
			if (!PMove_Fix_Origin()) {
				return;
			}
		}
		self.origin = trace_endpos;

		PMove_DoTouch(trace_ent);
	}
}

/*
=================
PMove_Run

	Runs the physics for one input frame.
=================
*/
void PMove_Run(void)
{
	PMove_WaterMove();

	if (self.waterlevel >= 2) {
		PMove_CheckWaterJump();
	}
	
	if (input_buttons & INPUT_BUTTON2) {
		input_movevalues[2] = 240;
	}	
	if (input_buttons & INPUT_BUTTON8) {
		input_movevalues[2] = -240;
	}

	self.dimension_solid = 255;
	self.dimension_hit = 255;

	/* Call accelerate before and after the actual move, 
	 * with half the move each time. 
	 * This reduces framerate dependance. */
	PMove_Run_Acceleration(input_timelength / 2, TRUE);
	PMove_Run_Move();
	PMove_Run_Acceleration(input_timelength / 2, FALSE);
	
	self.dimension_solid = 254;
	self.dimension_hit = 254;

	/* NOTE: should clip to network precision here if lower than a float */
	self.angles = input_angles;
	self.angles[0] *= -0.333;

	touchtriggers();
}
