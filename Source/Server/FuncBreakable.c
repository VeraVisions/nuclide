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

// Entity information from http://twhl.info/wiki.php?id=164


// These are the material types apparently
.float material;
enum { 
	MATERIAL_GLASS = 0, 
	MATERIAL_WOOD, 
	MATERIAL_METAL, 
	MATERIAL_FLESH, 
	MATERIAL_CINDER, 
	MATERIAL_TILE, 
	MATERIAL_COMPUTER, 
	MATERIAL_GLASS_UNBREAKABLE, 
	MATERIAL_ROCK, 
	MATERIAL_NONE	
};

// Whenever it gets damaged
void func_breakable_pain( void ) {
	string sTypeSample = "";
	int iTypeCount = 0;
	
	switch ( self.material ) {
		case MATERIAL_GLASS:
		case MATERIAL_COMPUTER:
		case MATERIAL_GLASS_UNBREAKABLE:
			sTypeSample = "debris/glass";
			iTypeCount = 3;
			break;
		case MATERIAL_WOOD:
			sTypeSample = "debris/wood";
			iTypeCount = 3;
			break;
		case MATERIAL_METAL:
			sTypeSample = "debris/metal";
			iTypeCount = 3;
			break;
		case MATERIAL_FLESH:
			sTypeSample = "debris/flesh";
			iTypeCount = 7;
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			sTypeSample = "debris/concrete";
			iTypeCount = 3;
			break;
	}
	
	if ( iTypeCount >= 1 ) {
		sound( self, CHAN_VOICE, sprintf( "%s%d.wav", sTypeSample, ceil( random() * iTypeCount ) ), 1.0, ATTN_NORM );
	}
}

// Whenever it.. dies
void func_breakable_die( void ) {
	string sTypeSample = "";
	int iTypeCount = 0;
	
	switch ( self.material ) {
		case MATERIAL_GLASS:
		case MATERIAL_GLASS_UNBREAKABLE:
			sTypeSample = "debris/bustglass";
			iTypeCount = 2;
			break;
		case MATERIAL_WOOD:
			sTypeSample = "debris/bustwood";
			iTypeCount = 2;
			break;
		case MATERIAL_METAL:
		case MATERIAL_COMPUTER:
			sTypeSample = "debris/bustmetal";
			iTypeCount = 2;
			break;
		case MATERIAL_FLESH:
			sTypeSample = "debris/bustflesh";
			iTypeCount = 2;
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			sTypeSample = "debris/bustconcrete";
			iTypeCount = 3;
			break;
		case MATERIAL_TILE:
			sTypeSample = "debris/bustceiling";
			iTypeCount = 3;
			break;
	}
	
	if ( iTypeCount >= 1 ) {
		sound( self, CHAN_VOICE, sprintf( "%s%d.wav", sTypeSample, ceil( random() * iTypeCount ) ), 1.0, ATTN_NORM );
	}
	
	Effect_BreakModel( self.origin, self.size, self.velocity, self.style );
	
	remove( self );
}

/*
=================
SPAWN: func_breakable

Entry function for the brushes that can die etc.
=================
*/
void func_breakable( void ) {
	func_wall();
	self.vPain = func_breakable_pain;
	self.vDeath = func_breakable_die;
	self.iBleeds = FALSE;
	self.takedamage = DAMAGE_YES;
}
