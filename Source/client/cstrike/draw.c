/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define CHAT_LINES 5
#define CHAT_TIME 	20
var int iLineScroll = 0;

float fChatTime;
float fChatAlpha;
string sMSGBuffer[CHAT_LINES];

/*
=================
CSQC_Parse_Print

Receives a message and sorts it into the chat messagebuffer
=================
*/
void CSQC_Parse_Print(string sMessage, float fLevel) {
	// This gives messages other than chat an orange tint
	if (fLevel != PRINT_CHAT) {
		sMessage = sprintf("^xF80%s", sMessage);
	}
	
	if (iLineScroll < (CHAT_LINES - 1)) {
		sMSGBuffer[iLineScroll + 1] = sMessage;
		iLineScroll++;
	} else {
		for (int i = 0; i < (CHAT_LINES - 1); i++) {
			sMSGBuffer[i] = sMSGBuffer[i + 1];
		}
		sMSGBuffer[CHAT_LINES - 1] = sMessage;
	}
		
	fChatTime = time + CHAT_TIME;
	fChatAlpha = 1.0f;
	
	// Log to console
	localcmd(sprintf("echo \"%s\"\n", sMessage));
}

/*
=================
CSQC_DrawChat

Just prints whatever is in the chat buffer and removes lines after some time.
=================
*/
void CSQC_DrawChat(void) {
	vector vChatPos = vVideoMins + [16, vVideoResolution_y - 128];
	
	// Remove messages after a fChatTime has passed
	if (fChatTime < time) {
		fChatAlpha -= frametime;
	} else {
		fChatAlpha = 1.0f;
	}
	
	if (fChatAlpha > 0.0f) {
#if 1
		for (int i = 0; i < CHAT_LINES; i++) {
			drawstring(vChatPos, sMSGBuffer[i], '12 12', '1 1 1', fChatAlpha, 0);
			vChatPos_y += 14;
		}
#else
		string sDraw = sMSGBuffer[0];
		for (int i = 1; i < CHAT_LINES; i++) {
			sDraw = sprintf("%s\n%s\n", sDraw, sMSGBuffer[i]);
		}
		
		drawtextfield(vChatPos, [vVideoResolution_x - 32, CHAT_LINES * 12], 1, sDraw);
#endif
	}
}

/*
=================
CSQC_DrawCenterprint

Read centerprints from a buffer and display them with alpha and whatnot
=================
*/
float fCenterPrintAlpha;
float fCenterPrintTime;
float fCenterPrintLines;
string sCenterPrintBuffer[18];

void CSQC_DrawCenterprint(void) {	
	if (fCenterPrintAlpha <= 0) {
		return;
	}
	
	vector vCenterPrintPos;
	
	if (fCenterPrintTime > time) {
		fCenterPrintAlpha = 1;
	} else {
		fCenterPrintAlpha -= frametime;
		
		if (fCenterPrintAlpha < 0) {
			fCenterPrintAlpha = 0;
		}
	}
	
	vCenterPrintPos_y = vVideoMins_y + (vVideoResolution_y / 2) - (fCenterPrintLines - 4) - 69;
	
	for (int i = 0; i < (fCenterPrintLines); i++) {
		vCenterPrintPos_x = vVideoMins_x + (vVideoResolution_x / 2) - (stringwidth(sCenterPrintBuffer[i], TRUE, '12 12') / 2);
		drawstring(vCenterPrintPos, sCenterPrintBuffer[i], '12 12', '1 1 1', fCenterPrintAlpha, 0);
		vCenterPrintPos_y += 8;
	}
}

/*
=================
CSQC_Parse_CenterPrint

Catches every centerprint call and allows us to tinker with it.
That's how we are able to add color, alpha and whatnot.
Keep in mind that newlines need to be tokenized
=================
*/
float CSQC_Parse_CenterPrint(string sMessage) {
	fCenterPrintLines = tokenizebyseparator(sMessage, "\n");
	
	for(int i = 0; i < (fCenterPrintLines); i++) {
		sCenterPrintBuffer[i] = sprintf("^xF80%s", argv(i));
	}
	
	fCenterPrintAlpha = 1;
	fCenterPrintTime = time + 3;
	
	return TRUE;
}

void CSQC_CalcViewport(int s, float fWinWidth, float fWinHeight) {
	//FIXME: this is awkward. renderscene internally rounds to pixels.
	//on the other hand, drawpic uses linear filtering and multisample and stuff.
	//this means that there can be a pixel or so difference between scene and 2d.
	//as a general rule, you won't notice unless there's some big drawfills.
	switch (numclientseats) {
	case 3:
		if (!s) {
	case 2:
		vVideoResolution = [fWinWidth, fWinHeight * 0.5];
		vVideoMins = [0, (s & 1) * vVideoResolution_y];
		break;
		}
		s++;
	case 4:
		vVideoResolution = [fWinWidth, fWinHeight] * 0.5;
		vVideoMins = [(s&1) * vVideoResolution_x, (s / 2i) * vVideoResolution_y];
		break;
	default:
		vVideoResolution = [fWinWidth, fWinHeight];
		vVideoMins = [0, 0];
		break;
	}
}

/*
=================
CSQC_UpdateView

Entry point for drawing on the client
=================
*/
void Cstrike_PreDraw(void)
{

	Nightvision_PreDraw();
}

void Cstrike_PostDraw(int x, int y, int w, int h)
{
	Nightvision_PostDraw(x, y, w, h);
}
