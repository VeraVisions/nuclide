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

class info_map_parameters
{
	void() info_map_parameters;
};

void info_map_parameters::info_map_parameters(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "bombradius":
			iBombRadius = stoi(argv(i + 1));
#ifdef GS_DEVELOPER
			print(sprintf("info_map_parameters: Set C4 radius to %i\n", iBombRadius));
#endif
			break;
		case "buying":
			iBuyRestriction = stoi(argv(i + 1));
#ifdef GS_DEVELOPER
			print(sprintf("info_map_parameters: Set buy restriction to %i\n", iBuyRestriction));
#endif
			break;
		default:
			break;
		}
	}

#ifndef GS_DEVELOPER
	remove(this);
#endif
}
