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

TODO: This gamemode is odd about balancing, right now the last surviving terrorist
 	  will decide the match. Still have to think about what rules to set up.
*/

class func_escapezone
{
	void(void) func_escapezone;
	virtual void(void) touch;
};

void Escape_Touch(entity targ)
{
	entity eOld = self;
	self = targ;
	Spawn_MakeSpectator();
	self.classname = "player";
	forceinfokey(self, "*dead", "0");
	self.health = 0;
	Rules_CountPlayers();
	self = eOld;
}

/*
=================
func_escapezone_touch
=================
*/
void func_escapezone::touch(void)
{
	if (other.classname == "player") {
		if (other.team == TEAM_T) {
			Escape_Touch(other);

			if (iAlivePlayers_T == 0) {
				Rules_RoundOver(TEAM_T, 2500, FALSE);
			}
		}
		other.fInEscapeZone = TRUE;
	}
}

/*
=================
SPAWN: func_escapezone

Entry function for the terrorist escape zone
=================
*/
void func_escapezone::func_escapezone(void)
{
	angles = [0,0,0];
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if (model) {
		setmodel(self, model);
	} else {
		setsize(self, mins, maxs);
	}

	model = 0;
	iEscapeZones++;
}
