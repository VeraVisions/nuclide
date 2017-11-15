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

entity eViewModel;
entity eMuzzleflash;
float fNumBones;

string sViewModels[ CS_WEAPON_COUNT - 1 ] = {
	"models/v_knife.mdl",
	"models/v_usp.mdl",
	"models/v_glock18.mdl",
	"models/v_deagle.mdl",
	"models/v_p228.mdl",
	"models/v_elite.mdl",
	"models/v_fiveseven.mdl",
	"models/v_m3.mdl",
	"models/v_xm1014.mdl",
	"models/v_mp5.mdl",
	"models/v_p90.mdl",
	"models/v_ump45.mdl",
	"models/v_mac10.mdl",
	"models/v_tmp.mdl",
	"models/v_ak47.mdl",
	"models/v_sg552.mdl",
	"models/v_m4a1.mdl",
	"models/v_aug.mdl",
	"models/v_scout.mdl",
	"models/v_awp.mdl",
	"models/v_g3sg1.mdl",
	"models/v_sg550.mdl",
	"models/v_m249.mdl",
	"models/v_c4.mdl",
	"models/v_flashbang.mdl",
	"models/v_hegrenade.mdl",
	"models/v_smokegrenade.mdl"
};

/*
====================
View_CalcBob
====================
*/
float View_CalcBob( void ) {
	static float fBobTime;
	static float fBob;
	float fCycle;

	vector vVelocity;
	
	if ( self.flags & FL_ONGROUND == -1 ) {
		return fBob;	
	}

	fBobTime += frametime;
	fCycle = fBobTime - (int)( fBobTime / autocvar_cl_bobcycle ) * autocvar_cl_bobcycle;
	fCycle /= autocvar_cl_bobcycle;
	
	if ( fCycle < autocvar_cl_bobup ) {
		fCycle = MATH_PI * fCycle / autocvar_cl_bobup;
	} else {
		fCycle = MATH_PI + MATH_PI * ( fCycle - autocvar_cl_bobup )/( 1.0 - autocvar_cl_bobup );
	}

	vVelocity = vPlayerVelocity;
	vVelocity_z = 0;

	fBob = sqrt( vVelocity_x * vVelocity_x + vVelocity_y * vVelocity_y ) * autocvar_cl_bob;
	fBob = fBob * 0.3 + fBob * 0.7 * sin( fCycle );
	fBob = min( fBob, 4 );
	fBob = max( fBob, -7 );
	
	return fBob;
}

void View_DropPunchAngle( void ) {
	float fLerp;
	fLerp = 1.0f - ( frametime * 4 );
	vPunchAngle *= fLerp;
}

void View_AddPunchAngle( vector vAdd ) {
	vPunchAngle += vAdd;
}

/*
====================
View_ProcessEvent
====================
*/
void View_ProcessEvent( float fTimeStamp, int iCode, string sData ) {
	if ( iCode == 5004 ) {
		localsound( sData, CHAN_AUTO, 1.0 );
	} else if ( iCode == 5001 ) {
		eMuzzleflash.alpha = 1.0f;
		eMuzzleflash.scale = 0.5;
		eMuzzleflash.skin = fNumBones;
		setmodel( eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
	} else if( iCode == 5011 ) {
		eMuzzleflash.alpha = 1.0f;
		eMuzzleflash.scale = 0.5;
		eMuzzleflash.skin = fNumBones + 1;
		setmodel( eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
	} else if ( iCode == 5021 ) {
		eMuzzleflash.alpha = 1.0f;
		eMuzzleflash.scale = 0.5;
		eMuzzleflash.skin = fNumBones + 2;
		setmodel( eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
	} else if ( iCode == 5031 ) {
		eMuzzleflash.alpha = 1.0f;
		eMuzzleflash.scale = 0.5;
		eMuzzleflash.skin = fNumBones + 3;
		setmodel( eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
	}
}

/*
====================
View_DrawViewModel
====================
*/
void View_DrawViewModel( void ) {
	static float fBob;
	static float fLastWeapon;

	if( !eViewModel ) {
		eViewModel = spawn();
		eViewModel.renderflags = RF_DEPTHHACK;
		
		eMuzzleflash = spawn();
		eMuzzleflash.renderflags = RF_DEPTHHACK | RF_ADDITIVE;
	}
	
	if ( getstatf( STAT_HEALTH ) <= 0 ) {
		return;
	}
	
	// Don't update when paused
	if ( serverkey("pausestate") == "0" ) {
		fBob = View_CalcBob();
		
		if( getstatf( STAT_ACTIVEWEAPON ) < CS_WEAPON_COUNT ) {
			if ( fLastWeapon != getstatf( STAT_ACTIVEWEAPON ) ) {
				fLastWeapon = getstatf( STAT_ACTIVEWEAPON );
				if ( fLastWeapon ) {
					setmodel( eViewModel, sViewModels[ getstatf( STAT_ACTIVEWEAPON ) - 1 ] );
					skel_delete( eMuzzleflash.skeletonindex );
					eMuzzleflash.skeletonindex = skel_create( eViewModel.modelindex );
					fNumBones = skel_get_numbones( eMuzzleflash.skeletonindex ) + 1;
				}
			}
		}
		
		// Take away alpha once it has drawn fully at least once
		if ( eMuzzleflash.alpha > 0.0f ) {
			eMuzzleflash.alpha -= ( frametime * 45 );			
		}
		
		static float fBaseTime;
		processmodelevents( eViewModel.modelindex, eViewModel.frame, fBaseTime, eViewModel.frame1time, View_ProcessEvent );
		
		eViewModel.frame1time += frametime;
		eViewModel.frame2time += frametime;
	}
	
	makevectors( getproperty( VF_ANGLES ) );
	eViewModel.origin = getproperty( VF_ORIGIN ) + '0 0 -1' + ( v_forward * ( fBob * 0.4 ) );
	eViewModel.angles = getproperty( VF_ANGLES );
	
	// Left-handed weapons
	if ( autocvar_v_lefthanded ) {
		v_right *= -1;
		eViewModel.renderflags |= RF_USEAXIS;
		eViewModel.forceshader = SHADER_CULLED;
	} else {
		if ( eViewModel.forceshader ) {
			eViewModel.forceshader = 0;
			eViewModel.renderflags -= RF_USEAXIS;
		}
	}
	
	// Give the gun a tilt effect like in old HL/CS versions
	if ( autocvar_cl_bobclassic == 1 ) {
		eViewModel.angles_z = -fBob;
	}

	// Only bother when zoomed out
	if ( getstatf( STAT_VIEWZOOM ) == 255 ) {
		// Update muzzleflash position and draw it
		if ( eMuzzleflash.alpha > 0.0f ) {
			eMuzzleflash.origin = gettaginfo( eViewModel, eMuzzleflash.skin );
			dynamiclight_add( eMuzzleflash.origin, 400 * eMuzzleflash.alpha, '1 0.45 0');
			addentity( eMuzzleflash );
		}
		
		addentity( eViewModel );
	}
}

/*
====================
View_DrawViewModel
====================
*/
void View_PlayAnimation( int iSequence ) {
	eViewModel.frame = (float)iSequence;
	eViewModel.frame1time = 0.0f;
}
