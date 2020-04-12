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

class info_player_teamspawn:CBaseTrigger
{
	void(void) info_player_teamspawn;
};

void
info_player_teamspawn::info_player_teamspawn(void)
{
	int team = 1;
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "team_no":
			team = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}

	switch (team) {
	case 1:
		classname = "info_teamspawn_blue";
		break;
	case 2:
		classname = "info_teamspawn_red";
		break;
	case 3:
		classname = "info_teamspawn_yellow";
		break;
	case 4:
		classname = "info_teamspawn_green";
		break;
	}
}

CLASSEXPORT(i_p_t, info_player_teamspawn)
