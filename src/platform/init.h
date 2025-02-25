/*
 * Copyright (c) 2024 Vera Visions LLC.
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

void Platform_Init(void);
void Platform_Shutdown(void);
bool Platform_Draw(vector);
void Platform_RendererRestarted(void);
void Platform_CalculateRenderingScale(vector);
bool Platform_DimensionsChanged(vector);
bool Platform_HasStartupVideos(void);
void Platform_PlayStartupVideos(void);


/* Basic Menu Globals */
int g_active;

var float frametime;

#ifdef MENU
noref float lasttime;
#endif

var int g_background = FALSE;
var int g_gamestate;
var vector g_vecMousePos;
vector g_menuofs;
vector g_vidsize;

noref vector g_lastmousepos;
noref vector g_logosize;
