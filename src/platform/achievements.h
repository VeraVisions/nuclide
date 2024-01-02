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

/*! @file achievements.h
    @brief Achievement APIs

    The Achievements API manages the retrieval, storage and networking
	 of game achievements.

	 This is a work in progress.
*/

/** Data for an achievement definition. */
typedef struct
{
	int m_iID; /**< Unique numeric ID of an achievement. */
	string m_strName; /**< Name of the achivement. */
	string m_strDescription; /**< Description of the achivement. */
	int m_iAchieved; /**< Indicator if it's been achieved or not. */
	string m_strMaterial; /**< An image or icon depicting the achivement. */
} achievement_t;

/** Unlock an achievement.

@param strName The name identifier of the achivement. */
void Achievement_Set(string strName);

/** Clear an achievement (development purposes mainly).

@param strName The name identifier of the achivement. */
void Achievement_Clear(string strName);

/** Returns whether or not an achievement has been achieved.

@param strName The name identifier of the achivement.
@return true when achieved, false if not. */
bool Achievement_Get(string strName);

/** Get the icon of an achievement.

@param strName The name identifier of the achivement.
@return The URL or local file pointing to an image or icon. */
string Achievement_GetIcon(string strName);

/** STUB, returns how many other users achieved this

@param strName The name identifier of the achivement.
@return Normalized value between 0.0 - 1.0 indicating progress. */
float Achievement_GetPercentage(string strName);

/** Requests an overlay to be drawn.
It indicates the progression towards a particular achivement.

@param strName The name identifier of the achievement.
@param iCurrent The current value of progress.
@param iMax The maximum value of progress. */
void Achievement_IndicateProgress(string strName, int iCurrent, int iMax);

/** Updates the achievement_t pointer with what's been achieved and what's not been achieved from a remote location.

@param ptr Pointer to an achievement_t array.
@return Will return false upon failure. */
bool Achievement_RequestStats(achievement_t *ptr, int count);
