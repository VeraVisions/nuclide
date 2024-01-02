/*
 * Copyright (c) 2023 Vera Visions LLC.
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

var string g_lastDisconnectReason = "";

/** Query if we've been disconnected from the server.
The function is designed to be run every frame. It will return `true` only once per server session, so check it in one place and cache the result if necessary. This is meant for menu developers. If you are adding onto an existing menu framework, calling it more than once and out of order may break core menu functionality in your module.

@return Will return `true` if we've been disconnected and `false` any other time. */
bool
Error_ServerDisconnected(void)
{
	string disconnectReason;

	disconnectReason = cvar_string("_cl_disconnectreason");

	/* still empty */
	if (disconnectReason == "") {
		return false;
	}

	/* save to cache */
	g_lastDisconnectReason = disconnectReason;
	cvar_set("_cl_disconnectreason", "");
	return true;
}

/** Query the last reason for a server disconnect. Will stick and always return something valid when you've been disconnected at least once.

@return The reason for the disconnect. */
string
Error_GetDisconnectReason(void)
{
	return g_lastDisconnectReason;
}