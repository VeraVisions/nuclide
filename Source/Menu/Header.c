/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

fcsMenu fcsMain[ MENU_COUNT ] = {
	{ Menu_Main, -1 },
	{ Menu_Configuration, HEAD_CONFIG },
	{ Menu_Configuration_Audio, HEAD_AUDIO },
	{ Menu_Configuration_Video, HEAD_VIDEO },
	{ Menu_Configuration_Player, HEAD_CUSTOMIZE },
	{ Menu_Configuration_Controls, HEAD_CONTROLS },
	{ Menu_Multiplayer, HEAD_MULTI },
	{ Menu_Multiplayer_Create, HEAD_CREATEGAME },
	{ Menu_Multiplayer_Create, HEAD_ADVOPTIONS },
	{ Menu_Multiplayer_IRC, HEAD_ADVOPTIONS },
	{ Menu_Quit, -1 }	
};

string sHeaderImage[] = {
	"gfx/shell/head_advanced",
	"gfx/shell/head_advoptions",
	"gfx/shell/head_audio",
	"gfx/shell/head_config",
	"gfx/shell/head_controls",
	"gfx/shell/head_creategame",
	"gfx/shell/head_createroom",
	"gfx/shell/head_custom",
	"gfx/shell/head_customize",
	"gfx/shell/head_filter",
	"gfx/shell/head_gameopts",
	"gfx/shell/head_gore",
	"gfx/shell/head_inetgames",
	"gfx/shell/head_keyboard",
	"gfx/shell/head_lan",
	"gfx/shell/head_load",
	"gfx/shell/head_multi",
	"gfx/shell/head_readme",
	"gfx/shell/head_room",
	"gfx/shell/head_rooms",
	"gfx/shell/head_save",
	"gfx/shell/head_saveload",
	"gfx/shell/head_specgames",
	"gfx/shell/head_video",
	"gfx/shell/head_vidmodes",
	"gfx/shell/head_vidoptions"
};

void Header_Draw( void ) {
	static int iHeader;
	static int iLastHeader = -1;
	static float fHeaderLerp = 1.0f;
	static vector vHeaderPos;
	static vector vHeaderSize;
	
	iHeader = fcsMain[ iMenu ].iHeaderID;
	
	if ( iHeader != iLastHeader ) {
		fHeaderLerp = 0.0f;
		iLastHeader = iHeader;
		localsound("../media/launch_upmenu1.wav"); 
	}
	
	if ( iHeader == -1 ) {
		return;
	}
	
	if ( fHeaderLerp < 1.0f ) {
		vHeaderPos_x = Math_Lerp( vHeaderButtonPos_x, 18, fHeaderLerp );
		vHeaderPos_y = Math_Lerp( vHeaderButtonPos_y, 32, fHeaderLerp );
		
		vHeaderSize_x = Math_Lerp( 156, 460, fHeaderLerp );
		vHeaderSize_y = Math_Lerp( 26, 80, fHeaderLerp );
		
		vHeaderPos += vMenuOffset;
		drawpic( vHeaderPos, sHeaderImage[iHeader], vHeaderSize, '1 1 1', 0.5f, 1 );
		
		fHeaderLerp += ( frametime * 3 );
	} else {
		drawpic( '18 32' + vMenuOffset, sHeaderImage[ iHeader ], '460 80', '1 1 1', 0.5f, 1 );
	}
}
