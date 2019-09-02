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

typedef struct titles_s
{
	string m_strName;
	string m_strMessage;
	float m_flPosX;
	float m_flPosY;
	int m_iEffect;
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flFadeIn;
	float m_flFadeOut;
	float m_flHoldTime;
	float m_flFXTime;
} titles_t;
titles_t *g_titles;
int g_titles_count;

void
Titles_Init(void)
{
	float t_position[2];
	int t_effect;
	vector t_color;
	vector t_color2;
	float t_fxtime;
	float t_holdtime;
	float t_fadein;
	float t_fadeout;
	string t_name = "";
	string t_message = "";

	filestream fs_titles;
	string temp;
	int c;
	int braced;

	fs_titles = fopen("titles.txt", FILE_READ);

	if (fs_titles < 0) {
		print("^1WARNING: ^7Could NOT load titles.lst");
		return;
	}

	if (fs_titles >= 0) {
		while ((temp = fgets(fs_titles))) {
			c = tokenize_console(temp);
			if (c < 1) {
				continue;
			}
			switch(argv(0)) {
			case "$position":
				t_position[0] = stof(argv(1));
				t_position[1] = stof(argv(2));
				break;
			case "$effect":
				t_effect = stoi(argv(1));
				break;
			case "$color":
				if (c == 4) {
					t_color[0] = stof(argv(1)) / 255;
					t_color[1] = stof(argv(2)) / 255;
					t_color[2] = stof(argv(3)) / 255;
				} else {
					t_color = stov(argv(1)) / 255;
				}
				break;
			case "$color2":
				if (c == 4) {
					t_color2[0] = stof(argv(1)) / 255;
					t_color2[1] = stof(argv(2)) / 255;
					t_color2[2] = stof(argv(3)) / 255;
				} else {
					t_color2 = stov(argv(1)) / 255;
				}
				break;
			case "$fxtime":
				t_fxtime = stof(argv(1));
				break;
			case "$holdtime":
				t_holdtime = stof(argv(1));
				break;
			case "$fadein":
				t_fadein = stof(argv(1));
				break;
			case "$fadeout":
				t_fadeout = stof(argv(1));
				break;
			case "{":
				braced = TRUE;
				break;
			case "}":
				int id = g_titles_count - 1;
				braced = FALSE;
				g_titles[id].m_strName = t_name;
				g_titles[id].m_strMessage = t_message;
				g_titles[id].m_flPosX = t_position[0];
				g_titles[id].m_flPosY = t_position[1];
				g_titles[id].m_iEffect = t_effect;
				g_titles[id].m_vecColor1 = t_color;
				g_titles[id].m_vecColor2 = t_color2;
				g_titles[id].m_flFadeIn = t_fadein;
				g_titles[id].m_flFadeOut = t_fadeout;
				g_titles[id].m_flHoldTime = t_holdtime;
				g_titles[id].m_flFXTime = t_fxtime;
				t_message = "";
				t_name = "";
				break;
			default:
				if (braced) {
					t_message = sprintf("%s%s\n", t_message, temp);
				} else {
					t_name = strtoupper(argv(0));
					g_titles = memrealloc(g_titles, sizeof(titles_t), g_titles_count, ++g_titles_count);
					dprint(sprintf("[^1TITLES^7] Found ^2%s\n", t_name));
				}
			}
		}
		fclose(fs_titles);
	}
}
