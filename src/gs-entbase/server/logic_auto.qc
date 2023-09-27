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

#define LOGICAUTO_USEONCE 1

/*!QUAKED logic_auto (1 0 0) (-8 -8 -8) (8 8 8) USE_ONCE
# OVERVIEW
Will automatically trigger its outputs when the level has spawned.
This is Source's variant of trigger_auto. If you want to talk to old-styled
targets instead, use that instead.

# KEYS
- "targetname" : Name
- "globalstate" : The env_global state to read before firing.

# OUTPUTS
- "OnMapSpawn" : Triggered when the map is loaded for any reason.  
- "OnNewGame" : Triggered only when a new game starts on this level.  
- "OnLoadGame" : Triggered when the map is loaded via save game.  
- "OnMapTransition" : Triggered when we load this map via level transition.  
- "OnBackgroundMap" : Triggered if this map is used as a menu background.  
- "OnMultiNewMap" : Same as 'OnMapSpawn' but only valid in multiplayer.  
- "OnMultiNewRound" : Triggered only during round restarts in multiplayer.

# SPAWNFLAGS
- USE_ONCE (1) : Remove itself from the level permanently when activated.

# NOTES
When a logic_auto is removed via TA_USEONCE it won't survive match respawns.

Source Engine behaviour (do not fix):
The output 'OnMultiNewMap' is also triggered during round restarts.
This would make 'OnMultiNewRound' redundant, however 'OnMultiNewRound' does
not get called upon map start.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
logic_auto:NSPointTrigger
{
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

public:
	void logic_auto(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void RestoreComplete(void);
	
	nonvirtual void Processing(void);

};

void
logic_auto::logic_auto(void)
{
	m_iFromSaveGame = 0;
	m_strOnMapSpawn = __NULL__;
	m_strOnNewGame = __NULL__;
	m_strOnLoadGame = __NULL__;
	m_strOnMapTransition = __NULL__;
	m_strOnBackgroundMap = __NULL__;
	m_strOnMultiNewMap = __NULL__;
	m_strOnMultiNewRound = __NULL__;
}

void
logic_auto::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strOnMapSpawn", m_strOnMapSpawn);
	SaveString(handle, "m_strOnNewGame", m_strOnNewGame);
	SaveString(handle, "m_strOnLoadGame", m_strOnLoadGame);
	SaveString(handle, "m_strOnMapTransition", m_strOnMapTransition);
	SaveString(handle, "m_strOnBackgroundMap", m_strOnBackgroundMap);
	SaveString(handle, "m_strOnMultiNewMap", m_strOnMultiNewMap);
	SaveString(handle, "m_strOnMultiNewRound", m_strOnMultiNewRound);
}

void
logic_auto::Restore(string strKey, string strValue)
{
	m_iFromSaveGame = 1;

	switch (strKey) {
	case "m_strOnMapSpawn":
		m_strOnMapSpawn = ReadString(strValue);
		break;
	case "m_strOnNewGame":
		m_strOnNewGame = ReadString(strValue);
		break;
	case "m_strOnLoadGame":
		m_strOnLoadGame = ReadString(strValue);
		break;
	case "m_strOnMapTransition":
		m_strOnMapTransition = ReadString(strValue);
		break;
	case "m_strOnBackgroundMap":
		m_strOnBackgroundMap = ReadString(strValue);
		break;
	case "m_strOnMultiNewMap":
		m_strOnMultiNewMap = ReadString(strValue);
		break;
	case "m_strOnMultiNewRound":
		m_strOnMultiNewRound = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
logic_auto::RestoreComplete(void)
{
	ScheduleThink(Processing, 0.2f);
}

void
logic_auto::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
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
logic_auto::Spawned(void)
{
	super::Spawned();

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

void
logic_auto::Respawn(void)
{
	
	m_iFromSaveGame = 1;
	ScheduleThink(Processing, 0.2f);
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

	if (HasSpawnFlags(LOGICAUTO_USEONCE)) {
		NSLog("^2logic_auto::^3Processing ^7: %s triggerer removed self",  target);
		Destroy();
	}
}
