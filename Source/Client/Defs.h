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

// flags for 2d drawing
#define DRAWFLAG_NORMAL	0
#define DRAWFLAG_ADDITIVE 1
#define DRAWFLAG_MODULATE 2
#define DRAWFLAG_2XMODULATE 3

vector autocvar_con_color; // autocvar of "con_color"
vector autocvar_vgui_color; // autocvar of "vgui_color"
vector autocvar_cross_color; // autocvar of "cross_color"

vector vHUDColor; // Defined in HUD_Draw (HUD.c)
vector vVGUIColor; // Defined in HUD_Draw (VGUI.c)
vector vCrossColor; // Defined in HUD_Draw (HUDCrosshair.c)

float fVGUI_Display; // The VGUI menu currently being drawn

vector vVideoResolution; // Updated every frame

// Input globals, feel free to use them since they are updated upon input
float fInputKeyCode;
float fInputKeyASCII;
float fInputKeyDown;

// Input globals for the mouse
float fMouseClick;
vector vMousePos;

// Sound Stuff
.string sSoundSample;
.float fVolume;

// Camera Fields
//entity ePlayerEnt;
vector vCameraPos;
vector vCameraAngle;
float fCameraTime;

void View_PlayAnimation( int iSequence );
void Sound_Delayed( string sSample, float fVol, float fDelay );

// This actually belongs in Builtins.h since its an undocumented global
vector pmove_vel;
