/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

typedef struct
{
	string m_strPath;
	float m_flProgsID;
} plugin_t;

plugin_t *g_plugindb;
var int g_plugincount;

void
Plugin_Init(void)
{
	filestream pdb;
	string tmp;
	int i;

	if (autocvar_sv_plugins) {
		print("--------- Initializing Plugins ----------\n");
		g_plugins_enabled = 1;
	} else {
		g_plugins_enabled = 0;
		return;
	}

	pdb = fopen("plugins.txt", FILE_READ);

	if (pdb < 0) {
		print("^1no plugins.txt found.\n");
		g_plugins_enabled = 0;
		return;
	}

	/* count valid progs */
	g_plugincount = 0;
	while ((tmp = fgets(pdb))) {
		int argc = tokenize_console(tmp);

		/* check for valid entries/comments */
		if (argc <= 0)
			continue;

		g_plugincount++;
	}

	g_plugindb = memalloc(sizeof(plugin_t) * g_plugincount);
	fseek(pdb, 0);
	i = 0;

	while ((tmp = fgets(pdb))) {
		int a = tokenize_console(tmp);

		/* check for valid entries/comments */
		if (a <= 0)
			continue;

		g_plugindb[i].m_strPath = strcat("plugins/", argv(0));
		g_plugindb[i].m_flProgsID = addprogs(g_plugindb[i].m_strPath);
		i++;
	}

	fclose(pdb);

	void(void) vFunc;
	for (i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_Init");

		if (vFunc) {
			vFunc();
		}
	}

	print(sprintf("initialized %i plugins.\n", g_plugincount));
}

/*
=================
Plugin_Shutdown

Allows every plugin to properly free and unallocate whatever it is they've done
=================
*/
void
Plugin_Shutdown(void)
{
	void(void) vFunc;

	if (g_plugincount <= 0)
		return;

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_Shutdown");

		if (vFunc) {
			vFunc();
		}
	}

	memfree(g_plugindb);
	g_plugincount = 0;
}

/*
=================
Plugin_InitEnts

Called once entity slots are available for use.
=================
*/
void
Plugin_InitEnts(void)
{
	void(void) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_InitEnts");

		if (vFunc) {
			vFunc();
		}
	}
}

/*
=================
Plugin_RunClientCommand

Funtion that can interrupt client commands before physics are run
=================
*/
int
Plugin_RunClientCommand(void)
{
	int rval;
	int tval;
	int(void) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	/* rval = final return value, tval = temporary return value.
	   if at least one of the plugins returns TRUE, then RunClientCommand
	   will not be called by the engine, as it should be */
	rval = FALSE;
	tval = FALSE;

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_RunClientCommand");

		if (vFunc) {
			tval = vFunc();
			rval |= tval;
		}
	}

	return rval;
}

/*
=================
Plugin_ParseClientCommand

Intercepts 'cmd' calls. We use it to intercept
chat messages and handle distribution ourselves.
=================
*/
string
Plugin_ParseClientCommand(string msg)
{
	string(string msg) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_ParseClientCommand");

		if (vFunc) {
			string new;
			new = vFunc(msg);

			/* pass valid overrides forward */
			if (new != __NULL__)
				msg = new;
		}
	}

	return msg;
}

/*
=================
Plugin_PlayerConnect

Called whenever a new client connect to the game
=================
*/
int
Plugin_PlayerConnect(base_player cl)
{
	int rval;
	int tval;
	int(entity) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	/* rval = final return value, tval = temporary return value.
	   if at least one of the plugins returns TRUE, then RunClientCommand
	   will not be called by the engine, as it should be */
	rval = FALSE;
	tval = FALSE;

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_PlayerConnect");

		if (vFunc) {
			tval = vFunc(cl);
			rval |= tval;
		}
	}

	return rval;
}

/*
=================
Plugin_PlayerDisconnect

Called whenever a client leaves the game
=================
*/
int
Plugin_PlayerDisconnect(base_player cl)
{
	int rval;
	int tval;
	int(entity) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	/* rval = final return value, tval = temporary return value.
	   if at least one of the plugins returns TRUE, then RunClientCommand
	   will not be called by the engine, as it should be */
	rval = FALSE;
	tval = FALSE;

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_PlayerDisconnect");

		if (vFunc) {
			tval = vFunc(cl);
			rval |= tval;
		}
	}

	return rval;
}

/*
=================
Plugin_PlayerEntered

Called when a player has fully connected and entered the server
=================
*/
int
Plugin_PlayerEntered(base_player cl)
{
	int rval;
	int tval;
	int(entity) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	/* rval = final return value, tval = temporary return value.
	   if at least one of the plugins returns TRUE, then RunClientCommand
	   will not be called by the engine, as it should be */
	rval = FALSE;
	tval = FALSE;

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_PlayerEntered");

		if (vFunc) {
			tval = vFunc(cl);
			rval |= tval;
		}
	}

	return rval;
}

/*
=================
Plugin_PlayerObituary

Deathmessage hook
=================
*/
void
Plugin_PlayerObituary(entity attk, entity targ, int weapon, bodyType_t body, int dmg)
{
	void(entity,entity,int,int,int) vFunc;

	if (g_plugins_enabled == 0)
		return (0);

	for (int i = 0; i < g_plugincount; i++) {
		 vFunc = externvalue(g_plugindb[i].m_flProgsID, "FMX_PlayerObituary");

		if (vFunc) {
			vFunc(attk, targ, weapon, body, dmg);
		}
	}
}
