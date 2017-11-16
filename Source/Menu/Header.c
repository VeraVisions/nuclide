/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
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
	}
	
	if ( iHeader == -1 ) {
		return;
	}
	
	if ( fHeaderLerp < 1.0f ) {
		vHeaderPos_x = Math_Lerp( 484, 18, fHeaderLerp );
		vHeaderPos_y = Math_Lerp( 454, 32, fHeaderLerp );
		
		vHeaderSize_x = Math_Lerp( 156, 460, fHeaderLerp );
		vHeaderSize_y = Math_Lerp( 26, 80, fHeaderLerp );
		
		vHeaderPos += vMenuOffset;
		drawpic( vHeaderPos, sHeaderImage[iHeader], vHeaderSize, '1 1 1', 0.5f, 1 );
		
		fHeaderLerp += ( frametime * 3 );
	} else {
		drawpic( '18 32' + vMenuOffset, sHeaderImage[ iHeader ], '460 80', '1 1 1', 0.5f, 1 );
	}
}