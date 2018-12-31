/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CFuncLadder : CBaseEntity {
	void() CFuncLadder;
};

void CFuncLadder :: CFuncLadder ( void )
{
	setmodel( this, model );
	movetype = MOVETYPE_NONE;
	skin = CONTENT_LADDER;
	solid = SOLID_BSP;
}

CLASSEXPORT( func_ladder, CFuncLadder )
