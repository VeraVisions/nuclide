/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/* flags for 2d drawing */
#define DRAWFLAG_NORMAL		0
#define DRAWFLAG_ADDITIVE	1
#define DRAWFLAG_MODULATE	2
#define DRAWFLAG_2XMODULATE	3

/* undocumented printcall types */
#define PRINT_LOW	0
#define PRINT_MEDIUM	1
#define PRINT_HIGH	2
#define PRINT_CHAT	3

/* fonts */
var float FONT_16;
var float FONT_20;
var float FONT_CON;

/* clientside cvars */
var float autocvar_cl_bob = 0;
var float autocvar_v_bob = 0.01;
var float autocvar_v_bobcycle = 0.8;
var float autocvar_v_bobup = 0.5;
var float autocvar_zoom_sensitivity = 1.0f;
var int autocvar_cl_smoothstairs = TRUE;
var int autocvar_cl_thirdperson = FALSE;
var int autocvar_v_bobclassic = TRUE;
var int autocvar_v_lefthanded = FALSE;
var string autocvar_cl_logofile = "lambda";
var vector autocvar_cl_logocolor = [255,0,0];
var vector autocvar_con_color = [255,150,0];
var vector autocvar_vgui_color = [255,170,0];
var vector autocvar_v_gunofs = [0,0,0];

/* particle descriptors */
var float PARTICLE_BLOOD;
var float PARTICLE_PIECES_BLACK;
var float PARTICLE_SMOKE_BROWN;
var float PARTICLE_SMOKE_GREY;
var float PARTICLE_SPARK;
var float DECAL_SHOT;
var float DECAL_GLASS;

/* muzzleflash indices */
var int MUZZLE_SMALL;
var int MUZZLE_RIFLE;
var int MUZZLE_WEIRD;

/* misc globals */
vector video_mins;
vector video_res;
vector mouse_pos;

/* TODO: Move these into gs-entbase/client/defs.h? */
vector g_vecSunDir;

/* this actually belongs in builtins.h since its an undocumented global */
float clframetime;

/* prototypes */
void View_SetMuzzleflash(int);
void View_UpdateWeapon(entity, entity);
void View_PlayAnimation(int);
void Game_Input(void);
