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

class func_buyzone
{
	void(void) func_buyzone;
	virtual void(void) touch;
};

void func_buyzone::touch(void)
{
	/* This will be cleared every frame inside SV_RunClientCommand */
	if((other.classname == "player") && (other.team == self.team)) {
		other.fInBuyZone = TRUE;
	}
}

void func_buyzone::func_buyzone(void)
{
	if (autocvar_fcs_knifeonly == TRUE) {
		remove(self);
		return;
	}

	if (autocvar_fcs_swapteams == TRUE) {
		if (team == TEAM_T) {
			team = TEAM_CT;
		} else if (team == TEAM_CT) {
			team = TEAM_T;
		}
	}

	angles = '0 0 0';
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if (model) {
		SetModel(model);
	} else {
		mins = '-128 -128 -36';
		maxs = '128 128 36';
		setsize(this, mins, maxs);
	}

	model = 0;
	iBuyZones++;
}

/*
=================
Game_CreateBuyZones

Called by StartFrame if we somehow got no buy zones
=================
*/
void Game_CreateBuyZones(void) {
	entity a;

	if (autocvar_fcs_knifeonly == TRUE) {
		return;
	}

	if (iBuyRestriction == BUY_T || iBuyRestriction == BUY_BOTH) {
		for (a = world; (a = find(a, classname, "info_player_deathmatch"));) {
			func_buyzone zone = spawn(func_buyzone);
			setorigin(zone, a.origin);
			zone.team = TEAM_T;
		}
	}

	if (iBuyRestriction == BUY_CT || iBuyRestriction == BUY_BOTH) {
		for (a = world; (a = find(a, classname, "info_player_start"));) {
			func_buyzone zone = spawn(func_buyzone);
			setorigin(zone, a.origin);
			zone.team = TEAM_CT;
		}
	}
}
