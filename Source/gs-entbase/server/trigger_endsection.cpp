/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_endsection:CBaseTrigger
{
	void() trigger_endsection;

	virtual void() Trigger;
	virtual void() Respawn;
}

void trigger_endsection::Trigger ( void )
{
	localcmd( "disconnect\n" );
}

/* TODO: Make this redundant */
void trigger_endsection::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_endsection::trigger_endsection(void)
{
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
	trigger_endsection::Respawn();
}
