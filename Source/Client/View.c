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
	"models/v_m249.mdl"
};

entity eViewModel;
void View_DrawViewModel( void ) {
	if( !eViewModel ) {
		eViewModel = spawn();
		eViewModel.renderflags = RF_DEPTHHACK;
	}
	
	eViewModel.origin = getproperty( VF_ORIGIN ) + '0 0 -1';
	eViewModel.angles = getproperty( VF_ANGLES );
	
	if( getstatf( STAT_ACTIVEWEAPON ) < CS_WEAPON_COUNT ) {
		setmodel( eViewModel, sViewModels[ getstatf( STAT_ACTIVEWEAPON ) ] );
	}
	
	addentity( eViewModel );
	eViewModel.frame1time += frametime;
}

void View_PlayAnimation( int iSequence ) {
	eViewModel.frame = (float)iSequence;
	eViewModel.frame1time = 0;
}
