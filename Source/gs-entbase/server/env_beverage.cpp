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

// Dependency from item_food.cpp
void item_sodacan( void );

// TODO: Implement support for skins
enum
{
	SKIN_COCACOLA,
	SKIN_SPRITE,
	SKIN_DIETCOKE,
	SKIN_ORANGE,
	SKIN_SURGE,
	SKIN_MOXIE,
	SKIN_RANDOM
};

class env_beverage : CBaseTrigger
{
	int m_iUses;
	int m_iReady;
	int m_iSkin;
	void() env_beverage;
	virtual void() Trigger;
};

void env_beverage :: Trigger ( void )
{
	if ( m_iReady == FALSE || m_iUses <= 0 ) {
		return;
	}

	entity eCan = spawn();
	setorigin( eCan, origin );
	eCan.angles = angles;
	eCan.owner = this;
	eCan.think = item_sodacan;
	eCan.nextthink = time;

	m_iUses--;
	m_iReady = FALSE;
}

void env_beverage :: env_beverage ( void )
{
	precache_model( "models/can.mdl" );
	precache_sound( "weapons/g_bounce3.wav" );
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < (  tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "health":
			m_iUses = stoi( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	if ( !m_iUses ) {
		m_iUses = 10;
	}
	m_iReady = TRUE;
}
