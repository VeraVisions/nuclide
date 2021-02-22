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

/*QUAKED func_recharge (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"snd_first"     Sound to play when first used.
"snd_charging"  Sound to play when first charging.
"snd_done"      Sound to play when first finished charging.

Brush that fills up your armor when used, to a maximum of 100 points.

Trivia:
This entity was introduced in Half-Life (1998).
*/

class func_recharge:CBaseTrigger
{
	entity m_eUser;
	float m_flDelay;
	float m_flCheck;

	string m_strSndFirst;
	string m_strSndCharging;
	string m_strSndDone;

	void(void) func_recharge;
	virtual void(void) customphysics;
	virtual void(void) OnPlayerUse;
	virtual void(string, string) SpawnKey;
	virtual void(void) ResetHealth;
};

void
func_recharge::ResetHealth(void)
{
	if (health <= 0) {
		sound(this, CHAN_VOICE, m_strSndFirst, 1.0, ATTN_NORM);
	}

	SetFrame(0);
	health = max_health = Skill_GetValue("suitcharger", 75);
}

void
func_recharge::OnPlayerUse(void)
{
	/* let's not let this become too funny... */
	if (eActivator.health <= 0) {
		return;
	}

	eActivator.flags |= FL_USE_RELEASED;

	/* First come first serve */ 
	if (m_eUser && eActivator != m_eUser) {
		return;
	}

	/* First time */
	if (m_eUser == world) {
		sound(this, CHAN_VOICE, m_strSndFirst, 1.0, ATTN_NORM);
	}

	if (m_flDelay > time) {
		return;
	}

	if (health <= 0) {
		eActivator.flags &= ~FL_USE_RELEASED;
		sound(this, CHAN_VOICE, m_strSndDone, 1.0, ATTN_NORM);
		m_eUser = world;
		return;
	}

	base_player pl = (base_player)eActivator;
	if (pl.armor >= 100) {
		eActivator.flags &= ~FL_USE_RELEASED;
		sound(this, CHAN_VOICE, m_strSndDone, 1.0, ATTN_NORM);
	} else {
		if (m_eUser == world) {
			sound(this, CHAN_ITEM, m_strSndCharging, 1.0, ATTN_NORM);
		}
		pl.armor = bound(0, pl.armor += 1, 100);

		/* Reset 30 seconds after first being used successfully */
		//if (health == max_health) {
			think = ResetHealth;
			nextthink = time + 30.0f;
		//}
		health -= 1;

		/* Disable when empty */
		if (health <= 0) {
			sound(this, CHAN_ITEM, "common/null.wav", 1.0, ATTN_NORM);
			sound(this, CHAN_VOICE, m_strSndDone, 1.0, ATTN_NORM);
			SetFrame(1);
			eActivator.flags &= ~FL_USE_RELEASED;
			m_eUser = world;
			return;
		}
	}

	m_eUser = eActivator;
	m_flDelay = time + 0.1f;
	m_flCheck = time + 0.25f;
}

void
func_recharge::customphysics(void)
{
	if (m_flCheck > time) {
		return;
	}

	if (m_eUser) {
		sound(this, CHAN_ITEM, "common/null.wav", 1.0, ATTN_NORM);
		m_eUser = world;
	}

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
func_recharge::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "snd_first":
		m_strSndFirst = strValue;
		break;
	case "snd_charging":
		m_strSndCharging = strValue;
		break;
	case "snd_done":
		m_strSndDone = strValue;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
func_recharge::func_recharge(void)
{
	m_strSndFirst = "items/suitchargeok1.wav";
	m_strSndCharging = "items/suitcharge1.wav";
	m_strSndDone = "items/suitchargeno1.wav";

	CBaseTrigger::CBaseTrigger();

	precache_sound(m_strSndFirst);
	precache_sound(m_strSndCharging);
	precache_sound(m_strSndDone);

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetOrigin(origin);
	SetModel(model);
	PlayerUse = OnPlayerUse;
	ResetHealth();
}
