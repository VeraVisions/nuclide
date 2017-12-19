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

void CSQC_ambient_generic( string sSample, float fVolume, float fAttenuation ) {
	//print( sprintf( "SOUND: %s, %f, %d\n%d %d %d", sSample, fVolume, fAttenuation, self.origin_x, self.origin_y, self.origin_z ) );
	sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, SOUNDFLAG_FORCELOOP );
}

/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update( float flIsNew ) {
	float fEntType = readbyte();
	
	if( fEntType == ENT_PLAYER ) {
		if ( flIsNew == TRUE ) {
			self.classname = "player";
			self.solid = SOLID_SLIDEBOX;
			self.predraw = Player_PreDraw;
			self.drawmask = MASK_ENGINE;
			self.pmove_frame = servercommandframe;
		} else {
			Player_PreUpdate();
		}
		
		self.modelindex = readbyte();
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		self.subblend2frac = readcoord() / 90;
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		self.velocity_x = readshort();
		self.velocity_y = readshort();
		self.velocity_z = readshort();
		self.flags = readfloat();
		self.weapon = readbyte();
		
		Player_PostUpdate();
		
		if ( self.flags & FL_CROUCHING ) {
			setsize( self, VEC_CHULL_MIN, VEC_CHULL_MAX );
		} else {
			setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
		}
		
		setorigin( self, self.origin );
	} else if ( fEntType == ENT_AMBIENTSOUND ) {
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
	} else if ( fEntType == ENT_SPRAY ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		
		self.color_x = 1.0f - ( readbyte() / 255 );
		self.color_y = 1.0f - ( readbyte() / 255 );
		self.color_z = 1.0f - ( readbyte() / 255 );
		string sLogo = readstring();
		
		self.classname = sprintf( "spray_%s", sLogo );
		self.predraw = Effect_Spraypaint;
		self.drawmask = MASK_ENGINE;
	}
}

/*
=================
CSQC_Ent_Remove

Self explanatory
=================
*/
void CSQC_Ent_Remove( void ) {
	if ( self.eGunModel ) {
		remove( self.eGunModel );
	}
	
	soundupdate( self, CHAN_VOICE, "", -1, ATTN_IDLE, 0, 0, 0 );
	remove( self );
}

