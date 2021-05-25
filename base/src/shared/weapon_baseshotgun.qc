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

enum
{
	SHOTGUN_FIRE_FAILED,
	SHOTGUN_FIRED,
	SHOTGUN_LAST,
	SHOTGUN_EMPTY
};

int
w_baseshotgun_fire(int w, .int mag, int c, int d, vector bs)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return (SHOTGUN_FIRE_FAILED);
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		return (SHOTGUN_FIRE_FAILED);
	}
	if (pl.(mag) <= 0) {
		pl.gflags |= GF_SEMI_TOGGLED;
		return (SHOTGUN_EMPTY);
	}

	pl.(mag)--;

#ifdef SERVER
	TraceAttack_FireBullets(c, pl.origin + pl.view_ofs, d, bs, w);
#endif

	pl.gflags |= GF_SEMI_TOGGLED;

	if (pl.(mag) == 0)
		return (SHOTGUN_LAST);
	else
		return (SHOTGUN_FIRED);
}

enum
{
	SHOTTY_IDLE,
	SHOTTY_RELOAD_START,
	SHOTTY_RELOAD,
	SHOTTY_RELOAD_END,
	SHOTTY_COCKSOUND
};

void
w_baseshotgun_reload(.int mag, .int ammo, int max)
{
	player pl = (player)self;

	if (pl.(mag) >= max) {
		return;
	}
	if (pl.(ammo) <= 0) {
		return;
	}
	if (pl.mode_tempstate > SHOTTY_IDLE) {
		return;
	}

	pl.mode_tempstate = SHOTTY_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

enum
{
	SHOTGUN_IDLE,
	SHOTGUN_BUSY,
	SHOTGUN_START_RELOAD,
	SHOTGUN_RELOAD,
	SHOTGUN_END_RELOAD
};

int
w_baseshotgun_release(.int mag, .int ammo, int max)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return (SHOTGUN_BUSY);
	}

	if (pl.mode_tempstate == SHOTTY_RELOAD_START) {
		pl.mode_tempstate = SHOTTY_RELOAD;
		pl.w_idle_next = 0.65f;
		return (SHOTGUN_START_RELOAD);
	} else if (pl.mode_tempstate == SHOTTY_RELOAD) {
		pl.(mag)++;
		pl.(ammo)--;

		if (pl.(ammo) <= 0 || pl.(mag) >= max) {
			pl.mode_tempstate = SHOTTY_RELOAD_END;
		}
		Weapons_UpdateAmmo(pl, pl.(mag), pl.(ammo), pl.mode_tempstate);
		pl.w_idle_next = 0.5f;
		return (SHOTGUN_RELOAD);
	} else if (pl.mode_tempstate == SHOTTY_RELOAD_END) {
		pl.mode_tempstate = SHOTTY_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
		return (SHOTGUN_END_RELOAD);
	}

	return (SHOTGUN_IDLE);
}
