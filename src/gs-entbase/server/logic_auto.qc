/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED logic_auto (1 0 0) (-8 -8 -8) (8 8 8) TA_USEONCE
Will automatically trigger its outputs when the level has spawned.
This is Source's variant of trigger_auto. If you want to talk to old-styled
targets instead, use that instead.

-------- KEYS --------
"targetname" : Name
"globalstate" : The env_global state to read before firing.

-------- INPUTS --------
"OnMapSpawn" : Triggered when the map is loaded for any reason.
"OnNewGame" : Triggered only when a new game starts on this level.
"OnLoadGame : Triggered when the map is loaded via save game.
"OnMapTransition" : Triggered when we load this map via level transition.
"OnBackgroundMap" : Triggered if this map is used as a menu background.
"OnMultiNewMap" : Same as 'OnMapSpawn' but only valid in multiplayer.
"OnMultiNewRound" : Triggered only during round restarts in multiplayer.

-------- SPAWNFLAGS --------
TA_USEONCE : Remove itself from the level permanently when activated.

-------- NOTES --------
When a logic_auto is removed via TA_USEONCE it won't survive match respawns.

Source Engine behaviour (do not fix):
The output 'OnMultiNewMap' is also triggered during round restarts.
This would make 'OnMultiNewRound' redundant, however 'OnMultiNewRound' does
not get called upon map start.

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

class logic_auto:NSPointTrigger
{
	string m_strGlobalState;

	/* outputs */
	string m_strOnMapSpawn;
	string m_strOnNewGame;
	string m_strOnLoadGame;
	string m_strOnMapTransition;
	string m_strOnBackgroundMap;
	string m_strOnMultiNewMap;
	string m_strOnMultiNewRound;

	/* temporary */
	int m_iFromSaveGame;

	void(void) logic_auto;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

	virtual void(void) Processing;
};

void
logic_auto::Save(float handle)
{
	SaveString(handle, "globalstate", m_strGlobalState);
	SaveString(handle, "OnMapSpawn", m_strOnMapSpawn);
	SaveString(handle, "OnNewGame", m_strOnNewGame);
	SaveString(handle, "OnLoadGame", m_strOnLoadGame);
	SaveString(handle, "OnMapTransition", m_strOnMapTransition);
	SaveString(handle, "OnBackgroundMap", m_strOnBackgroundMap);
	SaveString(handle, "OnMultiNewMap", m_strOnMultiNewMap);
	SaveString(handle, "OnMultiNewRound", m_strOnMultiNewRound);
	super::Save(handle);
}

void
logic_auto::Restore(string strKey, string strValue)
{
	m_iFromSaveGame = 1;

	switch (strKey) {
	case "globalstate":
		m_strGlobalState = ReadString(strValue);
		think = Processing;
		nextthink = time + 0.2f;
		break;
	case "OnMapSpawn":
		m_strOnMapSpawn = ReadString(strValue);
		break;
	case "OnNewGame":
		m_strOnNewGame = ReadString(strValue);
		break;
	case "OnLoadGame":
		m_strOnLoadGame = ReadString(strValue);
		break;
	case "OnMapTransition":
		m_strOnMapTransition = ReadString(strValue);
		break;
	case "OnBackgroundMap":
		m_strOnBackgroundMap = ReadString(strValue);
		break;
	case "OnMultiNewMap":
		m_strOnMultiNewMap = ReadString(strValue);
		break;
	case "OnMultiNewRound":
		m_strOnMultiNewRound = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
logic_auto::Processing(void)
{
	if (m_strGlobalState)
		if (GetGlobalValue(m_strGlobalState) == 0)
			return;

	UseOutput(this, m_strOnMapSpawn);

	if (cvar("sv_playerslots") == 1) {
		if (m_iFromSaveGame) {
			/* set by trigger_changelevel, however not by the changelevel cmd */
			if (cvar("_bsp_change_auto") == 1) {
				UseOutput(this, m_strOnMapTransition);
				readcmd("set _bsp_change_auto \"\"\n");
			} else
				UseOutput(this, m_strOnLoadGame);
		} else
			UseOutput(this, m_strOnNewGame);
	} else {
		/* TODO: more reliable way of figuring out round restarts */
		if (time > 5)
			UseOutput(this, m_strOnMultiNewRound);

		/* yes, this is also called during entity respawns :X */
		UseOutput(this, m_strOnMultiNewMap);
	}

	if (serverkeyfloat("background") == 1)
		UseOutput(this, m_strOnBackgroundMap);

	if (HasSpawnFlags(1)) {
		NSLog("^2logic_auto::^3think^7: %s triggerer removed self",  target);
		remove(this);
	}
}

void
logic_auto::Respawn(void)
{
	think = Processing;
	nextthink = time + 0.2f;
}

void
logic_auto::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "globalstate":
		m_strGlobalState = strValue;
		break;
	/* outputs */
	case "OnMapSpawn":
		m_strOnMapSpawn = PrepareOutput(m_strOnMapSpawn, strValue);
		break;
	case "OnNewGame":
		m_strOnNewGame = PrepareOutput(m_strOnNewGame, strValue);
		break;
	case "OnLoadGame":
		m_strOnLoadGame = PrepareOutput(m_strOnLoadGame, strValue);
		break;
	case "OnMapTransition":
		m_strOnMapTransition = PrepareOutput(m_strOnMapTransition, strValue);
		break;
	case "OnBackgroundMap":
		m_strOnBackgroundMap = PrepareOutput(m_strOnBackgroundMap, strValue);
		break;
	case "OnMultiNewMap":
		m_strOnMultiNewMap = PrepareOutput(m_strOnMultiNewMap, strValue);
		break;
	case "OnMultiNewRound":
		m_strOnMultiNewRound = PrepareOutput(m_strOnMultiNewRound, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
logic_auto::logic_auto(void)
{
	m_iFromSaveGame = 0;

	super::NSPointTrigger();

	if (m_strOnMapSpawn)
		m_strOnMapSpawn = CreateOutput(m_strOnMapSpawn);
	if (m_strOnNewGame)
		m_strOnNewGame = CreateOutput(m_strOnNewGame);
	if (m_strOnLoadGame)
		m_strOnLoadGame = CreateOutput(m_strOnLoadGame);
	if (m_strOnMapTransition)
		m_strOnMapTransition = CreateOutput(m_strOnMapTransition);
	if (m_strOnBackgroundMap)
		m_strOnBackgroundMap = CreateOutput(m_strOnBackgroundMap);
	if (m_strOnMultiNewMap)
		m_strOnMultiNewMap = CreateOutput(m_strOnMultiNewMap);
	if (m_strOnMultiNewRound)
		m_strOnMultiNewRound = CreateOutput(m_strOnMultiNewRound);
}
