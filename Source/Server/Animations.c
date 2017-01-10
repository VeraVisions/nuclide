/*
OpenCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

.float baseframe_time;

enum {
	ANIM_DUMMY1,
	ANIM_IDLE,
	ANIM_IDLE_CROUCH,
	ANIM_WALK,
	ANIM_RUN,
	ANIM_RUN_CROUCH,
	ANIM_JUMP,
	ANIM_LONGJUMP,
	ANIM_SWIM,
	ANIM_TREADWATER,
	ANIM_CROUCH_AIM_CARBINE,
	ANIM_CROUCH_SHOOT_CARBINE,
	ANIM_CROUCH_RELOAD_CARBINE,
	ANIM_AIM_CARBINE,
	ANIM_SHOOT_CARBINE,
	ANIM_RELOAD_CARBINE,
	ANIM_CROUCH_AIM_ONEHAND,
	ANIM_CROUCH_SHOOT_ONEHAND,
	ANIM_CROUCH_RELOAD_ONEHAND,
	ANIM_AIM_ONEHAND,
	ANIM_SHOOT_ONEHAND,
	ANIM_RELOAD_ONEHAND,
	ANIM_CROUCH_AIM_DUALPISTOLS,
	ANIM_CROUCH_SHOOT_DUALPISTOLS,
	ANIM_CROUCH_SHOOT2_DUALPISTOLS,
	ANIM_CROUCH_RELOAD_DUALPISTOLS,
	ANIM_AIM_DUALPISTOLS,
	ANIM_SHOOT_DUALPISTOLS,
	ANIM_SHOOT2_DUALPISTOLS,
	ANIM_RELOAD_DUALPISTOLS,
	ANIM_CROUCH_AIM_RIFLE,
	ANIM_CROUCH_SHOOT_RIFLE,
	ANIM_CROUCH_RELOAD_RIFLE,
	ANIM_AIM_RIFLE,
	ANIM_SHOOT_RIFLE,
	ANIM_RELOAD_RIFLE,
	ANIM_CROUCH_AIM_MP5,
	ANIM_CROUCH_SHOOT_MP5,
	ANIM_CROUCH_RELOAD_MP5,
	ANIM_AIM_MP5,
	ANIM_SHOOT_MP5,
	ANIM_RELOAD_MP5,
	ANIM_CROUCH_AIM_SHOTGUN,
	ANIM_CROUCH_SHOOT_SHOTGUN,
	ANIM_CROUCH_RELOAD_SHOTGUN,
	ANIM_AIM_SHOTGUN,
	ANIM_SHOOT_SHOTGUN,
	ANIM_RELOAD_SHOTGUN,
	ANIM_CROUCH_AIM_PARA,
	ANIM_CROUCH_SHOOT_PARA,
	ANIM_CROUCH_RELOAD_PARA,
	ANIM_AIM_PARA,
	ANIM_SHOOT_PARA,
	ANIM_RELOAD_PARA,
	ANIM_DUMMY2,
	ANIM_DUMMY3,
	ANIM_AIM_GRENADE,
	ANIM_SHOOT_GRENADE,
	ANIM_CROUCH_AIM_GRENADE,
	ANIM_CROUCH_SHOOT_GRENADE,
	ANIM_CROUCH_AIM_C4,
	ANIM_CROUCH_SHOOT_C4,
	ANIM_AIM_C4,
	ANIM_SHOOT_C4,
	ANIM_RELOAD_C4,
	ANIM_DUPLICATE1,
	ANIM_DUPLICATE2,
	ANIM_DUPLICATE3,
	ANIM_DUPLICATE4,
	ANIM_DUPLICATE5,
	ANIM_DUPLICATE6,
	ANIM_DUPLICATE7,
	ANIM_DUPLICATE8,
	ANIM_AIM_KNIFE9,
	ANIM_CROUCH_SHOOT_KNIFE,
	ANIM_AIM_KNIFE,
	ANIM_SHOOT_KNIFE,
	ANIM_CROUCH_AIM_AK47,
	ANIM_CROUCH_SHOOT_AK47,
	ANIM_CROUCH_RELOAD_AK47,
	ANIM_AIM_AK47,
	ANIM_SHOOT_AK47,
	ANIM_RELOAD_AK47,
	ANIM_GUT_FLINCH,
	ANIM_HEAD_FLINCH,
	ANIM_DEATH1,
	ANIM_DEATH2,
	ANIM_DEATH3,
	ANIM_DIE_HEAD,
	ANIM_DIE_GUT,
	ANIM_DIE_LEFT,
	ANIM_DIE_BACK,
	ANIM_DIE_RIGHT,
	ANIM_DIE_FORWARD,
	ANIM_CROUCH_DIE
};

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void Animation_PlayerUpdate( void ) {
	self.basebone = 40;
	
	if ( self.baseframe_time < time ) {
		self.baseframe = ANIM_AIM_SHOTGUN;
	}
	
	if ( vlen( self.velocity ) == 0 ) {
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
	}
	
	if ( !( self.flags & FL_ONGROUND ) ) {
		self.frame = ANIM_JUMP;
	}
}

/*
=================
Animation_PlayerTop

Changes the animation sequence for the upper body part
=================
*/
void Animation_PlayerTop( float fFrame, float fTime ) {
	self.baseframe = fFrame;
	self.baseframe_time = time + fTime;
}
