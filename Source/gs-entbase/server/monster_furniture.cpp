/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	MF_WAITTILSEEN,
	MF_GAG,
	MF_MONSTERCLIP,
	MF_PRISONER,
	MF_UNUSED,
	MF_WAITFORSCRIPT,
	MF_PREDISASTER,
	MF_FADECORPSE
};

class CMonsterFurniture : CBaseEntity
{
	void() CMonsterFurniture;
	//virtual void() Respawn;
};

void CMonsterFurniture :: CMonsterFurniture ( void )
{
	precache_model( model );
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
	
#if 1
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	//self.avelocity = '0 90 0 ';
	//self.modelflags = MF_ROTATE;
#endif
}

CLASSEXPORT( monster_furniture, CMonsterFurniture )
