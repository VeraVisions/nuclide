/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class func_bomb_target:CBaseTrigger
{
	void() func_bomb_target;
	virtual void() touch;
	virtual void() Respawn;
};

void func_bomb_target::touch(void)
{
	if (iBombPlanted == TRUE) {
		return;
	}

	/* This will be cleared every frame inside SV_RunClientCommand */
	if ((other.classname == "player") && (other.team == TEAM_T)) {
		other.fInBombZone = TRUE;
	}
}

void func_bomb_target::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void func_bomb_target::func_bomb_target(void)
{
	func_bomb_target::Respawn();
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
	iBombZones++;
}
