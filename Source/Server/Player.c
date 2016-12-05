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

void Player_Pain( void ) {
	
}

void Player_Death( void ) {
	
	// Drop a corpse
	entity eCorpse = spawn();
	setorigin( eCorpse, self.origin );
	setmodel( eCorpse, self.model );
	eCorpse.angles = self.angles;
	eCorpse.frame = 93; // TODO: Pick the right frame
	
	Spawn_MakeSpectator();
	
	if ( self.team == TEAM_T ) {
		iAlivePlayers_T--;
		
		if ( iAlivePlayers_T == 0 ) {
			Rules_RoundOver( TEAM_CT );
		}
	} else if ( self.team == TEAM_CT ) {
		iAlivePlayers_CT--;
		
		if ( iAlivePlayers_T == 0 ) {
			Rules_RoundOver( TEAM_T );
		}
	} else if ( self.team == TEAM_VIP ) {
		// TODO: Finish me
	}
}

float Player_GetMaxSpeed( float fWeapon ) {
	if ( self.iCrouching == TRUE ) {
		return (cvar( "cl_forwardspeed" ) * wptTable[ fWeapon ].fSpeedM) * 0.5;
	} else {
		return cvar( "cl_forwardspeed" ) * wptTable[ fWeapon ].fSpeedM;
	}
}

/*
=================
Player_CrouchCheck
=================
*/
float Player_CrouchCheck( entity targ ) {
	float fCheck = FALSE;
	vector vTrace = self.origin + '0 0 20';
	
	tracebox( vTrace, VEC_HULL_MIN, VEC_HULL_MAX, vTrace, FALSE, self );

	if ( trace_startsolid == FALSE ) {
		fCheck = TRUE;
	}
	
	return fCheck;
}

/*
=================
Player_CrouchDown
=================
*/
void Player_CrouchDown( void ) {
	if( self.movetype != MOVETYPE_WALK ) {
		return;
	}

	if( !self.iCrouching ) {
		setsize( self, VEC_CHULL_MIN, VEC_CHULL_MAX );
		self.iCrouching = TRUE;
		self.view_ofs = VEC_PLAYER_CVIEWPOS;
		self.velocity_z = self.velocity_z + 50;
		self.maxspeed = Player_GetMaxSpeed( self.weapon );
		self.iCrouchAttempt = 1;
		return;
	}

	self.iCrouchAttempt = FALSE;
}

/*
=================
Player_CrouchUp
=================
*/
void Player_CrouchUp( void ) {
	if ( self.movetype != MOVETYPE_WALK ) {
		return;
	}

	if ( self.iCrouching && ( !self.velocity_z ) && (Player_CrouchCheck( self ) ) ) {
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

		setorigin( self, self.origin + '0 0 18');
		self.velocity_z = self.velocity_z + 16;
		self.view_ofs = VEC_PLAYER_VIEWPOS;
		self.iCrouching = FALSE;
		self.iCrouchAttempt = FALSE;
		self.maxspeed = Player_GetMaxSpeed( self.weapon );
		return;
	}

	self.iCrouchAttempt = TRUE;
}
