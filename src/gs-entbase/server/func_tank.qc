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

/*! \brief Server-Entity: Mountable Gun Turret */
/*!QUAKED func_tank (0 .5 .8) ? FNCTANK_ACTIVE x x x FNCTANK_DIRECTONLY FNCTANK_CONTROLLABLE
# OVERVIEW
A mountable tank gun turret type entity. A player (or NPC) can interact with
it and shoot it. It's in the same family as the func_tankmortar entity, the
difference being that this shoots bullets and not mortar blasts.

# KEYS
- "targetname" : Name
- "yawrate" : The speed of the left/right movement of the gun.
- "yawrange" : Range of left/right movement in degrees.
- "pitchrate" : The speed of the up/down movement of the gun.
- "pitchrange" : Range of up/down movement in degrees.
- "barrel" : Distance from origin to barrel tip in units.
- "barrely" : Horizontal distance origin to the center of the barrel tip.
- "barrelz" : Vertical distance origin to the center of the barrel tip.
- "firerate" : Number of bullets fired per second.
- "bullet_damage" : Damage each fired bullet does.
- "firespread" : Accuracy of the gun. 0 is best, 4 is worst.
- "persistance" : Time in seconds for how long an NPC might continue shooting.
- "minRange" : Minimum range the target can be at for an NPC to fire.
- "maxRange" : Maximum range the target can be at for an NPC to fire.
- "spritesmoke" : Sprite to spawn for 'smoke' when the entity is fired.
- "spriteflash" : Sprite to spawn for a 'muzzleflash' when the entity is fired.
- "spritescale" : Scale multiplier for both smoke and flash sprites.
- "rotatesound" : Sound file to play in a loop while barrel is rotating.

# SPAWNFLAGS
- FNCTANK_ACTIVE (1) : TODO: Start active?
- FNCTANK_DIRECTONLY (16) : TODO: ?
- FNCTANK_CONTROLLABLE (32) : TODO: Can be interacted with similar to a tankmortar?

# NOTES
I don't like the sprite stuff tacked on at all because of the extra networking
involved and because it's so awfully GoldSrc specific.
Eventually I need to design a more generic routine that allows people to just
refer to materials with the appropriate blend-modes instead of hardcoding that
some random sprites needs to be treated additive.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_tank:ncVehicle
{
public:
	void func_tank(void);
	
	virtual void Precache(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void customphysics(void);
	virtual void PlayerInput(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	nonvirtual void SpriteSmoke(vector);
	nonvirtual void SpriteFlash(vector);

private:
	/* attributes */
	float m_flYawRate; /* TODO */
	float m_flYawRange; /* TODO */
	float m_flPitchRate; /* TODO */
	float m_flPitchRange; /* TODO */
	vector m_vecTipPos;
	float m_flFireRate;
	int m_iDamage;
	vector m_vecSpread; /* TODO: Needs checking */
	string m_strSpriteSmoke;
	string m_strSpriteFlash;
	float m_flSpriteScale;
	string m_strSndRotate; /* TODO */
	float m_flPersistance; /* TODO */
	float m_flMinRange; /* TODO */
	float m_flMaxRange; /* TODO */
	float m_flFireTime;
};

void
func_tank::func_tank(void)
{
	m_flYawRate = 0.0f;
	m_flYawRange = 0.0f;
	m_flPitchRate = 0.0f;
	m_flPitchRange = 0.0f;
	m_vecTipPos = [0.0f, 0.0f, 0.0f];
	m_flFireRate = 0.0f;
	m_iDamage = 0i;
	m_vecSpread = [0.0f, 0.0f, 0.0f];
	m_strSpriteSmoke = __NULL__;
	m_strSpriteFlash = __NULL__;
	m_flSpriteScale = 0.0f;
	m_strSndRotate = __NULL__;
	m_flPersistance = 0.0f;
	m_flMinRange = 0.0f;
	m_flMaxRange = 0.0f;
	m_flFireTime = 0.0f;

	m_iVehicleFlags |= VHF_FROZEN | VHF_NOATTACK;
}

void
func_tank::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iDamage", m_iDamage);
	SaveFloat(handle, "m_flYawRate", m_flYawRate);
	SaveFloat(handle, "m_flYawRange", m_flYawRange);
	SaveFloat(handle, "m_flPitchRate", m_flPitchRate);
	SaveFloat(handle, "m_flPitchRange", m_flPitchRange);
	SaveFloat(handle, "m_flFireRate", m_flFireRate);
	SaveFloat(handle, "m_flSpriteScale", m_flSpriteScale);
	SaveFloat(handle, "m_flPersistance", m_flPersistance);
	SaveFloat(handle, "m_flMinRange", m_flMinRange);
	SaveFloat(handle, "m_flMaxRange", m_flMaxRange);
	SaveString(handle, "m_strSpriteSmoke", m_strSpriteSmoke);
	SaveString(handle, "m_strSpriteFlash", m_strSpriteFlash);
	SaveString(handle, "m_strSndRotate", m_strSndRotate);
	SaveVector(handle, "m_vecTipPos", m_vecTipPos);
	SaveVector(handle, "m_vecSpread", m_vecSpread);
}

void
func_tank::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iDamage":
		m_iDamage = ReadInt(strValue);
		break;
	case "m_flYawRate":
		m_flYawRate = ReadFloat(strValue);
		break;
	case "m_flYawRange":
		m_flYawRange = ReadFloat(strValue);
		break;
	case "m_flPitchRate":
		m_flPitchRate = ReadFloat(strValue);
		break;
	case "m_flPitchRange":
		m_flPitchRange = ReadFloat(strValue);
		break;
	case "m_flFireRate":
		m_flFireRate = ReadFloat(strValue);
		break;
	case "m_flSpriteScale":
		m_flSpriteScale = ReadFloat(strValue);
		break;
	case "m_flPersistance":
		m_flPersistance = ReadFloat(strValue);
		break;
	case "m_flMinRange":
		m_flMinRange = ReadFloat(strValue);
		break;
	case "m_flMaxRange":
		m_flMaxRange = ReadFloat(strValue);
		break;
	case "m_strSpriteSmoke":
		m_strSpriteSmoke = ReadString(strValue);
		break;
	case "m_strSpriteFlash":
		m_strSpriteFlash = ReadString(strValue);
		break;
	case "m_strSndRotate":
		m_strSndRotate = ReadString(strValue);
		break;
	case "m_vecTipPos":
		m_vecTipPos = ReadVector(strValue);
		break;
	case "m_vecSpread":
		m_vecSpread = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_tank::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "yawrate":
		m_flYawRate = ReadFloat(strValue);
		break;
	case "yawrange":
		m_flYawRange = ReadFloat(strValue);
		break;
	case "pitchrate":
		m_flPitchRate = ReadFloat(strValue);
		break;
	case "pitchrange":
		m_flPitchRange = ReadFloat(strValue);
		break;
	case "barrel":
		m_vecTipPos[0] = ReadFloat(strValue);
		break;
	case "barrely":
		m_vecTipPos[1] = ReadFloat(strValue);
		break;
	case "barrelz":
		m_vecTipPos[2] = ReadFloat(strValue);
		break;
	case "firerate":
		m_flFireRate = 1.0f / ReadFloat(strValue);
		break;
	case "bullet_damage":
		m_iDamage = ReadInt(strValue);
		break;
	case "firespread":
		m_vecSpread = [0.1, 0.1, 0] * ReadFloat(strValue);
		break;
	case "persistance":
		m_flPersistance = ReadFloat(strValue);
		break;
	case "minRange":
		m_flMinRange = ReadFloat(strValue);
		break;
	case "maxRange":
		m_flMaxRange = ReadFloat(strValue);
		break;
	case "spritesmoke":
		m_strSpriteSmoke = ReadString(strValue);
		break;
	case "spriteflash":
		m_strSpriteFlash = ReadString(strValue);
		break;
	case "spritescale":
		m_flSpriteScale = ReadFloat(strValue);
		break;
	case "rotatesound":
		m_strSndRotate = ReadString(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_tank::Precache(void)
{
	precache.Model(m_strSpriteFlash);
	precache.Model(m_strSpriteSmoke);
}

void
func_tank::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);

	if (m_eDriver) {
		PlayerLeave((ncPlayer)m_eDriver);
	}
}

void
func_tank::SpriteSmoke(vector org)
{
	static void Die(void) {
		remove(self);
	}

	if (!STRING_SET(m_strSpriteSmoke)) {
		return;
	}

	ncRenderableEntity smoke = spawn(ncRenderableEntity);
	smoke.SetModel(m_strSpriteSmoke);
	smoke.SetOrigin(org);
	smoke.think = Die;
	smoke.nextthink = time + 0.1f;
	smoke.scale = m_flSpriteScale;
	smoke.SetRenderMode(RM_ADDITIVE);
	smoke.SetRenderColor([255,255,255]);
	smoke.SetRenderAmt(255);
}

void
func_tank::SpriteFlash(vector org)
{
	static void Die(void) {
		remove(self);
	}

	if (!STRING_SET(m_strSpriteFlash)) {
		return;
	}

	ncRenderableEntity flash = spawn(ncRenderableEntity);
	flash.SetModel(m_strSpriteFlash);
	flash.SetOrigin(org);
	flash.think = Die;
	flash.nextthink = time + 0.1f;
	flash.scale = m_flSpriteScale;
	flash.SetRenderMode(RM_ADDITIVE);
	flash.SetRenderColor([255,255,255]);
	flash.SetRenderAmt(255);
}

void
func_tank::customphysics(void)
{
	if (m_eDriver && m_eDriver.health <= 0) {
		PlayerLeave((ncPlayer)m_eDriver);
	}

	if (m_eDriver) {
		vector endorg;
		endorg = anglesToForward(m_eDriver.v_angle) * 4096.0f;
		angles = vectorToAngles(endorg - origin);
		PlayerUpdateFlags();

		if (distance(m_eDriver.origin, origin) > 128) {
			PlayerLeave((ncPlayer)m_eDriver);
		}
	}
}

void
func_tank_shootsingle(entity shooter, vector org, vector spread, int damg)
{
	entity oldself = self;
	self = shooter;
	//TraceAttack_FireBullets(1, org, damg, spread, 0);
	self = oldself;
}

void
func_tank::PlayerInput(void)
{
	if (m_flFireTime < time)
	if (input_buttons & INPUT_BUTTON0) {
		vector spos;

		/* barrel tip offset */
		makevectors(angles);
		spos = origin + v_forward * m_vecTipPos[0];
		spos += v_right * m_vecTipPos[1];
		spos += v_up * m_vecTipPos[2];

		UseTargets(this, TRIG_ON, m_flDelay);
		func_tank_shootsingle(m_eDriver, spos, m_vecSpread, m_iDamage);
		m_flFireTime = time + m_flFireRate;

		SpriteSmoke(spos);
		SpriteFlash(spos);

		/* disable actual weapon fire */
		input_buttons = 0;
	}

	input_buttons &= ~INPUT_BUTTON0;
}
