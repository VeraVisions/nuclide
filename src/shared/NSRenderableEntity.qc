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
NSRenderableEntity::NSRenderableEntity(void)
{
	m_iRenderMode = RM_NORMAL;
	m_iRenderFX = RFX_NORMAL;
	m_vecRenderColor[0] = 1.0f;
	m_vecRenderColor[1] = 1.0f;
	m_vecRenderColor[2] = 1.0f;
	m_flRenderAmt = 0.0f;
	m_flBoneControl1 = 0.5f;
	m_flBoneControl2 = 0.5f;
	m_flBoneControl3 = 0.5f;
	m_flBoneControl4 = 0.5f;
	m_flBoneControl5 = 0.5f;
	m_iBody = 0i;
	m_vecAxialScale = [1,1,1];

	effects |= EF_NOSHADOW;

	m_iMuzzleModel = 0i;
	m_flMuzzleScale = 0.25f;

#ifdef CLIENT
	drawmask = MASK_ENGINE;
#endif
}


#ifdef CLIENT
void NSRenderableEntity::RendererRestarted( void ) {
	_UpdateGeomset();
}

void NSRenderableEntity::_UpdateGeomset(void)
{
	/* unpack our half bytes */
	int firstBody = (m_iBody & 0x0F);
	int secondBody = ((m_iBody >> 4) & 0x0F);
	int thirdBody = ((m_iBody >> 8) & 0x0F);
	int fourthBody = ((m_iBody >> 12) & 0x0F);

	//print(sprintf("%i body 0: %i body 1: %i body 2: %i body 3: %i\n", m_iBody , firstBody, secondBody, thirdBody, fourthBody));

	setcustomskin(this, "",
		sprintf("geomset 0 %i\ngeomset 1 %i\ngeomset 2 %i\ngeomset 3 %i\n", firstBody, secondBody, thirdBody, fourthBody)
	);
}

void
NSRenderableEntity::_UpdateBoneCount(void)
{
	skeletonindex = skel_create(modelindex);
	m_iNumBones = skel_get_numbones(skeletonindex) + 1;
	//print(sprintf("UPDATED GEOMSET FOR MODELINDEX %d, %d BONES\n", modelindex, m_iNumBones));
	skel_delete(skeletonindex);
	skeletonindex = 0;
}
#endif

/*
============
NSRenderableEntity::MakeStatic

after this gets called the entity is unreachable in the QC-logic
and merged with the world to optimise drawcalls

we usually want to do this with most decorative ents without
a valid targetname
============
*/
void
NSRenderableEntity::MakeStatic(void)
{
#ifdef CLIENT
	/* give renderFX the opportunity to write into renderable
	 * fields at least once before forever pulling it out the cgame */
	if (m_iRenderMode > RM_FULLBRIGHT)
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
NSRenderableEntity::EvaluateEntity(void)
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
	EVALUATE_FIELD(m_iBody, RDENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 0, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 1, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 2, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)
}

/* Make sure StartFrame calls this */
float
NSRenderableEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
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
		if (m_iRenderMode == RM_NORMAL && m_iRenderFX == RFX_NORMAL) {
			flChanged &= ~RDENT_CHANGED_RENDERMODE;
			//flChanged &= ~RDENT_CHANGED_RENDERCOLOR; /* glowmod needs this */
			flChanged &= ~RDENT_CHANGED_RENDERAMT;
		}

		if (m_bIsBrush == true) {
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
	SENDENTITY_BYTE(frame, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_iBody, RDENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[0], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[1], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[2], RDENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_COLOR(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)

	return (1);
}
#else
/*
============
NSRenderableEntity::ReceiveEntity
============
*/
void
NSRenderableEntity::ReceiveEntity(float flNew, float flChanged)
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
	READENTITY_BYTE(frame, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	READENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	READENTITY_SHORT(m_iBody, RDENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[0], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[1], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[2], RDENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	READENTITY_COLOR(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & RDENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & RDENT_CHANGED_BODY)
		_UpdateGeomset();
	if (flChanged & RDENT_CHANGED_MODELINDEX)
		_UpdateBoneCount();
}

/*
============
NSRenderableEntity::RenderFXPass

all the render-modes manipulating the final colormod, alpha and effects
fields that the engine cares about
============
*/
void
NSRenderableEntity::RenderFXPass(void)
{
	vector vecPlayer = g_view.GetCameraOrigin();

	/* HACK: this tells our GLSL to render this masked */
	//glowmod = [1.0,0.0,1.0];
	colormod = m_vecRenderColor;
	alpha = m_flRenderAmt;

	/* these should be reset! */
	renderflags = 0;
	effects = 0;
	drawflags = 0;
	abslight = 0;

	switch (m_iRenderMode) {
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
		colormod = [1,1,1];
		alpha = m_flRenderAmt == 0.0 ? 0.0f : 1.0f;
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
		colormod *= m_flRenderAmt;
		alpha = bound(0.0f, alpha, 1.0f);
		effects = EF_ADDITIVE | EF_FULLBRIGHT;

		/* Scale the glow somewhat with the players distance */
		if (alpha > 0.0f)
			scale = bound(1, vlen(vecPlayer - origin) / 256, 4);
		break;
	case RM_SOLID:
		colormod = [1,1,1];
		alpha = m_flRenderAmt == 0.0 ? 0.0f : 1.0f;
		glowmod[0] = 0.5f;
		break;
	case RM_ADDITIVE:
		effects = EF_ADDITIVE;
		break;
	case RM_ADDFRAC: /* TODO: Figure out what this does differently */
		effects = EF_ADDITIVE;
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

	switch (m_iRenderFX) {
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
			alpha *= m_flRenderAmt;
		} else {
			alpha = 0.00001f;
		}
		colormod *= 0.5;
		effects = EF_ADDITIVE;
		drawflags = 7;
		abslight = 128;
		break;
	case RFX_GLOWSHELL2:
		/* make this entity shellchrome */
		effects = EF_ADDITIVE;
		fatness = 0;
		colormod = m_vecRenderColor;
		forceshader = g_shellchromeshader_cull;
		alpha = m_flRenderAmt;
		/* copy entity into rendering queue */
		addentity(this);
		/* reset */
		forceshader = 0;
		fatness = 0;
		colormod = [1,1,1];
		alpha = 1.0f;
		effects = 0;
		break;
	case RFX_GLOWSHELL:
		/* make this entity shellchrome */
		effects = EF_ADDITIVE;
		fatness = 0;
		colormod = m_vecRenderColor;
		forceshader = g_shellchromeshader;
		alpha = m_flRenderAmt;
		/* copy entity into rendering queue */
		addentity(this);
		/* reset */
		forceshader = 0;
		fatness = 0;
		colormod = [1,1,1];
		alpha = 1.0f;
		effects = 0;
		break;
	case RFX_Q2PULSE:
	default:
		break;
	}
}

void
NSRenderableEntity::RenderDebugSkeleton(void)
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
NSRenderableEntity::RenderAxialScale(void)
{
	/* only bother if we're non-standard */
	if (m_vecAxialScale != [1,1,1]) {
		makevectors(angles);
		v_forward *= m_vecAxialScale[0];
		v_right *= m_vecAxialScale[1];
		v_up *= m_vecAxialScale[2];
		renderflags |= RF_USEAXIS;
	}
}

void
NSRenderableEntity::RenderGLQuakeShadow(void)
{
	vector oldOrigin = origin;

	if (autocvar(r_drawGLQuakeShadow, 0) == 0)
		return;

	if (effects & EF_NOSHADOW)
		return;

	if (m_bIsBrush == true)
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
NSRenderableEntity::predraw

a lot of the things in here don't even apply to most
entities, so TODO: make things like anims, sentences apply
only to relevant child-classes
============
*/
.vector last_pos;
float
NSRenderableEntity::predraw(void)
{
	if (GetModelindex() == 0 || IsHidden()) {
		return (PREDRAW_NEXT);
	}

	bonecontrol1 = m_flBoneControl1;
	bonecontrol2 = m_flBoneControl2;
	bonecontrol3 = m_flBoneControl3;
	bonecontrol4 = m_flBoneControl4;
	bonecontrol5 = m_flBoneControl5;

	RenderFXPass();
	RenderDebugSkeleton();

	if (modelflags & MF_ROTATE) {
		angles[1] -= frametime * 120.0;
	}

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, HandleAnimEvent);

	RenderAxialScale();

	if (alpha > 0.0) {
		/* TODO: Move this somewhere more sane */
		if (m_iRenderFX == RFX_Q2PULSE) {
			float dim = ((sin(time * autocvar(rfx_q2pulse_speed, 4)) + (M_PI/2)) * autocvar(rfx_q2pulse_intensity, 1.0));
			dim += 1.0f;
			addentity_lighting(this, [0,0,0], [dim, dim, dim], [0,0,0], 0, 0);
		} else if (m_iRenderMode != RM_DONTRENDER) {
			addentity(this);
		}
	}

	if (traileffectnum) {
		if (oldorigin != g_vec_null)
			trailparticles(traileffectnum, this, oldorigin, origin);
	}
	oldorigin = origin;

	RenderGLQuakeShadow();

	return (PREDRAW_NEXT);
}

void
NSRenderableEntity::postdraw(void)
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
		m_vecRenderColor, m_flRenderAmt, renderMode, renderFX);

	PointMessage_StringAtPos(WorldSpaceCenter(), renderString);
}
#endif

#ifdef SERVER
void
NSRenderableEntity::Respawn(void)
{
	super::Respawn();

	SetRenderFX(GetSpawnRenderFX());
	SetRenderMode(GetSpawnRenderMode());
	SetRenderAmt(GetSpawnRenderAmt());
	SetRenderColor(GetSpawnRenderColor());
}
#endif

void
NSRenderableEntity::SetBody(int newBody)
{
	m_iBody = newBody;

#ifdef CLIENT
	_UpdateGeomset();
#endif
}

void
NSRenderableEntity::SetBodyInGroup(int groupID, int bodyValue)
{
	/* pack our half bytes */
	m_iBody |= (bodyValue << (4 * groupID));
	m_iBody_net = 0;
	//print(sprintf("NEW BODY: %i %i %i\n", m_iBody, groupID, bodyValue));
}

void
NSRenderableEntity::SetRenderFX(float newFX)
{
	m_iRenderFX = newFX;
}

void
NSRenderableEntity::SetRenderMode(float newMode)
{
	m_iRenderMode = newMode;
}

void
NSRenderableEntity::SetRenderAmt(float newAmt)
{
	m_flRenderAmt = newAmt;
}

void
NSRenderableEntity::SetRenderColor(vector newColor)
{
	/* rendercolor can NEVER be pitch black. */
	if (newColor == g_vec_null)
		m_vecRenderColor = [1.0, 1.0, 1.0];

	m_vecRenderColor = newColor;
}

void
NSRenderableEntity::SetBoneControl1(float val)
{
	m_flBoneControl1 = val;
}

void
NSRenderableEntity::SetBoneControl2(float val)
{
	m_flBoneControl2 = val;
}

void
NSRenderableEntity::SetBoneControl3(float val)
{
	m_flBoneControl3 = val;
}

void
NSRenderableEntity::SetBoneControl4(float val)
{
	m_flBoneControl4 = val;
}

void
NSRenderableEntity::SetBoneControl5(float val)
{
	m_flBoneControl5 = val;
}

void
NSRenderableEntity::SetAxialScale(vector scaleVec)
{
	m_vecAxialScale = scaleVec;
}

int
NSRenderableEntity::GetBody(void)
{
	return m_iBody;
}

int
NSRenderableEntity::GetBodyInGroup(int bodyGroup)
{
	return m_iBody;
}

#ifdef SERVER
vector
NSRenderableEntity::GetSpawnRenderColor(void)
{
	return m_oldvecRenderColor;
}

float
NSRenderableEntity::GetSpawnRenderAmt(void)
{
	return m_oldflRenderAmt;
}

int
NSRenderableEntity::GetSpawnRenderMode(void)
{
	return m_oldiRenderMode;
}

int
NSRenderableEntity::GetSpawnRenderFX(void)
{
	return m_oldiRenderFX;
}
#endif

float
NSRenderableEntity::GetRenderMode(void)
{
	return m_iRenderMode;
}

float
NSRenderableEntity::GetRenderFX(void)
{
	return m_iRenderFX;
}

float
NSRenderableEntity::GetRenderAmt(void)
{
	return m_flRenderAmt;
}

vector
NSRenderableEntity::GetRenderColor(void)
{
	return m_vecRenderColor;
}

float
NSRenderableEntity::GetBoneControl1(void)
{
	return m_flBoneControl1;
}

float
NSRenderableEntity::GetBoneControl2(void)
{
	return m_flBoneControl2;
}

float
NSRenderableEntity::GetBoneControl3(void)
{
	return m_flBoneControl3;
}

float
NSRenderableEntity::GetBoneControl4(void)
{
	return m_flBoneControl4;
}

float
NSRenderableEntity::GetBoneControl5(void)
{
	return m_flBoneControl5;
}

vector
NSRenderableEntity::GetAxialScale(void)
{
	return m_vecAxialScale;
}

void
NSRenderableEntity::HandleAnimEvent(float flTimeStamp, int iCode, string strData)
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
	case 5004: /* view model sound? */
		StartSound(strData, CHAN_AUTO, 0, true);
		break;
#ifdef CLIENT
	case 5001: /* muzzle flash on attachment 0 */
		EV_MuzzleFlash_Create(this, m_iNumBones, m_flMuzzleScale, m_iMuzzleModel);
		break;
	case 5011: /* muzzle flash on attachment 1 */
		EV_MuzzleFlash_Create(this, m_iNumBones + 1, m_flMuzzleScale, m_iMuzzleModel);
		break;
	case 5021: /* muzzle flash on attachment 2 */
		EV_MuzzleFlash_Create(this, m_iNumBones + 2, m_flMuzzleScale, m_iMuzzleModel);
		break;
	case 5031: /* muzzle flash on attachment 3 */
		EV_MuzzleFlash_Create(this, m_iNumBones + 3, m_flMuzzleScale, m_iMuzzleModel);
		break;
#else
	case 1003:	/* trigger SSQC entity with specific targetname */
		for (entity f = world; (f = find(f, ::targetname, strData));) {
			NSEntity trigger = (NSEntity)f;

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
				EntLog("Calling trigger '%s'", strData);
			}
		}
		break;
#endif
	default:
#ifdef SERVER
		int eDefEvents = tokenize(m_strModelEventCB);
		//print(sprintf("%i\n", eDefEvents));

		for (int i = 0; i < eDefEvents; i+=3) {
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

				tokenize(m_strModelEventCB); /* ensure argv() is 'rewound'... */
			}
		}
		
		//print(sprintf("Received: %f %i %S\n", flTimeStamp, iCode, strData));
		EntWarning("Unknown server model event: %f %i %S", flTimeStamp, iCode, strData);
#else
		EntWarning("Unknown client model event: %f %i %S", flTimeStamp, iCode, strData);
#endif
	}
}

#ifdef SERVER
void
NSRenderableEntity::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flBoneControl1", m_flBoneControl1);
	SaveFloat(handle, "m_flBoneControl2", m_flBoneControl2);
	SaveFloat(handle, "m_flBoneControl3", m_flBoneControl3);
	SaveFloat(handle, "m_flBoneControl4", m_flBoneControl4);
	SaveFloat(handle, "m_flBoneControl5", m_flBoneControl5);
	SaveFloat(handle, "modelflags", modelflags);
	SaveInt(handle, "m_iBody", m_iBody);
	SaveFloat(handle, "colormap", colormap);
	SaveVector(handle, "glowmod", glowmod);
	SaveFloat(handle, "m_flRenderAmt", m_flRenderAmt);
	SaveVector(handle, "m_vecRenderColor", m_vecRenderColor);
	SaveFloat(handle, "m_iRenderMode", m_iRenderMode);
	SaveFloat(handle, "m_iRenderFX", m_iRenderFX);
	SaveVector(handle, "m_vecAxialScale", m_vecAxialScale);
	SaveFloat(handle, "m_flBaseTime", m_flBaseTime);
}

void
NSRenderableEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flBoneControl1":
		m_flBoneControl1 = ReadFloat(strValue);
		break;
	case "m_flBoneControl2":
		m_flBoneControl2 = ReadFloat(strValue);
		break;
	case "m_flBoneControl3":
		m_flBoneControl3 = ReadFloat(strValue);
		break;
	case "m_flBoneControl4":
		m_flBoneControl4 = ReadFloat(strValue);
		break;
	case "m_flBoneControl5":
		m_flBoneControl5 = ReadFloat(strValue);
		break;
	case "modelflags":
		modelflags = ReadFloat(strValue);
		break;
	case "m_iBody":
		m_iBody = ReadInt(strValue);
		break;
	case "colormap":
		colormap = ReadFloat(strValue);
		break;
	case "glowmod":
		glowmod = ReadVector(strValue);
		break;
	case "m_flRenderAmt":
		m_flRenderAmt = ReadFloat(strValue);
		break;
	case "m_vecRenderColor":
		m_vecRenderColor = ReadVector(strValue);
		break;
	case "m_iRenderMode":
		m_iRenderMode = ReadFloat(strValue);
		break;
	case "m_iRenderFX":
		m_iRenderFX = ReadFloat(strValue);
		break;
	case "m_vecAxialScale":
		m_vecAxialScale = ReadVector(strValue);
		break;
	case "m_flBaseTime":
		m_flBaseTime = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSRenderableEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Color":
		SetRenderColor(stov(strData) / 255);
		break;
	case "Alpha":
		SetRenderAmt(stof(strData) / 255);
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
		//print(sprintf("SetAnimation: %S (%d) on %S\n",strData, animFrame, model));
		break;
	case "SetBodyInGroup":
		int argC = tokenize(strData);

		if (argC == 2) {
			int bodyGroup = stoi(argv(0));
			int bodyModel = stoi(argv(1));
			SetBodyInGroup(bodyGroup, bodyModel);
			//print(sprintf("SetBodyInGroup %i to %i\n", bodyGroup, bodyModel));
		}
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
#endif

void
NSRenderableEntity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "body":
		m_iBody = ReadInt(strValue);
		break;
	case "body0":
		SetBodyInGroup(0, ReadInt(strValue));
		break;
	case "body1":
		SetBodyInGroup(1, ReadInt(strValue));
		break;
	case "body2":
		SetBodyInGroup(2, ReadInt(strValue));
		break;
	case "body3":
		SetBodyInGroup(3, ReadInt(strValue));
		break;
	case "modelscale":
	case "scale":
		scale = ReadFloat(strValue);
		break;
	case "modelstretch":
	case "axialscale":
		m_vecAxialScale = ReadVector(strValue);
		break;
	case "skin":
		skin = ReadFloat(strValue);
		break;
	case "shadows":
		if (stof(strValue) == 1) {
			effects &= ~EF_NOSHADOW;
		}
		break;
	/* Source */
	case "disableshadows":
		if (stof(strValue) == 1) {
			effects |= EF_NOSHADOW;
		}
		break;
	case "renderamt":
		m_flRenderAmt = ReadFloat(strValue) / 255;
#ifdef SERVER
		m_oldflRenderAmt = m_flRenderAmt;
#endif
		break;
	case "rendercolor":
		m_vecRenderColor = ReadVector(strValue) / 255;
#ifdef SERVER
		m_oldvecRenderColor = m_vecRenderColor;
#endif
		break;
	case "rendermode":
		m_iRenderMode = ReadFloat(strValue);
#ifdef SERVER
		m_oldiRenderMode = m_iRenderMode;
#endif
		break;
	case "renderfx":
		m_iRenderFX = ReadFloat(strValue);
#ifdef SERVER
		m_oldiRenderFX = m_iRenderFX;
#endif
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}
