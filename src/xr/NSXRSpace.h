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

/* class handling the room to world translations for XR */
class
NSXRSpace
{
	vector m_vecForward;
	vector m_vecRight;
	vector m_vecUp;
	vector m_vecOrigin;

	void(void) NSXRSpace;

	virtual void(vector) SetOrigin;
	virtual void(vector) SetAngles;

	virtual vector(void) GetForward;
	virtual vector(void) GetRight;
	virtual vector(void) GetUp;

	virtual vector(vector) RoomToWorldOrigin;
	virtual vector(vector) RoomToWorldAngles;
};
