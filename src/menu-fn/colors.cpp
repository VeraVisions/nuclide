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

vector col_help;
vector col_prompt_bg;
vector col_prompt_text;
vector col_prompt_title;
vector col_input_text;
vector col_input_bg;
vector col_refresh_title;
vector col_refresh_text;
vector col_refresh_bg;

string Colors_RGB8_to_HEX(vector color)
{
	string out = "^x";

	for (int i = 0; i < 3; i++) {
		string a;
		float b = rint(color[i] * 15);

		switch (b) {
			case 10:
				a = "A";
				break;
			case 11:
				a = "B";
				break;
			case 12:
				a = "C";
				break;
			case 13:
				a = "D";
				break;
			case 14:
				a = "E";
				break;
			case 15:
				a = "F";
				break;
			default:
				a = ftos(b);
		}
		out = sprintf("%s%s", out, a);
	}
	return out;
}

void Colors_Init(void)
{
	int c;
	vector coltmp;
	string temp;
	filestream fs_colors;

	/* Defaults */
	col_help			= [127,127,127] / 255;
	col_prompt_bg		= [56,56,56] / 255;
	col_prompt_text		= [240,180,24] / 255;
	col_prompt_title	= [255,255,255] / 255;
	col_input_text		= [240,180,24] / 255;
	col_input_bg		= [56,56,56] / 255;
	col_refresh_title	= [240,180,24] / 255;
	col_refresh_text	= [255,255,255] / 255;
	col_refresh_bg		= [56,56,56] / 255;
	
	fs_colors = fopen("gfx/shell/colors.lst", FILE_READ);

	if (fs_colors < 0) {
		fs_colors = fopen("gfx/shell/Colors.lst", FILE_READ);
	}

	if (fs_colors < 0) {
		print("^1WARNING: ^7Could NOT load gfx/shell/colors.lst");
		return;
	}

	/* Count the valid entries */
	if (fs_colors >= 0) {
		while ((temp = fgets(fs_colors))) {
			c = tokenize(temp);
			if (c != 4) {
				continue;
			}
			coltmp = [stof(argv(1)),stof(argv(2)),stof(argv(3))] / 255;
			switch(argv(0)) {
				case "HELP_COLOR":
				col_help = coltmp;
				break;
				case "PROMPT_BG_COLOR":
				col_prompt_bg = coltmp;
				break;
				case "PROMPT_TEXT_COLOR":
				col_prompt_text = coltmp;
				break;
				case "PROMPT_TITLE_COLOR":
				col_prompt_title = coltmp;
				break;
				case "INPUT_TEXT_COLOR":
				col_input_text = coltmp;
				break;
				case "INPUT_BG_COLOR":
				col_input_bg = coltmp;
				break;
				case "REFRESH_TITLE_COLOR":
				col_refresh_title = coltmp;
				break;
				case "REFRESH_TEXT_COLOR":
				col_refresh_text = coltmp;
				break;
				case "REFRESH_BG_COLOR":
				col_refresh_bg = coltmp;
				break;
			}
		}
		fclose(fs_colors);
	}
}
