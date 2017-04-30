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

#define KEY_UNKNOWN 		-1
#define KEY_GAME 			0
#define KEY_MENU 			2
#define KEY_MENU_GRABBED 	3

#define TARGET_MENU 	1
#define TARGET_CLIENT 	2

var vector vVideoAspect;
var vector vVideoSize;
var vector vMenuSize;
var int iMenuPadding;

var vector vMousePos;
var float fInputKeyCode;
var float fInputKeyASCII;
var float fInputKeyDown;
var float fMouseClick;

var int iMenuActive;

var float fMenuScale;

float frametime;
float fLastTime;

string *sMapList;
int iMapCount;

/*
=================
gcd_r

Returns the greatest common denominator
=================
*/
int gcd_r( float a, float b ) {
  if ( a == 0 ) { 
	  return b;
  }
  
  return gcd_r( floor( b%a ), a );
}

/*
=================
Menu_Util_GetAspect

Returns the aspect ratio for the current mode.
=================
*/
vector Menu_Util_GetAspect( vector vResolution ) {
	int r = gcd_r( vResolution_x, vResolution_y );
	return [ vResolution_x/r, vResolution_y/r ];
}

/*
=================
Menu_Util_GetAspectSize

Returns the menu size for the given ratio.
=================
*/
vector Menu_Util_GetMenuSize( vector vAspect ) {
	float fScale = ( vAspect_x / vAspect_y );
	
		return [ rint( 480 * fScale ), 480 ];
	
}

/*
=================
Menu_Util_GetMenuPadding

Returns the padding size for the current ratio.
=================
*/
int Menu_Util_GetMenuPadding( void ) {
	return ( vMenuSize_x - 640 ) / 2;
}
