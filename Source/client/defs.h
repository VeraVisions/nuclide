/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
var float FONT_20;
var float FONT_CON;

/* Clientside CVARS */

var vector autocvar_con_color = '255 150 0'; // autocvar of "con_color"
var vector autocvar_vgui_color = '255 170 0'; // autocvar of "vgui_color"

var float autocvar_cl_bob = 0;
var float autocvar_v_bob = 0.01;
var float autocvar_v_bobcycle = 0.8;
var float autocvar_v_bobup = 0.5;
var int autocvar_v_bobclassic = FALSE;
var vector autocvar_v_gunofs = [0,0,0];
var int autocvar_cl_thirdperson = FALSE;
var int autocvar_cl_smoothstairs = TRUE;
var int autocvar_v_lefthanded = FALSE;
var string autocvar_cl_logofile = "lambda";
var vector autocvar_cl_logocolor = '255 0 0';

// Particle stuff
var float PARTICLE_SPARK;
var float PARTICLE_PIECES_BLACK;
var float PARTICLE_SMOKE_GREY;
var float PARTICLE_SMOKE_BROWN;
var float PARTICLE_BLOOD;
var float DECAL_SHOT;
var float DECAL_GLASS;

var float SHADER_CULLED;

float fInputSendNext;

vector video_mins;
vector video_res;

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
vector mouse_pos;

// This actually belongs in builtins.h since its an undocumented global
float clframetime;


int(float playernum, string keyname, optional void *outptr, int size) getplayerkeyblob = #0;
