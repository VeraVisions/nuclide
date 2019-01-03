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

class func_breakable : CBaseTrigger
{
	float m_iMaterial;
	float m_flDelay;
	/*entity m_pressAttacker;
	int m_pressType;
	int m_pressDamage;*/

	virtual void() Trigger;
	virtual void() PlayerTouch;
	/*virtual void() PressureDeath;*/
	virtual void( entity eAttacker, int iType, int iDamage ) vPain;
	virtual void( entity eAttacker, int iType, int iDamage ) vDeath;
};

void func_breakable :: vPain ( entity attacker, int type, int damage )
{
	if (spawnflags & SF_TRIGGER) {
		return;
	}

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
			/* There never was a flesh4.wav */
			if ( fRand == 4 ) {
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

void func_breakable :: vDeath ( entity attacker, int type, int damage )
{
	if (m_iMaterial == MATERIAL_GLASS_UNBREAKABLE) {
		return;
	}
	health = 0;
	Effect_BreakModel( absmin, absmax, '0 0 0', m_iMaterial );
	CBaseTrigger::UseTargets();
	CBaseEntity::Hide();
}

void func_breakable :: Trigger ( void )
{
	func_breakable::vDeath( world, 0, 0 );
}

/*void func_breakable :: PressureDeath ( void )
{
	func_breakable::vDeath(m_pressAttacker, m_pressType, m_pressDamage);
}*/

void func_breakable :: PlayerTouch ( void )
{
	if ( other.classname == classname ) {
		return;
	}

	if (spawnflags & SF_TOUCH) {
		int fDamage = (float)(vlen(other.velocity) * 0.01f);

		if (fDamage >= health) {
			touch = __NULL__;
			Damage_Apply( this, other, fDamage, absmin, FALSE );
			
			if ((m_iMaterial == MATERIAL_GLASS) || (m_iMaterial == MATERIAL_COMPUTER)) {
				Damage_Apply(other, this, fDamage / 4, other.origin, FALSE);
			}
		}
	}

	if ((spawnflags & SF_PRESSURE) && (other.absmin_z >= maxs_z - 2)) {
		think = Trigger;

		if (m_flDelay == 0) {
			m_flDelay = 0.1f;
		}

		nextthink = time + m_flDelay;
	}
}


void func_breakable :: Respawn ( void )
{
	touch = PlayerTouch;
	if ( spawnflags & SF_TRIGGER ) {
		takedamage = DAMAGE_NO;
	} else {
		takedamage = DAMAGE_YES;
	}

	health = m_oldHealth;

	if ( !health ) {
		health = 15;
	}
}

void func_breakable :: func_breakable( void )
{
	precache_model( model );
	angles = [0,0,0];
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSP;
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
	func_breakable::Respawn();

	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "material":
			m_iMaterial = stof( argv( i + 1 ) );
			break;
		case "delay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	
}
