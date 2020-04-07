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

class info_tfgoal:CBaseTrigger
{
	string m_strName;
	string m_strSound;

	void() info_tfgoal;
	virtual void() touch;
	virtual void() Respawn;
};

void
info_tfgoal::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	sound(this, CHAN_ITEM, m_strSound, 1.0f, ATTN_NORM);
	Logging_Pickup(other, this, m_strName);

	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void
info_tfgoal::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_NONE;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(this, m_oldOrigin);
}

void
info_tfgoal::info_tfgoal(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "netname":
			m_strSound = argv(i+1);
			netname = __NULL__;
			break;
		case "noise":
			m_strSound = argv(i+1);
			break;
		case "mdl":
			model = argv(i+1);
			break;
		default:
			break;
		}
	}
	precache_sound(m_strSound);

	CBaseEntity::CBaseEntity();
	info_tfgoal::Respawn();
}

CLASSEXPORT(i_t_g, info_tfgoal)
