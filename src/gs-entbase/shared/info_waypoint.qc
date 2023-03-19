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

/*!QUAKED info_waypoint (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
When active, will display an icon and text at its position that can be seen
by players.

# KEYS
- "targetname" : Name
- "Image" : Path of the material that the game will use for the icon.
- "Text" : A localised string to display next to it.

# INPUTS
- "Enable" : Enables the entity.
- "Disable" : Disables the entity.

# TRIVIA
This entity was introduced in Obsidian Conflict (2006).
*/
class
info_waypoint
{
public:
	void info_waypoint(void);

private:
	string m_strIcon;
	string m_strText;
};

void
info_waypoint::info_waypoint(void)
{
	m_strIcon =
	m_strText = __NULL__;
}