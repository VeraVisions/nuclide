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

typedef enum
{
	IGNORE_NO,
	IGNORE_YES,
	IGNORE_DEFAULT
} ignorefacing_t;

/* TODO: Make this match NSMonster more */
typedef enum
{
	AISTATE_IDLE,
	AISTATE_ALERT,
	AISTATE_COMBAT
} aistate_t;

#define HINTSF_ALLOWJUMPUP 65536

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
*/
class
info_hint:NSPointTrigger
{
public:
	void info_hint(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);

private:
	hinttype_t m_hintType;
	string m_strHintActivity;
	float m_flNodeFOV;
	string m_strHintGroup;
	ignorefacing_t m_ignoreFacing;
	aistate_t m_minState;
	aistate_t m_maxState;
};

void
info_hint::info_hint(void)
{
	m_hintType = HINT_NONE;
	m_strHintActivity = __NULL__;
	m_flNodeFOV = 360;
	m_strHintGroup = __NULL__;
	m_ignoreFacing = IGNORE_DEFAULT;
	m_minState = AISTATE_IDLE;
	m_maxState = AISTATE_COMBAT;
};

void
info_hint::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_hintType", m_hintType);
	SaveString(handle, "m_strHintActivity", m_strHintActivity);
	SaveFloat(handle, "m_flNodeFOV", m_flNodeFOV);
	SaveString(handle, "m_strHintGroup", m_strHintGroup);
	SaveFloat(handle, "m_ignoreFacing", m_ignoreFacing);
	SaveFloat(handle, "m_minState", m_minState);
	SaveFloat(handle, "m_maxState", m_maxState);
}

void
info_hint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_hintType":
		m_hintType = ReadFloat(strValue);
		break;
	case "m_strHintActivity":
		m_strHintActivity = ReadString(strValue);
		break;
	case "m_flNodeFOV":
		m_flNodeFOV = ReadFloat(strValue);
		break;
	case "m_strHintGroup":
		m_strHintGroup = ReadString(strValue);
		break;
	case "m_ignoreFacing":
		m_ignoreFacing = ReadFloat(strValue);
		break;
	case "m_minState":
		m_minState = ReadFloat(strValue);
		break;
	case "m_maxState":
		m_maxState = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
info_hint::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "hinttype":
		m_hintType = stof(strValue);
		break;
	case "hintactivity":
		m_strHintActivity = strValue;
		break;
	case "nodeFOV":
		m_flNodeFOV = stof(strValue);
		break;
	case "StartHintDisabled":
		m_bStartDisabled = stof(strValue) == 1 ? true : false;
		break;
	case "Group":
		m_strHintGroup = strValue;
		break;
	case "IgnoreFacing":
		m_ignoreFacing = stof(strValue);
		break;
	case "MinimumState":
		m_minState = stof(strValue);
		break;
	case "MaximumState":
		m_maxState = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}
