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

string Damage_GetHitLocation( int iSurface ) {
	switch ( iSurface ) {
		case BODY_HEAD:
			return "Head";
			break;
		case BODY_CHEST:
			return "Chest";
			break;
		case BODY_STOMACH:
			return "Stomach";
			break;
		case BODY_ARMLEFT:
			return "Left Arm";
			break;
		case BODY_ARMRIGHT:
			return "Right Arm";
			break;
		case BODY_LEGLEFT:
			return "Left leg";
			break;
		case BODY_LEGRIGHT:
			return "Right Leg";
			break;
		default:
			return "Generic";
	}
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
	
	if ( trace_surface_id == BODY_HEAD ) {
		iDamage *= 4;
	} else if ( trace_surface_id == BODY_STOMACH ) {
		iDamage *= 0.9;
	} else if ( trace_surface_id == BODY_LEGLEFT ) {
		iDamage *= 0.4;
	} else if ( trace_surface_id == BODY_LEGRIGHT ) {
		iDamage *= 0.4;
	}
	
	bprint( sprintf( "[DEBUG] Hit Bodypart: %s\n", Damage_GetHitLocation( trace_surface_id ) ) );
	
	// Target is dead and a client....
	if ( eTarget.health <= 0 ) {
		if ( eTarget.flags & FL_CLIENT ) {
			eTarget.fDeaths++;
			forceinfokey( eTarget, "*deaths", ftos( eTarget.fDeaths ) );
		}
		
		if ( ( eTarget.flags & FL_CLIENT )  && ( eAttacker.flags & FL_CLIENT ) ) {
			eAttacker.frags++;
			Money_AddMoney( eAttacker, 300 );
			Damage_CastOrbituary( eAttacker, eTarget, eAttacker.weapon, FALSE );
		}
	}
	
	entity eOld = self;
	self = eTarget;
	
	if ( self.health <= 0 ) {
		self.health = 0;
		self.vDeath();
		
		// Make a cooky death sound
		if ( self.classname == "player" ) {
			
			if ( trace_surface_id == BODY_HEAD ) {
				sound( self, CHAN_VOICE, sprintf( "player/headshot%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
			} else {
				sound( self, CHAN_VOICE, sprintf( "player/die%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
			}
		}
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
	
				if ( fDiff > 0 ) {
					Damage_Apply( eDChain, eAttacker, fDamage, eDChain.origin );
				}
		}
		
		eDChain = eDChain.chain;
	}
}
