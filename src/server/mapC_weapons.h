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

/** @defgroup mapc_weapons MapC: Weapons
    @brief Server-side plugin wrappers for weapon related functions.
    @ingroup multiprogs

    @{
*/

string
weaponType(string weaponDef)
{
	string(string) spawnFunc = externvalue(0, "weaponType");
	return spawnFunc(weaponDef);
}

int
weaponStartAmmo(string weaponDef)
{
	int(string) spawnFunc = externvalue(0, "weaponStartAmmo");
	return spawnFunc(weaponDef);
}

int
weaponMaxAmmo(string weaponDef)
{
	int(string) spawnFunc = externvalue(0, "weaponMaxAmmo");
	return spawnFunc(weaponDef);
}

bool
weaponIsSemiAuto(string weaponDef)
{
	bool(string) spawnFunc = externvalue(0, "weaponIsSemiAuto");
	return spawnFunc(weaponDef);
}

string
weaponInventoryType(string weaponDef)
{
	string(string) spawnFunc = externvalue(0, "weaponInventoryType");
	return spawnFunc(weaponDef);
}

float
weaponFireTime(string weaponDef)
{
	float(string) spawnFunc = externvalue(0, "weaponFireTime");
	return spawnFunc(weaponDef);
}

int
weaponClipSize(string weaponDef)
{
	int(string) spawnFunc = externvalue(0, "weaponClipSize");
	return spawnFunc(weaponDef);
}

string
weaponClass(string weaponDef)
{
	string(string) spawnFunc = externvalue(0, "weaponClass");
	return spawnFunc(weaponDef);
}

bool
isWeaponClipOnly(string weaponDef)
{
	bool(string) spawnFunc = externvalue(0, "isWeaponClipOnly");
	return spawnFunc(weaponDef);
}

bool
isWeaponDetonationTimed(string weaponDef)
{
	bool(string) spawnFunc = externvalue(0, "isWeaponDetonationTimed");
	return spawnFunc(weaponDef);
}

/** @} */ // end of mapc_weapons
