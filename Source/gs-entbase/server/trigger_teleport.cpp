/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_teleport : CBaseTrigger
{
	void() trigger_teleport;
	virtual void() touch;
	virtual void() Respawn;
};

void trigger_teleport :: touch ( void )
{
	if ( other.health > 0 || other.solid == SOLID_SLIDEBOX ) {
		entity eTarget = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

		if (eTarget) {
			setorigin(other, eTarget.origin + [0,0,16]);
		}
	}
}

void trigger_teleport :: Respawn( void )
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_teleport :: trigger_teleport ( void )
{
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
}

CLASSEXPORT( info_teleport_destination, info_notnull )
