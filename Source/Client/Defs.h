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

// flags for 2d drawing
#define DRAWFLAG_NORMAL	0
#define DRAWFLAG_ADDITIVE 1
#define DRAWFLAG_MODULATE 2
#define DRAWFLAG_2XMODULATE 3

// Undocumented printcall types
#define	PRINT_LOW		0
#define	PRINT_MEDIUM	1
#define	PRINT_HIGH		2
#define	PRINT_CHAT		3

var float FONT_16;

// Clientside cvars
var vector autocvar_con_color = '255 128 0'; // autocvar of "con_color"
var vector autocvar_vgui_color = '255 128 0'; // autocvar of "vgui_color"
var vector autocvar_cross_color = '0 255 0'; // autocvar of "cross_color"
var float autocvar_cl_bob = 0.01;
var float autocvar_cl_bobcycle = 0.8;
var float autocvar_cl_bobup = 0.5;
var float autocvar_cl_bobclassic = 0;

// Particle stuff
var float PARTICLE_SPARK;
var float PARTICLE_PIECES_BLACK;
var float PARTICLE_SMOKE_GREY;
var float PARTICLE_SMOKE_BROWN;
var float PARTICLE_BLOOD;
var float DECAL_SHOT;
var float DECAL_GLASS;

vector vHUDColor; // Defined in HUD_Draw (HUD.c)
vector vVGUIColor; // Defined in HUD_Draw (VGUI.c)
vector vCrossColor; // Defined in HUD_Draw (HUDCrosshair.c)

float fVGUI_Display; // The VGUI menu currently being drawn
float fInputSendNext;

vector vVideoResolution; // Updated every frame

// Input globals, feel free to use them since they are updated upon input
float fInputKeyCode;
float fInputKeyASCII;
float fInputKeyDown;

var int iInputAttack2;
var int iInputReload;
var int iInputUse;
var int iInputDuck;

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

vector vPlayerOrigin;
vector vPlayerOriginOld;
vector vPlayerVelocity;

void View_PlayAnimation( int iSequence );

// This actually belongs in Builtins.h since its an undocumented global
vector pmove_vel;
.float weapon;
.float maxframe;

// For the player entity
.entity eGunModel;
float fWeaponEventPlayer;
.float fWeaponLast;
.float fWeaponBoneID;

void Animation_ShootWeapon( entity ePlayer );
void Animation_ReloadWeapon( entity ePlayer );

void CSQC_DrawText( vector vPos, string sString, vector vSize, vector vColor, float fAlpha, float fFlags, float fFont ) {
	drawfont = fFont;
	drawstring( vPos, sString, vSize, vColor, fAlpha, fFlags );
}