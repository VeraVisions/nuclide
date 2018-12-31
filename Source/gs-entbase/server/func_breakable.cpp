/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/*
	Flags
		Only Trigger (1) - Entity can only be activated (broken) by being triggered.
		Touch (2) - Brush will break on touch.
		Pressure (4) - Brush will break when pressured (e.g. player walking on it).
*/

enumflags
{
	SF_TRIGGER,
	SF_TOUCH,
	SF_PRESSURE
};

class CFuncBreakable : CBaseTrigger
{
	float m_iMaterial;
	virtual void() Trigger;
	virtual void() touch;
	virtual void( entity eAttacker, int iType, int iDamage ) vPain;
	virtual void( entity eAttacker, int iType, int iDamage ) vDeath;
};

void CFuncBreakable :: Respawn ( void )
{
	if ( spawnflags & SF_TRIGGER ) {
		takedamage = DAMAGE_NO;
	} else {
		takedamage = DAMAGE_YES;
	}
}

void CFuncBreakable :: vPain ( entity attacker, int type, int damage )
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
	switch ( m_iMaterial ) {
		case MATERIAL_GLASS:
		case MATERIAL_COMPUTER:
		case MATERIAL_GLASS_UNBREAKABLE:
			sound( self, CHAN_VOICE, sprintf( "debris/glass%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_WOOD:
			sound( self, CHAN_VOICE, sprintf( "debris/wood%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_METAL:
			sound( self, CHAN_VOICE, sprintf( "debris/metal%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_FLESH:
			float fRand  = floor( random( 1, 8 ) );
			if ( fRand == 4 ) { // sigh
				fRand = 5;
			}
			sound( self, CHAN_VOICE, sprintf( "debris/flesh%d.wav", fRand ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			sound( self, CHAN_VOICE, sprintf( "debris/concrete%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
	}
}

void CFuncBreakable :: vDeath ( entity attacker, int type, int damage )
{
	health = 0;
	Effect_BreakModel( absmin, absmax, '0 0 0', m_iMaterial );
	CBaseTrigger::UseTargets();
	CBaseEntity::Hide();
}

void CFuncBreakable :: Trigger ( void )
{
	CFuncBreakable::vDeath( world, 0, 0 );
}

void CFuncBreakable :: touch ( void )
{
	if ( other.classname == classname ) {
		return;
	}

	if ( m_iMaterial == MATERIAL_GLASS ) {
		if (vlen(other.velocity) > 200) {
			vDeath( other, 0, 1 );
		}
	}
}

void CFuncBreakable :: CFuncBreakable( void )
{
	precache_model( model );
	angles = [0,0,0];
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSP;
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
	CFuncBreakable::Respawn();

	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "material":
			m_iMaterial = stoi( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	if ( !health ) {
		health = 15;
	}
}

CLASSEXPORT( func_breakable, CFuncBreakable )
