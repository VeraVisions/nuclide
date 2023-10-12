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

/*
====================
Event_Callback

Calls one event based on viewmodel frame timeline, to avoid running more than once.
Prediction runs through weapon many times per frame, so we have to do call special
events based on time passed on the viewmodel.
====================
*/
void
Event_Callback(float mtime, __inout float btime)
{
	/* don't bother if no valid function is set */
	if (pSeat->m_pEventCall == __NULL__)
		return;

	/* if the sequence ain't the same anymore... */
	if (pSeat->m_flEventFrame != pSeat->m_eViewModel.frame)
		return;

	/* if the model changed... */
	if (pSeat->m_flEventMdl != pSeat->m_eViewModel.modelindex)
		return;

	/* weapon changed */
	player pl = (player)(pSeat->m_ePlayer);

	if (pSeat->m_iEventWeapon != pl.activeweapon)
		return;

	/* only play once */
	if (mtime == btime)
		return;

	/* call when we've passed the keyframe the first time */
	if (btime <= pSeat->m_flEventTime && (mtime > pSeat->m_flEventTime)) {
		pSeat->m_pEventCall();
		pSeat->m_pEventCall = __NULL__;
		pSeat->m_flEventMdl = 0;
		pSeat->m_flEventFrame = -1;
	}

	btime = mtime;
}
