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

var int g_plugins_enabled;
var int autocvar_sv_plugins = 1;

void Plugin_Init(void)
{	
	if (autocvar_sv_plugins) {
		print("Initializing plugins...\n");
		g_plugins_enabled = 1;
	} else {
		print("Initializing plugins...\n");
		g_plugins_enabled = 0;
	}
}

/*
=================
Plugin_RunClientCommand

Funtion that can interrupt client commands before physics are run
=================
*/
int Plugin_RunClientCommand(void)
{
	int(void) vFunc = externvalue(-2, "FMX_RunClientCommand");

	if (vFunc || g_plugins_enabled == 0) {
		return vFunc();
	}

	return FALSE;
}

/*
=================
Plugin_ParseClientCommand

Intercepts 'cmd' calls. We use it to intercept
chat messages and handle distribution ourselves.
=================
*/
int Plugin_ParseClientCommand(string msg)
{
	int(string msg) vFunc = externvalue(-2, "FMX_ParseClientCommand");

	if (vFunc || g_plugins_enabled == 0) {
		return vFunc(msg);
	}

	return FALSE;
}
