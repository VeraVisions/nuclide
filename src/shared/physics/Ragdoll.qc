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

void
ncRagdoll::ncRagdoll(void)
{
	m_morphTime = 1.0f;
}

void
ncRagdoll::OnRemoveEntity(void)
{
	skel_ragupdate(this, "cleardoll", 0);

	/* decouple */
	if (skeletonindex) {
		skel_delete(skeletonindex);
		skeletonindex = 0;
	}

	modelindex = 0;
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	ClearVelocity();
}

void
ncRagdoll::CreateRagdoll(void)
{

	skeletonindex = skel_create(modelindex);
	skel_build(skeletonindex, this, modelindex, 0, 0, 0, 1);

#if 0
	string dollString = GetPropData(PROPINFO_DOLL);
	printf("Doll file:\n");
	printf(dollString);
	printf("\n");

	if (STRING_SET(dollString))
		skel_ragupdate(this, strcat("dollstring ", dollString), 0);
	else
#else
		if (fileExists(strcat(modelnameforindex(modelindex), ".doll")))
			skel_ragupdate(this, strcat("doll ", modelnameforindex(modelindex), ".doll"), 0);
		else
#endif
		skel_ragupdate(this, "doll models/rt2/human.doll", 0);

	skel_ragupdate(this, "animate 0", 0);
	m_morphTime = 1.0f;
}

#ifdef SERVER
void
ncRagdoll::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, RDENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, RDENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, RDENT_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, RDENT_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, RDENT_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, RDENT_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(colormap, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(flags, RDENT_CHANGED_FLAGS)
	EVALUATE_FIELD(modelflags, RDENT_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, RDENT_CHANGED_SIZE)
	EVALUATE_FIELD(frame, RDENT_CHANGED_FRAME)
	EVALUATE_FIELD(frame1time, RDENT_CHANGED_FRAME)
	EVALUATE_FIELD(skin, RDENT_CHANGED_SKIN)
	EVALUATE_FIELD(effects, RDENT_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_geomsetField, RDENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 0, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 1, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 2, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_renderMode, RDENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_renderFX, RDENT_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_renderColor, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_renderAmount, RDENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_studioBoneController1, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController2, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController3, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController4, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController5, RDENT_CHANGED_CONTROLLER)
}

/* Make sure StartFrame calls this */
float
ncRagdoll::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex && solid == SOLID_NOT)
		return (0);

	WriteByte(MSG_ENTITY, ENT_RAGDOLL);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~RDENT_CHANGED_VELOCITY;
			flChanged &= ~RDENT_CHANGED_ANGULARVELOCITY;
		}

		/* no rendermode means no extra fields */
		if (m_renderMode == RM_NORMAL && m_renderFX == RFX_NORMAL) {
			flChanged &= ~RDENT_CHANGED_RENDERMODE;
			//flChanged &= ~RDENT_CHANGED_RENDERCOLOR; /* glowmod needs this */
			flChanged &= ~RDENT_CHANGED_RENDERAMT;
		}

		if (m_modelBrushBased == true) {
			flChanged &= ~RDENT_CHANGED_FLAGS;
			flChanged &= ~RDENT_CHANGED_BODY;
			flChanged &= ~RDENT_CHANGED_SCALE;
			flChanged &= ~RDENT_CHANGED_CONTROLLER;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], RDENT_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], RDENT_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], RDENT_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], RDENT_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], RDENT_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], RDENT_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, RDENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(colormap, RDENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, RDENT_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, RDENT_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], RDENT_CHANGED_SIZE)
	SENDENTITY_FLOAT(frame, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_geomsetField, RDENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[0], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[1], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[2], RDENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_renderMode, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderFX, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_COLOR(m_renderColor[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_renderColor[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_renderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_renderAmount, RDENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_studioBoneController1, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController2, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController3, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController4, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController5, RDENT_CHANGED_CONTROLLER)

	return (1);
}
#else
/*
============
ncRagdoll::ReceiveEntity
============
*/
void
ncRagdoll::ReceiveEntity(float flNew, float flChanged)
{
	vector oldVelocity = velocity;
	READENTITY_COORD(origin[0], RDENT_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], RDENT_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], RDENT_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], RDENT_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], RDENT_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], RDENT_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(colormap, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_INT(flags, RDENT_CHANGED_FLAGS)
	READENTITY_INT(modelflags, RDENT_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], RDENT_CHANGED_SIZE)
	READENTITY_COORD(mins[1], RDENT_CHANGED_SIZE)
	READENTITY_COORD(mins[2], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], RDENT_CHANGED_SIZE)
	READENTITY_FLOAT(frame, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	READENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	READENTITY_SHORT(m_geomsetField, RDENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[0], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[1], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[2], RDENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_renderMode, RDENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderFX, RDENT_CHANGED_RENDERMODE)
	READENTITY_COLOR(m_renderColor[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_renderColor[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_renderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_renderAmount, RDENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_studioBoneController1, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController2, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController3, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController4, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController5, RDENT_CHANGED_CONTROLLER)

	movetype = MOVETYPE_PHYSICS;

	if (flNew == false) {
		velocity = oldVelocity;
	}

	if (!skeletonindex && modelindex) {
		CreateRagdoll();
	}

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & RDENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & RDENT_CHANGED_BODY)
		_UpdateGeomset();
	if (flChanged & RDENT_CHANGED_MODELINDEX)
		_UpdateBoneCount();
}

float
ncRagdoll::predraw(void)
{
	if (!modelindex || !skeletonindex) {
		return (PREDRAW_NEXT);
	}

	frame1time += frametime;
	frame2time += frametime;
	lerpfrac = 0.0;
	skel_build(this.skeletonindex, this, this.modelindex, 0, 0, 0, 1);
	skel_ragupdate(this, "", m_morphTime);
	addentity(this);

	m_morphTime -= frametime * 0.25f;

	if (m_morphTime < 0.0f)
		m_morphTime = 0.0f;

	if (frame1time >= 10.0f) {
		OnRemoveEntity();
	}

	return (PREDRAW_NEXT);
}

void
ncRagdoll_Create(string modelFile)
{
	ncRagdoll rag = spawn(ncRagdoll);
	rag.Spawn();
	rag.SetMovetype(MOVETYPE_PHYSICS);
	rag.drawmask = MASK_ENGINE;
	rag.SetSolid(SOLID_CORPSE);
	rag.SetOrigin(g_view.GetCameraOrigin());

	if (STRING_SET(modelFile))
		rag.SetModel(modelFile);
	else
		rag.SetModel("models/police.mdl");

	//rag.m_propdataID = PropData_ForModel(rag.model);
	rag.CreateRagdoll();
}
#endif
