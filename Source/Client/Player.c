/*
FreeCS Project
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
		// Don't predict if we're frozen/paused FIXME: FTE doesn't have serverkey_float yet!
		if ( serverkey( SERVERKEY_PAUSESTATE ) == "1" || ( ( getstati( STAT_GAMESTATE ) == GAME_FREEZE ) && ( getstati( STAT_HEALTH ) > 0 ) ) ) {
			vPlayerOrigin = self.origin;
			vPlayerVelocity = '0 0 0';
			addentity( self );
			return PREDRAW_NEXT;
		}
		
		vector vOldOrigin = self.origin;
		vector vOldVelocity = self.velocity;
		float fOldPMoveFlags = self.pmove_flags;

		if ( getplayerkeyvalue( player_localnum, "*spectator" ) == "1" ) {
			self.movetype = MOVETYPE_NOCLIP;
		} else {
			self.movetype = MOVETYPE_WALK;
		}
		
		for ( int i = servercommandframe + 1; i <= clientcommandframe; i++ ) {
			getinputstate( i );
			runstandardplayerphysics( self );
		}
				
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

		self.origin = vOldOrigin;
		setorigin( self, self.origin );
		self.velocity = vOldVelocity;
		self.pmove_flags = fOldPMoveFlags;
		self.movetype = MOVETYPE_NONE;

		self.renderflags = RF_EXTERNALMODEL;
    } else {
		Animation_PlayerUpdate();
		self.baseframe1time += frametime;
		self.frame1time += frametime;
        addentity( self );
    }
    return PREDRAW_NEXT;
}
