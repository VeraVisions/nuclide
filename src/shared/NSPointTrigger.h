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

/** This entity class represents point-entity triggers.

It's primary function is to consistently set up triggers.
In your sub-class you'll probably want to call `InitPointTrigger()`
inside its `::Respawn()` reimplementation.
*/
class NSPointTrigger:NSEntity
{
public:
	void NSPointTrigger(void);

	/* overrides */
	virtual void Respawn(void);
	virtual void DebugDraw(void);

	/** Sets up a point entity trigger with no size. */
	nonvirtual void InitPointTrigger(void);

#ifdef SERVER
private:
	string m_strDebugTexture;
#endif
};
