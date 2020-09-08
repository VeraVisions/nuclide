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

/*QUAKED func_tankmortar (0 .5 .8) ?
"targetname"    Name
"yawrate"       The speed of the left/right movement of the mortar.
"yawrange"      Range of left/right movement in degrees.
"pitchrate"     The speed of the up/down movement of the mortar.
"pitchrange"    Range of up/down movement in degrees.
"barrel"        Distance from origin to barrel tip in units.
"barrely"       Horizontal distance origin to the center of the barrel tip.
"barrelz"       Vertical distance origin to the center of the barrel tip.
"firerate"      Number of bullets fired per second.
"iMagnitude"    Power of each explosion.
"firespread"    Accuracy of the mortar. 0 is best, 4 is worst.
"persistance"   Time in seconds for how long an NPC might continue shooting.
"minRange"      Minimum range the target can be at for an NPC to fire.
"maxRange"      Maximum range the target can be at for an NPC to fire.
"spritesmoke"   Sprite to spawn for 'smoke' when the entity is fired.
"spriteflash"   Sprite to spawn for a 'muzzleflash' when the entity is fired.
"spritescale"   Scale multiplier for both smoke and flash sprites.
"rotatesound"   Sound file to play in a loop while barrel is rotating.

Description:
A mountable tank mortar turret type entity. A player (or NPC) can interact with
it and shoot it. It's in the same family as the func_tank entity, the
difference being that this shoots mortar blasts and not bullets.

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

class func_tankmortar:CBaseVehicle
{
	/* attributes */
	float m_flYawRate;
	float m_flYawRange; /* TODO */
	float m_flPitchRate;
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
	void(void) func_tankmortar;

	virtual void(void) customphysics;
	virtual void(void) PlayerInput;
	virtual void(void) Respawn;
	virtual void(vector) SpriteSmoke;
	virtual void(vector) SpriteFlash;
	virtual void(string, string) SpawnKey;
};

void
func_tankmortar::SpriteSmoke(vector org)
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
	smoke.scale = m_flSpriteScale;
}

void
func_tankmortar::SpriteFlash(vector org)
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
	smoke.scale = m_flSpriteScale;
}

void
func_tankmortar::customphysics(void)
{
	if (m_eDriver && m_eDriver.health <= 0)
		PlayerLeave(m_eDriver);

	if (m_eDriver) {
		vector wantang, endang;
		vector aimorg;

		makevectors(m_eDriver.v_angle);
		aimorg = m_eDriver.origin + v_forward * 4086;

		/* lerp */
		makevectors(vectoangles(aimorg - origin));
		wantang = v_forward;
		makevectors(angles);

		endang[0] = Math_Lerp(v_forward[0], wantang[0], frametime);
		endang[1] = Math_Lerp(v_forward[1], wantang[1], frametime);
		endang[2] = Math_Lerp(v_forward[2], wantang[2], frametime);
		angles = vectoangles(endang);
		m_eDriver.flags |= FL_FROZEN;
	}
}

void
func_tankmortar::PlayerInput(void)
{
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

		CBaseTrigger::UseTargets(this, TRIG_ON);

		m_flFireTime = time + m_flFireRate;
	}

	input_buttons &= ~INPUT_BUTTON0;
}

void
func_tankmortar::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);

	if (m_eDriver)
		PlayerLeave(m_eDriver);
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
		CBaseTrigger::SpawnKey(strValue, strKey);
	}
}

void
func_tankmortar::func_tankmortar(void)
{
	CBaseVehicle::CBaseVehicle();

	if (m_strSpriteFlash)
		precache_model(m_strSpriteFlash);
	if (m_strSpriteSmoke)
		precache_model(m_strSpriteSmoke);
}
