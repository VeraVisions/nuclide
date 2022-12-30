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

/* unlock an achievement */
void
Achievement_Set(string strName)
{
}

/* clea an achievement (development purposes mainly) */
void
Achievement_Clear(string strName)
{
}

/* returns whether or not an achievement has been achieved */
bool
Achievement_Get(string strName)
{
	return 0;
}

/* get the icon of an achievement */
string
Achievement_GetIcon(string strName)
{
	return __NULL__;
}

/* STUB, returns how many other users achieved this */
float
Achievement_GetPercentage(string strName)
{
	return 0.0f;
}

/* called when you want to show a pop-up indicating progress */
void
Achievement_IndicateProgress(string strName, int iCurrent, int iMax)
{
}

/* updates the achievement_t pointer with what's been achieved and what's not been achieved */
bool
Achievement_RequestStats(achievement_t *ptr, int count)
{
}
