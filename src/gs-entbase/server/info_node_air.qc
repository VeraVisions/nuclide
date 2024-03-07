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

/*!QUAKED info_node_air (0 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
It's a node, helping monsters navigate in the air as well as underwater.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
info_node_air:NSPointTrigger
{
public:
	void info_node_air(void);
	
	virtual void Respawn(void);

};

void
info_node_air::info_node_air(void)
{

}

void
info_node_air::Respawn(void)
{
	InitPointTrigger();

	SetSize([0,0,0], [0,0,0]);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

	/* air nodes just stay where they are
	   see https://twhl.info/wiki/page/Tutorial%3A_All_about_info_nodes */
	SetOrigin(GetSpawnOrigin());
}
