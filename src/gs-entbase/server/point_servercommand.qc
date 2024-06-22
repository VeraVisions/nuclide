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

/*! \brief Server-Entity: Executes Console Commands */
/*!QUAKED point_servercommand (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Issues console commands on server when triggered.

# KEYS
- "targetname" : Name

# INPUTS
- "Command" : Enters a command into the server console, input data being the command.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup server
@ingroup pointentity
*/
class
point_servercommand:NSPointTrigger
{
public:
	void point_servercommand(void);
	
	/* overrides */
	virtual void Input(entity,string,string);
};

void
point_servercommand::point_servercommand(void)
{

}

void
point_servercommand::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Command":
		localcmd(strData);
		localcmd("\n");
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}