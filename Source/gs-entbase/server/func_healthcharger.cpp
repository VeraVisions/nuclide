/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

class func_healthcharger:CBaseTrigger
{
	entity m_eUser;
	float m_flDelay;
	float m_flCheck;

	void() func_healthcharger;
	virtual void() customphysics;
	virtual void() PlayerUse;
};

void func_healthcharger::PlayerUse(void)
{
	eActivator.gflags |= GF_USE_RELEASED;
	
	/* First come first serve */ 
	if (m_eUser && eActivator != m_eUser) {
		return;
	}

	/* First time */
	if (m_eUser == world) {
		sound(this, CHAN_VOICE, "items/medshot4.wav", 1.0, ATTN_NORM);
	}
	
	if (m_flDelay > time) {
		return;
	}

	if (eActivator.health >= 100) {
		eActivator.gflags &= ~GF_USE_RELEASED;
		sound(this, CHAN_VOICE, "items/medshotno1.wav", 1.0, ATTN_NORM);
	} else {
		if (m_eUser == world) {
			sound(this, CHAN_ITEM, "items/medcharge4.wav", 1.0, ATTN_NORM);
		}
		eActivator.health = bound(0, eActivator.health += 1, 100);
	}

	m_eUser = eActivator;
	m_flDelay = time + 0.1f;
	m_flCheck = time + 0.25f;
}

void func_healthcharger::customphysics(void)
{
	if (m_flCheck > time) {
		return;
	}
	if (m_eUser) {
		sound(this, CHAN_ITEM, "misc/null.wav", 1.0, ATTN_NORM);
		m_eUser = world;
	}
}

void func_healthcharger::func_healthcharger(void)
{
	
	precache_sound("items/medshot4.wav");
	precache_sound("items/medshotno1.wav");
	precache_sound("items/medcharge4.wav");

	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setorigin(this, origin);
	setmodel(this, model);
}
