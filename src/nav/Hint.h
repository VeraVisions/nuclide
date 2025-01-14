/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

typedef enum
{
	IGNORE_NO,
	IGNORE_YES,
	IGNORE_DEFAULT
} ignorefacing_t;

/*! \brief Nav Hint */
/*!QUAKED ncNavHint (0 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Helper entity for the Nav routines. Defines where to go for
sensible defense/offensive or other hints.

# KEYS
- "targetname"        : Name
- "hintType"          : Hint type, this controls this hints' purpose. Be short and descriptive.
- "hintActivity"      : Associated animation activity. Once an NPC goes to this node they'll play it
- "nodeFOV"           : Field of view of the node. You'll probably want to set a sensible angle too.
- "StartHintDisabled" : Whether or not to 'hide' the hint on start, requiring activation to work.
- "Group"             : Hint group definition. Some NPCs are set up to only look for their specific group.
- "IgnoreFacing"      : Whether or not we need to ignore the angle and field of view setting, see notes.
- "mindsetFilter"     : Comma-separated list of mindsets required to use this hint, see notes.

The 'IgnoreFacing' field can be one of 3 values:

  - NO = 0
  - YES = 1
  - AUTO = 2
*/
class
ncHint:ncPointTrigger
{
public:
	void ncHint(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);

private:
	string m_hintType;
	string m_strHintActivity;
	float m_flNodeFOV;
	string m_strHintGroup;
	ignorefacing_t m_ignoreFacing;
	string m_mindsetFilter;
};
