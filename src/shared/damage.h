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
typedef enumflags
{
	DMG_GENERIC,		/**< Non specific. */
	DMG_CRUSH,			/**< Being crushed by something heavy. */
	DMG_BULLET,			/**< Shot by a gun. */
	DMG_SLASH,			/**< Cutting, from swords or knives. */
	DMG_FREEZE,			/**< Ice/freezing temperature damage. */
	DMG_BURN,			/**< Short flame, or on-fire type damage. */
	DMG_VEHICLE,		/**< Vehicle ramming into you at speed. */
	DMG_FALL,			/**< Fall damage */
	DMG_EXPLODE,		/**< Firery explosion damage. */
	DMG_BLUNT,			/**< Blunt damage, like from a pipe or a bat. */
	DMG_ELECTRO,		/**< Electric shock damage. */
	DMG_SOUND,			/**< Noise so irritating it creates damage. */
	DMG_ENERGYBEAM,		/**< Energy beam damage. */
	DMG_GIB_NEVER,		/**< This damage type doesn't cause gibbing. */
	DMG_GIB_ALWAYS,		/**< This damage type will always gib. */
	DMG_DROWN,			/**< Drown damage, gets restored over time. */
	DMG_PARALYZE,		/**< Paralyzation damage. */
	DMG_NERVEGAS,		/**< Toxins to the nerve, special effect? */
	DMG_POISON,			/**< Poisonous damage. Similar to nervegas? */
	DMG_RADIATION,		/**< Radiation damage. Geiger counter go brrr */
	DMG_DROWNRECOVER,	/**< Health increase from drown recovery. */
	DMG_CHEMICAL,		/**< Chemical damage. */
	DMG_SLOWBURN,		/**< Slow burning, just like burning but different rate. */
	DMG_SLOWFREEZE,		/**< Slow freeze, just freezing but different rate. */
	DMG_SKIP_ARMOR,		/**< This damage will skip armor checks entirely. */
	DMG_SKIP_RAGDOLL	/**< This damage will not affect ragdolls. */
} damageType_t;

#define DMG_ACID DMG_CHEMICAL
