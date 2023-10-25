/*!QUAKED cycler_wreckage (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
A env_sprite with smoke all around it.

# KEYS
- "targetname" : Name
- "model" : Model to display on the player.
- "scale" : Scale of the sprite.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
cycler_wreckage:NSRenderableEntity
{
public:
	void cycler_wreckage(void);

	virtual void Spawned(void);
	virtual void OnRemoveEntity(void);

private:
	NSEntity m_eSmoke;
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
		m_eSmoke = NSEntity_SpawnClass("env_smoker", GetOrigin(), [-90.0f, 0.0f, 0.0f]);
		m_eSmoke.Input(this, "SetScale", "128");
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