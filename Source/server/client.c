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

void Client_TriggerCamera(entity target, vector pos, vector end, float wait)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CAMERATRIGGER);
	WriteCoord(MSG_MULTICAST, pos[0]);
	WriteCoord(MSG_MULTICAST, pos[1]);
	WriteCoord(MSG_MULTICAST, pos[2]);
	WriteCoord(MSG_MULTICAST, end[0]);
	WriteCoord(MSG_MULTICAST, end[1]);
	WriteCoord(MSG_MULTICAST, end[2]);
	WriteFloat(MSG_MULTICAST, wait);
	msg_entity = target;
	multicast([0,0,0], MULTICAST_ONE);
}
