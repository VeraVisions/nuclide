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

/*QUAKED path_corner (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
*/

enumflags {
	PC_WAIT,
	PC_TELEPORT,
	PC_FIREONCE
};

class path_corner:CBaseTrigger
{
	float m_flSpeed;
	float m_flYawSpeed;
	float m_flWait;

	void() path_corner;
	virtual void() Trigger;
};

void path_corner::Trigger(void)
{
	for ( entity eFind = world; ( eFind = find( eFind, CBaseTrigger::m_strTargetName, m_strMessage));) {
		CBaseTrigger trigger = (CBaseTrigger) eFind;
		trigger.Trigger();
	}
}

void path_corner::path_corner(void)
{
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "speed":
			m_flSpeed = stof(argv( i + 1 ));
			break;
		case "yaw_speed":
			m_flYawSpeed = stof(argv(i+1));
			break;
		case "wait":
			m_flWait = stof(argv( i + 1 ));
			break;
		case "message":
			m_strMessage = argv( i + 1);
			break;
		default:
			break;
		}
	}

	if (!m_flSpeed)
		m_flSpeed = 100;

	if (!m_flWait)
		m_flWait = 1.0f;

}
