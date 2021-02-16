/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

void
ClientGame_EventParse(float fHeader)
{
	switch (fHeader) {
	case EV_CHAT:
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();

		CSQC_Parse_Print(sprintf("%s: %s", getplayerkeyvalue(fSender, "name"), sMessage), PRINT_CHAT);
		break;
	case EV_CHAT_TEAM:
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();

		CSQC_Parse_Print(sprintf("[TEAM] %s: %s", getplayerkeyvalue(fSender2, "name"), sMessage2), PRINT_CHAT);
		break;
	}
}
