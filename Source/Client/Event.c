/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

/*
=================
CSQC_ConsoleCommand_Init

Init all the cmds in one place
=================
*/
void CSQC_ConsoleCommand_Init( void ) {
	registercommand( "buy" );
	registercommand( "chooseteam" );
	registercommand( "use" );
}

/*
=================
CSQC_ConsoleCommand

Can interject cmds and create new ones
=================
*/
float CSQC_ConsoleCommand( string sCMD ) {
	tokenize( sCMD );
	switch ( argv(0) )
	{
	case "buy":
		if( getstatf( STAT_BUYZONE ) == TRUE ) {
			fVGUI_Display = VGUI_BM_MAIN;
		}
		return TRUE;
    break;
    case "chooseteam":
		fVGUI_Display = VGUI_TEAMSELECT;
		return TRUE;
    break;
    case "use":
		sendevent( "PlayerUse", "" );
		return TRUE;
    break;
	}
  
	return FALSE;
}

/*
=================
CSQC_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
*/
void CSQC_Parse_Event( void ) {
	float fHeader = readbyte();
	
	if ( fHeader == EV_WEAPON_DRAW ) {
		Weapon_Draw( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_WEAPON_PRIMARYATTACK ) {
		Weapon_PrimaryAttack( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_WEAPON_SECONDARYATTACK ) {
		Weapon_SecondaryAttack( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_WEAPON_RELOAD ) {
		Weapon_Reload( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_MODELGIB ) {
		vector vPos;
		vPos_x = readcoord();
		vPos_y = readcoord();
		vPos_z = readcoord();
		
		vector vSize;
		vSize_x = readcoord();
		vSize_y = readcoord();
		vSize_z = readcoord();

		float fStyle = readbyte();
		Effect_BreakModel( vPos, vSize, '0 0 0', fStyle );
	} else if ( fHeader == EV_CAMERATRIGGER ) {

		vCameraPos_x = readcoord();
		vCameraPos_y = readcoord();
		vCameraPos_z = readcoord();

		vCameraAngle_x = readcoord();
		vCameraAngle_y = readcoord();
		vCameraAngle_z = readcoord();
		
		fCameraTime = time + readfloat();
	} else if ( fHeader == EV_RADIOMSG ) {
		Radio_BroadcastMessage( readbyte() );
	}
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
*/
float CSQC_InputEvent( float fEventType, float fKey, float fCharacter, float fDeviceID ) {
	if ( fEventType == IE_KEYDOWN ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 1;
		} else {
			fInputKeyDown = 1;
		}

		fInputKeyCode = fKey;
		fInputKeyASCII = fCharacter;
	} else if ( fEventType == IE_KEYUP ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 0;
		} else {
			fInputKeyDown = 0;
		}
		fInputKeyCode = 0;
		fInputKeyASCII = 0;
	} else if ( fEventType == IE_MOUSEABS ) {
		vMousePos_x = fKey;
		vMousePos_y = fCharacter;
	} 
	
	return FALSE;
}

/*
=================
CSQC_Input_Frame

Hijacks and controls what input globals are being sent to the server
=================
*/
void CSQC_Input_Frame( void ) {
	// If we are inside a VGUI, don't let the client do stuff outside
	if ( ( fVGUI_Display != VGUI_NONE ) ) {
		input_angles = '0 0 0';
		input_movevalues = '0 0 0';
		input_buttons = 0;
		input_impulse = 0;
	}
}
