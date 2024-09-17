/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/** This entity class represents an attack. Usually spawned by a decl's fireInfo properties.

@ingroup baseclass
*/
class NSAttack:NSSurfacePropEntity
{
public:
	void NSAttack(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string, string);

	/* launch the attack into the world */
	virtual void Launch(vector, vector, float, float, float);

	nonvirtual void SetWeaponOwner(NSWeapon);
	nonvirtual NSWeapon GetWeaponOwner(void);
#endif

#ifdef SERVER
private:
	float m_flFuse;
	NSWeapon m_weaponOwner;
	int m_iShots;
	vector m_vecSpread;
#endif
};

#ifdef SERVER
NSAttack NSAttack_SpawnDef(string entityDef, NSActor theOwner);
NSAttack NSAttack_SpawnDefAtPosition(string entityDef, NSActor theOwner, vector vecOrigin, vector vecAngles);
NSAttack NSAttack_SpawnDefAttachment(string entityDef, NSActor theOwner, int attachmentID);
#endif
