/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// Network Events
enum {
	EV_WEAPON_DRAW,
	EV_WEAPON_PRIMARYATTACK,
	EV_WEAPON_SECONDARYATTACK,
	EV_WEAPON_RELOAD,
	EV_IMPACT,
	EV_GIBHUMAN,
	EV_BLOOD,
	EV_EXPLOSION,
	EV_SPARK,
	EV_SHAKE,
	EV_FADE,
	EV_TEXT,
	EV_MESSAGE,
	EV_SPRITE,
	EV_MODELGIB,
	EV_CAMERATRIGGER,
	EV_ORBITUARY,
	EV_TAUNT,
	EV_CHAT,
	EV_CHAT_TEAM,
	EV_CHAT_VOX,
#ifdef VALVE
	EV_VIEWMODEL,
#endif
#ifdef CSTRIKE
	EV_RADIOMSG,
	EV_RADIOMSG2,
	EV_SMOKE,
	EV_FLASH,
#endif
};
