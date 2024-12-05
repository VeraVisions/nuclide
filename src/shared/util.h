/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/** @defgroup sharedutilities Utilities
    @brief Shared Utility API Reference
    @ingroup shared

    @{

 */

/** Changes the class of a given entity.
@param objectID Target entity.
@param className Name of the class the target entity will be changed to. */
void Util_ChangeClass(entity, string);
/** Extract the file extension from a given file name string.
@param inputString Path to a file. Can be local or remote.
@return The file extension, from the full path of a file. */
string Util_ExtensionFromString(string);
/** Format a chat message for a given player num, with a specific team set. 
@param playerNum ID of the player whose name will be displayed.
@param teamNum ID of the team the message should be displayed as being from.
@param chatMessage String containing the chat message to be displayed.
@return A colorized string with name, message and team identifier. */
string Util_ChatFormat(float, float, string);


var int g_numplayerslots;
int Util_GetMaxPlayers(void);
string Util_GetTime(void);
float Util_GetTimeLeft(void);
string Util_GetAddress(void);

/** @} */ // end of sharedutilities
