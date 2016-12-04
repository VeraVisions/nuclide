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

void Entities_UseTargets( void ) {
	entity eFind = findchain( targetname, self.target );
	
	while ( eFind ) {
		entity eOldSelf = self;
		self = eFind;
		eFind.vUse();
		self = eOldSelf;
		eFind = eFind.chain;
	}
}

enum { 
	RENDERMODE_NORMAL = 0,
	RENDERMODE_COLOR,
	RENDERMODE_TEXTURE,
	RENDERMODE_GLOW,
	RENDERMODE_SOLID,
	RENDERMODE_ADDITIVE
};

void Entities_RenderSetup( void ) {
	// GoldSrc-Rendermode support
	if ( self.rendermode != RENDERMODE_NORMAL ) {
		self.alpha = ( self.renderamt / 255 );
		if( self.alpha == 0 ) {
			self.alpha = 0.0001;
		}
		
		if ( self.rendermode == RENDERMODE_ADDITIVE ) {
			self.effects = EF_ADDITIVE;
		} else if ( self.rendermode == RENDERMODE_GLOW ) {
			self.effects = EF_FULLBRIGHT;
		}
	}
}

void func_wall( void ) {
	static void func_wall_use( void ) {
		self.skin = 1 - self.skin;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;

	setmodel( self, self.model );
	self.vUse = func_wall_use;
	Entities_RenderSetup();
}

void func_door( void ) {
	func_wall();
}

void func_button( void ) {
	func_wall();
}

void func_illusionary( void ){
	func_wall();
	self.solid = SOLID_NOT;
}

void func_water( void ) {
	func_wall();
	self.skin = CONTENT_WATER;
}
