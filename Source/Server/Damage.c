/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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

int Damage_ShouldDamage( float fTargetTeam, float fAttackerTeam ) {
	if ( fTargetTeam == TEAM_VIP ) {
		fTargetTeam = TEAM_CT;
	} else if ( fAttackerTeam == TEAM_VIP ) {
		fAttackerTeam = TEAM_CT;
	}
	
	if ( fTargetTeam == fAttackerTeam ) {
		return FALSE;
	}
	
	return TRUE;
}

/*
=================
Damage_Apply

Generic function that applies damage, pain and suffering
=================
*/
void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos, int iSkipArmor ) {
	// Modify the damage based on the location
	if ( trace_surface_id == BODY_HEAD ) {
		if ( eTarget.iEquipment & EQUIPMENT_HELMET ) {
			sound( self, CHAN_ITEM, "weapons/ric_metal-2.wav", 1, ATTN_IDLE );
			iDamage = 0;
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

	if (eTarget != eAttacker) {
		if ( !Damage_ShouldDamage(eTarget.team, eAttacker.team)) {
			if (!autocvar_mp_friendlyfire) {
				return;
			}
		}
	}

	eTarget.velocity = [0,0,0];

	// Apply the damage finally
	if ( eTarget.armor ) {
		float fRatio = 0.5;
		
		if ( eAttacker.weapon ) { 
			fRatio *= wptTable[ eAttacker.weapon ].fWeaponArmorRatio;
		}
		
		// Simple implementation of how kevlar damage is calculated
		float fNewDmg = iDamage * fRatio;
		float fNewArmor = ( iDamage - fNewDmg ) / 2;
		
		if ( fNewArmor > eTarget.armor ) {
			fNewArmor = eTarget.armor;
			fNewArmor *= (1/0.5);
			fNewDmg = rint( iDamage - fNewArmor );
			eTarget.armor = 0;
			eTarget.iEquipment -= EQUIPMENT_KEVLAR;
		} else {
			if ( fNewArmor < 0 ) {
				fNewArmor = 1;
			}
			eTarget.armor = rint( eTarget.armor - fNewArmor );
		}
		
		if ( iSkipArmor == TRUE ) {
			eTarget.health = rint( eTarget.health -= iDamage );
			eTarget.dmg_take = (float)iDamage;
		} else {
			eTarget.health = rint( eTarget.health -= fNewDmg );
			eTarget.dmg_take = (float)fNewDmg;
		}
	} else {
		// No armor
		eTarget.health -= iDamage;
		eTarget.dmg_take = (float)iDamage;
	}
	eTarget.dmg_inflictor = eAttacker;
	
	// Special monetary punishment for hostage murderers
	if ( eTarget.classname == "hostage_entity" ) {
		if ( eTarget.health > 0 ) {
			Money_AddMoney( eAttacker, autocvar_fcs_penalty_pain ); // Pain
		} else {
			Money_AddMoney( eAttacker, autocvar_fcs_penalty_kill ); // Death
		}
	}

	// Target is dead and a client....
	if ( eTarget.health <= 0 ) {
		if ( eTarget.flags & FL_CLIENT ) {
			eTarget.fDeaths++;
			forceinfokey( eTarget, "*deaths", ftos( eTarget.fDeaths ) );
		}
		
		if ( ( eTarget.flags & FL_CLIENT )  && ( eAttacker.flags & FL_CLIENT ) ) {
			// Don't encourage them to kill their own team members for $$$
			if ( Damage_ShouldDamage( eTarget.team, eAttacker.team ) == TRUE ) {
				eAttacker.frags++;
				Money_AddMoney( eAttacker, autocvar_fcs_reward_kill );
			} else {
				eAttacker.frags--;
			}
			
			Damage_CastOrbituary( eAttacker, eTarget, eAttacker.weapon, trace_surface_id == BODY_HEAD ? TRUE:FALSE );
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
Damage_CheckAttack

This verifies that the entity is actually able to receive some damage,
from a plain geographical standpoint
=================
*/
float Damage_CheckAttack( entity eTarget, vector vAttackPos ) {
	if ( eTarget.movetype == MOVETYPE_PUSH ) {
		traceline( vAttackPos, 0.5 * ( eTarget.absmin + eTarget.absmax ), TRUE, self );
		
		if ( trace_fraction == 1 ) {
			return TRUE;
		} 
		if ( trace_ent == eTarget ) {
			return TRUE;
		}
		return FALSE;
	}
	
	traceline( vAttackPos, eTarget.origin, TRUE, self );
	if ( trace_fraction == 1 ) {
		return TRUE;
	}
	traceline( vAttackPos, eTarget.origin + '15 15 0', TRUE, self );
	if ( trace_fraction == 1 ) {
		return TRUE;
	}
	traceline( vAttackPos, eTarget.origin + '-15 -15 0', TRUE, self );
	if ( trace_fraction == 1 ) {
		return TRUE;
	}
	traceline( vAttackPos, eTarget.origin + '-15 15 0', TRUE, self );
	if ( trace_fraction == 1 ) {
		return TRUE;
	}
	traceline( vAttackPos, eTarget.origin + '15 -15 0', TRUE, self );
	if ( trace_fraction == 1 ) {
		return TRUE;
	}

	return FALSE;
}

/*
=================
Damage_Radius

Even more pain and suffering, mostly used for explosives
=================
*/
void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius, int iCheckClip ) {
	for ( entity eDChain = world; ( eDChain = findfloat( eDChain, takedamage, DAMAGE_YES ) ); ) {
		vector vecRealPos;
		vecRealPos[0] = eDChain.absmin[0] + ( 0.5 * ( eDChain.absmax[0] - eDChain.absmin[0] ) );
		vecRealPos[1] = eDChain.absmin[1] + ( 0.5 * ( eDChain.absmax[1] - eDChain.absmin[1] ) );
		vecRealPos[2] = eDChain.absmin[2] + ( 0.5 * ( eDChain.absmax[2] - eDChain.absmin[2] ) );

		float fDist = vlen( vOrigin - vecRealPos );
		//vector vPush;

		if ( fDist > fRadius ) {
			continue;
		}

		if ( Damage_CheckAttack( eDChain, vOrigin ) || iCheckClip == FALSE ) {
			float fDiff = vlen( vOrigin - vecRealPos );

			fDiff = ( fRadius - fDiff ) / fRadius;
			fDamage = rint(fDamage * fDiff);

			if ( fDiff > 0 ) {
				Damage_Apply( eDChain, eAttacker, fDamage, eDChain.origin, TRUE );
				/*if ( eDChain.movetype != MOVETYPE_NONE ) {
					vPush = vectoangles( vecRealPos - vOrigin );
					makevectors( vPush );
					eDChain.velocity += ( v_forward * fDamage * 5 ) + ( v_up * fDamage * 2.5 );
				}*/
			}
			
		}
	}
}
