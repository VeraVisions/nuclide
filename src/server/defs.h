/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

#define CLASSEXPORT(classname,classa) void classname(void) { spawnfunc_##classa(); }

var int autocvar_mp_flashlight = TRUE;
var int g_hlbsp_materials = FALSE;

void FX_Impact(int iType, vector vecPos, vector vNormal);
void FX_Explosion(vector vecPos);
void FX_GibHuman(vector vecPos);
void Footsteps_Update(void);
void Vox_Broadcast(string sMessage);
void TraceAttack_FireBullets(int , vector, int, vector, int);
void Damage_Radius(vector, entity, float, float, int, int);
void Damage_Apply(entity, entity, float, int, int);
void Client_TriggerCamera(entity eTarget, vector vecPos, vector vEndPos, float fResetTime);
void Client_FixAngle(entity, vector);
void Game_Input(void);
int Rules_IsTeamPlay(void);

entity eActivator;
entity g_eAttacker;

/* Generic entity fields */
.void(void) PlayerUse;
.int iBleeds;
.entity eUser;
.float material;
.float armor;
.float deaths;
.float fStepTime;

/* in idTech the .owner field causes collisions to fail against set entity,
 * we don't want this all of the time. so use this as a fallback */
.entity real_owner;

int trace_surfaceflagsi;
string startspot;
string __fullspawndata;
hashtable hashMaterials;

.float gflags;

enumflags
{
	GF_CANRESPAWN,
	GF_USE_RELEASED,
	GF_IN_VEHICLE,
	GF_FROZEN,
	GF_SEMI_TOGGLED,
	GF_GAMESTARTS
};
