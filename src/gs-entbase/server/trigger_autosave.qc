/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED trigger_autosave (0 .5 .8) ?
Volume that'll save the current game when a client enters its bounds.
This entity does not work in multiplayer.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class trigger_autosave:NSBrushTrigger
{
	float m_flDelay;

	void(void) trigger_autosave;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void
trigger_autosave::touch(void)
{
	if (GetMaster() == FALSE)
		return;

	/* saved text */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);
	WriteString(MSG_MULTICAST, "GAMESAVED");
	WriteString(MSG_MULTICAST, "common/menu2.wav");
	WriteFloat(MSG_MULTICAST, 1.0);
	WriteByte(MSG_MULTICAST, ATTN_NONE);
	msg_entity = this;
	multicast(origin, MULTICAST_ALL);

	dprint(sprintf("^2trigger_autosave::^3touch^7: %s called autosave\n", 
		other.netname));

	//readcmd("save autosave\n");
	Hide();
	SetSolid(SOLID_NOT);

	UseTargets(other, TRIG_TOGGLE, m_flDelay);
}

void
trigger_autosave::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_autosave::trigger_autosave(void)
{
	if (cvar("sv_playerslots") > 1) {
		remove(this);
		return;
	}

	super::NSBrushTrigger();
}
