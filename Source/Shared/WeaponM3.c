/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

.int iClip_M3;

// Weapon Info
weaponinfo_t wptM3 = { 
	WEAPON_M3, 			// Identifier
	SLOT_PRIMARY,
	500, 				// Price
	CALIBER_BUCKSHOT, 	// Caliber ID
	220, 				// Max Player Speed
	9, 					// Bullets Per Shot
	8, 					// Clip/MagSize
	26, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	3000, 				// Bullet Range
	0.7, 				// Range Modifier
	TYPE_SEMI,
	2.0, 					// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_BUCKSHOT, 	// Caliber Pointer
	iClip_M3 			// Clip Pointer
};
