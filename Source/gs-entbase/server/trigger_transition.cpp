/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_transition
{
	void() trigger_transition;
};

void trigger_transition :: trigger_transition ( void )
{
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	setmodel( this, model );
	model = __NULL__;
	modelindex = 0;
} 

CLASSEXPORT( trigger_transition, trigger_transition )
