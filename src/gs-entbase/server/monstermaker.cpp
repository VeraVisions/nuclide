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

/*QUAKED monstermaker (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

All it does right now is spawn snarks, regardless of what monster you want to
spawn.
*/

class monstermaker : CBaseTrigger
{
	string m_strMonster;

	void() monstermaker;
	virtual void() Trigger;
};

void monstermaker::Trigger ( void )
{
	static void monstermaker_spawnunit(void) {
		callfunction(self.classname);
	}

	if (isfunction(strcat("spawnfunc_", m_strMonster))) {
		entity unit = spawn();
		unit.classname = strcat("spawnfunc_", m_strMonster);
		unit.think = monstermaker_spawnunit;
		unit.nextthink = time + 0.1f;
		print(sprintf("^2monstermaker::^3Trigger^7: Spawning %s\n", m_strMonster));
		setorigin(unit, origin);
	} else {
		print(sprintf("^1monstermaker::^3Trigger^7: cannot call spawnfunction for %s\n", m_strMonster));
	}
}

void monstermaker :: monstermaker ( void )
{
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < (  tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "monstertype":
			m_strMonster = argv(i+1);
			break;
		default:
			break;
		}
	}
}
