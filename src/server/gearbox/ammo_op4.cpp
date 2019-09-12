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

/*
 * Ammo for the M249.
 * A single ammo_556 will provide 50 bullets.
 */
class ammo_556:item_ammo
{
	void() ammo_556;
	virtual void() touch;
};

void
ammo_556::ammo_556(void)
{
	model = "models/w_saw_clip.mdl";
	item_ammo::item_ammo();
}
void
ammo_556::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_556 < 200) {
			pl.ammo_556 = bound(0, pl.ammo_556 + 50, 200);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the M-40A1 Sniper.
 * A single ammo_762 will provide 5 bullets.
 */
class ammo_762:item_ammo
{
	void() ammo_762;
	virtual void() touch;
};

void
ammo_762::ammo_762(void)
{
	model = "models/w_m40a1clip.mdl";
	item_ammo::item_ammo();
}
void
ammo_762::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_762 < 15) {
			pl.ammo_762 = bound(0, pl.ammo_762 + 5, 15);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the Spore Launcher.
 * A single ammo_spore will provide 1 spore.
 * TODO
 * It needs to be static (no pickup), and needs to
 * fire a projectile upon inflicted damage.
 */

class ammo_spore:item_ammo
{
	void() ammo_spore;
	virtual void() touch;
};

void
ammo_spore::ammo_spore(void)
{
	model = "models/spore_ammo.mdl";
	item_ammo::item_ammo();
}

void
ammo_spore::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_spore < 20) {
			pl.ammo_spore = bound(0, pl.ammo_spore + 1, 20);
			item_ammo::touch();
		}
	}
}
