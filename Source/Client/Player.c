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

float Player_PreDraw( void ) {
    if ( self.entnum == player_localentnum ) {
		self.movetype = MOVETYPE_WALK;
        // Prepare rollback
		vector vOldOrigin = self.origin;
		vector vOldVelocity = self.velocity;
		float fOldPMoveFlags = self.pmove_flags;

		// Apply physics for every single input-frame that has not yet been
		// acknowledged by the server (servercommandframe = last acknowledged frame)
		for ( int i = servercommandframe + 1; i <= clientcommandframe; i++ ) {
			getinputstate( i );
			runstandardplayerphysics( self );
		}
				
		// Smooth stair stepping, this has to be done manually!
		vPlayerOriginOld = vPlayerOrigin;
				
		if ( ( self.flags & FL_ONGROUND ) && ( self.origin_z - vPlayerOriginOld_z > 0 ) ) {
			vPlayerOriginOld_z += frametime * 150;
					
			if ( vPlayerOriginOld_z > self.origin_z ) {
				vPlayerOriginOld_z = self.origin_z;
			}
			if ( self.origin_z - vPlayerOriginOld_z > 18 ) {
				vPlayerOriginOld_z = self.origin_z - 18;
			}
			vPlayerOrigin_z += vPlayerOriginOld_z - self.origin_z;
		} else {
			vPlayerOriginOld_z = self.origin_z;
		}
			
		vPlayerOrigin = [ self.origin_x, self.origin_y, vPlayerOriginOld_z ];
		vPlayerVelocity = self.velocity;
		addentity( self );

		// Time to roll back
		self.origin = vOldOrigin;
		setorigin( self, self.origin );
		self.velocity = vOldVelocity;
		self.pmove_flags = fOldPMoveFlags;
		self.movetype = MOVETYPE_NONE;

		// Set renderflag for mirrors!
		self.renderflags = RF_EXTERNALMODEL;
    } else {
        addentity( self );
    }
    return PREDRAW_NEXT;
}
