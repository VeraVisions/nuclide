/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

void Weapons_PickupNotify(NSClientPlayer pl, int w);
void Weapons_RefreshAmmo(NSClientPlayer pl);
void Weapons_SwitchBest(NSClientPlayer pl, optional float skip);
int Weapons_AddItem(NSClientPlayer pl, int w, int startammo);
void Weapons_RemoveItem(NSClientPlayer pl, int w);
void Weapons_InitItem(int w);
void Weapons_ReloadWeapon(NSClientPlayer pl, .int mag, .int ammo, int max);
void Weapon_DropCurrentWeapon(NSClientPlayer pl);
int Weapon_GetCount();
int Weapon_GetBitID(int);
