/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include "text.h"
#include "textmenu.h"
#include "efx.h"
#include "font.h"
#include "fade.h"
#include "cmd.h"
#include "util.h"

/* flags for 2d drawing */
#define DRAWFLAG_NORMAL		0
#define DRAWFLAG_ADDITIVE	1
#define DRAWFLAG_MODULATE	2
#define DRAWFLAG_2XMODULATE	3

/* undocumented printcall types */
#define PRINT_LOW		0
#define PRINT_MEDIUM	1
#define PRINT_HIGH		2
#define PRINT_CHAT		3

const float MASK_GLOWS = 16;

/* fonts */
font_s FONT_16;
font_s FONT_20;
font_s FONT_CON;

//var string g_shellchrome;
var float g_shellchromeshader;
var float g_shellchromeshader_cull;

/* clientside cvars */
var float autocvar_zoom_sensitivity = 1.0f;
var int autocvar_cl_smoothstairs = TRUE;
var int autocvar_cl_thirdperson = FALSE;
var int autocvar_v_lefthanded = FALSE;
var string autocvar_cl_logofile = "lambda";
var vector autocvar_cl_logocolor = [255,0,0];
var vector autocvar_con_color = [255,150,0];
var vector autocvar_vgui_color = [255,170,0];
var vector autocvar_v_gunofs = [0,0,0];
var int autocvar_r_viewmodelpass = 0;
var float autocvar_r_viewmodelfov = 90.0f;
var float autocvar_r_viewmodelscale = 1.0f;
var float autocvar_cl_hudaspect = 0.0f;

/* particle descriptors */
var float PART_DUSTMOTE;
var float PART_BURNING;

/* muzzleflash indices */
var int MUZZLE_SMALL;
var int MUZZLE_RIFLE;
var int MUZZLE_WEIRD;

/* misc globals */
vector video_mins;
vector video_res;
vector mouse_pos;
int g_iIntermission;

/* this actually belongs in builtins.h since its an undocumented global */
float clframetime;

string(string modelname, int frame, float frametime) spriteframe = #0;

void CSQC_UpdateSeat(void);

void
drawstring_r(vector p, string t, vector s, vector c, float a, float f)
{
	p[0] -= stringwidth(t, TRUE, s);
	drawstring(p, t, s, c, a, f);
}

void GameMessage_Setup(string, int);
void View_SetMuzzleflash(int);

void Event_Callback(float mtime, __inout float btime);
void View_AddEvent(void(void) pCallback, float flTime);
void View_PlayAnimation(int);
void View_PlayAnimation(int);
void Event_ProcessModel(float, int, string);
void ClientGame_ModelEvent(float, int, string);

void View_EnableViewmodel(void);
void View_DisableViewmodel(void);

/* this really should be done in-engine */

void drawrect(vector pos, vector sz, float thickness, vector rgb, float al, optional float dfl)
{
	/* top */
	drawfill(pos, [sz[0], thickness], rgb, al, dfl);
	/* bottom */
	drawfill(pos + [0, sz[1] - thickness], [sz[0], thickness], rgb, al, dfl);
	/* left */
	drawfill(pos + [0, thickness], [thickness, sz[1] - (thickness * 2)], rgb, al, dfl);
	/* right */
	drawfill(pos + [sz[0] - thickness, thickness], [thickness, sz[1] - (thickness * 2)], rgb, al, dfl);
}

void
precache_cubemap(string path)
{
	precache_pic(strcat(path, "_bk"));
	precache_pic(strcat(path, "_dn"));
	precache_pic(strcat(path, "_ft"));
	precache_pic(strcat(path, "_lf"));
	precache_pic(strcat(path, "_rt"));
	precache_pic(strcat(path, "_up"));
}

struct
{
	/* viewmodel stuff */
	entity m_eViewModel;
	entity m_eMuzzleflash;
	int m_iVMBones;
	entity m_eViewModelL;
	entity m_eMuzzleflashL;
	int m_iVMBonesL;

	void(void) m_pEventCall;
	float m_flEventTime;
	float m_flEventFrame;
	float m_flEventMdl;

	int m_iLastWeapon;
	int m_iOldWeapon;

	/* damage overlay */
	float m_flDamageAlpha;
	vector m_vecDamagePos;
	int m_iDamageFlags;

	/* +zoomin cmd */
	int m_iZoomed;
	float m_flZoomTime;

	/* player fields */
	entity m_ePlayer;
	vector m_vecPredictedOrigin;
	vector m_vecPredictedOriginOld;
	vector m_vecPredictedVelocity;
	float m_flPredictedFlags;
	
	/* camera fields */
	vector m_vecCameraOrigin;
	vector m_vecCameraAngle;
	float m_flCameraTime;

	int m_iHUDWeaponSelected;
	float m_flHUDWeaponSelectTime;

	int m_iScoresVisible;

	/* saturn controller */
	int m_iSaturnMenu;

	/* centerprint related */
	float m_flCenterprintAlpha;
	float m_flCenterprintTime;
	float m_iCenterprintLines;
	string m_strCenterprintBuffer[18];

	/* chat related */
	float m_flPrintTime;
	string m_strPrintBuffer[5];
	int m_iPrintLines;

	int m_iInputAttack2;
	int m_iInputReload;
	int m_iInputUse;
	int m_iInputDuck;
	float m_flInputBlockTime;
	
	/* fading */
	float m_flFadeDuration;
	float m_flFadeHold;
	float m_flFadeMaxAlpha;
	float m_flFadeStyle;
	float m_flFadeAlpha;
	float m_flFadeTime;
	vector m_vecFadeColor;
	int m_iFadeActive;

	/* shake */
	float m_flShakeFreq;
	float m_flShakeDuration;
	float m_flShakeTime;
	float m_flShakeAmp;

	vector m_vecLag;

	/* vehicles */
	float m_flVehTransition;
	vector m_vecVehEntry;
} g_seats[4], *pSeat;
