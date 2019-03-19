/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class info_null
{
	void() info_null;
};

void info_null::info_null(void)
{
	remove( self );
}

class info_notnull:CBaseTrigger
{
	void() info_notnull;
};

void info_notnull::info_notnull(void)
{
	CBaseTrigger::CBaseTrigger();
}

CLASSEXPORT(info_node, info_notnull)
CLASSEXPORT(info_target, info_notnull)
CLASSEXPORT(env_sound, info_null)
