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

weapon_t w_null = {};

weapon_t g_weapons[] = {
	w_null,
	w_fists,
	w_aicore,
	w_gausspistol,
	w_shotgun,
	w_minigun,
	w_beamgun,
	w_dml,
	w_grenade,
	w_chemicalgun
};

#ifdef CSQC
int(player) gp_inputforward[] = {
	__NULL__,
	__NULL__,
	__NULL__,
	w_gausspistol_hudforward,
	w_shotgun_hudforward,
	__NULL__,
	w_beamgun_hudforward,
	w_dml_hudforward,
	w_grenade_hudforward,
	w_chemgun_hudforward
}

int(player) gp_inputback[] = {
	__NULL__,
	__NULL__,
	__NULL__,
	w_gausspistol_hudback,
	w_shotgun_hudback,
	__NULL__,
	w_beamgun_hudback,
	w_dml_hudback,
	w_grenade_hudback,
	w_chemgun_hudback
}

int Weapons_InputForward(player pl)
{
	if (gp_inputforward[pl.activeweapon] != __NULL__) {
		return gp_inputforward[pl.activeweapon](pl);
	}
	return TRUE;
}

int Weapons_InputBack(player pl)
{
	if (gp_inputback[pl.activeweapon] != __NULL__) {
		return gp_inputback[pl.activeweapon](pl);
	}
	return TRUE;
}
#endif
