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

/** @defgroup bot_tags Info Tags
    @brief Info tags for bots used to identify objects.
    @ingroup bot

Any entity can have these tags set onto using ncEntity::SetBotTag(), it will help
the AI figure out a lot of game specific details.

   @{
*/

/* we need to keep this an enum so find() does its work faster */
typedef enum
{
	BOTINFO_NONE,				/**< no info */
	BOTINFO_HEALTH,				/**< health item */
	BOTINFO_ARMOR,				/**< armor item */
	BOTINFO_AMMO,				/**< ammo pickup */
	BOTINFO_WEAPON,				/**< weapon pickup */
	BOTINFO_SPAWNPOINT,			/**< place where to find new players */
	BOTINFO_TEAM_GOALITEM,		/**< team-mode goal item (flag, intel) */
	BOTINFO_TEAM_GOALCAPTURE,	/**< where to go when goal-item present */
	BOTINFO_END				/**< end destination */
} botInfo_t;

.float botinfo;

/** @} */ // end of bot_tags