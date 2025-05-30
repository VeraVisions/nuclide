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

/*! \brief Server-Entity: Bouncy Gib/Model Shooter */
/*!QUAKED gibshooter (1 0 0) (-8 -8 -8) (8 8 8) GIBS_REPEATABLE
# OVERVIEW
Shoots model bouncy entities from its location.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll direction of the shooter.
- "shootmodel" : Model file to shoot.
- "shootsounds" : PCM sample to play whenever a piece shoots out.
- "m_iGibs" : Amount of models shot in total.
- "m_flDelay" : Delay before being able to be fired again.
- "m_flVelocity" : Speed of the models in units per second.
- "m_flVariance" : Delay between shots.
- "m_flGibLife" : Life of the individual model piece.
- "scale" : Scale modifier of the model pieces.

# SPAWNFLAGS
- GIBS_REPEATABLE (1) : Can be triggered repeatedly.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
gibshooter:env_shooter
{
public:
	void gibshooter(void);

	virtual void Spawned(void);
	virtual void Precache(void);
};

void
gibshooter::gibshooter(void)
{
}

void
gibshooter::Spawned(void)
{
	m_strShootModel = "models/hgibs.mdl";
	m_flShootSounds = 3;

	super::Spawned();
}

void
gibshooter::Precache(void)
{
	precache.Model(m_strShootModel);
}
