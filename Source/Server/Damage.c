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

/*
=================
Damage_CastOrbituary

Sends a message to the clients to display a death message
=================
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

/*
=================
Damage_GetHitLocation

Debug function
=================
*/
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


/*
=================
Damage_Apply

Generic function that applies damage, pain and suffering
=================
*/
void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos ) {
	// Modify the damage based on the location
	if ( trace_surface_id == BODY_HEAD ) {
		if ( eTarget.iEquipment & EQUIPMENT_HELMET ) {
			iDamage *= 0.5;
			eTarget.iEquipment -= EQUIPMENT_HELMET;
		} else {
			iDamage *= 4;
		}
	} else if ( trace_surface_id == BODY_STOMACH ) {
		iDamage *= 0.9;
	} else if ( trace_surface_id == BODY_LEGLEFT ) {
		iDamage *= 0.4;
	} else if ( trace_surface_id == BODY_LEGRIGHT ) {
		iDamage *= 0.4;
	}
	
	dprint( sprintf( "[DEBUG] Hit Bodypart: %s\n", Damage_GetHitLocation( trace_surface_id ) ) );
	
	// Apply the damage finally
	eTarget.health = eTarget.health - iDamage;
	
	// Special monetary punishment for hostage murderers
	if ( eTarget.classname == "hostage_entity" ) {
		if ( eTarget.health > 0 ) {
			Money_AddMoney( eAttacker, -150 ); // Pain
		} else {
			Money_AddMoney( eAttacker, -1500 ); // Death
		}
	}
	
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
		self.vDeath( trace_surface_id );
	} else {
		self.vPain( trace_surface_id );
	}
	
	self = eOld;
}

/*
=================
Damage_Radius

Even more pain and suffering, mostly used for explosives
=================
*/
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
