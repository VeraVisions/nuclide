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

.int iClip_XM1014;

// Weapon Info
weaponinfo_t wptXM1014 = { 
	WEAPON_XM1014, 		// Identifier
	SLOT_PRIMARY,
	3000, 				// Price
	CALIBER_BUCKSHOT, 		// Caliber ID
	240, 				// Max Player Speed
	6, 					// Bullets Per Shot
	7, 				// Clip/MagSize
	22, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	3000, 				// Bullet Range
	0.7, 				// Range Modifier
	TYPE_AUTO,
	0.15, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_BUCKSHOT, 		// Caliber Pointer
	iClip_XM1014 		// Clip Pointer
};
