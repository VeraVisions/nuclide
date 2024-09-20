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

/* TODO: Implement these */
enumflags
{
	FNCTANK_ACTIVE,
	FNCTANK_UNUSED1,
	FNCTANK_UNUSED2,
	FNCTANK_UNUSED3,
	FNCTANK_DIRECTONLY,
	FNCTANK_CONTROLLABLE
};

/*! \brief Shared-Entity: Mountable Mortar Turret */
/*!QUAKED func_tankmortar (0 .5 .8) ?
# OVERVIEW
A mountable tank mortar turret type entity. A player (or NPC) can interact with
it and shoot it. It's in the same family as the func_tank entity, the
difference being that this shoots mortar blasts and not bullets.

# KEYS
- "targetname" : Name
- "yawrate" : The speed of the left/right movement of the mortar.
- "yawrange" : Range of left/right movement in degrees.
- "pitchrate" : The speed of the up/down movement of the mortar.
- "pitchrange" : Range of up/down movement in degrees.
- "barrel" : Distance from origin to barrel tip in units.
- "barrely" : Horizontal distance origin to the center of the barrel tip.
- "barrelz" : Vertical distance origin to the center of the barrel tip.
- "firerate" : Number of bullets fired per second.
- "iMagnitude" : Power of each explosion.
- "firespread" : Accuracy of the mortar. 0 is best, 4 is worst.
- "persistance" : Time in seconds for how long an NPC might continue shooting.
- "minRange" : Minimum range the target can be at for an NPC to fire.
- "maxRange" : Maximum range the target can be at for an NPC to fire.
- "spritesmoke" : Sprite to spawn for 'smoke' when the entity is fired.
- "spriteflash" : Sprite to spawn for a 'muzzleflash' when the entity is fired.
- "spritescale" : Scale multiplier for both smoke and flash sprites.
- "rotatesound" : Sound file to play in a loop while barrel is rotating.

# NOTES
I don't like the sprite stuff tacked on at all because of the extra networking
involved and because it's so awfully GoldSrc specific.
Eventually I need to design a more generic routine that allows people to just
refer to materials with the appropriate blend-modes instead of hardcoding that
some random sprites needs to be treated additive.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup shared
@ingroup brushentity
*/
class func_tankmortar:NSVehicle
{
public:
	void func_tankmortar(void);
	
	virtual void Spawned(void);
	virtual void PlayerInput(void);
	virtual void SpriteSmoke(vector);
	virtual void SpriteFlash(vector);
	
#ifdef CLIENT
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void UpdateView(void);
#else
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
#endif

private:
	/* attributes */
	float m_flYawRate;
	float m_flPitchRate;
	vector m_vecTipPos;
	float m_flFireRate;
	int m_iDamage;
	string m_strSpriteSmoke;
	string m_strSpriteFlash;
	float m_flSpriteScale;
	vector m_vecSpread; /* TODO: Needs checking */
	string m_strSndRotate; /* TODO */
	float m_flPersistance; /* TODO */
	float m_flMinRange; /* TODO */
	float m_flMaxRange; /* TODO */
	float m_flYawRange; /* TODO */
	float m_flPitchRange; /* TODO */
	float m_flFireTime;
};


#ifdef CLIENT
void
func_tankmortar::UpdateView(void)
{
}

void
func_tankmortar::PredictPreFrame(void)
{
	SAVE_STATE(angles)
	SAVE_STATE(origin)
	SAVE_STATE(velocity)
}

void
func_tankmortar::PredictPostFrame(void)
{
	ROLL_BACK(angles)
	ROLL_BACK(origin)
	ROLL_BACK(velocity)
}

void
func_tankmortar::ReceiveEntity(float new, float fChanged)
{
	if (fChanged & VEHFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}

	if (fChanged & VEHFL_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}

	if (fChanged & VEHFL_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
	}

	if (fChanged & VEHFL_CHANGED_SOLID) {
		solid = readbyte();
	}

	if (fChanged & VEHFL_CHANGED_MOVETYPE) {
		movetype = readbyte();
	}

	if (fChanged & VEHFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}

	if (fChanged & VEHFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (fChanged & VEHFL_CHANGED_DRIVER) {
		m_eDriver = (NSEntity)findfloat(world, ::entnum, readentitynum());
	}

	if (new)
		drawmask = MASK_ENGINE;
}
#else
void
func_tankmortar::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(VEHFL_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(angles)) {
		angles = fixAngle(angles);
		SetSendFlags(VEHFL_CHANGED_ANGLES);
	}
	if (ATTR_CHANGED(velocity)) {
		SetSendFlags(VEHFL_CHANGED_VELOCITY);
	}

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(velocity)
}

float
func_tankmortar::SendEntity(entity ePEnt, float fChanged)
{
	WriteByte(MSG_ENTITY, ENT_VEH_TANKMORTAR);
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & VEHFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (fChanged & VEHFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}

	if (fChanged & VEHFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}

	if (fChanged & VEHFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}

	if (fChanged & VEHFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}

	if (fChanged & VEHFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}

	if (fChanged & VEHFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (fChanged & VEHFL_CHANGED_DRIVER) {
		WriteEntity(MSG_ENTITY, m_eDriver);
	}

	return (1);
}
#endif

void
func_tankmortar::SpriteSmoke(vector org)
{
#ifdef SERVER
	static void Die(void) {
		remove(self);
	}

	if (!m_strSpriteSmoke)
		return;

	NSRenderableEntity smoke = spawn(NSRenderableEntity);
	smoke.SetModel(m_strSpriteSmoke);
	smoke.SetOrigin(org);
	smoke.think = Die;
	smoke.nextthink = time + 0.1f;
	smoke.scale = m_flSpriteScale;
	smoke.SetRenderMode(RM_ADDITIVE);
	smoke.SetRenderColor([255,255,255]);
	smoke.SetRenderAmt(255);
#endif
}

void
func_tankmortar::SpriteFlash(vector org)
{
#ifdef SERVER
	static void Die(void) {
		remove(self);
	}

	if (!m_strSpriteFlash)
		return;

	NSRenderableEntity flash = spawn(NSRenderableEntity);
	flash.SetModel(m_strSpriteFlash);
	flash.SetOrigin(org);
	flash.think = Die;
	flash.nextthink = time + 0.1f;
	flash.scale = m_flSpriteScale;
	flash.SetRenderMode(RM_ADDITIVE);
	flash.SetRenderColor([255,255,255]);
	flash.SetRenderAmt(255);
#endif
}

void
func_tankmortar::PlayerInput(void)
{
#ifdef SERVER
	if (m_eDriver && m_eDriver.health <= 0)
		PlayerLeave((NSClientPlayer)m_eDriver);
#else
	//print("foooo\n");
#endif

	if (m_eDriver) {
		vector wantang, endang;
		vector aimorg;

		makevectors(input_angles);
		aimorg = m_eDriver.origin + v_forward * 4086;

		/* lerp */
		makevectors(vectoangles(aimorg - origin));
		wantang = v_forward;
		makevectors(angles);

		endang = vectorLerp(v_forward, wantang, input_timelength);
		angles = vectorToAngles(endang);
		PlayerUpdateFlags();
	}

#ifdef SERVER
	if (m_flFireTime < time)
	if (input_buttons & INPUT_BUTTON0) {
		vector spos;
		vector dir;
		float damageRange;

		/* barrel tip offset */
		makevectors(angles);
		spos = origin + (v_forward * m_vecTipPos[0]);
		spos += v_right * m_vecTipPos[1];
		spos += v_up * m_vecTipPos[2];

		/* spread */
		dir = v_forward;
		dir += random(-1,1) * m_vecSpread[0] * v_right;
		dir += random(-1,1) * m_vecSpread[1] * v_up;
		traceline(spos, spos + (dir * 4096), MOVE_NORMAL, this);
		
		damageRange = (float)m_iDamage * 2.5f;
		radiusDamage(trace_endpos, damageRange, 0i, m_iDamage, m_eDriver, "");

		/* fx */
		pointparticles(particleeffectnum("fx_explosion.main"), trace_endpos, [0,0,0], 1);
		SpriteSmoke(spos);
		SpriteFlash(spos);

		UseTargets(this, TRIG_ON, m_flDelay);

		m_flFireTime = time + m_flFireRate;
	}

	input_buttons &= ~INPUT_BUTTON0;
#endif
}

#ifdef SERVER
void
func_tankmortar::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);

	if (m_eDriver)
		PlayerLeave((NSClientPlayer)m_eDriver);
}

void
func_tankmortar::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "yawrate":
		m_flYawRate = stof(strValue) * 0.01f;
		break;
	case "yawrange":
		m_flYawRange = stof(strValue);
		break;
	case "pitchrate":
		m_flPitchRate = stof(strValue) * 0.01f;
		break;
	case "pitchrange":
		m_flPitchRange = stof(strValue);
		break;
	case "barrel":
		m_vecTipPos[0] = stof(strValue);
		break;
	case "barrely":
		m_vecTipPos[1] = stof(strValue);
		break;
	case "barrelz":
		m_vecTipPos[2] = stof(strValue);
		break;
	case "firerate":
		m_flFireRate = 1.0f / stof(strValue);
		break;
	case "iMagnitude":
		m_iDamage = stoi(strValue);
		break;
	case "firespread":
		m_vecSpread = [0.10, 0.10, 0] * stof(strValue);
		break;
	case "persistance":
		m_flPersistance = stof(strValue);
		break;
	case "minRange":
		m_flMinRange = stof(strValue);
		break;
	case "maxRange":
		m_flMaxRange = stof(strValue);
		break;
	case "spritesmoke":
		m_strSpriteSmoke = strValue;
		break;
	case "spriteflash":
		m_strSpriteFlash = strValue;
		break;
	case "spritescale":
		m_flSpriteScale = stof(strValue);
		break;
	case "rotatesound":
		m_strSndRotate = strValue;
		break;
	default:
		super::SpawnKey(strValue, strKey);
	}
}
#endif

void
func_tankmortar::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	if (m_strSpriteFlash)
		precache_model(m_strSpriteFlash);
	if (m_strSpriteSmoke)
		precache_model(m_strSpriteSmoke);
#endif
}

void
func_tankmortar::func_tankmortar(void)
{
	m_iVehicleFlags |= VHF_FROZEN | VHF_NOATTACK;

}
