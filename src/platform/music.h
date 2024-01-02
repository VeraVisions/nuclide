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

/*! @file music.h
    @brief Music handler.

    This is the internal music handler.
    Games primarily will use in-game entities such as trigger_cdaudio
    and target_cdaudio to play/change music tracks.

    This is the code that handles how music track id's are translated
    into different path/naming conventions and file formats.

    Some tracks may only want to be played once (as opposed to looping).
*/

/* we're forced to support a few different paths */
typedef enum
{
	MUSIC_AUTO, /**< Auto selection (default). */
	MUSIC_FLAC, /**< Free-Lossless-Audio-Codec requires fteplug_ffmpeg. */
	MUSIC_STEAMHL /**< MP3 tracks in the naming conventions of Steam Half-Life (2003) */
} musicstyle_t;

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

var musicstyle_t autocvar_cl_musicstyle = MUSIC_AUTO;

/** Get the path to a single music track.
Some installs may have the music in media/, others may be in music/.

@param id The music track in question.
@return Path to the music track. */
string Music_GetPath(int id);

/** This function is called by EV_MUSICTRACK events.
Will play a single music track once.

@param parm The music track in question. Mostly a track number. */
void Music_ParseTrack(string parm);

/** This function is called by EV_MUSICLOOP events.
Will play a music track that loops.

@param parm The music track in question. Mostly a track number. */
void Music_ParseLoop(string parm);

/** Called once when the menu is initialized.
Will start playing whatever track is defined in the manifest or liblist file. */
void Music_MenuStart(void);
