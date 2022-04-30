/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED func_tankmortar (0 .5 .8) ?
A mountable tank mortar turret type entity. A player (or NPC) can interact with
it and shoot it. It's in the same family as the func_tank entity, the
difference being that this shoots mortar blasts and not bullets.

-------- KEYS --------
"targetname" : Name
"yawrate" : The speed of the left/right movement of the mortar.
"yawrange" : Range of left/right movement in degrees.
"pitchrate" : The speed of the up/down movement of the mortar.
"pitchrange" : Range of up/down movement in degrees.
"barrel" : Distance from origin to barrel tip in units.
"barrely" : Horizontal distance origin to the center of the barrel tip.
"barrelz" : Vertical distance origin to the center of the barrel tip.
"firerate" : Number of bullets fired per second.
"iMagnitude" : Power of each explosion.
"firespread" : Accuracy of the mortar. 0 is best, 4 is worst.
"persistance" : Time in seconds for how long an NPC might continue shooting.
"minRange" : Minimum range the target can be at for an NPC to fire.
"maxRange" : Maximum range the target can be at for an NPC to fire.
"spritesmoke" : Sprite to spawn for 'smoke' when the entity is fired.
"spriteflash" : Sprite to spawn for a 'muzzleflash' when the entity is fired.
"spritescale" : Scale multiplier for both smoke and flash sprites.
"rotatesound" : Sound file to play in a loop while barrel is rotating.

-------- NOTES --------
I don't like the sprite stuff tacked on at all because of the extra networking
involved and because it's so awfully GoldSrc specific.
Eventually I need to design a more generic routine that allows people to just
refer to materials with the appropriate blend-modes instead of hardcoding that
some random sprites needs to be treated additive.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
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

class func_tankmortar:NSVehicle
{
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
	void(void) func_tankmortar;

	virtual void(void) PlayerInput;
	virtual void(vector) SpriteSmoke;
	virtual void(vector) SpriteFlash;

#ifdef CLIENT
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) UpdateView;
#else
	virtual float(entity, float) SendEntity;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
#endif
};


#ifdef CLIENT
void
func_tankmortar::UpdateView(void)
{
}

void
func_tankmortar::PredictPreFrame(void)
{
	SAVE_STATE(angles);
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
}

void
func_tankmortar::PredictPostFrame(void)
{
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
}

void
func_tankmortar::ReceiveEntity(float fChanged, float new)
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
		m_eDriver = findfloat(world, ::entnum, readentitynum());
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
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		SetSendFlags(VEHFL_CHANGED_ANGLES);
	}
	if (ATTR_CHANGED(velocity)) {
		SetSendFlags(VEHFL_CHANGED_VELOCITY);
	}

	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(velocity);
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

	entity smoke = spawn();
	setmodel(smoke, m_strSpriteSmoke);
	setorigin(smoke, org);
	smoke.think = Die;
	smoke.nextthink = time + 0.1f;
	smoke.scale = m_flSpriteScale;
	smoke.effects = EF_FLAG2;
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

	entity smoke = spawn();
	setmodel(smoke, m_strSpriteFlash);
	setorigin(smoke, org);
	smoke.think = Die;
	smoke.nextthink = time + 0.1f;
	smoke.scale = m_flSpriteScale;
	smoke.effects = EF_FLAG2;
#endif
}

void
func_tankmortar::PlayerInput(void)
{
#ifdef SERVER
	if (m_eDriver && m_eDriver.health <= 0)
		PlayerLeave((base_player)m_eDriver);
#else
	print("foooo\n");
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

		endang[0] = Math_Lerp(v_forward[0], wantang[0], input_timelength);
		endang[1] = Math_Lerp(v_forward[1], wantang[1], input_timelength);
		endang[2] = Math_Lerp(v_forward[2], wantang[2], input_timelength);
		angles = vectoangles(endang);
		PlayerUpdateFlags();
	}

#ifdef SERVER
	if (m_flFireTime < time)
	if (input_buttons & INPUT_BUTTON0) {
		vector spos;
		vector dir;
		float dmg;

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
		
		dmg = (float)m_iDamage;
		Damage_Radius(trace_endpos, m_eDriver, dmg, dmg * 2.5f, TRUE, 0);

		/* fx */
		FX_Explosion(trace_endpos);
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
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());

	if (m_eDriver)
		PlayerLeave((base_player)m_eDriver);
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
func_tankmortar::func_tankmortar(void)
{
	m_iVehicleFlags |= VHF_FROZEN | VHF_NOATTACK;

	super::NSVehicle();

#ifdef SERVER
	if (m_strSpriteFlash)
		precache_model(m_strSpriteFlash);
	if (m_strSpriteSmoke)
		precache_model(m_strSpriteSmoke);
#endif
}

#ifdef CLIENT
void
func_tankmortar_readentity(float isnew)
{
	func_tankmortar veh = (func_tankmortar)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_func_tankmortar();

	veh.ReceiveEntity(flags, isnew);
}
#endif
