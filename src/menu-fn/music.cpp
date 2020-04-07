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

/* we're forced to support a few different paths */
enum
{
	MUSIC_AUTO,
	MUSIC_FLAC, /* requires fteplug_ffmpeg */
	MUSIC_STEAMHL
};

string g_steamhltracks[27] = {
	"media/Half-Life01.mp3",
	"media/Prospero01.mp3",
	"media/Half-Life12.mp3",
	"media/Half-Life07.mp3",
	"media/Half-Life10.mp3",
	"media/Suspense01.mp3",
	"media/Suspense03.mp3",
	"media/Half-Life09.mp3",
	"media/Half-Life02.mp3",
	"media/Half-Life13.mp3",
	"media/Half-Life04.mp3",
	"media/Half-Life15.mp3",
	"media/Half-Life14.mp3",
	"media/Half-Life16.mp3",
	"media/Suspense02.mp3",
	"media/Half-Life03.mp3",
	"media/Half-Life08.mp3",
	"media/Prospero02.mp3",
	"media/Half-Life05.mp3",
	"media/Prospero04.mp3",
	"media/Half-Life11.mp3",
	"media/Half-Life06.mp3",
	"media/Prospero03.mp3",
	"media/Half-Life17.mp3",
	"media/Prospero05.mp3",
	"media/Suspense05.mp3",
	"media/Suspense07.mp3"
};

var int autocvar_cl_musicstyle = MUSIC_AUTO;

/* some installs may have the music in media/, others may be in music/ */
string
Music_GetPath(int id)
{
	if (autocvar_cl_musicstyle == MUSIC_AUTO) {
		return sprintf("%i", id);
	} else if (autocvar_cl_musicstyle == MUSIC_FLAC) {
		return sprintf("music/track%02i.flac", id);
	} else if (autocvar_cl_musicstyle == MUSIC_STEAMHL) {
		if (id >= 2 && id <= 28) {
			return g_steamhltracks[id - 2];
		}
	}

	return "";
}

/* EV_MUSICTRACK */
void
Music_ParseTrack(string parm)
{
	int track;
	string path;

	track = stof(parm);
	path = Music_GetPath(track);
	dprint(sprintf("^2Music_ParseTrack:^7 Single track %i from %s\n", track, path));
	localcmd(sprintf("music %s -\n", path));
}

/* EV_MUSICLOOP */
void
Music_ParseLoop(string parm)
{
	int track;
	string path;

	track = stof(parm);
	path = Music_GetPath(track);
	dprint(sprintf("^2Music_ParseLoop:^7 Looping track %i from %s\n", track, path));
	localcmd(sprintf("music %s\n", path));
}

void
Music_MenuStart(void)
{
	string tinfo = cvar_string("gameinfo_menutrack");
	if (tinfo) {
		localcmd(sprintf("music %s\n", tinfo));
	}
}
