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
ncRenderableEntity::ncRenderableEntity(void)
{
	m_renderMode = RM_NORMAL;
	m_renderFX = RFX_NORMAL;
	m_renderColor[0] = 255;
	m_renderColor[1] = 255;
	m_renderColor[2] = 255;
	m_renderAmount = 0;
	m_studioBoneController1 = 0.5f;
	m_studioBoneController2 = 0.5f;
	m_studioBoneController3 = 0.5f;
	m_studioBoneController4 = 0.5f;
	m_studioBoneController5 = 0.5f;
	m_geomsetField = 0i;
	m_axialScale = [1,1,1];

	effects |= EF_NOSHADOW;

	m_iMuzzleModel = 0i;
	m_flMuzzleScale = 0.25f;

#ifdef CLIENT
	drawmask = MASK_ENGINE;
#endif
}

#ifdef CLIENT
void ncRenderableEntity::ReloadVideoResources( void ) {
	_UpdateGeomset();
}

void ncRenderableEntity::_UpdateGeomset(void)
{
	/* unpack our half bytes */
	int firstBody = (m_geomsetField & 0x0F);
	int secondBody = ((m_geomsetField >> 4) & 0x0F);
	int thirdBody = ((m_geomsetField >> 8) & 0x0F);
	int fourthBody = ((m_geomsetField >> 12) & 0x0F);

	//print(sprintf("%i body 0: %i body 1: %i body 2: %i body 3: %i\n", m_geomsetField , firstBody, secondBody, thirdBody, fourthBody));

	setcustomskin(this, "",
		sprintf("geomset 0 %i\ngeomset 1 %i\ngeomset 2 %i\ngeomset 3 %i\n", firstBody, secondBody, thirdBody, fourthBody)
	);
}
#endif

void
ncRenderableEntity::_UpdateBoneCount(void)
{
	if (!modelindex) {
		return;
	}

	skeletonindex = skel_create(modelindex);
	m_iNumBones = skel_get_numbones(skeletonindex) + 1;
	//print(sprintf("UPDATED GEOMSET FOR MODELINDEX %d, %d BONES\n", modelindex, m_iNumBones));
	skel_delete(skeletonindex);
	skeletonindex = 0;
}

/*
============
ncRenderableEntity::MakeStatic

after this gets called the entity is unreachable in the QC-logic
and merged with the world to optimise drawcalls

we usually want to do this with most decorative ents without
a valid targetname
============
*/
void
ncRenderableEntity::MakeStatic(void)
{
#ifdef CLIENT
	/* give renderFX the opportunity to write into renderable
	 * fields at least once before forever pulling it out the cgame */
	if (m_renderMode > RM_FULLBRIGHT)
		return;

	RenderFXPass();

	/* static ents = no collision, so let's make a copy for visibility */
	if (alpha > 0.0)
		makestatic(copyentity(this));

	/* now *this* is only used for csqc collision */
	drawmask = 0;
#endif
}

#ifdef SERVER
void
ncRenderableEntity::EvaluateEntity(void)
{
	if (m_modelBrushBased == true) {
		frame1time = 0.0f;
		frame1time_net = 0.0f;
		m_studioBoneController1 = m_studioBoneController1_net = 0.5f;
		m_studioBoneController2 = m_studioBoneController2_net = 0.5f;
		m_studioBoneController3 = m_studioBoneController3_net = 0.5f;
		m_studioBoneController4 = m_studioBoneController4_net = 0.5f;
		m_studioBoneController5 = m_studioBoneController5_net = 0.5f;
	}

	EVALUATE_VECTOR(origin, 0, RDENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, RDENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, RDENT_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, RDENT_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, RDENT_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, RDENT_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(colormap, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
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
ncRenderableEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex && solid == SOLID_NOT)
		return (0);

	WriteByte(MSG_ENTITY, ENT_ENTITYRENDERABLE);

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
	SENDENTITY_BYTE(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
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
	SENDENTITY_BYTE(m_renderColor[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderAmount, RDENT_CHANGED_RENDERAMT)
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
ncRenderableEntity::ReceiveEntity
============
*/
void
ncRenderableEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], RDENT_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], RDENT_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], RDENT_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], RDENT_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], RDENT_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], RDENT_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(colormap, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
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
	READENTITY_FLOAT(m_netEffects, RDENT_CHANGED_EFFECTS)
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
	READENTITY_BYTE(m_renderColor[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderAmount, RDENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_studioBoneController1, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController2, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController3, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController4, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController5, RDENT_CHANGED_CONTROLLER)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & RDENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & RDENT_CHANGED_BODY)
		_UpdateGeomset();
	if (flChanged & RDENT_CHANGED_MODELINDEX) {
		_ModelChanged();
		_UpdateBoneCount();
	}
}

/*
============
ncRenderableEntity::RenderFXPass

all the render-modes manipulating the final colormod, alpha and effects
fields that the engine cares about
============
*/
void
ncRenderableEntity::RenderFXPass(void)
{
	vector vecPlayer = g_view.GetCameraOrigin();

	/* HACK: this tells our GLSL to render this masked */
	//glowmod = [1.0,0.0,1.0];
	colormod = m_renderColor / 255;
	alpha = m_renderAmount / 255;

	/* these should be reset! */
	renderflags = 0;
	effects = m_netEffects;
	drawflags = 0;
	abslight = 0;

	{
		if (m_studioBoneController1Spin != 0.0) {
			m_studioBoneController1 += frametime * m_studioBoneController1Spin;
		}
		if (m_studioBoneController2Spin != 0.0) {
			m_studioBoneController2 += frametime * m_studioBoneController2Spin;
		}
		if (m_studioBoneController3Spin != 0.0) {
			m_studioBoneController3 += frametime * m_studioBoneController3Spin;
		}
		if (m_studioBoneController4Spin != 0.0) {
			m_studioBoneController4 += frametime * m_studioBoneController4Spin;
		}
		if (m_studioBoneController5Spin != 0.0) {
			m_studioBoneController5 += frametime * m_studioBoneController5Spin;
		}

		if (m_studioBoneController1Spin > 0.0f)
			m_studioBoneController1Spin = max(0.0, m_studioBoneController1Spin - (frametime * 10.0f));
		if (m_studioBoneController2Spin > 0.0f)
			m_studioBoneController2Spin = max(0.0, m_studioBoneController2Spin - (frametime * 10.0f));
		if (m_studioBoneController3Spin > 0.0f)
			m_studioBoneController3Spin = max(0.0, m_studioBoneController3Spin - (frametime * 10.0f));
		if (m_studioBoneController4Spin > 0.0f)
			m_studioBoneController4Spin = max(0.0, m_studioBoneController4Spin - (frametime * 10.0f));
		if (m_studioBoneController5Spin > 0.0f)
			m_studioBoneController5Spin = max(0.0, m_studioBoneController5Spin - (frametime * 10.0f));

		if (m_studioBoneController1Spin < 0.0f)
			m_studioBoneController1Spin = bound(m_studioBoneController1Spin, m_studioBoneController1Spin + (frametime * 10.0f), 0.0);
		if (m_studioBoneController2Spin < 0.0f)
			m_studioBoneController2Spin = bound(m_studioBoneController2Spin, m_studioBoneController2Spin + (frametime * 10.0f), 0.0);
		if (m_studioBoneController3Spin < 0.0f)
			m_studioBoneController3Spin = bound(m_studioBoneController3Spin, m_studioBoneController3Spin + (frametime * 10.0f), 0.0);
		if (m_studioBoneController4Spin < 0.0f)
			m_studioBoneController4Spin = bound(m_studioBoneController4Spin, m_studioBoneController4Spin + (frametime * 10.0f), 0.0);
		if (m_studioBoneController5Spin < 0.0f)
			m_studioBoneController5Spin = bound(m_studioBoneController5Spin, m_studioBoneController5Spin + (frametime * 10.0f), 0.0);
	}

	switch (m_renderMode) {
	case RM_NORMAL:
		colormod = [1,1,1];
		alpha = 1.0f;
		break;
	case RM_COLOR:
		break;
	case RM_TEXTURE:
		if (autocvar_rm_unlit_texture == 0) {
			drawflags = 0;
			abslight = 0;
		} else {
			drawflags = 7;
			abslight = 128;
		}

		break;
	case RM_GLOW:
		colormod = m_renderColor / 255;
		alpha = (m_renderAmount == 0) ? 0.0f : 1.0f;
	case RM_WORLDGLOW: /* TODO: Figure out what this does differently */
		if (checkpvs(vecPlayer, this) == FALSE)
			alpha -= clframetime;

		other = world;
		traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

		/* If we can't trace against the player, or are two close, fade out */
		if (trace_fraction < 1.0f || vlen(origin - vecPlayer) < 128)
			alpha -= clframetime;
		else
			alpha += clframetime;

		/* max alpha will be applied here to the color instead */
		colormod *= (m_renderAmount / 255);
		alpha = bound(0.0f, alpha, 1.0f);
		effects |= EF_ADDITIVE | EF_FULLBRIGHT;

		/* Scale the glow somewhat with the players distance */
		if (alpha > 0.0f)
			scale = bound(1, vlen(vecPlayer - origin) / 256, 4);
		break;
	case RM_SOLID:
		colormod = [1,1,1];
		alpha = (m_renderAmount == 0) ? 0.0f : 1.0f;
		glowmod[0] = 0.5f;
		break;
	case RM_ADDITIVE:
		if (m_renderColor == g_vec_null)
			colormod = [1,1,1];

		effects = EF_ADDITIVE;
		break;
	case RM_ADDFRAC: /* TODO: Figure out what this does differently */
		effects |= EF_ADDITIVE;
		if (autocvar_rm_unlit_additive == 0) {
			drawflags = 0;
			abslight = 0;
		} else {
			drawflags = 7;
			abslight = 128;
		}
		break;
	case RM_FULLBRIGHT:
		alpha = 1.0f;
		drawflags = 7;
		abslight = 128;
		break;
	case RM_DONTRENDER:
		break;
	}

	switch (m_renderFX) {
	case RFX_SLOWPULSE:
		alpha = sin(cltime * 0.5) + (M_PI * 0.5);
		break;
	case RFX_FASTPULSE:
		alpha = sin(cltime * 2.0) + (M_PI * 0.5);
		break;
	case RFX_SLOWWIDEPULSE:
		alpha = (sin(cltime * 2.0));
		break;
	case RFX_FASTWIDEPULSE:
		alpha = sin(cltime * 2.0) + (M_PI * 0.5);
		break;
	case RFX_SLOWFADEAWAY:
		alpha -= clframetime * 0.25;
		break;
	case RFX_FASTFADEAWAY:
		effects = 0;
		alpha -= clframetime;
		break;
	case RFX_SLOWBECOMESOLID:
		break;
	case RFX_FASTBECOMESOLID:
		break;
	case RFX_SLOWSTROBE:
		alpha = (cltime & 1) ? 1.0 : 0.0f;
		break;
	case RFX_FASTSTROBE:
		alpha = ((cltime*2.0) & 1) ? 1.0 : 0.0f;
		break;
	case RFX_FASTERSTROBE:
		alpha = ((cltime*4.0) & 1) ? 1.0 : 0.0f;
		break;
	case RFX_SLOWFLICKER:
		break;
	case RFX_FASTFLICKER:
		break;
	case RFX_CONSTANTGLOW:
		break;
	case RFX_DISTORT:
		break;
	case RFX_HOLOGRAM:
		/* messy hologram imitation */
		float dist;
		float r;

		r = random() * 0.5f;
		makevectors(angles);

		if (cltime & 1) {
			v_right *= 0.75 + r;
			renderflags |= RF_USEAXIS;
		} else if (cltime & 2) {
			v_up *= 1.0 - (random() * 0.2f);
			renderflags |= RF_USEAXIS;
		}

		dist = vlen(vecPlayer - origin);
		if (dist < 256) {
			float distalpha = dist / 256;
			alpha = 1.0 - distalpha;
			alpha -= r;
			alpha *= (m_renderAmount / 255);
		} else {
			alpha = 0.00001f;
		}
		colormod *= 0.5;
		effects |= EF_ADDITIVE;
		drawflags = 7;
		abslight = 128;
		break;
	case RFX_GLOWSHELL2:
		/* make this entity shellchrome */
		effects |= EF_ADDITIVE;
		fatness = m_renderAmount / 25.5;
		colormod = (m_renderColor / 255);
		forceshader = g_shellchromeshader_cull;
		alpha = 1.0f;
		/* copy entity into rendering queue */
		addentity(this);
		/* reset */
		forceshader = 0;
		fatness = 0;
		colormod = [1,1,1];
		alpha = 1.0f;
		break;
	case RFX_GLOWSHELL:
		/* make this entity shellchrome */
		fatness = m_renderAmount / 25.5;
		colormod = (m_renderColor / 255);
		forceshader = g_shellchromeshader;
		alpha = 1.0f;
		/* copy entity into rendering queue */
		addentity(this);
		/* reset */
		forceshader = 0;
		fatness = 0;
		colormod = [1,1,1];
		alpha = 1.0f;
		break;
	case RFX_Q2PULSE:
	default:
		break;
	}

	/* HACK: let the GLSL know to cull this */
	switch (skin) {
	case CONTENT_WATER:
	case CONTENT_SLIME:
	case CONTENT_LAVA:
		glowmod[0] = 0.25f;
		break;
	}
}

void
ncRenderableEntity::RenderDebugSkeleton(void)
{
	if (autocvar(r_showSkeleton, 0))
	for (int i = 1; i < 64; i++) {
		vector v1 = gettaginfo(this, i);

		if (v1 == this.origin) {
			continue;
		}

		makevectors(input_angles);
		R_BeginPolygon("textures/dev/model_bone", 0, 0);
		R_PolygonVertex(v1 + v_right * 1 - v_up * 1, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(v1 - v_right * 1 - v_up * 1, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(v1 - v_right * 1 + v_up * 1, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(v1 + v_right * 1 + v_up * 1, [1,0], [1,1,1],1.0f);
		R_EndPolygon();
		alpha = 0.25f;
	}
}

void
ncRenderableEntity::RenderAxialScale(void)
{
	/* only bother if we're non-standard */
	if (m_axialScale != [1,1,1]) {
		makevectors(angles);
		v_forward *= m_axialScale[0];
		v_right *= m_axialScale[1];
		v_up *= m_axialScale[2];
		renderflags |= RF_USEAXIS;
	}
}

void
ncRenderableEntity::RenderGLQuakeShadow(void)
{
	vector oldOrigin = origin;

	if (autocvar(r_drawGLQuakeShadow, 0) == 0)
		return;

	if (m_netEffects & EF_NOSHADOW)
		return;

	if (IsBrush())
		return;

	traceline(origin + [0, 0, 1], origin + [0, 0, -1024], MOVE_NORMAL, this);
	origin = trace_endpos + [0,0,1];
	makevectors(angles);
	v_up *= 0.01;
	renderflags = RF_USEAXIS;
	alpha = 0.5f;
	addentity_lighting(this, [0,0,0], [0, 0, 0], [0,0,0], 0, 0);
	origin = oldOrigin;
}

/*
============
ncRenderableEntity::predraw

a lot of the things in here don't even apply to most
entities, so TODO: make things like anims, sentences apply
only to relevant child-classes
============
*/
.vector last_pos;

var float autocvar_boney1 = 0.0f;
var float autocvar_boney2 = 0.0f;
var float autocvar_boney3 = 0.0f;
var float autocvar_boney4 = 0.0f;
var float autocvar_boney5 = 0.0f;

var float autocvar_subblendfrac = 0.0f;
var float autocvar_subblend2frac = 0.0f;
var float autocvar_basesubblendfrac = 0.0f;
var float autocvar_basesubblend2frac = 0.0f;
var float autocvar_baseframe = 0.0f;

float
ncRenderableEntity::predraw(void)
{
	if (GetModelindex() == 0 || IsHidden()) {
		return (PREDRAW_NEXT);
	}

#if 0
	if (autocvar_boney1 != 0.0f)
		bonecontrol1 = autocvar_boney1;
	if (autocvar_boney2 != 0.0f)
		bonecontrol2 = autocvar_boney2;
	if (autocvar_boney3 != 0.0f)
		bonecontrol3 = autocvar_boney3;
	if (autocvar_boney4 != 0.0f)
		bonecontrol4 = autocvar_boney4;
	if (autocvar_boney5 != 0.0f)
		bonecontrol5 = autocvar_boney5;

	if (autocvar_subblendfrac != 0.0f)
		subblendfrac = autocvar_subblendfrac;
	if (autocvar_subblend2frac != 0.0f)
		subblend2frac = autocvar_subblend2frac;

	if (autocvar_basesubblendfrac != 0.0f)
		basesubblendfrac = autocvar_basesubblendfrac;
	if (autocvar_basesubblend2frac != 0.0f)
		basesubblend2frac = autocvar_basesubblend2frac;
#endif

	RenderFXPass();
	RenderDebugSkeleton();

	bonecontrol1 = m_studioBoneController1;
	bonecontrol2 = m_studioBoneController2;
	bonecontrol3 = m_studioBoneController3;
	bonecontrol4 = m_studioBoneController4;
	bonecontrol5 = m_studioBoneController5;

	if (modelflags & MF_ROTATE) {
		angles[1] = g_modelSpinAngle;
		angles[2] = g_modelSpinRoll;
		angles[0] = g_modelSpinPitch;
	}

	processmodelevents(modelindex, frame, m_modelEventTime,
		frame1time, HandleAnimEvent);

	RenderAxialScale();

	vector oldOrg = origin;

	/* TODO: make this a separate field */
	if (modelflags & MF_ROTATE) {
		origin[2] += g_modelBobHeight;
	}

	if (alpha > 0.0) {
		/* TODO: Move this somewhere more sane */
		if (m_renderFX == RFX_Q2PULSE) {
			float dim = ((sin(time * autocvar(rfx_q2pulse_speed, 4)) + (M_PI/2)) * autocvar(rfx_q2pulse_intensity, 1.0));
			dim += 1.0f;
			addentity_lighting(this, [0,0,0], [dim, dim, dim], [0,0,0], 0, 0);
		} else if (m_renderMode != RM_DONTRENDER) {
			addentity(this);
		}
	}
	origin = oldOrg;

	if (traileffectnum) {
		if (oldorigin != g_vec_null)
			trailparticles(traileffectnum, this, oldorigin, origin);
	}
	oldorigin = origin;

	RenderGLQuakeShadow();

	return (PREDRAW_NEXT);
}

void
ncRenderableEntity::postdraw(void)
{
	if not (autocvar(r_showRenderInfo, 0))
		return;

	if not (PointMessage_Visible(WorldSpaceCenter(), g_view.GetCameraOrigin(), g_view.GetCameraAngle()))
		return;

	string renderMode = "";
	string renderFX = "";

	switch (GetRenderMode()) {
	case RM_COLOR:
		renderMode = "RM_COLOR";
		break;
	case RM_TEXTURE:
		renderMode = "RM_TEXTURE";
		break;
	case RM_GLOW:
		renderMode = "RM_GLOW";
		break;
	case RM_SOLID:
		renderMode = "RM_SOLID";
		break;
	case RM_ADDITIVE:
		renderMode = "RM_ADDITIVE";
		break;
	case RM_FULLBRIGHT:
		renderMode = "RM_FULLBRIGHT";
		break;
	case RM_ADDFRAC:
		renderMode = "RM_ADDFRAC";
		break;
	case RM_WORLDGLOW:
		renderMode = "RM_WORLDGLOW";
		break;
	case RM_DONTRENDER:
		renderMode = "RM_DONTRENDER";
		break;
	case RM_NORMAL:
	default:
		renderMode = "RM_NORMAL";
		break;
	}

	switch (GetRenderFX()) {
	case RFX_SLOWPULSE:
		renderFX = "RFX_SLOWPULSE";
		break;
	case RFX_FASTPULSE:
		renderFX = "RFX_FASTPULSE";
		break;
	case RFX_SLOWWIDEPULSE:
		renderFX = "RFX_SLOWWIDEPULSE";
		break;
	case RFX_FASTWIDEPULSE:
		renderFX = "RFX_FASTWIDEPULSE";
		break;
	case RFX_SLOWFADEAWAY:
		renderFX = "RFX_SLOWFADEAWAY";
		break;
	case RFX_FASTFADEAWAY:
		renderFX = "RFX_FASTFADEAWAY";
		break;
	case RFX_SLOWBECOMESOLID:
		renderFX = "RFX_SLOWBECOMESOLID";
		break;
	case RFX_FASTBECOMESOLID:
		renderFX = "RFX_FASTBECOMESOLID";
		break;
	case RFX_SLOWSTROBE:
		renderFX = "RFX_SLOWSTROBE";
		break;
	case RFX_FASTSTROBE:
		renderFX = "RFX_FASTSTROBE";
		break;
	case RFX_FASTERSTROBE:
		renderFX = "RFX_FASTERSTROBE";
		break;
	case RFX_SLOWFLICKER:
		renderFX = "RFX_SLOWFLICKER";
		break;
	case RFX_FASTFLICKER:
		renderFX = "RFX_FASTFLICKER";
		break;
	case RFX_CONSTANTGLOW:
		renderFX = "RFX_CONSTANTGLOW";
		break;
	case RFX_DISTORT:
		renderFX = "RFX_DISTORT";
		break;
	case RFX_HOLOGRAM:
		renderFX = "RFX_HOLOGRAM";
		break;
	case RFX_GLOWSHELL:
		renderFX = "RFX_GLOWSHELL";
		break;
	case RFX_GLOWSHELL2:
		renderFX = "RFX_GLOWSHELL2";
		break;
	case RFX_Q2PULSE:
		renderFX = "RFX_Q2PULSE";
		break;
	case RFX_NORMAL:
	default:
		renderFX = "RFX_NORMAL";
		break;
	}
	string renderString = sprintf("RC: %v\nRA: %f\nRM: %s\nRFX: %s",
		m_renderColor, m_renderAmount, renderMode, renderFX);

	PointMessage_FieldAtPos(WorldSpaceCenter(), renderString, 128);
}
#endif

#ifdef SERVER
void
ncRenderableEntity::Respawn(void)
{
	super::Respawn();

	SetRenderFX(GetSpawnFloat("renderfx"));
	SetRenderMode(GetSpawnFloat("rendermode"));
	SetRenderAmt(GetSpawnFloat("renderamt"));
	SetRenderColor(GetSpawnVector("rendercolor"));

	SetScale(GetSpawnFloat("modelscale"));

	SetSkin(GetSpawnInt("skin"));
	SetBody(GetSpawnInt("body"));
	SetBodyInGroup(0, GetSpawnInt("body0"));
	SetBodyInGroup(1, GetSpawnInt("body1"));
	SetBodyInGroup(2, GetSpawnInt("body2"));
	SetBodyInGroup(3, GetSpawnInt("body3"));
}
#endif

void
ncRenderableEntity::SetBody(int newBody)
{
	m_geomsetField = newBody;

#ifdef CLIENT
	_UpdateGeomset();
#endif
}

void
ncRenderableEntity::SetBodyInGroup(int groupID, int bodyValue)
{
	/* pack our half bytes */
	m_geomsetField |= (bodyValue << (4 * groupID));
	m_geomsetField_net = 0;
	//print(sprintf("NEW BODY: %i %i %i\n", m_geomsetField, groupID, bodyValue));
}

void
ncRenderableEntity::SetRenderFX(float newFX)
{
	m_renderFX = newFX;
}

void
ncRenderableEntity::SetRenderMode(float newMode)
{
	m_renderMode = newMode;
}

void
ncRenderableEntity::SetRenderAmt(float newAmt)
{
	m_renderAmount = newAmt;
}

void
ncRenderableEntity::SetRenderColor(vector newColor)
{
	/* rendercolor can NEVER be pitch black. */
	if (newColor == g_vec_null) {
		m_renderColor = [255, 255, 255];
	}

	m_renderColor = newColor;
}

void
ncRenderableEntity::SetBoneController1(float val)
{
	m_studioBoneController1 = val;
}

void
ncRenderableEntity::SetBoneController2(float val)
{
	m_studioBoneController2 = val;
}

void
ncRenderableEntity::SetBoneController3(float val)
{
	m_studioBoneController3 = val;
}

void
ncRenderableEntity::SetBoneController4(float val)
{
	m_studioBoneController4 = val;
}

void
ncRenderableEntity::SetBoneController5(float val)
{
	m_studioBoneController5 = val;
}

void
ncRenderableEntity::SetAxialScale(vector scaleVec)
{
	m_axialScale = scaleVec;
}

int
ncRenderableEntity::GetBody(void)
{
	return m_geomsetField;
}

int
ncRenderableEntity::GetBodyInGroup(int bodyGroup)
{
	return m_geomsetField;
}

float
ncRenderableEntity::GetRenderMode(void)
{
	return m_renderMode;
}

float
ncRenderableEntity::GetRenderFX(void)
{
	return m_renderFX;
}

float
ncRenderableEntity::GetRenderAmt(void)
{
	return m_renderAmount;
}

vector
ncRenderableEntity::GetRenderColor(void)
{
	return m_renderColor;
}

float
ncRenderableEntity::GetBoneController1(void)
{
	return m_studioBoneController1;
}

float
ncRenderableEntity::GetBoneController2(void)
{
	return m_studioBoneController2;
}

float
ncRenderableEntity::GetBoneController3(void)
{
	return m_studioBoneController3;
}

float
ncRenderableEntity::GetBoneController4(void)
{
	return m_studioBoneController4;
}

float
ncRenderableEntity::GetBoneController5(void)
{
	return m_studioBoneController5;
}

vector
ncRenderableEntity::GetAxialScale(void)
{
	return m_axialScale;
}

void
ncRenderableEntity::HandleAnimEvent(float flTimeStamp, int iCode, string strData)
{
	switch(iCode) {
	case 1004:	/* plays a sound on CHAN_BODY */
#ifdef CLIENT
		if (substring(strData, 0, 1) == "*")
			StartSound(substring(strData, 1, -1), CHAN_BODY, 0, true);
		else
			StartSound(strData, CHAN_BODY, 0, true);
#endif
		break;
	case 1008:	/* plays a sound on CHAN_VOICE */
#ifdef CLIENT
		if (substring(strData, 0, 1) == "*")
			StartSound(substring(strData, 1, -1), CHAN_VOICE, 0, true);
		else
			StartSound(strData, CHAN_VOICE, 0, true);
#endif
		break;
	case 5000: /* view model muzzle special */
#ifdef CLIENT
		vector muzzlePos = g_vec_null;

		if (m_fiJointBarrel > 0) {
			muzzlePos = gettaginfo(pSeat->m_eViewModel, m_fiJointBarrel);
		} else {
			vector camPos = pSeat->m_eViewModel.origin;

			muzzlePos = camPos + anglesToForward(pSeat->m_eViewModel.angles) * m_muzzRelativeOffset[0];
			muzzlePos += anglesToRight(pSeat->m_eViewModel.angles) * m_muzzRelativeOffset[1];
			muzzlePos += anglesToUp(pSeat->m_eViewModel.angles) * m_muzzRelativeOffset[2];
		}

		muzzlePos += anglesToForward(pSeat->m_eViewModel.angles) * m_muzzOffset[0];
		muzzlePos += anglesToRight(pSeat->m_eViewModel.angles) * m_muzzOffset[1];
		muzzlePos += anglesToUp(pSeat->m_eViewModel.angles) * m_muzzOffset[2];

		ncRenderableEntity viewModel = (ncRenderableEntity)pSeat->m_eViewModel;

		EV_MuzzleFlash_CreateAtPos(pSeat->m_eViewModel, muzzlePos, 1.0, viewModel.m_iMuzzleModel);

		if (STRING_SET(m_muzzPartSmoke)) {
			setproperty(VF_ANGLES,g_view.GetCameraAngle());
			setproperty(VF_ORIGIN, g_view.GetCameraOrigin());
			pointparticles(particleeffectnum(m_muzzPartSmoke), muzzlePos, g_vec_null, 1);
		}
#endif
		break;
	case 5004: /* view model sound? */
		/* if the file doesn't exist, assume it's a SoundDef */
		if (fileExists(strcat("sound/", strData)) == false) {
			SoundDef_Play(this, CHAN_BODY, strData);
		} else {
			StartSound(strData, CHAN_AUTO, 0, true);
		}
		
		StartSound(strData, CHAN_AUTO, 0, true);
		break;
	/* GS events */
	case 5001: /* muzzle flash on attachment 0 */
#ifdef CLIENT
		EV_MuzzleFlash_CreateAdditive(this, m_iNumBones, m_flMuzzleScale, m_iMuzzleModel);
#endif
		break;
	case 5011: /* muzzle flash on attachment 1 */
#ifdef CLIENT
		EV_MuzzleFlash_CreateAdditive(this, m_iNumBones + 1, m_flMuzzleScale, m_iMuzzleModel);
#endif
		break;
	case 5021: /* muzzle flash on attachment 2 */
#ifdef CLIENT
		EV_MuzzleFlash_CreateAdditive(this, m_iNumBones + 2, m_flMuzzleScale, m_iMuzzleModel);
#endif
		break;
	case 5031: /* muzzle flash on attachment 3 */
#ifdef CLIENT
		EV_MuzzleFlash_CreateAdditive(this, m_iNumBones + 3, m_flMuzzleScale, m_iMuzzleModel);
#endif
		break;
	case 1003:	/* trigger SSQC entity with specific targetname */
#ifdef SERVER
		for (entity f = world; (f = find(f, ::targetname, strData));) {
			ncEntity trigger = (ncEntity)f;

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
				EntLog("Calling trigger '%s'", strData);
			}
		}
#endif
		break;

	case 6001:
		//EntWarning("Eject brass 1 '%s'", strData);
		break;
	case 6002:
		//EntWarning("Eject brass 2 '%s'", strData);
		break;
	case 6003:
		//EntWarning("Eject brass 3 '%s'", strData);
		break;
	case 6004:
		//EntWarning("Eject brass 4 '%s'", strData);
		break;
	case 6005:
		//EntWarning("Eject brass 5 '%s'", strData);
		break;
	case 9001:
#ifdef CLIENT
		m_studioBoneController1Spin += ReadFloat(strData);
#endif
		break;
	case 9002:
#ifdef CLIENT
		m_studioBoneController1Spin = ReadFloat(strData);
#endif
		break;
	case 9011:
#ifdef CLIENT
		m_studioBoneController2Spin += ReadFloat(strData);
#endif
		break;
	case 9012:
#ifdef CLIENT
		m_studioBoneController2Spin = ReadFloat(strData);
#endif
		break;
	case 9021:
#ifdef CLIENT
		m_studioBoneController3Spin += ReadFloat(strData);
#endif
		break;
	case 9022:
#ifdef CLIENT
		m_studioBoneController3Spin = ReadFloat(strData);
#endif
		break;
	case 9031:
#ifdef CLIENT
		m_studioBoneController4Spin += ReadFloat(strData);
#endif
		break;
	case 9032:
#ifdef CLIENT
		m_studioBoneController4Spin = ReadFloat(strData);
#endif
		break;
	case 9041:
#ifdef CLIENT
		m_studioBoneController5Spin += ReadFloat(strData);
#endif
		break;
	case 9042:
#ifdef CLIENT
		m_studioBoneController5Spin = ReadFloat(strData);
#endif
		break;
	default:
#ifdef SERVER
		bool success = false;

		//print(sprintf("%i\n", eDefEvents));
		for (int i = 0; i < tokenize(m_modelEventCallbacks); i+=3) {
			int testCode = stoi(argv(i+0));
			string testInput = argv(i+1);
			string testData = argv(i+2);
			//print(sprintf("%i %s %s\n", testCode, testInput, testData));

			/* this is kind of messy in that we can only pass one parm over another */
			if (iCode == testCode) {
				if (testData != "")
					Input(this, testInput, testData);
				else
					Input(this, testInput, strData); /* no parms passed. */

				success = true;
			}
		}

		if (success == true) {
			return;
		}
		//print(sprintf("Received: %f %i %S\n", flTimeStamp, iCode, strData));
#endif
		EntWarning("? event %i in %S from %S\n\tTime: %f; Data: %S", iCode, frametoname(modelindex, frame), modelnameforindex(modelindex), flTimeStamp, strData);
	}
}

#ifdef SERVER
void
ncRenderableEntity::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "studioBoneController1", m_studioBoneController1);
	SaveFloat(handle, "studioBoneController2", m_studioBoneController2);
	SaveFloat(handle, "studioBoneController3", m_studioBoneController3);
	SaveFloat(handle, "studioBoneController4", m_studioBoneController4);
	SaveFloat(handle, "studioBoneController5", m_studioBoneController5);
	SaveInt(handle, "geomsetField", m_geomsetField);
	SaveFloat(handle, "renderAmount", m_renderAmount);
	SaveVector(handle, "renderColor", m_renderColor);
	SaveFloat(handle, "renderMode", m_renderMode);
	SaveFloat(handle, "renderFX", m_renderFX);
	SaveVector(handle, "axialScale", m_axialScale);
	SaveFloat(handle, "modelEventTime", m_modelEventTime);
}

void
ncRenderableEntity::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "studioBoneController1":
		m_studioBoneController1 = ReadFloat(setValue);
		break;
	case "studioBoneController2":
		m_studioBoneController2 = ReadFloat(setValue);
		break;
	case "studioBoneController3":
		m_studioBoneController3 = ReadFloat(setValue);
		break;
	case "studioBoneController4":
		m_studioBoneController4 = ReadFloat(setValue);
		break;
	case "studioBoneController5":
		m_studioBoneController5 = ReadFloat(setValue);
		break;
	case "geomsetField":
		m_geomsetField = ReadInt(setValue);
		break;
	case "renderAmount":
		m_renderAmount = ReadFloat(setValue);
		break;
	case "renderColor":
		m_renderColor = ReadVector(setValue);
		break;
	case "renderMode":
		m_renderMode = ReadFloat(setValue);
		break;
	case "renderFX":
		m_renderFX = ReadFloat(setValue);
		break;
	case "axialScale":
		m_axialScale = ReadVector(setValue);
		break;
	case "modelEventTime":
		m_modelEventTime = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
ncRenderableEntity::Event_SpawnDefBone(string classDef, string boneName)
{
	_UpdateBoneCount();
	ncEntity rocket = Entity_CreateClass(classDef);
	rocket.SetOrigin(GetOrigin());
	rocket.SetAngles(GetAngles());
	rocket.tag_entity = this;
	rocket.tag_index = gettagindex(this, boneName);
	rocket.owner = this;
	EntLog("Spawned decl %S at bone %S (%v)", classDef, boneName, rocket.origin);
}

void
ncRenderableEntity::Event_SpawnDefAttachment(string classDef, float attachmentID)
{
	_UpdateBoneCount();
	ncEntity rocket = Entity_CreateClass(classDef);
	rocket.SetOrigin(GetOrigin());
	rocket.SetAngles(GetAngles());
	rocket.tag_entity = this;
	rocket.tag_index = m_iNumBones + attachmentID;
	rocket.owner = this;
	EntLog("Spawned decl %S at attachment %f (%v)", classDef, attachmentID, rocket.origin);
}

void
ncRenderableEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "SpawnDefBone":
#ifdef SERVER
		tokenize_console(strData);
		Event_SpawnDefBone(argv(0), argv(1));
#endif
		break;
	case "SpawnDefAttachment":
#ifdef SERVER
		string declName;
		string attachment;
		float attachmentID;
		tokenize_console(strData);
		declName = argv(0);
		attachment = argv(1);
		attachmentID = stof(attachment);
		Event_SpawnDefAttachment(declName, attachmentID);
#endif
		break;
	case "Color":
		SetRenderColor(stov(strData));
		break;
	case "Alpha":
		SetRenderAmt(stof(strData));
		break;
	case "Skin":
		SetSkin(stof(strData));
		break;
	case "DisableShadow":
		effects |= EF_NOSHADOW;
		break;
	case "EnableShadow":
		effects &= ~EF_NOSHADOW;
		break;
	case "SetAnimation":
		float animFrame = frameforname(modelindex, strcat("@", strData));
		SetFrame(animFrame);
		EntLog("SetAnimation: %S (%d) on %S\n", strData, animFrame, model);
		break;
	case "PlayNamedSequence":
		float animFrame = frameforname(modelindex, strData);
		SetFrame(animFrame);
		EntLog("PlayNamedSequence: %S (%d) on %S\n", strData, animFrame, model);
		frame1time = 0.0f;
		break;
	case "SetBody":
		SetBody(stoi(strData));
		break;
	case "SetBodyInGroup":
		int argC = tokenize(strData);

		if (argC == 2) {
			int bodyGroup = stoi(argv(0));
			int bodyModel = stoi(argv(1));
			SetBodyInGroup(bodyGroup, bodyModel);
			EntLog("changed body family %i to %i", bodyGroup, bodyModel);
		}
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
#endif

void
ncRenderableEntity::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "body":
		m_geomsetField = ReadInt(setValue);
		break;
	case "body0":
		SetBodyInGroup(0, ReadInt(setValue));
		break;
	case "body1":
		SetBodyInGroup(1, ReadInt(setValue));
		break;
	case "body2":
		SetBodyInGroup(2, ReadInt(setValue));
		break;
	case "body3":
		SetBodyInGroup(3, ReadInt(setValue));
		break;
	case "modelscale":
	case "scale":
		scale = ReadFloat(setValue);
		break;
	case "modelscale_vec":
	case "modelstretch":
	case "axialscale":
		m_axialScale = ReadVector(setValue);
		break;
	case "lightingPrecalc":
		m_renderColor = ReadVector(setValue) * 255;
		m_renderAmount = 255;
		break;
	case "skin":
		skin = ReadFloat(setValue);
		break;
	case "shadows":
		if (stof(setValue) == 1) {
			effects &= ~EF_NOSHADOW;
		} else {
			effects |= EF_NOSHADOW;
		}
		break;
	/* Source */
	case "disableshadows":
		if (stof(setValue) == 1) {
			effects |= EF_NOSHADOW;
		} else {
			effects &= ~EF_NOSHADOW;
		}
		break;
	case "renderamt":
		m_renderAmount = ReadFloat(setValue);
		break;
	case "rendercolor":
		m_renderColor = ReadVector(setValue);
		break;
	case "rendermode":
		m_renderMode = ReadFloat(setValue);
		break;
	case "renderfx":
		m_renderFX = ReadFloat(setValue);
		break;
	case "model_flash":
		m_iMuzzleModel = (int)getmodelindex(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

#if 0
float
ncRenderableEntity::PlayActOnChannel(float animChannel, string activityName)
{

}
#endif
