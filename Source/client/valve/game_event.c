/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Game_Parse_Event(float fHeader)
{
	if (fHeader == EV_CHAT) {
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();
		
		CSQC_Parse_Print(sprintf("%s: %s", getplayerkeyvalue(fSender, "name"), sMessage), PRINT_CHAT);
	} else if (fHeader == EV_CHAT_TEAM) {
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();
		
		CSQC_Parse_Print(sprintf("[TEAM] %s: %s", getplayerkeyvalue(fSender2, "name"), sMessage2), PRINT_CHAT);
	} else if (fHeader == EV_CHAT_VOX) {
		Sound_PlayVOX(readstring());
	} else if (fHeader == EV_VIEWMODEL) {
		View_PlayAnimation(readbyte());
	}
}
