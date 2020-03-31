/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/*QUAKED trigger_auto (1 0 0) (-8 -8 -8) (8 8 8) TA_USEONCE
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Time in seconds until it triggers its target.

Will automatically start working when the level has spawned.
If TA_USEONCE is set, it'll remove itself from the level permanently.
It will not survive round respawns, etc.
*/

class trigger_auto:CBaseTrigger
{
	float m_flDelay;

	void() trigger_auto;
	virtual void() think;
	virtual void() Respawn;
};

void trigger_auto::think(void)
{
	// This is weird, because ents may not be spawned yet.
	// However, Half-Life doesn't care about this, either.
	// So why should we?
	CBaseTrigger::UseTargets_Delay(m_flDelay);

	if (spawnflags & 1) {
		dprint( sprintf( "%s::think: %s removed self after trigger\n", 
			m_strTargetName, this.classname ) );
		remove(this);
	}
}

void trigger_auto::Respawn(void)
{
	nextthink = time + 0.2f;
}

void trigger_auto::trigger_auto(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}
