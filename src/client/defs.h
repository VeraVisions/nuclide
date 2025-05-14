/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#include "../platform/localize.h"
#include "api_func.h"
#include "../shared/api.h"
#include "../shared/entityDef.h"
#include "text.h"
#include "textmenu.h"
#include "font.h"
#include "fade.h"
#include "cmd.h"
#include "util.h"
#include "View.h"
#include "Radar.h"
#include "crosshair.h"
#include "hud.h"

var bool g_net_debug = false;
var bool g_cheats = false;

var float g_modelSpinAngle;
var float g_modelSpinPitch;
var float g_modelSpinRoll;
var float g_modelBobHeight;
var float autocvar_cg_modelSpinSpeed = 120.0f;
var float autocvar_cg_modelSpinRoll = 0.0f;
var float autocvar_cg_modelSpinRollSpeed = 0.0f;
var float autocvar_cg_modelSpinPitch = 0.0f;
var float autocvar_cg_modelSpinPitchSpeed = 0.0f;
var float autocvar_cg_modelBobHeight = 0.0f;
var float autocvar_cg_modelBobHeightSpeed = 0.0f;

var bool autocvar_net_showUpdates = false;

var bool g_clientInitialized = false;

#define PRINTFLAG(x) if (autocvar_net_showUpdates || g_net_debug) \
	print(sprintf("%f %s read update %s\n", time, classname, #x));

#define READENTITY_BYTE(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readbyte();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_SHORT(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readshort();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_FLOAT(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readfloat();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_INT(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readint();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_STRING(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readstring();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_COORD(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readcoord();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_ANGLE(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readangle();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_ENTITY(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = findentity(world, ::entnum, readentitynum());\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_ENTNUM(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readentitynum();\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_COLOR(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readbyte() / 255;\
		PRINTFLAG(changedflag); \
	}\
}

#define READENTITY_MODELINDEX(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = readshort();\
		PRINTFLAG(changedflag); \
	}\
}

/* undocumented printcall types */
#define PRINT_LOW		0
#define PRINT_MEDIUM	1
#define PRINT_HIGH		2
#define PRINT_CHAT		3

var bool g_dlight_cached = false;
var bool g_client_world_loaded = false;

const float MASK_GLOWS = 16;
var bool g_focus;
bool Util_IsFocused(void);

/* fonts */
font_s FONT_16;
font_s FONT_20;
font_s FONT_CON;
font_s FONT_CENTERPRINT;

//var string g_shellchrome;
var float g_shellchromeshader;
var float g_shellchromeshader_cull;

/* clientside cvars */
var float autocvar_in_zoomSensitivity = 1.0f;
var int autocvar_pm_stairSmoothing = TRUE;
var int autocvar_pm_thirdPerson = FALSE;
var int autocvar_cg_viewmodelFlip = FALSE;
var vector autocvar_con_color = [255,150,0];
var vector autocvar_vgui_color = [255,170,0];
var vector autocvar_cg_viewmodelOffset = [0,0,0];
var int autocvar_cg_viewmodelPass = 0;
var float autocvar_cg_viewmodelFov = 90.0f;
var float autocvar_cg_viewmodelScale = 1.0f;
var float autocvar_cg_hudAspect = 0.0f;
var bool autocvar_pm_crouchToggle = false;

/* particle descriptors */
var float PART_DUSTMOTE;
var float PART_BURNING;

/* misc globals */
vector video_mins;
vector g_vidsize;
int g_iIntermission;

/* this actually belongs in builtins.h since its an undocumented global */
float clframetime;

string(string modelname, int frame, float frametime) spriteframe = #0;

void CSQC_UpdateSeat(void);

/** Like drawstring() but aligns text to the right from the specified screen coordinates. */
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

void View_EnableViewmodel(void);
void View_DisableViewmodel(void);
void View_SetViewmodelSkin(float);

/** Draws a non-filled rectangle with a specified outline. */
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

/** Like drawpic, but instead of screen coords, it will take world coords.
Will project the 2D image relative to the active ncView that we're currently
rendering in (g_view). So it may only be called within certain contexts. */
void
drawpic3d(vector worldpos, string mat, vector sz, vector rgb, float alpha)
{
	static bool
	drawpic3d_visible(vector p1) {
		vector delta;
		float fov;
		vector p2 = g_view.GetCameraOrigin();
		vector ang = g_view.GetCameraAngle();

		makevectors(ang);
		delta = normalize (p1 - p2);
		fov = delta * v_forward;

		if (fov > (g_view.GetAFOV()/180)) {
			traceline(p2, p1, MOVE_WORLDONLY, self);
			if (trace_fraction == 1.0) {
				return (1);
			}
		}
		return (0);
	}

	if (drawpic3d_visible(worldpos) == true) {
		vector vecProj = project(worldpos) - (sz/2);
		drawpic(vecProj, mat, sz, rgb, alpha);
	}
}

/** Draws a (debug) cone in 3D space. */
void
drawcone(vector vecOrigin, vector vecAngle, int iDivisions, float flLength, float flRadius, vector vecColor, float flAlpha)
{
	vector c;
	vector e0;
	vector e1;
	float angDelta;

	static vector
	perpendicularCross(vector v)
	{
		float min = fabs(v[0]);
		vector ca = [1, 0, 0];

		if (fabs(v[1]) < min) {
			min = fabs(v.y);
			ca = [0, 1, 0];
		}

		if (fabs(v[2]) < min) {
			ca = [0, 0, 1];
		}

		return crossproduct(v, ca);
	}

	makevectors(vecAngle + [0, 0, 0]);
	vecAngle = v_forward * -1;
	c = vecOrigin + (-vecAngle * flLength);
	e0 = perpendicularCross(vecAngle);
	e1 = crossproduct(e0, vecAngle);
	angDelta = 360.0 / (iDivisions-1) * (M_PI / 180.0f);

    R_BeginPolygon("debugcone");
    R_PolygonVertex(vecOrigin, [0,0], vecColor, flAlpha);
    for (int i = 0; i < iDivisions; ++i) {
		vector vecPoint;
		float rad = angDelta * i;
		vecPoint = c + (((e0 * cos(rad)) + (e1 * sin(rad))) * flRadius);
		R_PolygonVertex(vecPoint, [0,0], vecColor, flAlpha);
    }
    R_EndPolygon();
}

/** Like precache_pic, but will precache sky/cube map images (_bk, _dn etc.) */
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

typedef enum
{
	STANCE_DEFAULT = 0,
	STANCE_CROUCH = 1,
	STANCE_PRONE = 2,
} movementStance_t;

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
	entity m_iEventEntity;

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

	bool m_iInputAttack;
	bool m_iInputAttack2;
	bool m_iInputReload;
	bool m_iInputUse;
	bool m_iInputDuck;
	bool m_iInputSprint;
	bool m_iInputProne;
	bool m_iInputJump;
	movementStance_t m_dForceStance;
	float m_flInputBlockTime;
	
	/* fading */
	float m_flFadeDuration;
	float m_flFadeHold;
	float m_flFadeMaxAlpha;
	float m_flFadeStyle;
	float m_flFadeAlpha;
	float m_flFadeTime;
	float m_flSprintLerp;
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

	/* new XR helpers */
	bool m_bMoveForward;

	bool m_bInterfaceFocused;
	bool m_bSpecInput;

	int m_iLeanDir;
	float m_flLeaning;
	int m_iSprinting;

	int m_iSelectedWeapon;
	bool m_bCommandMenu;
} g_seats[4], *pSeat;

.float modelindex2;
.float modelindex3;
.float modelindex4;

var vector g_vecMousePos;
var vector g_hudmins;
var vector g_hudres;

var ncRadar g_overview;

/** @defgroup cliententity Entities that are client-side
 *  @ingroup client
 *  @ingroup entities
 *  Entity classes that run entirely on the client.
 */
