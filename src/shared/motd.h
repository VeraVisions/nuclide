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

#ifdef SERVER
var string autocvar_motdfile = "motd.txt";
#define MOTD_FILE autocvar_motdfile

/** @defgroup motd Message of the Day
@brief Server set message of the day, display to clients.
@ingroup shared

# Message of the Day (MOTD) System {#motd}

Any multiplayer game has the capability of setting a **Message of the Day**, **MotD** for short.

Those are usually bits of information about the game server, how to contact the administrator or more.

A NSGameRules based class can usually call `MOTD_LoadDefault()` on the server to load the message from the default file location located under `gamedir/motd.txt`. The default location can be changed by adjusting the console variable `motdfile`.

The client game then receives the **MotD** using `MOTD_GetTextBody()`, in addition to `MOTD_GetLineCount()` for figuring out how many lines of text the message takes up.

@{

*/

/** Hard-limit to how many lines are allowed within a message of the day. */
#define MOTD_LINES 32

/** Called on the server to load the default 'message of the day' file. */
void MOTD_LoadDefault(void);

/** Called on the server to load a specific 'message of the day' file. */
void MOTD_LoadFromFile(string);
#endif

/** Called by CSQC_Init() on the client game and by initents() on the server game to
set up a networked 'message of the day'. */
void MOTD_Init(void);

#ifdef CLIENT
/** Returns the full text body of the 'message of the day' that is on the server. Can be retrieved by clients via the `motd` console command. */
string MOTD_GetTextBody(void);
/** Returns how many individual lines are present in the message of the day. */
int MOTD_GetLineCount(void);
#endif

/** @} */ // end of motd
