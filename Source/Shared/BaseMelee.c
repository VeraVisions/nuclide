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
