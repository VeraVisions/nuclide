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

var string autocvar_skins_dir = "";

string sViewModels[ CS_WEAPON_COUNT - 1 ] = {
	"v_knife.mdl",
	"v_usp.mdl",
	"v_glock18.mdl",
	"v_deagle.mdl",
	"v_p228.mdl",
	"v_elite.mdl",
	"v_fiveseven.mdl",
	"v_m3.mdl",
	"v_xm1014.mdl",
	"v_mp5.mdl",
	"v_p90.mdl",
	"v_ump45.mdl",
	"v_mac10.mdl",
	"v_tmp.mdl",
	"v_ak47.mdl",
	"v_sg552.mdl",
	"v_m4a1.mdl",
	"v_aug.mdl",
	"v_scout.mdl",
	"v_awp.mdl",
	"v_g3sg1.mdl",
	"v_sg550.mdl",
	"v_m249.mdl",
	"v_c4.mdl",
	"v_flashbang.mdl",
	"v_hegrenade.mdl",
	"v_smokegrenade.mdl"
};

void View_Init(void)
{
	
}

/*
====================
View_CalcBob
====================
*/
void View_CalcBob( void ) {
	float fCycle;

	vector vVelocity;
	
	if ( self.flags & FL_ONGROUND == -1 ) {
		return;	
	}

	pSeat->fBobTime += clframetime;
	fCycle = pSeat->fBobTime - (int)( pSeat->fBobTime / autocvar_v_bobcycle ) * autocvar_v_bobcycle;
	fCycle /= autocvar_v_bobcycle;
	
	if ( fCycle < autocvar_v_bobup ) {
		fCycle = MATH_PI * fCycle / autocvar_v_bobup;
	} else {
		fCycle = MATH_PI + MATH_PI * ( fCycle - autocvar_v_bobup )/( 1.0 - autocvar_v_bobup );
	}

	vVelocity = pSeat->vPlayerVelocity;
	vVelocity_z = 0;

	float fBob = sqrt( vVelocity_x * vVelocity_x + vVelocity_y * vVelocity_y ) * autocvar_v_bob;
	fBob = fBob * 0.3 + fBob * 0.7 * sin( fCycle );
	pSeat->fBob = bound( -7, fBob, 4 );
}

/*
====================
View_DropPunchAngle

Quickly lerp to the original viewposition
====================
*/
void View_DropPunchAngle( void ) {
	float fLerp;
	fLerp = 1.0f - ( clframetime * 4 );
	pSeat->vPunchAngle *= fLerp;
}

/*
====================
View_AddPunchAngle

Gives the angle a bit of an offset/punch/kick
====================
*/
void View_AddPunchAngle( vector vAdd ) {
	pSeat->vPunchAngle += vAdd;
}

/*
====================
View_ShellEject

Spawns a shell tempentity. Looking fancy
====================
*/
void View_ShellEject( void ) {
	static void View_ShellEject_Death( void ) {
		remove( self );
	}
	vector vOrigin = pSeat->vPlayerOrigin;
	vector vEndPos = gettaginfo( pSeat->eViewModel, pSeat->fEjectBone );
	makevectors( view_angles );
	
	vOrigin += ( v_forward * vEndPos_x ) + ( v_right * -vEndPos_y ) + ( v_up * vEndPos_z ) + [ 0, 0, getstatf( STAT_VIEWHEIGHT ) ];
	
	entity eShell = spawn();
	setorigin( eShell, vOrigin );
	setmodel( eShell, sShellModel[ wptTable[ getstati( STAT_ACTIVEWEAPON ) ].iShellType ] );
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [ 0, view_angles_y, 0 ];
	eShell.velocity = pSeat->vPlayerVelocity + ( v_up * random( 70, 120 ) ) + ( v_right * -random( 50, 70 ) );
	eShell.think = View_ShellEject_Death;
	eShell.nextthink = time + 2.5f; 
}

/*
====================
View_ProcessEvent

Called by the engine whenever a model
tries to play an event.
====================
*/
void View_ProcessEvent( float fTimeStamp, int iCode, string sData ) {
	if ( iCode == 5004 ) {
		localsound( sData, CHAN_AUTO, 1.0 );
	} else if ( iCode == 5001 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		View_ShellEject();
	} else if( iCode == 5011 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 1;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		View_ShellEject();
	} else if ( iCode == 5021 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 2;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		View_ShellEject();
	} else if ( iCode == 5031 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 3;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		View_ShellEject();
	}
}

/*
====================
View_DrawViewModel

Really convoluted function that makes the gun,
muzzleflash, dynamic lights and so on appear
====================
*/
void View_DrawViewModel( void ) {
	if( !pSeat->eViewModel ) {
		pSeat->eViewModel = spawn();
		pSeat->eViewModel.classname = "view model";
		pSeat->eViewModel.renderflags = RF_VIEWMODEL | RF_DEPTHHACK;
		
		pSeat->eMuzzleflash = spawn();
		pSeat->eMuzzleflash.classname = "view muzzleflash";
		pSeat->eMuzzleflash.renderflags = RF_VIEWMODEL | RF_DEPTHHACK | RF_ADDITIVE;
	}
	entity eViewModel = pSeat->eViewModel;
	entity eMuzzleflash = pSeat->eMuzzleflash;

	if ( getstatf( STAT_HEALTH ) <= 0 ) {
		return;
	}

	// Don't update when paused
	if ( serverkey( "pausestate" ) == "0" ) {
		View_CalcBob();

		int aw = getstati( STAT_ACTIVEWEAPON );
		if( aw < CS_WEAPON_COUNT ) {
			if ( pSeat->fLastWeapon != aw ) {
				pSeat->fLastWeapon = aw;
				if ( aw >= 1 ) {
					string wm;
					if (autocvar_skins_dir != "") {
						wm = sprintf("skins/%s/%s", autocvar_skins_dir, sViewModels[ aw - 1 ]);
					} else {
						wm = sprintf("models/%s", sViewModels[ aw - 1 ]);
					}
					setmodel( eViewModel, wm );
					skel_delete( eMuzzleflash.skeletonindex );
					eMuzzleflash.skeletonindex = skel_create( eViewModel.modelindex );
					pSeat->fNumBones = skel_get_numbones( eMuzzleflash.skeletonindex ) + 1;
					pSeat->fEjectBone = pSeat->fNumBones + 1;
				}
			}
		}

		// Take away alpha once it has drawn fully at least once
		if ( eMuzzleflash.alpha > 0.0f ) {
			eMuzzleflash.alpha -= ( clframetime * 45 );			
		}

		float fBaseTime = eViewModel.frame1time;
		eViewModel.frame1time += clframetime;
		eViewModel.frame2time += clframetime;
		processmodelevents( eViewModel.modelindex, eViewModel.frame, fBaseTime, eViewModel.frame1time, View_ProcessEvent );
	}
	
	makevectors( '0 0 0');
	eViewModel.origin = '0 0 -1' + ( v_forward * ( pSeat->fBob * 0.4 ) )
			+ ( v_forward * autocvar_v_gunofs[0] )
			+ ( v_right * autocvar_v_gunofs[1] )
			+ ( v_up * autocvar_v_gunofs[2] );
	
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
	if ( autocvar_v_bobclassic == 1 ) {
		eViewModel.angles_z = -pSeat->fBob;
	}

	// Only bother when zoomed out
	if ( getstatf( STAT_VIEWZOOM ) == 1.0f ) {
		// Update muzzleflash position and draw it
		if ( eMuzzleflash.alpha > 0.0f ) {
			eMuzzleflash.origin = gettaginfo( eViewModel, eMuzzleflash.skin );
			dynamiclight_add( pSeat->vPlayerOrigin, 400 * eMuzzleflash.alpha, '1 0.45 0');
			addentity( eMuzzleflash );
		}
		addentity( eViewModel );
	}
}

/*
====================
View_PlayAnimation

Resets the timeline and plays a new sequence
onto the view model
====================
*/
void View_PlayAnimation( int iSequence ) {
	pSeat->eViewModel.frame = (float)iSequence;
	pSeat->eViewModel.frame1time = 0.0f;
}
