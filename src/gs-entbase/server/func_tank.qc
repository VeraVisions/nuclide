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

/*QUAKED func_tank (0 .5 .8) ? FNCTANK_ACTIVE x x x FNCTANK_DIRECTONLY FNCTANK_CONTROLLABLE
"targetname"    Name
"yawrate"       The speed of the left/right movement of the gun.
"yawrange"      Range of left/right movement in degrees.
"pitchrate"     The speed of the up/down movement of the gun.
"pitchrange"    Range of up/down movement in degrees.
"barrel"        Distance from origin to barrel tip in units.
"barrely"       Horizontal distance origin to the center of the barrel tip.
"barrelz"       Vertical distance origin to the center of the barrel tip.
"firerate"      Number of bullets fired per second.
"bullet_damage" Damage each fired bullet does.
"firespread"    Accuracy of the gun. 0 is best, 4 is worst.
"persistance"   Time in seconds for how long an NPC might continue shooting.
"minRange"      Minimum range the target can be at for an NPC to fire.
"maxRange"      Maximum range the target can be at for an NPC to fire.
"spritesmoke"   Sprite to spawn for 'smoke' when the entity is fired.
"spriteflash"   Sprite to spawn for a 'muzzleflash' when the entity is fired.
"spritescale"   Scale multiplier for both smoke and flash sprites.
"rotatesound"   Sound file to play in a loop while barrel is rotating.

Description:
A mountable tank gun turret type entity. A player (or NPC) can interact with
it and shoot it. It's in the same family as the func_tankmortar entity, the
difference being that this shoots bullets and not mortar blasts.

Notes:
I don't like the sprite stuff tacked on at all because of the extra networking
involved and because it's so awfully GoldSrc specific.
Eventually I need to design a more generic routine that allows people to just
refer to materials with the appropriate blend-modes instead of hardcoding that
some random sprites needs to be treated additive.

Trivia:
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

class func_tank:CBaseVehicle
{
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

	void(void) func_tank;

	virtual void(void) customphysics;
	virtual void(void) PlayerInput;
	virtual void(void) Respawn;
	virtual void(vector) SpriteSmoke;
	virtual void(vector) SpriteFlash;
	virtual void(string, string) SpawnKey;
};

void
func_tank::SpriteSmoke(vector org)
{
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
}

void
func_tank::SpriteFlash(vector org)
{
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
}

void
func_tank::customphysics(void)
{
	if (m_eDriver && m_eDriver.health <= 0)
		PlayerLeave((base_player)m_eDriver);

	if (m_eDriver) {
		vector endorg;
		makevectors(m_eDriver.v_angle);
		endorg = v_forward * 4086;
		angles = vectoangles(endorg - origin);
		PlayerUpdateFlags();

		if (vlen(m_eDriver.origin - origin) > 128)
			PlayerLeave((base_player)m_eDriver);
	}
}

void
func_tank_shootsingle(entity shooter, vector org, vector spread, int damg)
{
	entity oldself = self;
	self = shooter;
	TraceAttack_FireBullets(1, org, damg, spread, 0);
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

void
func_tank::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);

	if (m_eDriver)
		PlayerLeave((base_player)m_eDriver);
}

void
func_tank::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "yawrate":
		m_flYawRate = stof(strValue);
		break;
	case "yawrange":
		m_flYawRange = stof(strValue);
		break;
	case "pitchrate":
		m_flPitchRate = stof(strValue);
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
	case "bullet_damage":
		m_iDamage = stoi(strValue);
		break;
	case "firespread":
		m_vecSpread = [0.25, 0.25, 0] * stof(strValue);
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
func_tank::func_tank(void)
{
	m_iVehicleFlags |= VHF_FROZEN | VHF_NOATTACK;
	CBaseVehicle::CBaseVehicle();

	if (m_strSpriteFlash)
		precache_model(m_strSpriteFlash);
	if (m_strSpriteSmoke)
		precache_model(m_strSpriteSmoke);
}
