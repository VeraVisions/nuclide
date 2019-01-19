/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef SSQC
void BaseMelee_Draw( void ) {
	self.iCurrentMag = 0;
	self.iCurrentCaliber = 0;
	
	Client_SendEvent( self, EV_WEAPON_DRAW );
}

int BaseMelee_Attack( void ) {
	vector vSource;
	vector vOrigin;

	makevectors( self.v_angle );
	vSource = ( self.origin + self.view_ofs );
	traceline( vSource, vSource + ( v_forward * 64 ), MOVE_HITMODEL, self );

	if ( trace_fraction == 1.0 ) {
		return FALSE;
	}

	vOrigin = trace_endpos - v_forward * 2;

	if ( trace_ent.takedamage ) {
		if ( trace_ent.iBleeds == TRUE ) {
			Effect_Impact( IMPACT_FLESH, trace_endpos, trace_plane_normal );
			sound( self, CHAN_WEAPON, sprintf( "weapons/knife_hit%d.wav", floor( ( random() * 4 ) + 1 ) ), 1, ATTN_NORM );
		}
		Damage_Apply( trace_ent, self, wptTable[ self.weapon ].iDamage, trace_endpos, FALSE );
	} else {
		Effect_Impact( IMPACT_MELEE, trace_endpos, trace_plane_normal );
	}
	
	return TRUE;
}

void BaseMelee_Delayed( float fDelay ) {
	static void BaseMelee_Delayed_Trigger( void ) {
		BaseMelee_Attack();
	}
	
	self.think = BaseMelee_Delayed_Trigger;
	self.nextthink = time + fDelay;
}
#endif
