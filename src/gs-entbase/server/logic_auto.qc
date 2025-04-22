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

/*! \brief Server-Entity: Map-Start Trigger */
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

@ingroup serverentity
@ingroup pointentity
*/
class
logic_auto:ncPointTrigger
{
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

private:
	/* outputs */
	string m_outputOnMapSpawn;
	string m_outputOnNewGame;
	string m_outputOnLoadGame;
	string m_outputOnMapTransition;
	string m_outputOnBackgroundMap;
	string m_outputOnMultiNewMap;
	string m_outputOnMultiNewRound;

	/* temporary */
	int m_iFromSaveGame;
};

void
logic_auto::logic_auto(void)
{
	m_iFromSaveGame = 0i;
	m_outputOnMapSpawn = __NULL__;
	m_outputOnNewGame = __NULL__;
	m_outputOnLoadGame = __NULL__;
	m_outputOnMapTransition = __NULL__;
	m_outputOnBackgroundMap = __NULL__;
	m_outputOnMultiNewMap = __NULL__;
	m_outputOnMultiNewRound = __NULL__;
}

void
logic_auto::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_outputOnMapSpawn", m_outputOnMapSpawn);
	SaveString(handle, "m_outputOnNewGame", m_outputOnNewGame);
	SaveString(handle, "m_outputOnLoadGame", m_outputOnLoadGame);
	SaveString(handle, "m_outputOnMapTransition", m_outputOnMapTransition);
	SaveString(handle, "m_outputOnBackgroundMap", m_outputOnBackgroundMap);
	SaveString(handle, "m_outputOnMultiNewMap", m_outputOnMultiNewMap);
	SaveString(handle, "m_outputOnMultiNewRound", m_outputOnMultiNewRound);
}

void
logic_auto::Restore(string strKey, string setValue)
{
	m_iFromSaveGame = 1i;

	switch (strKey) {
	case "m_outputOnMapSpawn":
		m_outputOnMapSpawn = ReadString(setValue);
		break;
	case "m_outputOnNewGame":
		m_outputOnNewGame = ReadString(setValue);
		break;
	case "m_outputOnLoadGame":
		m_outputOnLoadGame = ReadString(setValue);
		break;
	case "m_outputOnMapTransition":
		m_outputOnMapTransition = ReadString(setValue);
		break;
	case "m_outputOnBackgroundMap":
		m_outputOnBackgroundMap = ReadString(setValue);
		break;
	case "m_outputOnMultiNewMap":
		m_outputOnMultiNewMap = ReadString(setValue);
		break;
	case "m_outputOnMultiNewRound":
		m_outputOnMultiNewRound = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
logic_auto::RestoreComplete(void)
{
	ScheduleThink(Processing, 0.2f);
}

void
logic_auto::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	/* outputs */
	case "OnMapSpawn":
		m_outputOnMapSpawn = PrepareOutput(m_outputOnMapSpawn, setValue);
		break;
	case "OnNewGame":
		m_outputOnNewGame = PrepareOutput(m_outputOnNewGame, setValue);
		break;
	case "OnLoadGame":
		m_outputOnLoadGame = PrepareOutput(m_outputOnLoadGame, setValue);
		break;
	case "OnMapTransition":
		m_outputOnMapTransition = PrepareOutput(m_outputOnMapTransition, setValue);
		break;
	case "OnBackgroundMap":
		m_outputOnBackgroundMap = PrepareOutput(m_outputOnBackgroundMap, setValue);
		break;
	case "OnMultiNewMap":
		m_outputOnMultiNewMap = PrepareOutput(m_outputOnMultiNewMap, setValue);
		break;
	case "OnMultiNewRound":
		m_outputOnMultiNewRound = PrepareOutput(m_outputOnMultiNewRound, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
logic_auto::Spawned(void)
{
	super::Spawned();

	if (m_outputOnMapSpawn)
		m_outputOnMapSpawn = CreateOutput(m_outputOnMapSpawn);
	if (m_outputOnNewGame)
		m_outputOnNewGame = CreateOutput(m_outputOnNewGame);
	if (m_outputOnLoadGame)
		m_outputOnLoadGame = CreateOutput(m_outputOnLoadGame);
	if (m_outputOnMapTransition)
		m_outputOnMapTransition = CreateOutput(m_outputOnMapTransition);
	if (m_outputOnBackgroundMap)
		m_outputOnBackgroundMap = CreateOutput(m_outputOnBackgroundMap);
	if (m_outputOnMultiNewMap)
		m_outputOnMultiNewMap = CreateOutput(m_outputOnMultiNewMap);
	if (m_outputOnMultiNewRound)
		m_outputOnMultiNewRound = CreateOutput(m_outputOnMultiNewRound);
}

void
logic_auto::Respawn(void)
{
	InitPointTrigger();
	ScheduleThink(Processing, 0.2f);
}

void
logic_auto::Processing(void)
{
	if (STRING_SET(m_globalState))
		if (GetGlobalValue(m_globalState) == 0)
			return;

	UseOutput(this, m_outputOnMapSpawn);

	if (cvar("sv_playerslots") == 1) {
		if (m_iFromSaveGame) {
			/* set by trigger_changelevel, however not by the changelevel cmd */
			if (cvar("_bsp_change_auto") == 1) {
				UseOutput(this, m_outputOnMapTransition);
				cvar_set("_bsp_change_auto", "");
			} else
				UseOutput(this, m_outputOnLoadGame);
		} else {
			UseOutput(this, m_outputOnNewGame);
		}
	} else {
		/* TODO: more reliable way of figuring out round restarts */
		if (time > 5)
			UseOutput(this, m_outputOnMultiNewRound);

		/* yes, this is also called during entity respawns :X */
		UseOutput(this, m_outputOnMultiNewMap);
	}

	if (serverkeyfloat("background") == 1)
		UseOutput(this, m_outputOnBackgroundMap);

	if (HasSpawnFlags(LOGICAUTO_USEONCE)) {
		EntLog("%S triggerer removed self",  target);
		Destroy();
	}
}
