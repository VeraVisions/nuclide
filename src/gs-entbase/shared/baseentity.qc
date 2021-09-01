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

#ifdef CLIENT
var int autocvar_cl_showtriggers = FALSE;
var int autocvar_rm_unlit_additive = TRUE;
var int autocvar_rm_unlit_texture = TRUE;

string __fullspawndata;
string Sentences_GetSamples(string);
string Sentences_ProcessSample(string);

void
CBaseEntity::RendererRestarted(void)
{
	
};

#ifdef GS_RENDERFX
void
CBaseEntity::RenderFXPass(void)
{
	vector vecPlayer;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	colormod = m_vecRenderColor;
	alpha = m_flRenderAmt;

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
		alpha = 1.0f;
		break;
	case RM_ADDITIVE:
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
		drawflags = 7;
		abslight = 128;
	}
}
#endif

void
CBaseEntity::MakeStatic(void)
{
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
}

var int autocvar_r_showSkeleton = 0;
float
CBaseEntity::predraw(void)
{
	if (!modelindex) {
		return (PREDRAW_NEXT);
	}

#ifdef GS_RENDERFX
	RenderFXPass();
#endif

	if (autocvar_r_showSkeleton == 1) {
		for (int i = 1; i < 64; i++) {
			vector v1 = gettaginfo(this, i);

			if (v1 != this.origin) {
				makevectors(input_angles);
				R_BeginPolygon("textures/dev/model_bone", 0, 0);
				R_PolygonVertex(v1 + v_right * 1 - v_up * 1, [1,1], [1,1,1], 1.0f);
				R_PolygonVertex(v1 - v_right * 1 - v_up * 1, [0,1], [1,1,1], 1.0f);
				R_PolygonVertex(v1 - v_right * 1 + v_up * 1, [0,0], [1,1,1], 1.0f);
				R_PolygonVertex(v1 + v_right * 1 + v_up * 1, [1,0], [1,1,1], 1.0f);
				R_EndPolygon();
				alpha = 0.25f;
			}
		}
	}

	/* mouth flapping action */
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;
	m_flBaseTime = frame1time;

	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1)
		frame1time += frametime;

	ProcessWordQue();

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, ClientGame_ModelEvent);

	if (alpha > 0.0)
		addentity(this);

	return (PREDRAW_NEXT);
}

void
CBaseEntity::SentenceSample(string sample)
{
	sound(this, CHAN_VOICE, sample, 1.0, ATTN_NORM, 100, SOUNDFLAG_FOLLOW);
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

	SentenceSample(m_pSentenceQue[m_iSentencePos].m_strSnd);

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

void
CBaseEntity::ReceiveEntity(float flChanged)
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
		setsize(this, mins, maxs);
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
	if (flChanged & BASEFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
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

	if (scale == 0.0)
		scale = 1.0f;

	setorigin(this, origin);
}

void
CBaseEntity::postdraw(void)
{
}

void
CBaseEntity::Init(void)
{
	isCSQC = TRUE;
	effects |= EF_NOSHADOW;

	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2)
		SpawnKey(argv(i), argv(i+1));

	Initialized();
}

void
CBaseEntity::Initialized(void)
{
}

void
CBaseEntity::CBaseEntity(void)
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
#else
/* Input/Output system */
void
CBaseEntity::UseOutput(entity act, string outname)
{
	if (!outname)
		return;

	for (entity f = world; (f = find(f, ::targetname, outname));) {
		CBaseOutput op = (CBaseOutput)f;

		/* no more tries and not -1 (infinite) */
		if (op.m_iCount == 0) {
			return;
		}

		op.m_eActivator = act;
		op.think = CBaseOutput::TriggerOutput;
		op.nextthink = time + op.m_flDelay;
	}
}

/* input is a 5 parameter, commar separated string, output is the targetname
   of a minion entity that'll handle the triggering (and counting down of uses)
   as defined in the Source Input/Output specs */
string
CBaseEntity::CreateOutput(string outmsg)
{
	static int outcount = 0;
	string outname = "";
	float c;

	if (!outmsg)
		return ("");

	outname = sprintf("output_%i\n", outcount);
	outcount++;

	/* to make sure tokenize 'remembers' to tell us about the commonly
	   empty data string, we prepared the output string beforehand to
	   at least contain a _ symbol after the comma separator... now
	   we gotta clip that away using substring(). messy, but that's the
	   only way to keep them at 5 argv() calls per output */
	c = tokenizebyseparator(outmsg, ",");
	for (float i = 1; i < c; i+=5) {
		CBaseOutput new_minion = spawn(CBaseOutput);

		new_minion.classname = "triggerminion";
		new_minion.targetname = outname;
		new_minion.m_strTarget = substring(argv(i), 1,-1);
		new_minion.m_strInput = substring(argv(i+1), 1,-1);
		new_minion.m_strData = substring(argv(i+2), 1,-1);
		new_minion.m_flDelay = stof(substring(argv(i+3), 1,-1));
		new_minion.m_iCount = stoi(substring(argv(i+4), 1,-1));
		new_minion.m_iOldCount = new_minion.m_iCount;

		/* print final debug output */
		dprint(sprintf("^2%s::CreateOutput report:\n", classname));
		dprint(sprintf("Target: %s\n", new_minion.m_strTarget));
		dprint(sprintf("Input: %s\n", new_minion.m_strInput));
		dprint(sprintf("Data Message: %s\n", new_minion.m_strData));
		dprint(sprintf("Delay: %f\n", new_minion.m_flDelay));
		dprint(sprintf("Uses: %i\n\n", new_minion.m_iCount));
	}

	/* return the name that'll act as the trigger for all outputs */
	return outname;
}

/* entities receive the inputs here and need to act on intype and data
   accordingly. this is just a stub for unknown event troubleshooting */
void
CBaseEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Kill":
		think = Util_Destroy;
		nextthink = time;
		break;
	case "KillHierarchy":
		/* this works because ents are basically just entnums */
		for (entity e = world; (e=findfloat(e, ::owner, this));) {
			e.think = Util_Destroy;
			e.nextthink = time;
		}
		think = Util_Destroy;
		nextthink = time;
		break;
	case "FireUser1":
		UseOutput(eAct, m_strOnUser1);
		break;
	case "FireUser2":
		UseOutput(eAct, m_strOnUser2);
		break;
	case "FireUser3":
		UseOutput(eAct, m_strOnUser3);
		break;
	case "FireUser4":
		UseOutput(eAct, m_strOnUser4);
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
	default:
		if (strData != "")
		print(sprintf("^2%s::^3Input^7: Receives input %s from %s with data %s\n", 
			this.classname, strInput, eAct.classname, strData));
		else
		print(sprintf("^2%s::^3Input^7: Receives input %s from %s\n", 
			this.classname, strInput, eAct.classname));
	}
}

/* Make sure StartFrame calls this */
float
CBaseEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_ENTITY);

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
	if (fChanged & BASEFL_CHANGED_RENDERFX) {
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}
	if (fChanged & BASEFL_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
	}

	if (fChanged & BASEFL_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
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

void
CBaseEntity::Pain(void)
{
	
}

void
CBaseEntity::Death(void)
{
	
}

void
CBaseEntity::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (net_origin != origin) {
		net_origin = origin;
		SendFlags |= BASEFL_CHANGED_ORIGIN;
	}
	if (net_angles != angles) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		net_angles = angles;
		SendFlags |= BASEFL_CHANGED_ANGLES;
	}
	if (net_velocity != velocity) {
		net_velocity = velocity;
		SendFlags |= BASEFL_CHANGED_VELOCITY;
	}
}

/* Make sure StartFrame calls this */
void
CBaseEntity::ParentUpdate(void)
{
	EvaluateEntity();

	frame1time += frametime;

	if (m_parent) {
		entity p = find(world, ::targetname, m_parent);

		if (p)
			SetOrigin(p.origin);
	}
}

void
CBaseEntity::SpawnInit(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}

	/* some entity might involuntarily call SpawnInit as part of being
	   a member of CBaseEntity. So we need to make sure that it doesn't
	   inherit stuff from the last previously loaded entity */
	__fullspawndata = "";
}

void
CBaseEntity::Respawn(void)
{
	health = m_oldHealth;
	SetModel(m_oldModel);
	SetSolid(m_oldSolid);
	SetAngles(m_oldAngle);
	SetOrigin(m_oldOrigin);
	target = m_oldstrTarget;

#ifdef GS_RENDERFX
	SetRenderFX(m_oldiRenderFX);
	SetRenderMode(m_oldiRenderMode);
	SetRenderAmt(m_oldflRenderAmt);
	SetRenderColor(m_oldvecRenderColor);
#endif
}

void
CBaseEntity::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	takedamage = DAMAGE_NO;
}

void
CBaseEntity::CBaseEntity(void)
{
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			remove(this);
			return;
		}
	}

	identity = 1;
	effects |= EF_NOSHADOW;
	scale = 1.0f;

	SpawnInit();

	m_oldAngle = angles;
	m_oldOrigin = origin;
	m_oldSolid = solid;
	m_oldHealth = health;
	m_oldModel = Util_FixModel(model);

	/* Input/Output system */
	m_strOnTrigger = CreateOutput(m_strOnTrigger);
	m_strOnUser1 = CreateOutput(m_strOnUser1);
	m_strOnUser2 = CreateOutput(m_strOnUser2);
	m_strOnUser3 = CreateOutput(m_strOnUser3);
	m_strOnUser4 = CreateOutput(m_strOnUser4);

#ifdef GS_RENDERFX
	m_oldiRenderFX = m_iRenderFX;
	m_oldiRenderMode = m_iRenderMode;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
#endif

	m_oldstrTarget = target;

	if (m_oldModel != "") {
		precache_model(m_oldModel);
	}
}
#endif

/* we want to really use those set functions because they'll notify of any
 * networking related changes. otherwise we'll have to keep track of copies
 * that get updated every frame */
void
CBaseEntity::SetSendFlags(float flSendFlags)
{
#ifdef SERVER
	SendFlags |= flSendFlags;
#endif
}

void
CBaseEntity::SetEffects(float newEffects)
{
	if (newEffects == effects)
		return;

	effects = newEffects;
	SetSendFlags(BASEFL_CHANGED_EFFECTS);
}
void
CBaseEntity::SetFrame(float newFrame)
{
	if (newFrame == frame)
		return;

	frame = newFrame;
	frame1time = 0.0f;
	SetSendFlags(BASEFL_CHANGED_FRAME);
}
void
CBaseEntity::SetModel(string newModel)
{
	model = newModel;
	setmodel(this, newModel);
	SetSendFlags(BASEFL_CHANGED_MODELINDEX);
}
void
CBaseEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex)
		return;

	modelindex = newModelIndex;
	SetSendFlags(BASEFL_CHANGED_MODELINDEX);
}
void
CBaseEntity::SetMovetype(float newMovetype)
{
	if (newMovetype == movetype)
		return;

	movetype = newMovetype;
	SetSendFlags(BASEFL_CHANGED_MOVETYPE);
}
void
CBaseEntity::SetSkin(float newSkin)
{
	if (newSkin == skin)
		return;

	skin = newSkin;
	SetSendFlags(BASEFL_CHANGED_SKIN);
}
void
CBaseEntity::SetSolid(float newSolid)
{
	if (newSolid == solid)
		return;

	solid = newSolid;
	SetSendFlags(BASEFL_CHANGED_SOLID);
}
void
CBaseEntity::SetBody(int newBody)
{
	if (newBody == m_iBody)
		return;

	m_iBody = newBody;
	SetSendFlags(BASEFL_CHANGED_BODY);
}
void
CBaseEntity::SetScale(float newScale)
{
	if (newScale == scale)
		return;

	scale = newScale;
	SetSendFlags(BASEFL_CHANGED_SCALE);
}
void
CBaseEntity::SetAngles(vector newAngles)
{
	if (newAngles == angles)
		return;

	angles = newAngles;
	SetSendFlags(BASEFL_CHANGED_ANGLES);
}
void
CBaseEntity::SetSize(vector newMins, vector newMaxs)
{
	if (newMins == mins && newMaxs == maxs)
		return;

	setsize(this, newMins, newMaxs);
	SetSendFlags(BASEFL_CHANGED_SIZE);
}
void
CBaseEntity::SetOrigin(vector newOrigin)
{
	if (newOrigin == origin)
		return;

	setorigin(this, newOrigin);
	SetSendFlags(BASEFL_CHANGED_ORIGIN);
}

#ifdef GS_RENDERFX
void
CBaseEntity::SetRenderFX(int newFX)
{
	if (newFX == m_iRenderFX)
		return;

	m_iRenderFX = newFX;
	SetSendFlags(BASEFL_CHANGED_RENDERFX);
}
void
CBaseEntity::SetRenderMode(float newMode)
{
	if (newMode == m_iRenderMode)
		return;

	m_iRenderMode = newMode;
	SetSendFlags(BASEFL_CHANGED_RENDERMODE);
}
void
CBaseEntity::SetRenderAmt(float newAmt)
{
	if (newAmt == m_flRenderAmt)
		return;

	m_flRenderAmt = newAmt;
	SetSendFlags(BASEFL_CHANGED_RENDERAMT);
}
void
CBaseEntity::SetRenderColor(vector newColor)
{
	if (newColor == m_vecRenderColor)
		return;

	m_vecRenderColor = newColor;
	SetSendFlags(BASEFL_CHANGED_RENDERCOLOR);
}
#endif

void
CBaseEntity::SpawnKey(string strKey, string strValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "scale":
		scale = stof(strValue);
		break;
	case "origin":
		origin = stov(strValue);
		break;
	case "angles":
		angles = stov(strValue);
		break;
	case "angle":
		angles[1] = stof(strValue);
		break;
	case "solid":
		solid = stof(strValue);
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
		break;
	case "targetname":
		targetname = strValue;
		break;
	case "target":
		target = strValue;
		break;
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
		m_iRenderMode = stoi(strValue);
		break;
	case "renderfx":
		m_iRenderFX = stoi(strValue);
		break;
#endif
	case "model":
		model = strValue;
		break;
	case "classname":
	case "spawnflags":
		break;
#ifdef SERVER
	case "health":
		health = stof(strValue);
		break;
	case "parentname":
		m_parent = strValue;
		break;
	case "ignorepvs":
		pvsflags = PVSF_IGNOREPVS;
		break;
	/* Input/Output system */
	case "OnTrigger":
		strValue = strreplace(",", ",_", strValue);
		m_strOnTrigger = strcat(m_strOnTrigger, ",_", strValue);
		break;
	case "OnUser1":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser1 = strcat(m_strOnUser1, ",_", strValue);
		break;
	case "OnUser2":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser2 = strcat(m_strOnUser2, ",_", strValue);
		break;
	case "OnUser3":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser3 = strcat(m_strOnUser3, ",_", strValue);
		break;
	case "OnUser4":
		strValue = strreplace(",", ",_", strValue);
		m_strOnUser4 = strcat(m_strOnUser4, ",_", strValue);
		break;
#endif
	default:
		print(sprintf("^3%s^7::SpawnKey:: Unknown key '%s' with value '%s'\n",
		      classname, strKey, strValue));
		break;
	}
}
