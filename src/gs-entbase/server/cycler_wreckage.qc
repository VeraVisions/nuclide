/*
 * Copyright (c) 2024 Vera Visions LLC.
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

/*! \brief Server-Entity: Model Emitting Smoke */
/*!QUAKED cycler_wreckage (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
A model with smoke all around it.

# KEYS
- "targetname" : Name
- "model" : Model to display on the player.
- "scale" : Scale of the sprite.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
cycler_wreckage:ncRenderableEntity
{
public:
	void cycler_wreckage(void);

	virtual void Spawned(void);
	virtual void OnRemoveEntity(void);

private:
	ncEntity m_eSmoke;
};

void
cycler_wreckage::cycler_wreckage(void)
{
	m_eSmoke = __NULL__;
}

void
cycler_wreckage::Spawned(void)
{
	super::Spawned();

	if (!m_eSmoke) {
		m_eSmoke = spawnClass("env_smoker", GetOrigin());
		m_eSmoke.Input(this, "SetScale", "128");
		m_eSmoke.Input(this, "SetAngle", vtos([-90.0f, 0.0f, 0.0f]));
		m_eSmoke.Input(this, "SetDispersion", "4");
		m_eSmoke.Input(this, "SetDuration", "-1");
		m_eSmoke.Respawn();
		m_eSmoke.ReleaseThink();
	}
}
void
cycler_wreckage::OnRemoveEntity(void)
{
	if (m_eSmoke) {
		m_eSmoke.Destroy();
	}
}