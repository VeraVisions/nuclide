/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

string sViewModels[ CS_WEAPON_COUNT ] = {
	"",
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
	"models/v_c4.mdl"
};

/*
====================
View_CalcBob
====================
*/
vector pmove_vel;
float V_CalcBob( void ) {
	static float fBobTime;
	static float fBob;
	float fCycle;

	vector vVelocity;
	
	if ( self.flags & FL_ONGROUND == -1 ) {
		return fBob;	
	}

	fBobTime += frametime;
	fCycle = fBobTime - (int)( fBobTime / cvar( "cl_bobcycle" ) ) * cvar( "cl_bobcycle" );
	fCycle /= cvar( "cl_bobcycle" );
	
	if ( fCycle < cvar( "cl_bobup" ) ) {
		fCycle = MATH_PI * fCycle / cvar( "cl_bobup" );
	} else {
		fCycle = MATH_PI + MATH_PI * ( fCycle - cvar( "cl_bobup" ) )/( 1.0 - cvar( "cl_bobup" ) );
	}

	vVelocity = pmove_vel; //ePlayerEnt.velocity;
	vVelocity_z = 0;

	fBob = sqrt( vVelocity_x * vVelocity_x + vVelocity_y * vVelocity_y ) * cvar( "cl_bob" );
	fBob = fBob * 0.3 + fBob * 0.7 * sin(fCycle);
	fBob = Math_Min( fBob, 4 );
	fBob = Math_Max( fBob, -7 );
	
	return fBob * 0.5;
}

entity eViewModel;
void View_DrawViewModel( void ) {
	static float fLastTime;
	
	if( !eViewModel ) {
		eViewModel = spawn();
		eViewModel.renderflags = RF_DEPTHHACK;
	}
	
	if ( time != fLastTime ) {
		makevectors( getproperty( VF_ANGLES ) );
		eViewModel.origin = getproperty( VF_ORIGIN ) + '0 0 -1' + ( v_forward * V_CalcBob() );
		eViewModel.angles = getproperty( VF_ANGLES );
		
		if( getstatf( STAT_ACTIVEWEAPON ) < CS_WEAPON_COUNT ) {
			setmodel( eViewModel, sViewModels[ getstatf( STAT_ACTIVEWEAPON ) ] );
		}
	
		eViewModel.frame1time += frametime;
	}
	
	fLastTime = time;
	addentity( eViewModel );
}

void View_PlayAnimation( int iSequence ) {
	eViewModel.frame = (float)iSequence;
	eViewModel.frame1time = 0;
}
