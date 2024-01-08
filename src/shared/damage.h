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

/** All available damage types. */
typedef enum
{
	DMG_GENERIC = 1,		/**< Non specific. */
	DMG_CRUSH = 2,			/**< Being crushed by something heavy. */
	DMG_BULLET = 4,			/**< Shot by a gun. */
	DMG_SLASH = 8,			/**< Cutting, from swords or knives. */
	DMG_FREEZE = 16,			/**< Ice/freezing temperature damage. */
	DMG_BURN = 32,			/**< Short flame, or on-fire type damage. */
	DMG_VEHICLE = 64,		/**< Vehicle ramming into you at speed. */
	DMG_FALL = 128,			/**< Fall damage */
	DMG_EXPLODE = 256,		/**< Firery explosion damage. */
	DMG_BLUNT = 512,			/**< Blunt damage, like from a pipe or a bat. */
	DMG_ELECTRO = 1024,		/**< Electric shock damage. */
	DMG_SOUND = 2048,			/**< Noise so irritating it creates damage. */
	DMG_ENERGYBEAM = 4096,		/**< Energy beam damage. */
	DMG_GIB_NEVER = 8192,		/**< This damage type doesn't cause gibbing. */
	DMG_GIB_ALWAYS = 16384,		/**< This damage type will always gib. */
	DMG_DROWN = 32768,			/**< Drown damage, gets restored over time. */
	DMG_PARALYZE = 65536,		/**< Paralyzation damage. */
	DMG_NERVEGAS = 131072,		/**< Toxins to the nerve, special effect? */
	DMG_POISON = 262144,			/**< Poisonous damage. Similar to nervegas? */
	DMG_RADIATION = 524288,		/**< Radiation damage. Geiger counter go brrr */
	DMG_DROWNRECOVER = 1048576,	/**< Health increase from drown recovery. */
	DMG_CHEMICAL = 2097152,		/**< Chemical damage. */
	DMG_SLOWBURN = 4194304,		/**< Slow burning, just like burning but different rate. */
	DMG_SLOWFREEZE = 8388608,		/**< Slow freeze, just freezing but different rate. */
	DMG_SKIP_ARMOR = 16777216,		/**< This damage will skip armor checks entirely. */
	DMG_SKIP_RAGDOLL = 33554432	/**< This damage will not affect ragdolls. */
} damageType_t;

#define DMG_ACID DMG_CHEMICAL
