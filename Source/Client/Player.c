/*
FreeCS Project
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

string sPModels[ CS_WEAPON_COUNT - 1 ] = {
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

void Player_Draw( void ) {
	if ( !self.eGunModel ) {
		self.eGunModel = spawn();
		self.eGunModel.drawmask = MASK_ENGINE;
			
		// Get the weapon bone ID for the current player model
		self.fWeaponBoneID = gettagindex( self, "Bip01 R Hand" );
	}
	    
	// Only bother updating the model if the weapon has changed
	if ( self.fWeaponLast != self.weapon ) {
		setmodel( self.eGunModel, sPModels[ self.weapon - 1 ] );
		self.fWeaponLast = self.weapon;
	    	
		// Update the bone index of the current p_ model so we can calculate the offset
		self.eGunModel.fWeaponBoneID = gettagindex( self.eGunModel, "Bip01 R Hand" );
	}
	    
	Animation_PlayerUpdate();
	self.baseframe1time += frametime;
	self.frame1time += frametime;
		
	self.baseframe2time += frametime;
	self.frame2time += frametime;	
}
/*
=================
Player_PreDraw

Run every before every frame is rendered.
Responsible for local player prediction and other player appearance/interpolation.
=================
*/
float Player_PreDraw( void ) {
    if ( self.entnum == player_localentnum ) {
	    vector vOldOrigin;
	    vector vOldVelocity;
	    float fOldPMoveFlags;
		// Don't predict if we're frozen/paused FIXME: FTE doesn't have serverkey_float yet!
		if ( serverkey( SERVERKEY_PAUSESTATE ) == "1" || ( ( getstati( STAT_GAMESTATE ) == GAME_FREEZE ) && ( getstati( STAT_HEALTH ) > 0 ) ) ) {
			vPlayerOrigin = self.origin;
			vOldOrigin = vPlayerOrigin;
			
			self.velocity = '0 0 0';
			vOldVelocity = self.velocity;
			fOldPMoveFlags = 0;
		} else {
			vOldOrigin = self.origin;
			vOldVelocity = self.velocity;
			fOldPMoveFlags = self.pmove_flags;
	
			if ( getplayerkeyvalue( player_localnum, "*spec" ) == "0" ) {
				self.movetype = MOVETYPE_WALK;
			} else {
				self.movetype = MOVETYPE_NOCLIP;
			}
			
			for ( int i = servercommandframe + 1; i <= clientcommandframe; i++ ) {
				getinputstate( i );
				runstandardplayerphysics( self );
			}
		}
		vPlayerOriginOld = vPlayerOrigin;
				
		if ( ( self.flags & FL_ONGROUND ) && ( self.origin_z - vPlayerOriginOld_z > 0 ) ) {
			vPlayerOriginOld_z += frametime * 150;
					
			if ( vPlayerOriginOld_z > self.origin_z ) {
				vPlayerOriginOld_z = self.origin_z;
			}
			if ( self.origin_z - vPlayerOriginOld_z > 18 ) {
				vPlayerOriginOld_z = self.origin_z - 18;
			}
			vPlayerOrigin_z += vPlayerOriginOld_z - self.origin_z;
		} else {
			vPlayerOriginOld_z = self.origin_z;
		}
			
		vPlayerVelocity = self.velocity;
		
		if ( autocvar_cl_thirdperson == TRUE && getstatf( STAT_HEALTH ) > 0 ) {
			static vector vStart;
			static vector vEnd;
			
			makevectors( view_angles );
			vStart = [ self.origin_x, self.origin_y, vPlayerOriginOld_z + 8 ] + ( v_right * 4 );
			vEnd = vStart + ( v_forward * -48 ) + '0 0 8' + ( v_right * 4 );
			traceline( vStart, vEnd, FALSE, self );
			vPlayerOrigin = trace_endpos + ( v_forward * 5 );
			self.renderflags = 0;
			Player_Draw();	
		} else {
			if ( self.eGunModel ) {
				remove( self.eGunModel );
			}
			self.renderflags = RF_EXTERNALMODEL;
			vPlayerOrigin = [ self.origin_x, self.origin_y, vPlayerOriginOld_z ];
		}
		addentity( self );

		self.origin = vOldOrigin;
		setorigin( self, self.origin );
		self.velocity = vOldVelocity;
		self.pmove_flags = fOldPMoveFlags;
		self.movetype = MOVETYPE_NONE;
    } else {
		Player_Draw();
        addentity( self );
    }
    return PREDRAW_NEXT;
}
