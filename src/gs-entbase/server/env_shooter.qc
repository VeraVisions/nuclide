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

/*QUAKED env_shooter (1 0 0) (-8 -8 -8) (8 8 8)
Shoots model entities from its location.

-------- KEYS --------
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"angles"        Sets the pitch, yaw and roll direction of the shooter.
"shootmodel"    Model file to shoot.
"shootsounds"   PCM sample to play whenever a piece shoots out.
"m_iGibs"       Amount of models shot in total.
"m_flDelay"     Delay before being able to be fired again.
"m_flVelocity"  Speed of the models in units per second.
"m_flVariance"  Delay between shots.
"m_flGibLife"   Life of the individual model piece.
"scale"         Scale modifier of the model pieces.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class env_shooter:CBaseTrigger
{
	int m_iGibs;
	int m_iGibsLeft;

	float m_flDelay;
	float m_flVelocity;
	float m_flVariance;
	float m_flGibLife;
	string m_strShootModel;
	float m_flShootSounds;
	float m_flScale;
	float m_flSkin;
	
	void(void) env_shooter;
	virtual void(void) Respawn;
	virtual void(void) ShootGib;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
env_shooter::ShootGib(void)
{
	static void Gib_Remove(void) { remove(self); }

	entity eGib = spawn();
	eGib.movetype = MOVETYPE_BOUNCE;
	setmodel(eGib, m_strShootModel);
	setorigin(eGib, origin);

	makevectors(angles);
	eGib.velocity = v_forward * m_flVelocity + [0,0,64 + (random()*64)];
	eGib.avelocity[0] = random(-1,1) * 32;
	eGib.avelocity[1] = random(-1,1) * 32;
	eGib.avelocity[2] = random(-1,1) * 32;

	eGib.think = Gib_Remove;
	eGib.nextthink = time + m_flGibLife;
	eGib.angles = angles;

	m_iGibsLeft--;

	if (m_iGibsLeft) {
		nextthink = time + m_flVariance;
	}
}

void
env_shooter::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		think = __NULL__;
		nextthink = 0.0f;
		break;
	case TRIG_ON:
		think = ShootGib;
		nextthink = time + m_flVariance;
		break;
	default:
		if (think == __NULL__)
			Trigger(act, TRIG_ON);
		else
			Trigger(act, TRIG_OFF);
	}
}

void
env_shooter::Respawn(void)
{
	m_iGibsLeft = m_iGibs;
}

void
env_shooter::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iGibs":
		m_iGibs = stoi(strValue);
		break;
	case "m_flDelay":
		m_flDelay = stof(strValue);
		break;
	case "m_flVelocity":
		m_flVelocity = stof(strValue);
		break;
	case "m_flVariance":
		m_flVariance = stof(strValue);
		break;
	case "m_flGibLife":
		m_flGibLife = stof(strValue);
		break;
	case "shootmodel":
		m_strShootModel = strValue;
		precache_model(m_strShootModel);
		break;
	case "shootsounds":
		m_flShootSounds = stof(strValue);
		break;
	case "scale":
		m_flScale = stof(strValue);
		break;
	case "skin":
		m_flSkin = stof(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
env_shooter::env_shooter(void)
{
	CBaseTrigger::CBaseTrigger();

	if (!m_strShootModel) {
		remove(this);
	}
}
