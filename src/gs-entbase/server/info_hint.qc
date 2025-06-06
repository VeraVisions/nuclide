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

/* hint types taken from https://developer.valvesoftware.com/wiki/Hint_nodes#Hint */
typedef enum
{
	HINT_NONE = 0,
	HINT_WORLD_WINDOW = 2,
	HINT_WORLD_WORK_POSITION = 12,
	HINT_WORLD_VISUALLY_INTERESTING = 13,
	HINT_WORLD_VISUALLY_INTERESTING_DONT_AIM = 14,
	HINT_WORLD_INHIBIT_COMBINE_MINES = 15,
	HINT_WORLD_VISUALLY_INTERESTING_STEALTH = 16,
	HINT_TACTICAL_COVER_MED = 100,
	HINT_TACTICAL_COVER_LOW = 101,
	HINT_TACTICAL_WASTESCANNER = 102,
	HINT_TACTICAL_PINCH = 103,
	HINT_TACTICAL_GUARD_POINT = 104,
	HINT_TACTICAL_ENEMY_DISADVANTAGED = 105,
	HINT_HEALTH_KIT = 106,
	HINT_ANTLION_BURROW_POINT = 400,
	HINT_ANTLION_THUMPER_FLEE_POINT = 401,
	HINT_HEADCRAB_BURROW_POINT = 450,
	HINT_CROW_FLYTO_POINT = 700,
	HINT_CROW_PERCH_POINT = 701,
	HINT_FOLLOW_WAIT_POINT = 900,
	HINT_JUMP_OVERRIDE = 901,
	HINT_PLAYER_SQUAD_TRANSITON_POINT = 902,
	HINT_NPC_EXIT_POINT = 903,
	HINT_STRIDER_NODE = 904,
	HINT_PLAYER_ALLY_MOVE_AWAY_DEST = 950,
	HINT_PLAYER_ALLY_FEAR_DEST = 951,
	HINT_WORLD_MACHINERY = 1000,
	HINT_WORLD_BLINKING_LIGHT = 1001,
	HINT_WORLD_HUMAN_BLOOD = 1002,
	HINT_WORLD_ALIEN_BLOOD = 1003,
} hinttype_t;

/* TODO: Make this match ncMonster more */
typedef enum
{
	AISTATE_IDLE,
	AISTATE_ALERT,
	AISTATE_COMBAT
} aistate_t;

#define HINTSF_ALLOWJUMPUP 65536

/*! \brief Server-Entity: Nodegraph Hint */
/*!QUAKED info_hint (0 0 0) (-8 -8 -8) (8 8 8) x x x x x x x x x x x x x x x x HINTSF_ALLOWJUMPUP
# OVERVIEW
Helper entity for the AI routines. Defines where to go for
sensible defense/offensive or other hints.

# KEYS
- "targetname"        : Name
- "hinttype"          : Hint type, this controls this hints' purpose. See notes
- "hintactivity"      : Associated animation activity. Once an NPC goes to this node they'll play it
- "nodeFOV"           : Field of view of the node. You'll probably want to set a sensible angle too.
- "StartHintDisabled" : Whether or not to 'hide' the hint on start, requiring activation to work.
- "Group"             : Hint group definition. Some NPCs are set up to only look for their specific group.
- "IgnoreFacing"      : Whether or not we need to ignore the angle (?), see notes.
- "MinimumState"      : The minimum AI state required to use this hint, see notes.
- "MaximumState"      : The maximum AI state allowed to use this hint, see notes.

# SPAWNFLAGS
- HINTSF_ALLOWJUMPUP (65536) : Allow the AI to 'jump' up this node.

# NOTES
The 'hinttype' field can be one of these integer values:

  - HINT_NONE = 0
  - HINT_WORLD_WINDOW = 2
  - HINT_WORLD_WORK_POSITION = 12
  - HINT_WORLD_VISUALLY_INTERESTING = 13
  - HINT_WORLD_VISUALLY_INTERESTING_DONT_AIM = 14
  - HINT_WORLD_INHIBIT_COMBINE_MINES = 15
  - HINT_WORLD_VISUALLY_INTERESTING_STEALTH = 16
  - HINT_TACTICAL_COVER_MED = 100
  - HINT_TACTICAL_COVER_LOW = 101
  - HINT_TACTICAL_WASTESCANNER = 102
  - HINT_TACTICAL_PINCH = 103
  - HINT_TACTICAL_GUARD_POINT = 104
  - HINT_TACTICAL_ENEMY_DISADVANTAGED = 105
  - HINT_HEALTH_KIT = 106
  - HINT_ANTLION_BURROW_POINT = 400
  - HINT_ANTLION_THUMPER_FLEE_POINT = 401
  - HINT_HEADCRAB_BURROW_POINT = 450
  - HINT_CROW_FLYTO_POINT = 700
  - HINT_CROW_PERCH_POINT = 701
  - HINT_FOLLOW_WAIT_POINT = 900
  - HINT_JUMP_OVERRIDE = 901
  - HINT_PLAYER_SQUAD_TRANSITON_POINT = 902
  - HINT_NPC_EXIT_POINT = 903
  - HINT_STRIDER_NODE = 904
  - HINT_PLAYER_ALLY_MOVE_AWAY_DEST = 950
  - HINT_PLAYER_ALLY_FEAR_DEST = 951
  - HINT_WORLD_MACHINERY = 1000
  - HINT_WORLD_BLINKING_LIGHT = 1001
  - HINT_WORLD_HUMAN_BLOOD = 1002
  - HINT_WORLD_ALIEN_BLOOD = 1003

The 'IgnoreFacing' field can be one of 3 values:

  - IGNORE_NO = 0
  - IGNORE_YES = 1
  - IGNORE_DEFAULT = 2

The 'MinimumState' and 'MaximumState' field can be one of 3 values:

  - AISTATE_IDLE = 0
  - AISTATE_ALERT = 1
  - AISTATE_COMBAT = 2

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

Some functionality of this entity was meant to be part of `info_node` in the original Half-Life (1998).
However, that was never completed.

@ingroup serverentity
@ingroup pointentity
*/
class
info_hint:ncHint
{
public:
	void info_hint(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);

private:
	hinttype_t m_hintTypeID;
	aistate_t m_stateIDMin;
	aistate_t m_stateIDMax;
};

void
info_hint::info_hint(void)
{
	m_hintTypeID = HINT_NONE;
	m_stateIDMin = AISTATE_IDLE;
	m_stateIDMax = AISTATE_COMBAT;
};

void
info_hint::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_hintTypeID", m_hintTypeID);
	SaveFloat(handle, "m_stateIDMin", m_stateIDMin);
	SaveFloat(handle, "m_stateIDMax", m_stateIDMax);
}

void
info_hint::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_hintTypeID":
		m_hintTypeID = ReadFloat(setValue);
		break;
	case "m_stateIDMin":
		m_stateIDMin = ReadFloat(setValue);
		break;
	case "m_stateIDMax":
		m_stateIDMax = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
info_hint::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "hinttype":
		m_hintTypeID = stof(setValue);
		break;
	case "State":
		m_stateIDMin = 
		m_stateIDMax = stof(setValue);
		break;
	case "MinimumState":
		m_stateIDMin = stof(setValue);
		break;
	case "MaximumState":
		m_stateIDMax = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
info_hint::Spawned(void)
{
	super::Spawned();
}
