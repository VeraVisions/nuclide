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

void
NSXRSpace::NSXRSpace(void)
{
	m_vecForward =
	m_vecRight =
	m_vecUp =
	m_vecOrigin = [0.0f, 0.0f, 0.0f];
}

vector
NSXRSpace::GetForward(void)
{
	return m_vecForward;
}

vector
NSXRSpace::GetRight(void)
{
	return m_vecRight;
}

vector
NSXRSpace::GetUp(void)
{
	return m_vecUp;
}

vector
NSXRSpace::RoomToWorldOrigin(vector vecRoomOrg)
{
	vector vecOut;
	vecOut = m_vecOrigin;
	vecOut += (m_vecForward * vecRoomOrg[0]);
	vecOut -= (m_vecRight * vecRoomOrg[1]);
	vecOut += (m_vecUp * vecRoomOrg[2]);
	return vecOut;
}

vector
NSXRSpace::RoomToWorldAngles(vector vecRoomAng)
{
	makevectors(vecRoomAng);
	rotatevectorsbyvectors(m_vecForward, m_vecRight, m_vecUp);
	return vectoangles(v_forward, v_up);
}

void
NSXRSpace::SetOrigin(vector vecOrigin)
{
	m_vecOrigin = vecOrigin;
}

void
NSXRSpace::SetAngles(vector vecAngles)
{
	makevectors(vecAngles);
	m_vecForward = v_forward;
	m_vecRight = v_right;
	m_vecUp = v_up;
}