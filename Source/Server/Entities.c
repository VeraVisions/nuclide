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

/*
====================
GOLDSRC-RENDERMODE STUFF
====================
*/
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
		self.colormod = self.rendercolor;
		
		if( self.alpha == 0 ) {
			self.alpha = 0.0001;
		}
		
		if ( self.rendermode == RENDERMODE_ADDITIVE ) {
			self.effects = EF_ADDITIVE;
		} else if ( self.rendermode == RENDERMODE_GLOW ) {
			self.effects = EF_ADDITIVE | EF_FULLBRIGHT;
		}
	}
}

/*
====================
Entities_UseTargets
====================
*/
void Entities_UseTargets( void ) {
	entity eFind = findchain( targetname, self.target );
	
	entity eOld = self;
	while ( eFind ) {
		self = eFind;
		self.vUse();
		eFind = eFind.chain;
	}
	self = eOld;
}

/*
====================
Entities_UseTargets_Delay
====================
*/
void Entities_UseTargets_Delay( float fDelay ) {
	static void Entities_UseTargets_Delay_Think( void ) {
		entity eOld = self;
		self = self.owner;
		Entities_UseTargets();
		remove( eOld );
	}
	
	entity eTimer = spawn();
	eTimer.owner = self;
	eTimer.think = Entities_UseTargets_Delay_Think;
	eTimer.nextthink = time + fDelay;
}

/*
====================
Entities_InitRespawnable

Called
====================
*/
.string sOldModel;
.float fOldSolid;
.float fOldHealth;
.vector vOldOrigin;
.vector vOldAngle;
.void() vRespawn;
void Entities_InitRespawnable( void() vRespawnFunc ) {
	self.sOldModel = self.model;
	self.fOldSolid = self.solid;
	self.fOldHealth = self.health;
	self.vOldOrigin = self.origin;
	self.vOldAngle = self.angles;
	self.vRespawn = vRespawnFunc;
	self.fRespawns = TRUE;
}

void Entities_Respawn( void ) {
	self.model = self.sOldModel;
	self.solid = self.fOldSolid;
	self.health = self.fOldHealth;
	self.origin = self.vOldOrigin;
	self.angles = self.vOldAngle;
	Entities_RenderSetup();
	self.vRespawn();
}

/*
====================
Entities_Remove

Technically, it doesn't remove everything
====================
*/
void Entities_Remove( void ) {
	if ( self.fRespawns == TRUE ) {
		self.solid = SOLID_NOT;
		self.model = 0;
	} else {
		remove( self );
	}
}

/*
====================
Entities_SetMovedir

Returns the movement direction based on angles
====================
*/
void Entities_SetMovementDirection( void )
{
	if ( self.angles == '0 -1 0' ) {
		self.movedir = '0 0 1';
	} else if ( self.angles == '0 -2 0' ) {
		self.movedir = '0 0 -1';
	} else {
		makevectors( self.angles );
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
}

/*
====================
Entities_InitTrigger

  Prepares an entity to have the properties of a TRIGGER
====================
*/
void Entities_InitTrigger( void ) {
	if ( self.angles != '0 0 0' ) {
		Entities_SetMovementDirection();
	}
	self.solid = SOLID_TRIGGER;
	setmodel ( self, self.model );
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}

/*
====================
Entities_MoveToDestination_End
====================
*/
.vector vFinalDestination;
.void() vThinkMove;
void Entities_MoveToDestination_End( void ) {
	setorigin( self, self.vFinalDestination );
	self.velocity = '0 0 0';
	self.nextthink = -1;
	self.vThinkMove();
}

/*
====================
Entities_MoveToDestination

Sets velocity of an ent to move to a destination at the desired speed
====================
*/
void Entities_MoveToDestination(vector vDestination, float fMoveSpeed, void() func) {
	local vector vPositionDifference;
	local float fTravelLength, fTravelTime;

	if ( !fMoveSpeed ) {
		objerror("No speed defined for moving entity! Will not divide by zero.");
	}

	self.vThinkMove = func;
	self.vFinalDestination = vDestination;
	self.think = Entities_MoveToDestination_End;

	if ( vDestination == self.origin ) {
		self.velocity = '0 0 0';
		self.nextthink = ( self.ltime + 0.1 );
		return;
	}

	vPositionDifference = ( vDestination - self.origin );
	fTravelLength = vlen( vPositionDifference );
	fTravelTime = ( fTravelLength / fMoveSpeed );

	if ( fTravelTime < 0.1 ) {
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
	self.nextthink = ( self.ltime + fTravelTime );
	self.velocity = ( vPositionDifference * ( 1 / fTravelTime ) );
}

/*
====================
Entities_CalcAngleMoveDone
====================
*/
.vector vFinalAngle;
void Entities_RotateToDestination_End( void ) {
	self.angles = self.vFinalAngle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	self.vThinkMove();
}

/*
====================
Entities_RotateToDestination
====================
*/
void Entities_RotateToDestination( vector vDestinationAngle, float fTravelSpeed, void() func ) {
	local vector	vAngleDifference;
	local float		fTravelLength, fTravelTime;

	if ( !fTravelSpeed ) {
		objerror("No speed defined for moving entity! Will not divide by zero.");
	}
	
	vAngleDifference = ( vDestinationAngle - self.angles );
	fTravelLength = vlen( vAngleDifference );
	fTravelTime = ( fTravelLength / fTravelSpeed );
	self.nextthink = ( self.ltime + fTravelTime );
	self.avelocity = ( vAngleDifference * ( 1 / fTravelTime ) );
	self.vFinalAngle = vDestinationAngle;
	self.vThinkMove = func;
	self.think = Entities_RotateToDestination_End;
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

void func_illusionary( void ){
	func_wall();
	self.solid = SOLID_NOT;
}

void func_water( void ) {
	func_wall();
	self.skin = CONTENT_WATER;
	/*self.forceshader = shaderforname( "{\n"
				"surfaceparm nodlight\n"
				"surfaceparm nomarks\n"
				"{\n"
					"map $refraction\n"
				"}\n"
				"{\n"
					"map $null\n"
				"}\n"
				"{\n"
					"map $ripplemap\n"
				"}\n"
				"{\n"
					"map $null\n" 
				"}\n"
				"program altwater#RIPPLEMAP#FRESNEL=4\n"
			"}\n" );*/
}
