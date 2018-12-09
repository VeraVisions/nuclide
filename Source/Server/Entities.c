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
		dprint( sprintf( "Triggering %s %s\n", self.classname, self.targetname ) );
		
		// Make sure we really do have a target...
		if ( self.vUse != __NULL__ ) {
			self.vUse();
		}
		
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
void Entities_InitRespawnable( void() vRespawnFunc ) {
	self.sOldModel = self.model;
	self.fOldSolid = self.solid;
	self.fOldHealth = self.health;
	self.vOldOrigin = self.origin;
	self.vOldAngle = self.angles;
	self.vRespawn = vRespawnFunc;
	self.vOldUse = self.vUse;
	self.fRespawns = TRUE;
}

void Entities_Respawn( void ) {
	self.model = self.sOldModel;
	self.solid = self.fOldSolid;
	self.health = self.fOldHealth;
	self.origin = self.vOldOrigin;
	self.angles = self.vOldAngle;
	self.vUse = self.vOldUse;
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
		setorigin( self, self.vOldOrigin );
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

Rotate to a given destination at a given pace
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
