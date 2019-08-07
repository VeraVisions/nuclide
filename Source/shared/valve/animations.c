/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

.float baseframe_time;
.float baseframe_old;
.float fWasCrouching;

enum {
	ANIM_LOOKIDLE,
	ANIM_IDLE,
	ANIM_DEEPIDLE,
	ANIM_RUN2,
	ANIM_WALK2HANDED,
	ANIM_2HANDSHOT,
	ANIM_CRAWL,
	ANIM_CROUCHIDLE,
	ANIM_JUMP,
	ANIM_LONGJUMP,
	ANIM_SWIM,
	ANIM_TREADWATER,
	ANIM_RUN,
	ANIM_WALK,
	ANIM_AIM2,
	ANIM_SHOOT2,
	ANIM_AIM1,
	ANIM_SHOOT1,
	ANIM_DIESIMPLE,
	ANIM_DIEBACKWARDS1,
	ANIM_DIEBACKWARDS2,
	ANIM_DIEFORWARD,
	ANIM_DIEHEADSHOT,
	ANIM_DIESPIN,
	ANIM_DIEGUTSHOT,
	ANIM_AIMCROWBAR,
	ANIM_SHOOTCROWBAR,
	ANIM_CR_AIMCROWBAR,
	ANIM_CR_SHOOTCROWBAR,
	ANIM_AIMTRIPMINE,
	ANIM_SHOOTTRIPMINE,
	ANIM_CR_AIMTRIPMINE,
	ANIM_CR_SHOOTTRIPMINE,
	ANIM_AIM1HAND,
	ANIM_SHOOT1HAND,
	ANIM_CR_AIM1HAND,
	ANIM_CR_SHOOT1HAND,
	ANIM_AIMPYTHON,
	ANIM_SHOOTPYTHON,
	ANIM_CR_AIMPYTHON,
	ANIM_CR_SHOOTPYTHON,
	ANIM_AIMSHOTGUN,
	ANIM_SHOOTSHOTGUN,
	ANIM_CR_AIMSHOTGUN,
	ANIM_CR_SHOOTSHOTGUN,
	ANIM_AIMGAUSS,
	ANIM_SHOOTGAUSS,
	ANIM_CR_AIMGAUSS,
	ANIM_CR_SHOOTGAUSS,
	ANIM_AIMMP5,
	ANIM_SHOOTMP5,
	ANIM_CR_AIMMP5,
	ANIM_CR_SHOOTMP5,
	ANIM_AIMRPG,
	ANIM_SHOOTRPG,
	ANIM_CR_AIMRPG,
	ANIM_CR_SHOOTRPG,
	ANIM_AIMEGON,
	ANIM_SHOOTEGON,
	ANIM_CR_AIMEGON,
	ANIM_CR_SHOOTEGON,
	ANIM_AIMSQUEAK,
	ANIM_SHOOTSQUEAK,
	ANIM_CR_AIMSQUEAK,
	ANIM_CR_SHOOTSQUEAK,
	ANIM_AIMHIVE,
	ANIM_SHOOTHIVE,
	ANIM_CR_AIMHIVE,
	ANIM_CR_SHOOTHIVE,
	ANIM_AIMBOW,
	ANIM_SHOOTBOW,
	ANIM_CR_AIMBOW,
	ANIM_CR_SHOOTBOW
};

// For lerping, sigh
#ifdef CSQC
.float frame_last;
.float baseframe_last;
#else
.float subblend2frac;
#endif

void Animation_Print( string sWow ) {
#ifdef CSQC
	print( sprintf( "[DEBUG] %s", sWow ) );
#else 
	bprint(PRINT_HIGH, sprintf( "SSQC: %s", sWow )  );
#endif	
}

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void Animation_PlayerUpdate( void ) {
	self.basebone = 16;
#ifdef SSQC
	// TODO: Make this faster
	if ( self.baseframe_time < time ) {
		player pl = (player)self;
		int i = pl.activeweapon;
		switch ( i ) {
			case WEAPON_CROWBAR:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
			break;
			case WEAPON_GLOCK:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
			break;
			case WEAPON_PYTHON:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
			break;
			case WEAPON_MP5:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMMP5 : ANIM_AIMMP5;
			break;
			case WEAPON_SHOTGUN:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
			break;
			case WEAPON_CROSSBOW:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMBOW : ANIM_AIMBOW;
			break;
			case WEAPON_RPG:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMRPG : ANIM_AIMRPG;
			break;
			case WEAPON_GAUSS:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMGAUSS : ANIM_AIMGAUSS;
			break;
			case WEAPON_EGON:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
			break;
			case WEAPON_HORNETGUN:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
			break;
			case WEAPON_HANDGRENADE:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
			break;
			case WEAPON_SATCHEL:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
			break;
			case WEAPON_TRIPMINE:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMTRIPMINE : ANIM_AIMTRIPMINE;
			break;
			case WEAPON_SNARK:
				self.frame = self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
			break;
		}
		self.baseframe_old = self.frame;
	}
	
	if ( !( self.flags & FL_ONGROUND ) ) {
		self.baseframe = ANIM_JUMP;
	} else if ( vlen( self.velocity ) == 0 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.baseframe = ANIM_CROUCHIDLE;
		} else {
			self.baseframe = ANIM_IDLE;
		}
	} else if ( vlen( self.velocity ) < 150 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.baseframe = ANIM_CRAWL;
		} else {
			self.baseframe = ANIM_WALK;
		}
	} else if ( vlen( self.velocity ) > 150 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.baseframe = ANIM_CRAWL;
		} else {
			self.baseframe = ANIM_RUN;
		}
	}
#endif

#ifdef CSQC
	// Lerp it down!
	if ( self.lerpfrac > 0 ) {
		self.lerpfrac -= frametime * 5;
		if ( self.lerpfrac < 0 ) {
			self.lerpfrac = 0;
		}
	}

	if ( self.baselerpfrac > 0 ) {
		self.baselerpfrac -= frametime * 5;
		if ( self.baselerpfrac < 0 ) {
			self.baselerpfrac = 0;
		}
	}

	if ( self.frame != self.frame_last ) {
		//Animation_Print( sprintf( "New Frame: %d, Last Frame: %d\n", self.frame, self.frame_last ));
		
		// Move everything over to frame 2
		self.frame2time = self.frame1time;
		self.frame2 = self.frame_last;
		
		// Set frame_last to avoid this being called again
		self.frame_last = self.frame;
		
		self.lerpfrac = 1.0f;
		self.frame1time = 0.0f;
	}
	
	if ( self.baseframe != self.baseframe_last ) {
		//Animation_Print( sprintf( "New Baseframe: %d, Last Baseframe: %d\n", self.baseframe, self.baseframe_last ) );
		
		// Move everything over to frame 2
		self.baseframe2time = self.baseframe1time;
		self.baseframe2 = self.baseframe_last;
		
		// Set frame_last to avoid this being called again
		self.baseframe_last = self.baseframe;
		
		self.baselerpfrac = 1.0f;
		self.baseframe1time = 0.0f;
	}
	
	self.bonecontrol1 = self.angles[0];
#endif
	self.angles[0] = self.angles[2] = 0;
	
	if ( !( self.flags & FL_ONGROUND ) ) {
		/*self.frame = ANIM_JUMP;*/
	}
	
	// Force the code above to update if we switched positions
	if ( self.fWasCrouching != ( self.flags & FL_CROUCHING ) ) {
		self.baseframe_old = 0;
		self.baseframe_time = 0;
		self.fWasCrouching = ( self.flags & FL_CROUCHING );
	}

#ifdef SSQC
	// On the CSQC it's done in Player.c
	self.subblend2frac = self.v_angle[0] / 90;
#endif
}

/*
=================
Animation_PlayerTop

Changes the animation sequence for the upper body part
=================
*/
void Animation_PlayerTop( float fFrame ) {
	self.baseframe = fFrame;
	self.baseframe_old = fFrame;
}

void Animation_PlayerTopTemp( float fFrame, float fTime ) {
	self.baseframe = fFrame;
	self.baseframe_time = time + fTime;
}

void Animation_ShootWeapon( entity ePlayer ) {
	/*switch ( Weapon_GetAnimType( ePlayer.weapon )  ) {
		case ATYPE_AK47:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_AK47 : ANIM_SHOOT_AK47;
			break;
		case ATYPE_C4:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_C4 : ANIM_SHOOT_C4;
			break;
		case ATYPE_CARBINE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_CARBINE : ANIM_SHOOT_CARBINE;
			break;
		case ATYPE_DUALPISTOLS:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_DUALPISTOLS : ANIM_SHOOT_DUALPISTOLS;
			break;
		case ATYPE_GRENADE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_GRENADE : ANIM_SHOOT_GRENADE;
			break;
		case ATYPE_KNIFE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_KNIFE : ANIM_SHOOT_KNIFE;
			break;
		case ATYPE_MP5:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_MP5 : ANIM_SHOOT_MP5;
			break;
		case ATYPE_ONEHAND:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_ONEHAND : ANIM_SHOOT_ONEHAND;
			break;
		case ATYPE_PARA:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_PARA : ANIM_SHOOT_PARA;
			break;
		case ATYPE_RIFLE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_RIFLE : ANIM_SHOOT_RIFLE;
			break;
		case ATYPE_SHOTGUN:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_SHOOT_SHOTGUN : ANIM_SHOOT_SHOTGUN;
			break;
	}
	
	ePlayer.baseframe_time = time + Weapon_GetFireRate( ePlayer.weapon );*/
}

void Animation_ReloadWeapon( entity ePlayer ) {
	/*switch ( Weapon_GetAnimType( ePlayer.weapon )  ) {
		case ATYPE_AK47:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_AK47 : ANIM_RELOAD_AK47;
			break;
		case ATYPE_C4:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_C4 : ANIM_AIM_C4;
			break;
		case ATYPE_CARBINE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_CARBINE : ANIM_RELOAD_CARBINE;
			break;
		case ATYPE_DUALPISTOLS:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_DUALPISTOLS : ANIM_RELOAD_DUALPISTOLS;
			break;
		case ATYPE_GRENADE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_GRENADE : ANIM_AIM_GRENADE;
			break;
		case ATYPE_KNIFE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_KNIFE : ANIM_AIM_KNIFE;
			break;
		case ATYPE_MP5:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_MP5 : ANIM_RELOAD_MP5;
			break;
		case ATYPE_ONEHAND:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_ONEHAND : ANIM_RELOAD_ONEHAND;
			break;
		case ATYPE_PARA:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_PARA : ANIM_RELOAD_PARA;
			break;
		case ATYPE_RIFLE:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_RIFLE : ANIM_RELOAD_RIFLE;
			break;
		case ATYPE_SHOTGUN:
			ePlayer.baseframe = ePlayer.flags & FL_CROUCHING ? ANIM_CROUCH_RELOAD_SHOTGUN : ANIM_RELOAD_SHOTGUN;
			break;
	}
	
	ePlayer.baseframe_time = time + Weapon_GetReloadTime( ePlayer.weapon );*/
}
