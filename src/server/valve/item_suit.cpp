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

/*QUAKED item_suit (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

HEV Suit
Provides the player with armor, a flashlight and a Heads-Up-Display.

*/
class item_suit:CBaseTrigger
{
	void(void) item_suit;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void item_suit::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;
	if (pl.g_items & ITEM_SUIT) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	sound(other, CHAN_ITEM, "fvox/bell.wav", 1, ATTN_NORM);
	sound(other, CHAN_VOICE, "fvox/hev_logon.wav", 1, ATTN_NORM);
	pl.g_items |= ITEM_SUIT;

	CBaseTrigger::UseTargets();
	
	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void item_suit::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(this, m_oldOrigin);
	setmodel(this, m_oldModel);

	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
}

void item_suit::item_suit(void)
{
	model = "models/w_suit.mdl";
	precache_sound("items/suitchargeok1.wav");
	precache_sound("fvox/hev_logon.wav");
	precache_sound("fvox/bell.wav");
	CBaseTrigger::CBaseTrigger();
}
