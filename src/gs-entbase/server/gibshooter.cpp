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

/*QUAKED gibshooter (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"angles"        Sets the pitch, yaw and roll direction of the shooter.
"shootmodel"    Model file to shoot.
"shootsounds"   PCM sample to play whenever a piece shoots out.
"m_iGibs"       Amount of models shot in total.
"m_flDelay"     Delay before being able to be fired again.
"m_flVelocity"  Speed of the models in units per second.
"m_flVariance"  Delay between shots.
"m_flGibLife"   Life of the individual model piece.
"scale"         Scale modifier of the model pieces.

Shoots model entities from its location.
*/

class gibshooter2:env_shooter
{
	void(void) gibshooter2;
};

void gibshooter2::gibshooter2(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "m_iGibs":
			m_iGibs = stoi(argv(i+1));
			break;
		case "delay":
		case "m_flDelay":
			m_flDelay = stof(argv(i+1));
			break;
		case "m_flVelocity":
			m_flVelocity = stof(argv(i+1));
			break;
		case "m_flVariance":
			m_flVariance = stof(argv(i+1));
			break;
		case "m_flGibLife":
			m_flGibLife = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	m_strShootModel = "models/hgibs.mdl";
	m_flShootSounds = 3;
	m_flScale = 1.0;

	precache_model(m_strShootModel);
	CBaseTrigger::CBaseTrigger();
}
