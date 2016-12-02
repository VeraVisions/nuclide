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

void Damage_Apply( entity eTarget, entity eAttacker, float fWeapon, vector vHitPos ) {
	
	eTarget.health = eTarget.health - wptTable[ self.weapon ].iDamage; // TODO: Body part multipliers
	
	if ( eTarget.iBleeds == TRUE ) {
		makevectors( eAttacker.angles );
		pointparticles( EFFECT_BLOOD, vHitPos, v_forward * -1, 1 );
	}
	
	entity eOld = self;
	self = eTarget;
	
	if ( eTarget.health <= 0 ) {
		eTarget.health = 0;
		eTarget.vDeath();
	} else {
		eTarget.vPain();
	}
	
	self = eOld;
}
