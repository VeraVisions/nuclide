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
	self.basebone = 40;
	/*
	// TODO: Make this faster
	if ( self.baseframe_time < time ) {
		switch ( Weapon_GetAnimType( self.weapon ) ) {
			case ATYPE_AK47:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_AK47 : ANIM_AIM_AK47;
				break;
			case ATYPE_C4:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_C4 : ANIM_AIM_C4;
				break;
			case ATYPE_CARBINE:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_CARBINE : ANIM_AIM_CARBINE;
				break;
			case ATYPE_DUALPISTOLS:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_DUALPISTOLS : ANIM_AIM_DUALPISTOLS;
				break;
			case ATYPE_GRENADE:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_GRENADE : ANIM_AIM_GRENADE;
				break;
			case ATYPE_KNIFE:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_KNIFE : ANIM_AIM_KNIFE;
				break;
			case ATYPE_MP5:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_MP5 : ANIM_AIM_MP5;
				break;
			case ATYPE_ONEHAND:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_ONEHAND : ANIM_AIM_ONEHAND;
				break;
			case ATYPE_PARA:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_PARA : ANIM_AIM_PARA;
				break;
			case ATYPE_RIFLE:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_RIFLE : ANIM_AIM_RIFLE;
				break;
			case ATYPE_SHOTGUN:
				self.baseframe = self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_SHOTGUN : ANIM_AIM_SHOTGUN;
				break;
		}
		self.baseframe_old = self.baseframe;
	}
	
	if ( !( self.flags & FL_ONGROUND ) ) {
		self.frame = ANIM_JUMP;
	} else if ( vlen( self.velocity ) == 0 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.frame = ANIM_IDLE_CROUCH;
		} else {
			self.frame = ANIM_IDLE;
		}
	} else if ( vlen( self.velocity ) < 150 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.frame = ANIM_RUN_CROUCH;
		} else {
			self.frame = ANIM_WALK;
		}
	} else if ( vlen( self.velocity ) > 150 ) {
		if ( self.flags & FL_CROUCHING ) {
			self.frame = ANIM_RUN_CROUCH;
		} else {
			self.frame = ANIM_RUN;
		}
	}*/

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
	
	self.bonecontrol1 = self.angles_x;
#endif
	self.angles_x = self.angles_z = 0;
	
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
	self.subblend2frac = self.v_angle_x / 90;
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
