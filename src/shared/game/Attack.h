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

# OVERVIEW

ncAttack is currently the main spot for various miscallanous attack types that don't fit into ncProjectile.

# KEYS
- "plant" : When 1, will plant the entityDef defined in "def_plant" against surfaces.
- "drop" : When 1, will drop the entityDef defined in "def_drop" near us.
- "def_plant" : Name of the entityDef to plant.
- "def_drop" : Name of the entityDef to drop.
- "plantOnGround" : Only allow planting on ground. Think C4 in CS.
- "plantDistance" : Distance at which we're testing for surfaces.
- "plantOffset" : Offset the planted entityDef this many units from the surface it's attached to.
- "dropDistance" : Drop the entityDef this many units away from us.

@ingroup baseclass
*/
class ncAttack:ncSurfacePropEntity
{
public:
	void ncAttack(void);

#ifdef SERVER
	/* launch the attack into the world */
	virtual void Launch(vector, vector, float, float, float);

	nonvirtual void SetWeaponOwner(ncWeapon);
	nonvirtual ncWeapon GetWeaponOwner(void);
#endif

#ifdef SERVER
private:
	ncWeapon m_weaponOwner;
#endif
};

#ifdef SERVER
ncAttack ncAttack_SpawnDef(string entityDef, ncActor theOwner);
ncAttack ncAttack_SpawnDefAtPosition(string entityDef, ncActor theOwner, vector vecOrigin, vector vecAngles);
ncAttack ncAttack_SpawnDefAttachment(string entityDef, ncActor theOwner, int attachmentID);
#endif
