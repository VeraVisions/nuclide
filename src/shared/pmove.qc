/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#define CUSTOMPLAYERPHYSICS

#ifdef CUSTOMPLAYERPHYSICS
	void PMoveCustom_Init(void);
#endif

#ifndef PMOVE_STEPHEIGHT
	#define PMOVE_STEPHEIGHT 18.0f
#endif
var int autocvar_pm_stepsize = PMOVE_STEPHEIGHT;

#ifndef PMOVE_AIRSTEPHEIGHT
	#define PMOVE_AIRSTEPHEIGHT 18.0f
#endif
var int autocvar_pm_airstepsize = PMOVE_AIRSTEPHEIGHT;

#ifndef PMOVE_FRICTION
	#define PMOVE_FRICTION 4.0f
#endif
var float autocvar_pm_friction = PMOVE_FRICTION;

#ifndef PMOVE_EDGEFRICTION
	#define PMOVE_EDGEFRICTION 1.0f
#endif
var float autocvar_pm_edgefriction = PMOVE_EDGEFRICTION;

#ifndef PMOVE_STOPSPEED
	#define PMOVE_STOPSPEED 75.0f
#endif
var float autocvar_pm_stopspeed = PMOVE_STOPSPEED;

#ifndef PMOVE_GRAVITY
	#define PMOVE_GRAVITY 800.0f
#endif
var float autocvar_pm_gravity = PMOVE_GRAVITY;

#ifndef PMOVE_AIRACCELERATE
	#define PMOVE_AIRACCELERATE 10.0f
#endif
var float autocvar_pm_airaccelerate = PMOVE_AIRACCELERATE;

#ifndef PMOVE_WATERACCELERATE
	#define PMOVE_WATERACCELERATE 8.0f
#endif
var float autocvar_pm_wateraccelerate = PMOVE_WATERACCELERATE;

#ifndef PMOVE_ACCELERATE
	#define PMOVE_ACCELERATE 8.0f
#endif
var float autocvar_pm_accelerate = PMOVE_ACCELERATE;

#ifndef PMOVE_STEP_WALKSPEED
	#define PMOVE_STEP_WALKSPEED 190.0f
#endif
var float autocvar_pm_walkspeed = PMOVE_STEP_WALKSPEED;

#ifndef PMOVE_STEP_RUNSPEED
	#define PMOVE_STEP_RUNSPEED (PMOVE_STEP_WALKSPEED * 1.5f)
#endif
var float autocvar_pm_runspeed = PMOVE_STEP_RUNSPEED;

#ifndef PMOVE_STEP_CROUCHSPEED
	#define PMOVE_STEP_CROUCHSPEED (PMOVE_STEP_WALKSPEED * 0.65f)
#endif
var float autocvar_pm_crouchspeed = PMOVE_STEP_CROUCHSPEED;

#ifndef PMOVE_STEP_PRONESPEED
	#define PMOVE_STEP_PRONESPEED (PMOVE_STEP_WALKSPEED * 0.15f)
#endif
var float autocvar_pm_pronespeed = PMOVE_STEP_PRONESPEED;

/* stamina system, inspired by idTech 4 */
#ifndef PMOVE_STAMINA
	#define PMOVE_STAMINA 24.0f
#endif
var float autocvar_pm_stamina = PMOVE_STAMINA;

#ifndef PMOVE_STAMINARATE
	#define PMOVE_STAMINARATE 0.75f
#endif
var float autocvar_pm_staminarate = PMOVE_STAMINARATE;

#ifndef PMOVE_STAMINATHRESHOLD
	#define PMOVE_STAMINATHRESHOLD 4.0f
#endif
var float autocvar_pm_staminathreshold = PMOVE_STAMINATHRESHOLD;

#ifndef PMOVE_NOCLIPSPEED
	#define PMOVE_NOCLIPSPEED 500.0f
#endif
var float autocvar_pm_noclipspeed = PMOVE_NOCLIPSPEED;

#ifndef PMOVE_NOCLIPACCELERATE
	#define PMOVE_NOCLIPACCELERATE 5.0f
#endif
var float autocvar_pm_noclipaccelerate = PMOVE_NOCLIPACCELERATE;

#ifndef PMOVE_JUMP_HEIGHT
	#define PMOVE_JUMP_HEIGHT 240.0f
#endif
var float autocvar_pm_jumpheight = PMOVE_JUMP_HEIGHT;

#ifndef PMOVE_WATERJUMP_HEIGHT
	#define PMOVE_WATERJUMP_HEIGHT 350.0f
#endif
var float autocvar_pm_waterjumpheight = PMOVE_WATERJUMP_HEIGHT;

#ifndef PMOVE_BOXCENTER
	#define PMOVE_BOXCENTER true
#endif
var bool autocvar_pm_boxcenter = PMOVE_BOXCENTER;

#ifndef PMOVE_BOXWIDTH
	#define PMOVE_BOXWIDTH 32.0f
#endif
var float autocvar_pm_boxwidth = PMOVE_BOXWIDTH;

var float autocvar_pm_maxviewpitch = 89.0f;
var float autocvar_pm_minviewpitch = -89.0f;


#ifndef PMOVE_NORMAL_HEIGHT
	#define PMOVE_NORMAL_HEIGHT 74.0f
#endif
var float autocvar_pm_normalheight = PMOVE_NORMAL_HEIGHT;

#ifndef PMOVE_NORMAL_VIEWHEIGHT
	#define PMOVE_NORMAL_VIEWHEIGHT 68.0f
#endif
var float autocvar_pm_normalviewheight = PMOVE_NORMAL_VIEWHEIGHT;

#ifndef PMOVE_CROUCH_HEIGHT
	#define PMOVE_CROUCH_HEIGHT 38.0f
#endif
var float autocvar_pm_crouchheight = PMOVE_CROUCH_HEIGHT;

#ifndef PMOVE_CROUCH_VIEWHEIGHT
	#define PMOVE_CROUCH_VIEWHEIGHT 32.0f
#endif
var float autocvar_pm_crouchviewheight = PMOVE_CROUCH_VIEWHEIGHT;

#ifndef PMOVE_PRONE_HEIGHT
	#define PMOVE_PRONE_HEIGHT 20.0f
#endif
var float autocvar_pm_proneheight = PMOVE_PRONE_HEIGHT;

#ifndef PMOVE_PRONE_VIEWHEIGHT
	#define PMOVE_PRONE_VIEWHEIGHT 16.0f
#endif
var float autocvar_pm_proneviewheight = PMOVE_PRONE_VIEWHEIGHT;

#ifndef PMOVE_PRONE_RUNFIRING
	#define PMOVE_PRONE_RUNFIRING 1.0f
#endif
var float autocvar_pm_runfiring = PMOVE_PRONE_RUNFIRING;

/* if they're undefined by a config, they'll be set by the game/mod default */
var float autocvar_g_gravity = PMOVE_GRAVITY;
var bool autocvar_pm_nospeedcap = false;

/* these are not tied to cvars, because clients (cl) and bots (bot) select
separate cvars for overriding their speeds. */
#ifndef PMOVE_FORWARD_SPEED
	#define PMOVE_FORWARD_SPEED 190.0f
#endif

#ifndef PMOVE_SIDE_SPEED
	#define PMOVE_SIDE_SPEED 152.0f
#endif

#ifndef PMOVE_BACK_SPEED
	#define PMOVE_BACK_SPEED 133.0f
#endif

/* TODO: optimise. */
#define PMOVEVARS_UPDATE 1

void
ncPMoveVars::ncPMoveVars(void)
{
	m_defLink = __NULL__;
}

void
ncPMoveVars::UpdateBoundingBoxes(void)
{
	float halfWidth = pm_boxwidth * 0.5f;
	float halfHeight = pm_normalheight * 0.5f;
	m_vecStandingMins = [-halfWidth, -halfWidth, 0];
	m_vecStandingMaxs = [halfWidth, halfWidth, pm_normalheight];
	m_vecCrouchMins = [-halfWidth, -halfWidth, 0];
	m_vecCrouchMaxs = [halfWidth, halfWidth, pm_crouchheight];
	m_vecProneMins = [-halfHeight, -halfHeight, 0];
	m_vecProneMaxs = [halfHeight, halfHeight, pm_proneheight];

	m_vecNormalViewOffset =
	m_vecCrouchViewOffset =
	m_vecProneViewOffset = g_vec_null;

	m_vecNormalViewOffset[2] = pm_normalviewheight;
	m_vecCrouchViewOffset[2] = pm_crouchviewheight;
	m_vecProneViewOffset[2] = pm_proneviewheight;

	if (pm_boxcenter == true) {
		m_vecStandingMins[2] -= (pm_normalheight * 0.5f);
		m_vecStandingMaxs[2] -= (pm_normalheight * 0.5f);
		m_vecCrouchMins[2] -= (pm_crouchheight * 0.5f);
		m_vecCrouchMaxs[2] -= (pm_crouchheight * 0.5f);
		m_vecProneMins[2] -= (pm_proneheight * 0.5f);
		m_vecProneMaxs[2] -= (pm_proneheight * 0.5f);

		m_vecNormalViewOffset[2] -= (pm_normalheight * 0.5f);
		m_vecCrouchViewOffset[2] -= (pm_crouchheight * 0.5f);
		m_vecProneViewOffset[2] -= (pm_proneheight * 0.5f);
	}
}

void
ncPMoveVars::Refresh(void)
{
// 	printf("Refreshing pmove Vars %S\n", m_defLink);

	/* global. */
	if (!STRING_SET(m_defLink)) {
		UpdateBoundingBoxes();
		return;
	}

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "g_gravity")))
		g_gravity = stof(EntityDef_GetKeyValue(m_defLink, "g_gravity"));
	else
		g_gravity = g_pmoveVars.g_gravity;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_accelerate")))
		pm_accelerate = stof(EntityDef_GetKeyValue(m_defLink, "pm_accelerate"));
	else
		pm_accelerate = g_pmoveVars.pm_accelerate;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_airaccelerate")))
		pm_airaccelerate = stof(EntityDef_GetKeyValue(m_defLink, "pm_airaccelerate"));
	else
		pm_airaccelerate = g_pmoveVars.pm_airaccelerate;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_airstepsize")))
		pm_airstepsize = stof(EntityDef_GetKeyValue(m_defLink, "pm_airstepsize"));
	else
		pm_airstepsize = g_pmoveVars.pm_airstepsize;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_boxcenter")))
		pm_boxcenter = stof(EntityDef_GetKeyValue(m_defLink, "pm_boxcenter"));
	else
		pm_boxcenter = g_pmoveVars.pm_boxcenter;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_boxwidth")))
		pm_boxwidth = stof(EntityDef_GetKeyValue(m_defLink, "pm_boxwidth"));
	else
		pm_boxwidth = g_pmoveVars.pm_boxwidth;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_crouchheight")))
		pm_crouchheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_crouchheight"));
	else
		pm_crouchheight = g_pmoveVars.pm_crouchheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_crouchspeed")))
		pm_crouchspeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_crouchspeed"));
	else
		pm_crouchspeed = g_pmoveVars.pm_crouchspeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_crouchviewheight")))
		pm_crouchviewheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_crouchviewheight"));
	else
		pm_crouchviewheight = g_pmoveVars.pm_crouchviewheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_edgefriction")))
		pm_edgefriction = stof(EntityDef_GetKeyValue(m_defLink, "pm_edgefriction"));
	else
		pm_edgefriction = g_pmoveVars.pm_edgefriction;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_friction")))
		pm_friction = stof(EntityDef_GetKeyValue(m_defLink, "pm_friction"));
	else
		pm_friction = g_pmoveVars.pm_friction;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_gravity")))
		pm_gravity = stof(EntityDef_GetKeyValue(m_defLink, "pm_gravity"));
	else
		pm_gravity = g_pmoveVars.pm_gravity;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_jumpheight")))
		pm_jumpheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_jumpheight"));
	else
		pm_jumpheight = g_pmoveVars.pm_jumpheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_maxviewpitch")))
		pm_maxviewpitch = stof(EntityDef_GetKeyValue(m_defLink, "pm_maxviewpitch"));
	else
		pm_maxviewpitch = g_pmoveVars.pm_maxviewpitch;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_minviewpitch")))
		pm_minviewpitch = stof(EntityDef_GetKeyValue(m_defLink, "pm_minviewpitch"));
	else
		pm_minviewpitch = g_pmoveVars.pm_minviewpitch;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_noclipaccelerate")))
		pm_noclipaccelerate = stof(EntityDef_GetKeyValue(m_defLink, "pm_noclipaccelerate"));
	else
		pm_noclipaccelerate = g_pmoveVars.pm_noclipaccelerate;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_noclipspeed")))
		pm_noclipspeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_noclipspeed"));
	else
		pm_noclipspeed = g_pmoveVars.pm_noclipspeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_normalheight")))
		pm_normalheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_normalheight"));
	else
		pm_normalheight = g_pmoveVars.pm_normalheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_normalviewheight")))
		pm_normalviewheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_normalviewheight"));
	else
		pm_normalviewheight = g_pmoveVars.pm_normalviewheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_nospeedcap")))
		pm_nospeedcap = stof(EntityDef_GetKeyValue(m_defLink, "pm_nospeedcap"));
	else
		pm_nospeedcap = g_pmoveVars.pm_nospeedcap;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_proneheight")))
		pm_proneheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_proneheight"));
	else
		pm_proneheight = g_pmoveVars.pm_proneheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_pronespeed")))
		pm_pronespeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_pronespeed"));
	else
		pm_pronespeed = g_pmoveVars.pm_pronespeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_proneviewheight")))
		pm_proneviewheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_proneviewheight"));
	else
		pm_proneviewheight = g_pmoveVars.pm_proneviewheight;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_runspeed")))
		pm_runspeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_runspeed"));
	else
		pm_runspeed = g_pmoveVars.pm_runspeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_runfiring")))
		pm_runfiring = stof(EntityDef_GetKeyValue(m_defLink, "pm_runfiring"));
	else
		pm_runfiring = g_pmoveVars.pm_runfiring;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_stamina")))
		pm_stamina = stof(EntityDef_GetKeyValue(m_defLink, "pm_stamina"));
	else
		pm_stamina = g_pmoveVars.pm_stamina;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_staminarate")))
		pm_staminarate = stof(EntityDef_GetKeyValue(m_defLink, "pm_staminarate"));
	else
		pm_staminarate = g_pmoveVars.pm_staminarate;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_staminathreshold")))
		pm_staminathreshold = stof(EntityDef_GetKeyValue(m_defLink, "pm_staminathreshold"));
	else
		pm_staminathreshold = g_pmoveVars.pm_staminathreshold;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_stepsize")))
		pm_stepsize = stof(EntityDef_GetKeyValue(m_defLink, "pm_stepsize"));
	else
		pm_stepsize = g_pmoveVars.pm_stepsize;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_stopspeed")))
		pm_stopspeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_stopspeed"));
	else
		pm_stopspeed = g_pmoveVars.pm_stopspeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_walkspeed")))
		pm_walkspeed = stof(EntityDef_GetKeyValue(m_defLink, "pm_walkspeed"));
	else
		pm_walkspeed = g_pmoveVars.pm_walkspeed;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_wateraccelerate")))
		pm_wateraccelerate = stof(EntityDef_GetKeyValue(m_defLink, "pm_wateraccelerate"));
	else
		pm_wateraccelerate = g_pmoveVars.pm_wateraccelerate;

	if (STRING_SET(EntityDef_GetKeyValue(m_defLink, "pm_waterjumpheight")))
		pm_waterjumpheight = stof(EntityDef_GetKeyValue(m_defLink, "pm_waterjumpheight"));
	else
		pm_waterjumpheight = g_pmoveVars.pm_waterjumpheight;


	UpdateBoundingBoxes();
}

void
ncPMoveVars::LinkToEntity(string defName)
{
	m_defLink = defName;
	Refresh();

}

#ifdef SERVER
void
ncPMoveVars::EvaluateEntity(void)
{
	/* this is belonging to a decl */
	if (STRING_SET(m_defLink)) {
		return;
	}

	g_gravity = autocvar_g_gravity;
	pm_accelerate = autocvar_pm_accelerate;
	pm_airaccelerate = autocvar_pm_airaccelerate;
	pm_airstepsize = autocvar_pm_airstepsize;
	pm_boxcenter = autocvar_pm_boxcenter;
	pm_boxwidth = autocvar_pm_boxwidth;
	pm_crouchheight = autocvar_pm_crouchheight;
	pm_crouchspeed = autocvar_pm_crouchspeed;
	pm_crouchviewheight = autocvar_pm_crouchviewheight;
	pm_edgefriction = autocvar_pm_edgefriction;
	pm_friction = autocvar_pm_friction;
	pm_gravity = autocvar_pm_gravity;
	pm_jumpheight = autocvar_pm_jumpheight;
	pm_maxviewpitch = autocvar_pm_maxviewpitch;
	pm_minviewpitch = autocvar_pm_minviewpitch;
	pm_noclipaccelerate = autocvar_pm_noclipaccelerate;
	pm_noclipspeed = autocvar_pm_noclipspeed;
	pm_normalheight = autocvar_pm_normalheight;
	pm_normalviewheight = autocvar_pm_normalviewheight;
	pm_nospeedcap = autocvar_pm_nospeedcap;
	pm_proneheight = autocvar_pm_proneheight;
	pm_pronespeed = autocvar_pm_pronespeed;
	pm_proneviewheight = autocvar_pm_proneviewheight;
	pm_runspeed = autocvar_pm_runspeed;
	pm_runfiring = autocvar_pm_runfiring;
	pm_stamina = autocvar_pm_stamina;
	pm_staminarate = autocvar_pm_staminarate;
	pm_staminathreshold = autocvar_pm_staminathreshold;
	pm_stepsize = autocvar_pm_stepsize;
	pm_stopspeed = autocvar_pm_stopspeed;
	pm_walkspeed = autocvar_pm_walkspeed;
	pm_wateraccelerate = autocvar_pm_wateraccelerate;
	pm_waterjumpheight = autocvar_pm_waterjumpheight;

	EVALUATE_FIELD(g_gravity, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_accelerate, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_airaccelerate, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_airstepsize, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_boxcenter, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_boxwidth, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_crouchheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_crouchspeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_crouchviewheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_edgefriction, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_friction, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_gravity, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_jumpheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_maxviewpitch, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_minviewpitch, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_noclipaccelerate, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_noclipspeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_normalheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_normalviewheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_nospeedcap, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_proneheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_pronespeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_proneviewheight, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_runspeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_runfiring, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_stamina, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_staminarate, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_staminathreshold, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_stepsize, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_stopspeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_walkspeed, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_wateraccelerate, PMOVEVARS_UPDATE)
	EVALUATE_FIELD(pm_waterjumpheight, PMOVEVARS_UPDATE)
	UpdateBoundingBoxes();
}

bool
ncPMoveVars::SendEntity(entity pvsEnt, float flChanged)
{
	/* this is belonging to a decl */
	if (STRING_SET(m_defLink)) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_PMOVEVARS);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_FLOAT(g_gravity, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_accelerate, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_airaccelerate, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_airstepsize, PMOVEVARS_UPDATE)
	SENDENTITY_BYTE(pm_boxcenter, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_boxwidth, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_crouchheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_crouchspeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_crouchviewheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_edgefriction, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_friction, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_gravity, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_jumpheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_maxviewpitch, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_minviewpitch, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_noclipaccelerate, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_noclipspeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_normalheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_normalviewheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_nospeedcap, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_proneheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_pronespeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_proneviewheight, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_runspeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_runfiring, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_stamina, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_staminarate, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_staminathreshold, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_stepsize, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_stopspeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_walkspeed, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_wateraccelerate, PMOVEVARS_UPDATE)
	SENDENTITY_FLOAT(pm_waterjumpheight, PMOVEVARS_UPDATE)
	return (true);
}
#endif

#ifdef CLIENT
void
ncPMoveVars::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_FLOAT(g_gravity, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_accelerate, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_airaccelerate, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_airstepsize, PMOVEVARS_UPDATE)
	READENTITY_BYTE(pm_boxcenter, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_boxwidth, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_crouchheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_crouchspeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_crouchviewheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_edgefriction, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_friction, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_gravity, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_jumpheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_maxviewpitch, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_minviewpitch, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_noclipaccelerate, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_noclipspeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_normalheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_normalviewheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_nospeedcap, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_proneheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_pronespeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_proneviewheight, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_runspeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_runfiring, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_stamina, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_staminarate, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_staminathreshold, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_stepsize, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_stopspeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_walkspeed, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_wateraccelerate, PMOVEVARS_UPDATE)
	READENTITY_FLOAT(pm_waterjumpheight, PMOVEVARS_UPDATE)

	if (flNew) {
		g_pmoveVars = this;
	}

// 	printf("Refreshing all pmove vars.\n");

	for (ncPMoveVars vars = __NULL__;(vars = (ncPMoveVars)find(vars, ::classname, "ncPMoveVars"));) {
		vars.Refresh();
	}

}
#endif

vector
ncPMoveVars::GetStandingMins(void)
{
	return (m_vecStandingMins);
}

vector
ncPMoveVars::GetStandingMaxs(void)
{
	return (m_vecStandingMaxs);
}

vector
ncPMoveVars::GetCrouchMins(void)
{
	return (m_vecCrouchMins);
}

vector
ncPMoveVars::GetCrouchMaxs(void)
{
	return (m_vecCrouchMaxs);
}

vector
ncPMoveVars::GetProneMins(void)
{
	return (m_vecProneMins);
}

vector
ncPMoveVars::GetProneMaxs(void)
{
	return (m_vecProneMaxs);
}

vector
ncPMoveVars::GetStandingViewOffset(void)
{
	return (m_vecNormalViewOffset);
}

vector
ncPMoveVars::GetCrouchViewOffset(void)
{
	return (m_vecCrouchViewOffset);
}

vector
ncPMoveVars::GetProneViewOffset(void)
{
	return (m_vecProneViewOffset);
}

#ifdef SERVER
void
ncPMoveVars::Save(float handle)
{
	//super::Save(handle);

	SaveFloat(handle, "g_gravity", g_gravity);
	SaveFloat(handle, "pm_accelerate", pm_accelerate);
	SaveFloat(handle, "pm_airaccelerate", pm_airaccelerate);
	SaveFloat(handle, "pm_airstepsize", pm_airstepsize);
	SaveFloat(handle, "pm_boxcenter", pm_boxcenter);
	SaveFloat(handle, "pm_boxwidth", pm_boxwidth);
	SaveFloat(handle, "pm_crouchheight", pm_crouchheight);
	SaveFloat(handle, "pm_crouchspeed", pm_crouchspeed);
	SaveFloat(handle, "pm_crouchviewheight", pm_crouchviewheight);
	SaveFloat(handle, "pm_edgefriction", pm_edgefriction);
	SaveFloat(handle, "pm_friction", pm_friction);
	SaveFloat(handle, "pm_gravity", pm_gravity);
	SaveFloat(handle, "pm_jumpheight", pm_jumpheight);
	SaveFloat(handle, "pm_maxviewpitch", pm_maxviewpitch);
	SaveFloat(handle, "pm_minviewpitch", pm_minviewpitch);
	SaveFloat(handle, "pm_noclipaccelerate", pm_noclipaccelerate);
	SaveFloat(handle, "pm_noclipspeed", pm_noclipspeed);
	SaveFloat(handle, "pm_normalheight", pm_normalheight);
	SaveFloat(handle, "pm_normalviewheight", pm_normalviewheight);
	SaveFloat(handle, "pm_nospeedcap", pm_nospeedcap);
	SaveFloat(handle, "pm_proneheight", pm_proneheight);
	SaveFloat(handle, "pm_pronespeed", pm_pronespeed);
	SaveFloat(handle, "pm_proneviewheight", pm_proneviewheight);
	SaveFloat(handle, "pm_runspeed", pm_runspeed);
	SaveFloat(handle, "pm_runfiring", pm_runfiring);
	SaveFloat(handle, "pm_stamina", pm_stamina);
	SaveFloat(handle, "pm_staminarate", pm_staminarate);
	SaveFloat(handle, "pm_staminathreshold", pm_staminathreshold);
	SaveFloat(handle, "pm_stepsize", pm_stepsize);
	SaveFloat(handle, "pm_stopspeed", pm_stopspeed);
	SaveFloat(handle, "pm_walkspeed", pm_walkspeed);
	SaveFloat(handle, "pm_wateraccelerate", pm_wateraccelerate);
	SaveFloat(handle, "pm_waterjumpheight", pm_waterjumpheight);
}

void
ncPMoveVars::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "g_gravity":
		g_gravity = ReadFloat(setValue);
		break;
	case "pm_accelerate":
		pm_accelerate = ReadFloat(setValue);
		break;
	case "pm_airaccelerate":
		pm_airaccelerate = ReadFloat(setValue);
		break;
	case "pm_airstepsize":
		pm_airstepsize = ReadFloat(setValue);
		break;
	case "pm_boxcenter":
		pm_boxcenter = ReadFloat(setValue);
		break;
	case "pm_boxwidth":
		pm_boxwidth = ReadFloat(setValue);
		break;
	case "pm_crouchheight":
		pm_crouchheight = ReadFloat(setValue);
		break;
	case "pm_crouchspeed":
		pm_crouchspeed = ReadFloat(setValue);
		break;
	case "pm_crouchviewheight":
		pm_crouchviewheight = ReadFloat(setValue);
		break;
	case "pm_edgefriction":
		pm_edgefriction = ReadFloat(setValue);
		break;
	case "pm_friction":
		pm_friction = ReadFloat(setValue);
		break;
	case "pm_gravity":
		pm_gravity = ReadFloat(setValue);
		break;
	case "pm_jumpheight":
		pm_jumpheight = ReadFloat(setValue);
		break;
	case "pm_maxviewpitch":
		pm_maxviewpitch = ReadFloat(setValue);
		break;
	case "pm_minviewpitch":
		pm_minviewpitch = ReadFloat(setValue);
		break;
	case "pm_noclipaccelerate":
		pm_noclipaccelerate = ReadFloat(setValue);
		break;
	case "pm_noclipspeed":
		pm_noclipspeed = ReadFloat(setValue);
		break;
	case "pm_normalheight":
		pm_normalheight = ReadFloat(setValue);
		break;
	case "pm_normalviewheight":
		pm_normalviewheight = ReadFloat(setValue);
		break;
	case "pm_nospeedcap":
		pm_nospeedcap = ReadFloat(setValue);
		break;
	case "pm_proneheight":
		pm_proneheight = ReadFloat(setValue);
		break;
	case "pm_pronespeed":
		pm_pronespeed = ReadFloat(setValue);
		break;
	case "pm_proneviewheight":
		pm_proneviewheight = ReadFloat(setValue);
		break;
	case "pm_runspeed":
		pm_runspeed = ReadFloat(setValue);
		break;
	case "pm_runfiring":
		pm_runfiring = ReadFloat(setValue);
		break;
	case "pm_stamina":
		pm_stamina = ReadFloat(setValue);
		break;
	case "pm_staminarate":
		pm_staminarate = ReadFloat(setValue);
		break;
	case "pm_staminathreshold":
		pm_staminathreshold = ReadFloat(setValue);
		break;
	case "pm_stepsize":
		pm_stepsize = ReadFloat(setValue);
		break;
	case "pm_stopspeed":
		pm_stopspeed = ReadFloat(setValue);
		break;
	case "pm_walkspeed":
		pm_walkspeed = ReadFloat(setValue);
		break;
	case "pm_wateraccelerate":
		pm_wateraccelerate = ReadFloat(setValue);
		break;
	case "pm_waterjumpheight":
		pm_waterjumpheight = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}

void
ncPMoveVars::RestoreComplete(void)
{
	UpdateBoundingBoxes();

	/* HACK: potentially unreliable. mark our global one in the save... */
	if (!g_pmoveVars) {
		g_pmoveVars = this;
	}
}
#endif

void
PMove_Init(void)
{
	#ifdef SERVER
	if (!g_pmoveVars) {
		g_pmoveVars = spawn(ncPMoveVars);
		g_pmoveVars.pvsflags = PVSF_IGNOREPVS;
	}
	#endif

	#ifdef CUSTOMPLAYERPHYSICS
	PMoveCustom_Init();
	#endif

	g_waterDecl = ncDict::LoadDeclFromFile("water", "typeinfo/water.decl");
	g_slimeDecl = ncDict::LoadDeclFromFile("slime", "typeinfo/slime.decl");
	g_lavaDecl = ncDict::LoadDeclFromFile("lava", "typeinfo/lava.decl");
	g_fallDamageDecl = ncDict::LoadDeclFromFile("falldamage", "typeinfo/falldamage.decl");

	if (g_waterDecl.GetString("def_damage") == "") {
		g_waterDamageDecl = spawn(ncDict);
		g_waterDamageDecl.AddKey("damage", g_waterDecl.GetString("damage"));
	} else {
		g_waterDamageDecl = ncDict::LoadDeclFromFile(g_waterDecl.GetString("def_damage"), "typeinfo/water.decl");
	}

	if (g_slimeDecl.GetString("def_damage") == "") {
		g_slimeDamageDecl = spawn(ncDict);
		g_slimeDamageDecl.AddKey("damage", g_slimeDecl.GetString("damage"));
	} else {
		g_slimeDamageDecl = ncDict::LoadDeclFromFile(g_slimeDecl.GetString("def_damage"), "typeinfo/slime.decl");
	}

	if (g_lavaDecl.GetString("def_damage") == "") {
		g_lavaDamageDecl = spawn(ncDict);
		g_lavaDamageDecl.AddKey("damage", g_lavaDecl.GetString("damage"));
	} else {
		g_lavaDamageDecl = ncDict::LoadDeclFromFile(g_lavaDecl.GetString("def_damage"), "typeinfo/lava.decl");
	}

// 	printf("WATER DAMAGE: %i %i\n", g_waterDecl.GetInteger("damage"), g_waterDamageDecl.GetInteger("damage"));
// 	printf("SLIME DAMAGE: %i %i\n", g_slimeDecl.GetInteger("damage"), g_slimeDamageDecl.GetInteger("damage"));
// 	printf("LAVA DAMAGE: %i %i\n", g_lavaDecl.GetInteger("damage"), g_lavaDamageDecl.GetInteger("damage"));
}

/* simple bounds check */
bool
PMove_IsStuck(entity eTarget, vector testOrg, vector vecMins, vector vecMaxs)
{
	if (eTarget.solid != SOLID_SLIDEBOX) {
		return (0);
	}

	tracebox(testOrg, vecMins, vecMaxs, testOrg, MOVE_NORMAL, eTarget);
	return trace_startsolid;
}
