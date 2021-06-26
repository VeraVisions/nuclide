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

/*QUAKED trigger_hurt (0 .5 .8) ? SF_HURT_ONCE SF_HURT_OFF x SF_HURT_NOPLAYERS SF_HURT_FIREONPLAYER SF_HURT_TOUCHPLAYER
"targetname"    Name
"target"        Target when triggered.
"delay"         Delay until target is triggered.
"killtarget"    Target to kill when triggered.
"dmg"           Damage inflicted.

Trigger volume that damages everything it touches.

If SF_HURT_ONCE is set, it'll stop once it's been triggered the first time.
If SF_HURT_OFF is set, it needs to be triggered in order to work again.
If SF_HURT_NOPLAYERS is set, it will only NPCs.
If SF_HURT_TOUCHPLAYER is set, it'll only hurt players.
If SF_HURT_FIREONPLAYER is set, it'll only trigger a target if a player
activates it.

Trivia:
This entity was introduced in Quake (1996).
*/

.float hurt_next;

#define SF_HURT_ONCE			1 // Turn off once it fired the first time
#define SF_HURT_OFF				2 // Needs to be triggered in order to work again
#define SF_HURT_NOPLAYERS		8 // Don't hurt players
#define SF_HURT_FIREONPLAYER	16 // Only call UseTarget functions when it's a player
#define SF_HURT_TOUCHPLAYER		32 // Only hurt players

class trigger_hurt:CBaseTrigger
{
	float m_flNextTrigger;
	float m_flNextDmg;
	int m_iDamage;
	float m_flDelay;

	string m_strOnHurt;
	string m_strOnHurtPlayer;

	void(void) trigger_hurt;

	virtual void(entity, int) Trigger;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
};

void
trigger_hurt::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		solid = SOLID_NOT;
		break;
	case TRIG_ON:
		solid = SOLID_TRIGGER;
		InitBrushTrigger();
		break;
	default:
		if (solid == SOLID_NOT)
			Trigger(act, TRIG_ON);
		else
			Trigger(act, TRIG_OFF);
	}
}

void
trigger_hurt::touch(void)
{
	if (other.takedamage == DAMAGE_NO) {
		return;
	} else if ((spawnflags & SF_HURT_TOUCHPLAYER) && !(other.flags & FL_CLIENT)) {
		return;
	} else if ((spawnflags & SF_HURT_NOPLAYERS) && (other.flags & FL_CLIENT)) {
		return;
	} else if (other.hurt_next > time) {
		return;
	}

	if (!target) {
		if (other.flags & FL_CLIENT)
			UseOutput(other, m_strOnHurtPlayer);
		else
			UseOutput(other, m_strOnHurt);
	} else {
		if (spawnflags & SF_HURT_FIREONPLAYER) {
			if (other.flags & FL_CLIENT) {
				eActivator = other;
				UseTargets(other, TRIG_TOGGLE, m_flDelay);
			}
		} else {
			eActivator = other;
			UseTargets(other, TRIG_TOGGLE, m_flDelay);
		}
	}

	Damage_Apply(other, this, m_iDamage, 0, DMG_GENERIC);

	dprint(sprintf("^2trigger_hurt::^3Touch^7: Hurting '%s' with %i\n", 
		other.netname, m_iDamage));

	/* shut it down if used once */
	if (spawnflags & SF_HURT_ONCE) {
		Trigger(other, TRIG_OFF);
	}

	other.hurt_next = time + m_flNextDmg;
}

void
trigger_hurt::Respawn(void)
{
	if (spawnflags & SF_HURT_OFF) {
		Trigger(this, TRIG_OFF);
	} else {
		Trigger(this, TRIG_ON);
	}
}

void
trigger_hurt::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "SetDamage":
		m_iDamage = stoi(strData);
		break;
	default:
		CBaseTrigger::Input(eAct, strInput, strData);
	}
}

void
trigger_hurt::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "dmg":
		m_iDamage = stoi(strValue);
		break;
	case "wait":
		m_flNextDmg = stof(strValue);
		break;
	case "OnHurt":
		strValue = strreplace(",", ",_", strValue);
		m_strOnHurt = strcat(m_strOnHurt, ",_", strValue);
		break;
	case "OnHurtPlayer":
		strValue = strreplace(",", ",_", strValue);
		m_strOnHurtPlayer = strcat(m_strOnHurtPlayer, ",_", strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_hurt::trigger_hurt(void)
{
	/* defaults */
	m_iDamage = 15;
	m_flNextDmg = 0.5f;

	CBaseTrigger::CBaseTrigger();

	if (m_strOnHurt)
		m_strOnHurt = CreateOutput(m_strOnHurt);

	if (m_strOnHurtPlayer)
		m_strOnHurtPlayer = CreateOutput(m_strOnHurtPlayer);
}
