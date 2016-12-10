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

void Damage_CastOrbituary( entity eAttacker, entity eTarget, float fWeapon, float fHeadShot ) {
	WriteByte( MSG_BROADCAST, SVC_CGAMEPACKET );
	WriteByte( MSG_BROADCAST, EV_ORBITUARY );
	WriteByte( MSG_BROADCAST, num_for_edict( eAttacker ) - 1 );
	WriteByte( MSG_BROADCAST, eAttacker.team );
	WriteByte( MSG_BROADCAST, num_for_edict( eTarget ) - 1 );
	WriteByte( MSG_BROADCAST, eTarget.team );
	WriteByte( MSG_BROADCAST, fWeapon );
	WriteByte( MSG_BROADCAST, fHeadShot );
	msg_entity = self;
	multicast( '0 0 0', MULTICAST_ALL );
}

void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos ) {
	
	eTarget.health = eTarget.health - iDamage; // TODO: Body part multipliers
	
	// Special monetary punishment for hostage murderers
	if ( eTarget.classname == "hostage_entity" ) {
		if ( eTarget.health > 0 ) {
			Money_AddMoney( eAttacker, -150 ); // Pain
		} else {
			Money_AddMoney( eAttacker, -1500 ); // Death
		}
	}
	
	// Don't be like Q1 and make everything bleed.
	if ( eTarget.iBleeds == TRUE ) {
		makevectors( eAttacker.angles );
		pointparticles( EFFECT_BLOOD, vHitPos, v_forward * -1, 1 );
	}
	
	// Target is dead and a client....
	if ( eTarget.health <= 0 ) {
		if ( ( eTarget.flags & FL_CLIENT )  && ( eAttacker.flags & FL_CLIENT ) ) {
			Damage_CastOrbituary( eAttacker, eTarget, eAttacker.weapon, FALSE );
			eAttacker.frags++;
			eTarget.fDeaths++;
			
			forceinfokey( eTarget, "*deaths", ftos( eTarget.fDeaths ) );
			
			Money_AddMoney( eAttacker, 300 );
		}
	}
	
	entity eOld = self;
	self = eTarget;
	
	if ( self.health <= 0 ) {
		self.health = 0;
		self.vDeath();
	} else {
		self.vPain();
	}
	
	self = eOld;
}

void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius ) {
	entity eDChain = findradius( vOrigin, fRadius );
	
	while( eDChain ) {
		
		if ( eDChain.takedamage == DAMAGE_YES ) {
				float fDiff = vlen( vOrigin - eDChain.origin );
				
				fDiff = ( fRadius - fDiff ) / fRadius;
				
				fDamage = fDamage * fDiff;
				
				bprint( sprintf("[DEBUG] EXPLOSION! Hit Radius: %d, Damage Multiplier: %f\n", vlen( vOrigin - eDChain.origin ), fDiff ) );

				if ( fDiff > 0 ) {
					Damage_Apply( eDChain, eAttacker, fDamage, eDChain.origin );
				}
		}
		
		eDChain = eDChain.chain;
	}
}
