/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags 
{
	MF_WAITTILLSEEN,
	MF_GAG,
	MF_MONSTERCLIP,
	MF_PRISONER,
	MF_UNUSED,
	MF_WAITFORSCRIPT,
	MF_PREDISASTER,
	MF_FADECORPSE
};

class CMonsterGeneric : CBaseEntity
{
	void() CMonsterGeneric;
	//virtual void() Respawn;
};

void CMonsterGeneric :: CMonsterGeneric ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "sequence":
			frame = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	precache_model( model );
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
	
#if 0
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	self.avelocity = '0 90 0 ';
	self.modelflags = MF_ROTATE;
#endif
}

CLASSEXPORT( monster_generic, CMonsterGeneric )

