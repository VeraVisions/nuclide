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


/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update( float fIsNew ) {
	float fEntType = readbyte();
	
	/*if( fEntType == ENT_PLAYER ) {
		if ( self.entnum == player_localentnum ) {
			ePlayerEnt = self;
		}
		if ( fIsNew == TRUE ) {
			self.predraw = CSQC_PlayerUpdate;
			//self.drawmask = MASK_ENGINE;
		}
		
		float fFlags = readbyte();
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		self.modelindex = readbyte();
		
		if ( fFlags & PLAYER_SENDFLAG_INGAME ) {
			self.velocity_x = readcoord();
			self.velocity_y = readcoord();
			self.velocity_z = readcoord();
			self.flags = readfloat();
		}
		
		setorigin( self, self.origin );
	
	} else */if ( fEntType == ENT_AMBIENTSOUND ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		setorigin( self, self.origin );
		
		CSQC_ambient_generic( readstring(), readfloat(), readbyte() );
	} else if ( fEntType == ENT_SPRITE ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();

		Effect_AnimatedSprite( self.origin, readfloat(), readfloat(), readfloat(), readfloat(), readfloat() );
	}
	
}

/*
=================
CSQC_Ent_Remove

Self explanatory
=================
*/
void CSQC_Ent_Remove( void ) {
	soundupdate( self, CHAN_VOICE, "", -1, ATTN_IDLE, 0, 0, 0 );
	remove( self );
}

