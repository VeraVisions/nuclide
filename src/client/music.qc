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

/* We'll let the menu handle the music, as it may want to do special stuff with
 * track orders and whatnot. We also cannot predict the paths that easily
 * without making wrong assumptions. */

/*
====================
Music_ParseTrack

Handles EV_MUSICTRACK, a type of music track that only plays once.
====================
*/
void
Music_ParseTrack(void)
{
	int track;
	track = readbyte();
	localcmd(sprintf("menu_musictrack %i\n", track));
}

/*
====================
Music_ParseLoop

Handles EV_MUSICLOOP, a type of music track that loops continously.
====================
*/
void
Music_ParseLoop(void)
{
	int track;
	track = readbyte();
	localcmd(sprintf("menu_musicloop %i\n", track));
}

void
Music_ReadLoop(void)
{
	float trackID = readfloat();
	string musicTrack = substring(modelnameforindex(trackID), 3, -1);
	localcmd(strcat("music ", musicTrack, " 1\n"));
}

void
Music_ReadOnce(void)
{
	float trackID = readfloat();
	string musicTrack = substring(modelnameforindex(trackID), 3, -1);
	localcmd(strcat("music ", musicTrack, " 0\n"));
}

void
Music_Stop(void)
{
	localcmd("stopmusic\n");
}
