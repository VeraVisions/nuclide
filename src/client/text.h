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

/** @brief Definition of a text channel.

A text channel is a special type of text string that is commonly
defined within the titles.txt file of a game. Common use cases are
chapter titles and message with a special type of fade in/out rendering effect
on them.*/
typedef struct
{
	string m_strMessage; /**< the message contents. */
	float m_flPosX; /**< Normalized starting position on the X-axis. -1 is center. */
	float m_flPosY; /**< Normalized starting position on the X-axis. -1 is center. */
	int m_iEffect; /**< Effect to use when rendering the text. */
	vector m_vecColor1; /**< Primary text color. */
	vector m_vecColor2; /**< Secondary text color for use with effects. */
	float m_flFadeIn; /**< Time in seconds it takes for the text to fade in. */
	float m_flFadeOut; /**< Time in seconds it takes for the text to fade out. */
	float m_flHoldTime; /**< Time in seconds on which we'll hold onto the text. */
	float m_flFXTime; /**< Time in seconds that it takes for the effect to finish. */
	float m_flTime; /**< The time that's passed on the active channel. */
} gametext_t;

/** Global pool of text channels. */
gametext_t g_textchannels[6];

#define TEXTQUEUE_MAX 6

/** this is reserved for channel 0 */
gametext_t g_textqueue[TEXTQUEUE_MAX];


int g_textqueue_next;
int g_textqueue_count;

/** Used by Nuclide to draw all active text channels to the screen. */
void GameText_Draw(void);

/** @brief Places a message within a specified channel.

We look up a message within our titles.txt file and copy its parameters
and string contents into a text channel.

We have 6 channels in total.

@param strMessage is the message we'll look up.
@param iChannel is the channel it will be stored in. */
void GameMessage_Setup(string strMessage, int iChannel);

/** Used by Nuclide to parse a message delivered by the game_text entity.

@sa game_text */
void GameText_Parse(void);

/** Used by Nuclide to parse a message delivered by the env_message entity.

@sa env_message */
void GameMessage_Parse(void);