/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

int iNightVision;

/*
=================
Nightvision_Toggle

Called by the cmd 'nightvision'
=================
*/
void Nightvision_Toggle(void) {
	if(getplayerkeyvalue(player_localnum, "*spec") == "1") {
		return;
	}
	
	if (!(getstatf(STAT_EQUIPMENT) & EQUIPMENT_NIGHTVISION)) {
		return;
	}
	
	iNightVision = 1 - iNightVision;
	
	if (iNightVision == TRUE) {
		localsound("items/nvg_on.wav", CHAN_ITEM, 1);
	} else {
		localsound("items/nvg_off.wav", CHAN_ITEM, 1);
	}
}

/*
=================
Nightvision_PreDraw

Called before rendering the frame in Draw.c
=================
*/
void Nightvision_PreDraw(void) {
	if(getplayerkeyvalue(player_localnum, "*spec") != "0") {
		iNightVision = FALSE;
		return;
	}
	
	if (iNightVision == TRUE) {
		dynamiclight_add(pSeat->m_vecPredictedOrigin, 500, '0 0.45 0');
	}
}

/*
=================
Nightvision_PostDraw

Called after rendering the frame in Draw.c
=================
*/
void Nightvision_PostDraw(int x, int y, int w, int h) {
	if (iNightVision == TRUE) {
		drawfill([x,y], [w,h], '0 0.5 0', 1, DRAWFLAG_ADDITIVE);
	}
}
