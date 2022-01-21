/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
#ifdef GS_RENDERFX
	if (m_iRenderMode > RM_FULLBRIGHT)
		return;

	RenderFXPass();
#endif

	/* static ents = no collision, so let's make a copy for visibility */
	if (alpha > 0.0)
		makestatic(copyentity(this));

	/* now *this* is only used for csqc collision */
	drawmask = 0;
#endif
}

#ifdef SERVER
/* Make sure StartFrame calls this */
float
NSRenderableEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_ENTITYRENDERABLE);

	/* newly popped into the PVS, sadly this is the only hacky way to check
	 * for this right now. convince the engine maintainer to make this more sensible */
	if (fChanged == 0xFFFFFF) {
		/* check for defaults. if these are predictable fields, don't even bother
		 * networking them! you're just wasting bandwidth. */
		if (frame == 0)
			fChanged &= ~BASEFL_CHANGED_FRAME;
		if (skin == 0)
			fChanged &= ~BASEFL_CHANGED_SKIN;
		if (effects == 0)
			fChanged &= ~BASEFL_CHANGED_EFFECTS;
		if (m_iBody == 0)
			fChanged &= ~BASEFL_CHANGED_BODY;
		if (scale == 0.0 || scale == 1.0)
			fChanged &= ~BASEFL_CHANGED_SCALE;
		if (origin == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ORIGIN;
		if (angles == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ANGLES;
		if (velocity == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_VELOCITY;
		if (mins == [0,0,0] && maxs == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_SIZE;
		if (solid == SOLID_NOT)
			fChanged &= ~BASEFL_CHANGED_SOLID;
		if (movetype == MOVETYPE_NONE)
			fChanged &= ~BASEFL_CHANGED_MOVETYPE;
#ifdef GS_RENDERFX
		if (m_iRenderMode == RM_NORMAL)
			fChanged &= ~BASEFL_CHANGED_RENDERMODE;
#endif
	}

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

#ifdef GS_RENDERFX
	/* let's not waste networking power on certain render-modes where they would
	 * not apply anyway. this seems sensible enough. */
	if (m_iRenderMode == RM_NORMAL || m_iRenderMode == RM_TRIGGER) {
		if (!glowmod) /* FIXME: Get rid of this, network this hack on its own. */
			fChanged &= ~BASEFL_CHANGED_RENDERCOLOR;
		fChanged &= ~BASEFL_CHANGED_RENDERAMT;
	}
#endif

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & BASEFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & BASEFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & BASEFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
		WriteByte(MSG_ENTITY, colormap);
	}
	if (fChanged & BASEFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & BASEFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & BASEFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & BASEFL_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
		WriteByte(MSG_ENTITY, frame1time);
	}
	if (fChanged & BASEFL_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & BASEFL_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & BASEFL_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}
	if (fChanged & BASEFL_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (fChanged & BASEFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

#ifdef GS_RENDERFX
	if (fChanged & BASEFL_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}

	if (fChanged & BASEFL_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
		WriteFloat(MSG_ENTITY, glowmod[0]);
		WriteFloat(MSG_ENTITY, glowmod[1]);
		WriteFloat(MSG_ENTITY, glowmod[2]);
	}
	if (fChanged & BASEFL_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
#else
	if (fChanged & BASEFL_CHANGED_ALPHA) {
		WriteFloat(MSG_ENTITY, alpha);
	}
#endif

	return (1);
}
#else
#ifdef GS_RENDERFX
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
	vector vecPlayer;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

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
		alpha = (m_flRenderAmt == 0.0) ? 0.0f : 1.0f;
		break;
	case RM_ADDITIVE:
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
	case RM_TRIGGER:
		if (autocvar_cl_showtriggers) {
			effects = EF_FULLBRIGHT;
			alpha = 0.75f;
			colormod = [1,0,0];
		} else {
			alpha = 0.0f;
		}
		break;
	case RM_DONTRENDER:
		/* prevent addentity() from being called */
		alpha = 0.0f;
	}

	switch (m_iRenderFX) {
	case RFX_SLOWPULSE:
		alpha = sin(cltime * 0.5);
		break;
	case RFX_FASTPULSE:
		alpha = sin(cltime * 2.0);
		break;
	case RFX_SLOWWIDEPULSE:
		alpha = sin(cltime * 0.5);
		break;
	case RFX_FASTWIDEPULSE:
		alpha = sin(cltime * 2.0);
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
	default:
		break;
	}

	/* HACK: This marks this entity as alphatested in platform's defaultwall.glsl */
	if (m_iRenderMode != RM_NORMAL) {
		glowmod[0] = 0.5f;
	} else {
		glowmod[0] = 1.0f;
	}
}
#endif
/*
============
NSRenderableEntity::ReceiveEntity
============
*/
void
NSRenderableEntity::ReceiveEntity(float flNew, float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
		colormap = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & BASEFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_FRAME) {
		frame = readbyte();
		frame1time =
		frame2time = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & BASEFL_CHANGED_EFFECTS) {
		effects = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_BODY) {
		m_iBody = readbyte();
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	}
	if (flChanged & BASEFL_CHANGED_SCALE) {
		scale = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

#ifdef GS_RENDERFX
	if (flChanged & BASEFL_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
		m_iRenderFX = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
		glowmod[0] = readfloat();
		glowmod[1] = readfloat();
		glowmod[2] = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_RENDERAMT) {
		m_flRenderAmt = readfloat();
	}
#else
	if (flChanged & BASEFL_CHANGED_ALPHA) {
		alpha = readfloat();
	}
#endif

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & BASEFL_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);

	setorigin(this, origin);
}
/*
============
NSEntity::predraw

a lot of the things in here don't even apply to most
entities, so TODO: make things like anims, sentences apply
only to relevant child-classes
============
*/
float
NSRenderableEntity::predraw(void)
{
	if (!modelindex) {
		return (PREDRAW_NEXT);
	}

#ifdef GS_RENDERFX
	RenderFXPass();
#endif

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

	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1)
		frame1time += frametime;

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, ClientGame_ModelEvent);

	if (alpha > 0.0)
		addentity(this);

	return (PREDRAW_NEXT);
}
#endif

#ifdef SERVER
void
NSRenderableEntity::Respawn(void)
{
	NSEntity::Respawn();

#ifdef GS_RENDERFX
	SetRenderFX(m_oldiRenderFX);
	SetRenderMode(m_oldiRenderMode);
	SetRenderAmt(m_oldflRenderAmt);
	SetRenderColor(m_oldvecRenderColor);
#endif
}

void
NSRenderableEntity::Show(void)
{
}

void
NSRenderableEntity::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	takedamage = DAMAGE_NO;
}
#endif

void
NSRenderableEntity::SetEffects(float newEffects)
{
	if (newEffects == effects)
		return;

	effects = newEffects;
	SetSendFlags(BASEFL_CHANGED_EFFECTS);
}
void
NSRenderableEntity::SetFrame(float newFrame)
{
	if (newFrame == frame)
		return;

	frame = newFrame;
	frame1time = 0.0f;
	SetSendFlags(BASEFL_CHANGED_FRAME);
}
void
NSRenderableEntity::SetSkin(float newSkin)
{
	if (newSkin == skin)
		return;

	skin = newSkin;
	SetSendFlags(BASEFL_CHANGED_SKIN);
}
void
NSRenderableEntity::SetBody(int newBody)
{
	if (newBody == m_iBody)
		return;

	m_iBody = newBody;
	SetSendFlags(BASEFL_CHANGED_BODY);
}
void
NSRenderableEntity::SetScale(float newScale)
{
	if (newScale == scale)
		return;

	scale = newScale;
	setsize(this, m_vecMins * scale, m_vecMaxs * scale);
	SetSendFlags(BASEFL_CHANGED_SCALE);
}

#ifdef GS_RENDERFX
void
NSRenderableEntity::SetRenderFX(float newFX)
{
	if (newFX == m_iRenderFX)
		return;

	m_iRenderFX = newFX;
	SetSendFlags(BASEFL_CHANGED_RENDERMODE);
}
void
NSRenderableEntity::SetRenderMode(float newMode)
{
	if (newMode == m_iRenderMode)
		return;

	m_iRenderMode = newMode;
	SetSendFlags(BASEFL_CHANGED_RENDERMODE);
}
void
NSRenderableEntity::SetRenderAmt(float newAmt)
{
	if (newAmt == m_flRenderAmt)
		return;

	m_flRenderAmt = newAmt;
	SetSendFlags(BASEFL_CHANGED_RENDERAMT);
}
void
NSRenderableEntity::SetRenderColor(vector newColor)
{
	if (newColor == m_vecRenderColor)
		return;

	m_vecRenderColor = newColor;
	SetSendFlags(BASEFL_CHANGED_RENDERCOLOR);
}
#endif


#ifdef SERVER
void
NSRenderableEntity::Save(float handle)
{
	SaveInt(handle, "body", m_iBody);
	SaveFloat(handle, "frame", frame);
	SaveFloat(handle, "scale", scale);
	SaveFloat(handle, "skin", skin);
	SaveFloat(handle, "effects", effects);

#ifndef GS_RENDERFX
	SaveVector(handle, "color", colormod);
	SaveFloat(handle, "alpha", alpha);
#else
	SaveFloat(handle, "renderamt", m_flRenderAmt);
	SaveVector(handle, "rendercolor", m_vecRenderColor);
	SaveFloat(handle, "rendermode", m_iRenderMode);
	SaveFloat(handle, "renderfx", m_iRenderFX);
#endif

	super::Save(handle);
}
void
NSRenderableEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "body":
		m_iBody = stoi(strValue);
		break;
	case "frame":
		frame = stof(strValue);
		break;
	case "scale":
		scale = stof(strValue);
		break;
	case "skin":
		skin = stof(strValue);
		break;
	case "effects":
		effects = stof(strValue);
		break;
#ifndef GS_RENDERFX
	case "color":
		colormod = stov(strValue);
		break;
	case "alpha":
		alpha = stof(strValue);
		break;
#else
	case "renderamt":
		m_flRenderAmt = stof(strValue) / 255;
		break;
	case "rendercolor":
		m_vecRenderColor = stov(strValue) / 255;
		break;
	case "rendermode":
		m_iRenderMode = stof(strValue);
		break;
	case "renderfx":
		m_iRenderFX = stof(strValue);
		break;
#endif
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSRenderableEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Color":
#ifdef GS_RENDERFX
		SetRenderColor(stov(strData) / 255);
#else
		colormod = stov(strData) / 255;
#endif
		break;
	case "Alpha":
#ifdef GS_RENDERFX
		SetRenderAmt(stof(strData) / 255);
#else
		alpha = stof(strData) / 255;
#endif
		break;
	case "DisableShadow":
		effects |= EF_NOSHADOW;
		break;
	case "EnableShadow":
		effects &= ~EF_NOSHADOW;
		break;
	default:
		NSEntity::Input(eAct, strInput, strData);
	}
}
#endif

void
NSRenderableEntity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "body":
		m_iBody = stoi(strValue);
		break;
	case "modelscale":
	case "scale":
		scale = stof(strValue);
		break;
	case "skin":
		skin = stof(strValue);
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
	case "color":
#ifdef GS_RENDERFX
		m_vecRenderColor = stov(strValue);
#else
		colormod = stov(strValue);
#endif
		break;
	case "alpha":
#ifdef GS_RENDERFX
		m_flRenderAmt = stof(strValue);
#else
		alpha = stof(strValue);
#endif
		break;
#ifdef GS_RENDERFX
	case "renderamt":
		m_flRenderAmt = stof(strValue) / 255;
		break;
	case "rendercolor":
		m_vecRenderColor = stov(strValue) / 255;
		break;
	case "rendermode":
		m_iRenderMode = stof(strValue);
		break;
	case "renderfx":
		m_iRenderFX = stof(strValue);
		break;
#endif
	default:
		NSEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSRenderableEntity::NSRenderableEntity(void)
{
	effects |= EF_NOSHADOW;
	//scale = 1.0f;

	super::NSEntity();

#ifdef SERVER
#ifdef GS_RENDERFX
	m_oldiRenderFX = m_iRenderFX;
	m_oldiRenderMode = m_iRenderMode;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
#endif
#endif
}
