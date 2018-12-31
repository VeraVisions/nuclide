/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CTriggerTeleport : CBaseTrigger
{
	void() CTriggerTeleport;
	virtual void() touch;
};

void CTriggerTeleport :: touch ( void )
{
	if ( other.health > 0 || other.solid == SOLID_SLIDEBOX ) {
		entity eTarget = find( world, ::targetname, target );
		setorigin( other, eTarget.origin );
	}
}

void CTriggerTeleport :: CTriggerTeleport ( void )
{
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
}

CLASSEXPORT( trigger_teleport, CTriggerTeleport )
CLASSEXPORT( info_teleport_destination, CInfoNull )
