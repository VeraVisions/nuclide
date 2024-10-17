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

/*! \brief Server-Entity: Player Health Controller */
/*!QUAKED game_player_hurt (1 .5 0) (-8 -8 -8) (8 8 8) REMOVE
# OVERVIEW
Upon being triggered, the entity will damage/heal the activating player.

# KEYS
- "targetname" : Name
- "dmg" : Damage value to apply to a player.
- "master" : Name of the multisource regulating its usage.


# SPAWNFLAGS
- REMOVE (1) : Remove after being triggered.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup pointentity
*/
class
game_player_hurt:NSPointTrigger
{
public:
	void game_player_hurt(void);

	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);

private:
	int m_iDamage;
};

void
game_player_hurt::game_player_hurt(void)
{
	m_iDamage = 0i;
}

void
game_player_hurt::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "dmg":
		m_iDamage = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
game_player_hurt::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iDamage", m_iDamage);
}

void
game_player_hurt::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iDamage":
		m_iDamage = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
game_player_hurt::Trigger(entity activatingEntity, triggermode_t triggerMode)
{
	if (GetMaster(activatingEntity) == FALSE) {
		return;
	}
	if (!(activatingEntity.flags & FL_CLIENT)) {
		return;
	}

	NSDict damageDecl = spawn(NSDict);
	damageDecl.AddKey("damage", itos(m_iDamage));
	combat.Damage(activatingEntity, this, activatingEntity, damageDecl.GetDeclBody(), GetOrigin(), g_vec_null, activatingEntity.origin);
	remove(damageDecl);

	if (HasSpawnFlags(1)) {
		Destroy();
	}
}
