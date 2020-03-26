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

/* we're forced to support a few different paths */
enum
{
	MUSIC_AUTO,
	MUSIC_FLAC,
	MUSIC_STEAMHL
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
		/* this doesn't happen often enough for it to be in RAM all the time */
		switch (id) {
		case 2:
			return "media/Half-Life01.mp3";
			break;
		case 3:
			return "media/Prospero01.mp3";
			break;
		case 4:
			return "media/Half-Life12.mp3";
			break;
		case 5:
			return "media/Half-Life07.mp3";
			break;
		case 6:
			return "media/Half-Life10.mp3";
			break;
		case 7:
			return "media/Suspense01.mp3";
			break;
		case 8:
			return "media/Suspense03.mp3";
			break;
		case 9:
			return "media/Half-Life09.mp3";
			break;
		case 10:
			return "media/Half-Life02.mp3";
			break;
		case 11:
			return "media/Half-Life13.mp3";
			break;
		case 12:
			return "media/Half-Life04.mp3";
			break;
		case 13:
			return "media/Half-Life15.mp3";
			break;
		case 14:
			return "media/Half-Life14.mp3";
			break;
		case 15:
			return "media/Half-Life16.mp3";
			break;
		case 16:
			return "media/Suspense02.mp3";
			break;
		case 17:
			return "media/Half-Life03.mp3";
			break;
		case 18:
			return "media/Half-Life08.mp3";
			break;
		case 19:
			return "media/Prospero02.mp3";
			break;
		case 20:
			return "media/Half-Life05.mp3";
			break;
		case 21:
			return "media/Prospero04.mp3";
			break;
		case 22:
			return "media/Half-Life11.mp3";
			break;
		case 23:
			return "media/Half-Life06.mp3";
			break;
		case 24:
			return "media/Prospero03.mp3";
			break;
		case 25:
			return "media/Half-Life17.mp3";
			break;
		case 26:
			return "media/Prospero05.mp3";
			break;
		case 27:
			return "media/Suspense05.mp3";
			break;
		case 28:
			return "media/Suspense07.mp3w";
			break;
		}
	}

	return "";
}

/* EV_MUSICTRACK */
void
Music_ParseTrack(void)
{
	int track;
	string path;

	track = readbyte();
	path = Music_GetPath(track);
	dprint(sprintf("^2Music_ParseTrack:^7 Single track %i from %s\n", track, path));
	localcmd(sprintf("music %s -\n", path));
}

/* EV_MUSICLOOP */
void
Music_ParseLoop(void)
{
	int track;
	string path;

	track = readbyte();
	path = Music_GetPath(track);
	dprint(sprintf("^2Music_ParseTrack:^7 Looping track %i from %s\n", track, path));
	localcmd(sprintf("music %s\n", path));
}
