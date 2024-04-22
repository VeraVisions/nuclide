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

.float waterlevel;
.float watertype;
.float maxspeed;
.vector view_ofs;
int trace_endcontentsi;
.vector basevelocity;
.entity groundentity;

typedef enum
{
	WATERLEVEL_OUTSIDE,
	WATERLEVEL_KNEE,
	WATERLEVEL_CHEST,
	WATERLEVEL_SUBMERGED
} waterlevel_t;


/** This class networks pmove related variables to each client. */
class
NSPMoveVars:NSEntity
{
public:
	void NSPMoveVars(void);

	NETWORKED_FLOAT(g_gravity)
	NETWORKED_FLOAT(pm_accelerate)
	NETWORKED_FLOAT(pm_airaccelerate)
	NETWORKED_FLOAT(pm_airstepsize)
	NETWORKED_FLOAT(pm_boxcenter)
	NETWORKED_FLOAT(pm_boxwidth)
	NETWORKED_FLOAT(pm_crouchheight)
	NETWORKED_FLOAT(pm_crouchspeed)
	NETWORKED_FLOAT(pm_crouchviewheight)
	NETWORKED_FLOAT(pm_edgefriction)
	NETWORKED_FLOAT(pm_friction)
	NETWORKED_FLOAT(pm_gravity)
	NETWORKED_FLOAT(pm_jumpheight)
	NETWORKED_FLOAT(pm_maxviewpitch)
	NETWORKED_FLOAT(pm_minviewpitch)
	NETWORKED_FLOAT(pm_noclipaccelerate)
	NETWORKED_FLOAT(pm_noclipspeed)
	NETWORKED_FLOAT(pm_normalheight)
	NETWORKED_FLOAT(pm_normalviewheight)
	NETWORKED_FLOAT(pm_nospeedcap)
	NETWORKED_FLOAT(pm_proneheight)
	NETWORKED_FLOAT(pm_pronespeed)
	NETWORKED_FLOAT(pm_proneviewheight)
	NETWORKED_FLOAT(pm_runspeed)
	NETWORKED_FLOAT(pm_stamina)
	NETWORKED_FLOAT(pm_staminarate)
	NETWORKED_FLOAT(pm_staminathreshold)
	NETWORKED_FLOAT(pm_stepsize)
	NETWORKED_FLOAT(pm_stopspeed)
	NETWORKED_FLOAT(pm_walkspeed)
	NETWORKED_FLOAT(pm_wateraccelerate)
	NETWORKED_FLOAT(pm_waterjumpheight)

	/** Returns the standing player collision box mins. Calculated from pm_normalheight. */
	nonvirtual vector GetStandingMins(void);
	/** Returns the standing player collision box maxs. */
	nonvirtual vector GetStandingMaxs(void);
	/** Returns the standing player view offset. Calculated from pm_normalviewheight and pm_boxcenter. */
	nonvirtual vector GetStandingViewOffset(void);
	/** Returns the crouching/ducked player collision box mins. */
	nonvirtual vector GetCrouchMins(void);
	/** Returns the crouching/ducked player collision box maxs. */
	nonvirtual vector GetCrouchMaxs(void);
	/** Returns the crouching/ducked player view offset. Calculated from pm_crouchviewheight and pm_boxcenter. */
	nonvirtual vector GetCrouchViewOffset(void);
	/** Returns the prone player collision box maxs. */
	nonvirtual vector GetProneMins(void);
	/** Returns the prone player collision box maxs. */
	nonvirtual vector GetProneMaxs(void);
	/** Returns the prone player view offset. Calculated from pm_proneviewheight and pm_boxcenter. */
	nonvirtual vector GetProneViewOffset(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual bool SendEntity(entity, float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
#endif

private:
	nonvirtual void UpdateBoundingBoxes(void);

	vector m_vecStandingMins;
	vector m_vecStandingMaxs;
	vector m_vecCrouchMins;
	vector m_vecCrouchMaxs;
	vector m_vecProneMins;
	vector m_vecProneMaxs;
	vector m_vecNormalViewOffset;
	vector m_vecCrouchViewOffset;
	vector m_vecProneViewOffset;
};

/** The global, shared object containing all currently valid pmove parameters. */
NSPMoveVars g_pmoveVars;

/** Called by Nuclide. Sets up g_pmoveVars. */
void PMove_Init(void);

void PMoveCustom_RunPlayerPhysics(entity);
void PMoveCustom_RunCrouchPhysics(entity);