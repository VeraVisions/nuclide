/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/* very basic wrapper around loadfont(), as we don't want to hard-code
 * paths to fonts used in the cgame */
float
Font_LoadFont(string filename)
{
	string line;
	filestream fs_font;

	fs_font = fopen(filename, FILE_READ);

	if (fs_font < 0) {
		print(sprintf("[FONT] ^1WARNING: ^7Could NOT load %s\n", filename));
		return -1;
	}

	string font = "gfx/conchars";
	string size = "8";
	string shortname "";

	while ((line = fgets(fs_font))) {
		int c = tokenize_console(line);

		switch (argv(0)) {
		case "font":
			font = argv(1);
			break;
		case "size":
			size = argv(1);
			break;
		case "name":
			shortname = argv(1);
			break;
		}
	}

	fclose(fs_font);

	return loadfont(shortname, font, size, -1);
}
