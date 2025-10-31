/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

var vector autocvar_menu_color_help           = [0.50,0.50,0.50];
var vector autocvar_menu_color_prompt_bg      = [0.22,0.22,0.22];
var vector autocvar_menu_color_prompt_text    = [0.94,0.71,0.09];
var vector autocvar_menu_color_prompt_title   = [1.00,1.00,1.00];
var vector autocvar_menu_color_input_text     = [0.94,0.71,0.09];
var vector autocvar_menu_color_input_bg       = [0.22,0.22,0.22];
var vector autocvar_menu_color_refresh_title  = [0.94,0.71,0.09];
var vector autocvar_menu_color_refresh_text   = [1.00,1.00,1.00];
var vector autocvar_menu_color_refresh_bg     = [0.22,0.22,0.22];
var vector autocvar_menu_color_button_bg      = [0.97,0.71,0.22];
var vector autocvar_menu_color_button_select  = [1.00,0.00,0.00];
var vector autocvar_menu_color_button_click   = [1.00,1.00,0.00];
var vector autocvar_menu_color_button_disabled = [0.25,0.25,0.25];
var vector autocvar_menu_color_list = [1,0.5,0.1];
var vector autocvar_menu_color_list_select = [84/255,45/255,0];
var vector autocvar_menu_color_scrollbar_bg = [0,0,0];
var vector autocvar_menu_color_scrollbar_select = [1,0.5,0.25];
var vector autocvar_menu_color_scrollbar_click = [1,0.5,0.25];
var bool autocvar_menu_color_external = true;

vector col_help;
vector col_prompt_bg;
vector col_prompt_text;
vector col_prompt_title;
vector col_input_text;
vector col_input_bg;
vector col_refresh_title;
vector col_refresh_text;
vector col_refresh_bg;
vector col_button_bg; /* 1,1,1 */
vector col_button_select; /* 1,0,0 */
vector col_button_click; /* 1,1,0 */
vector col_button_disabled; /* 0.25, 0.25, 0.25 */
vector col_list_text;
vector col_list_select;

/* Menu color scheme init.
   First we read cvars for defaults.
   Then we load the shell colors.lst on top. Mods shipped
   quite a lot with those.

   We also want to allow users to ignore the colors a mod
   may supply. This seems like the most reasonable
   implementation at this time.
*/
void
Colors_Init(void)
{
	int c;
	vector coltmp;
	string temp;
	filestream fs_colors;

	/* Defaults */
	col_help			= autocvar_menu_color_help;
	col_prompt_bg		= autocvar_menu_color_prompt_bg;
	col_prompt_text		= autocvar_menu_color_prompt_text;
	col_prompt_title	= autocvar_menu_color_prompt_title;
	col_input_text		= autocvar_menu_color_input_text;
	col_input_bg		= autocvar_menu_color_input_bg;
	col_refresh_title	= autocvar_menu_color_refresh_title;
	col_refresh_text	= autocvar_menu_color_refresh_text;
	col_refresh_bg		= autocvar_menu_color_refresh_bg;

	col_button_bg		= autocvar_menu_color_button_bg;
	col_button_select	= autocvar_menu_color_button_select;
	col_button_click	= autocvar_menu_color_button_click;
	col_button_disabled	= autocvar_menu_color_button_disabled;
	col_list_text		= autocvar_menu_color_list;
	col_list_select		= autocvar_menu_color_list_select;

	if (autocvar_menu_color_external == false) {
		ncLog("Ignoring external colors list due to menu_color_external cvar.");
		return;
	}

	/* we parse both capitalizations we've commonly found - just. in. case. */
	fs_colors = fopen("gfx/shell/colors.lst", FILE_READ);

	if (fs_colors < 0) {
		fs_colors = fopen("gfx/shell/Colors.lst", FILE_READ);
	}

	/* at this point give up */
	if (fs_colors < 0) {
		ncLog("Missing gfx/shell/colors.lst, using built-in colors.");
		return;
	}

	/* Example format we're reading in here:

	```
	COLOR_RED		255 0 0
	COLOR_YELLOW	255 255 0
	```

	so we check for 4 columns, and convert the color values to normalized
	floating point values. as most drawing functions don't operate in that channel
	*/
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
			case "BUTTON_BG_COLOR":
				col_button_bg = coltmp;
				break;
			case "BUTTON_SELECT_COLOR":
				col_button_select = coltmp;
				break;
			case "BUTTON_CLICK_COLOR":
				col_button_click = coltmp;
				break;
			case "BUTTON_DISABLED_COLOR":
				col_button_disabled = coltmp;
				break;
			case "LIST_TEXT_COLOR":
				col_list_text = coltmp;
				break;
			case "LIST_SELECT_COLOR":
				col_list_select = coltmp;
				break;
			}
		}
		fclose(fs_colors);
	}
}
