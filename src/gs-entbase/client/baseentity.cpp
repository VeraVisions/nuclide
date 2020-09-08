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

/* a lot of the rendering info is assembled with the following url:
 * https://sites.google.com/site/svenmanor/rendermodes
 * for reference. I thank thee fellow soldiers at sven manor! */

var int autocvar_cl_showtriggers = FALSE;

string __fullspawndata;
string Sentences_GetSamples(string);
string Sentences_ProcessSample(string);

#ifdef GS_RENDERFX
void
CBaseEntity::RenderFXPass(void)
{
	vector vecPlayer;
#ifdef WASTES
	vecPlayer = [0,0,0];
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;
#endif

	colormod = m_vecRenderColor;
	alpha = m_flRenderAmt;

	switch (m_iRenderMode) {
	case RM_NORMAL:
		alpha = 1.0f;
		break;
	case RM_COLOR:
		break;
	case RM_TEXTURE:
		drawflags = 7;
		abslight = 255;
		break;
	case RM_GLOW:
		if (checkpvs(vecPlayer, this) == FALSE) {
			alpha -= clframetime;
		}

		other = world;
		traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

		/* If we can't trace against the player, or are two close, fade out */
		if (trace_fraction < 1.0f || vlen(origin - vecPlayer) < 128) {
			alpha -= clframetime; 
		} else {
			alpha += clframetime;
		}

		alpha = bound(0, alpha, 1.0f);
		effects = EF_ADDITIVE | EF_FULLBRIGHT;

		if (alpha > 0) {
			float falpha;
			
			/* Scale the glow somewhat with the players distance */
			scale = bound(1, vlen(vecPlayer - origin) / 256, 4);
			
			/* Fade out when the player is starting to move away */
			falpha = 1 - bound(0, vlen(vecPlayer - origin) / 1024, 1);
			falpha *= alpha;
			
			/* Clamp the alpha by the glows' renderamt value */
			alpha = bound(0, falpha, m_flRenderAmt);
		}
		break;
	case RM_SOLID:
		break;
	case RM_ADDITIVE:
		effects = EF_ADDITIVE;
		drawflags = 7;
		abslight = 255;
		break;
	case RM_FULLBRIGHT:
		alpha = 1.0f;
		drawflags = 7;
		abslight = 255;
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
	}

	/* messy hologram imitation */
	if (m_iRenderFX == RFX_HOLOGRAM) {
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
	}
}
#endif

float
CBaseEntity::predraw(void)
{
	if (!modelindex) {
		return PREDRAW_NEXT;
	}

#ifdef GS_RENDERFX
	RenderFXPass();
#endif

	/* mouth flapping action */
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;
	frame1time += clframetime;
	ProcessWordQue();

	if (alpha > 0.0)
		addentity(this);

	return PREDRAW_NEXT;
}

void
CBaseEntity::ProcessWordQue(void)
{
	if (time < 1 || !m_iSentenceCount) {
		return;
	}

	if (m_flSentenceTime > time) {
		return;
	}

	sound(this, CHAN_VOICE, m_pSentenceQue[m_iSentencePos].m_strSnd, 1.0, ATTN_NORM, 100, SOUNDFLAG_FOLLOW);
	dprint(sprintf("^2CBaseEntity::^3ProcessWordQue^7: Speaking %s\n", m_pSentenceQue[m_iSentencePos].m_strSnd));
	m_iSentencePos++;

	if (m_iSentencePos == m_iSentenceCount) {
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_iSentencePos = 0;
		m_pSentenceQue = 0;
	} else {
		m_flSentenceTime = time + m_pSentenceQue[m_iSentencePos - 1].m_flLength;
	}
}

/* we'll pass it a sentences.txt word (e.g. !BA_TEST) and start queing it */
void
CBaseEntity::Sentence(string msg)
{
	/* not defined */
	if (msg == "") {
		return;
	}

	if (m_iSentenceCount) {
		memfree(m_pSentenceQue);
		m_iSentenceCount = 0;
		m_pSentenceQue = 0;
		m_iSentencePos = 0;
	}

	m_iSentenceCount = tokenize(Sentences_GetSamples(msg));
	m_pSentenceQue = memalloc(sizeof(sound_t) * m_iSentenceCount);

	/* first we have to get the info out of the token */
	for (int i = 0; i < m_iSentenceCount; i++) {
		m_pSentenceQue[i].m_strSnd = sprintf("%s.wav", argv(i));
	}

	/* process more info, we'll need to override argv() here */
	for (int i = 0; i < m_iSentenceCount; i++) {
		m_pSentenceQue[i].m_strSnd = Sentences_ProcessSample(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flLength = soundlength(m_pSentenceQue[i].m_strSnd);
		m_pSentenceQue[i].m_flPitch = 100;
	}
	m_flSentenceTime = time;
}

void CBaseEntity::ReadEntity(float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		modelindex = readshort();
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
		frame1time = 0.0;
		frame2time = 0.0f;
		frame = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & BASEFL_CHANGED_EFFECTS) {
		effects = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_BODY) {
		m_iBody = readbyte();
		setcustomskin(this, "", sprintf("geomset 1 %i\n", m_iBody));
	}
	if (flChanged & BASEFL_CHANGED_SCALE) {
		scale = readfloat();
	}

#ifdef GS_RENDERFX
	if (flChanged & BASEFL_CHANGED_RENDERFX) {
		m_iRenderFX = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
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

	setorigin(this, origin);
	setsize(this, mins, maxs);
}

void CBaseEntity::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		/* compiler specific stuff */
		case "angle":
		case "_minlight":
		case "_cs":
			break;
		case "shadows":
			if (stof(strKey) == 1) {
				effects &= ~EF_NOSHADOW;
			}
			break;
		case "targetname":
			targetname = strKey;
			break;
		case "target":
			target = strKey;
			break;
		case "origin":
			origin = stov(strKey);
			setorigin(this, origin);
			break;
		case "angles":
			angles = stov(strKey);
			break;
		case "model":
			model = strKey;
			break;
		case "style":
			style = stof(strKey);
			break;
		case "color":
			color = stov(strKey);
			break;
		case "movetype":
			movetype = stof(strKey);
			break;
		case "solid":
			solid = stof(strKey);
			break;
		case "scale":
			scale = stof(strKey);
			break;
		case "spawnflags":
			spawnflags = stof(strKey);
			break;
		default:
#ifdef GS_DEVELOPER
			print(sprintf("%s::SpawnKey: Unknown '%s' value '%s'\n", 
				this.classname, strField, strKey));
#endif
	}
}

void
CBaseEntity::postdraw(void)
{
}

void
CBaseEntity::customphysics(void)
{
	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void CBaseEntity::Init(void)
{
	isCSQC = TRUE;
	effects |= EF_NOSHADOW;
	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}
	Initialized();
}

void CBaseEntity::Initialized(void)
{
}

void CBaseEntity::CBaseEntity(void)
{
}

/* our EV_SENTENCE event */
void
CBaseEntity_ParseSentence(void)
{
	entity ent;
	CBaseEntity targ;
	string sentence;
	float e;

	/* parse packets */
	e = readentitynum();
	sentence = readstring();

	ent = findfloat(world, entnum, e);

	if (ent) {
		targ = (CBaseEntity)ent;
		targ.Sentence(sentence);
	} else {
		print(sprintf("^3CBaseNPC_ParseSentence^7: Entity %d not in PVS\n", e));
	}
}
