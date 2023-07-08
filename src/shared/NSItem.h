/*
 * Copyright (c) 2023 Vera Visions LLC.
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

#ifdef SERVER
/* PICKUP ITEMS */
class NSItem:NSRenderableEntity
{
public:
	void NSItem(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void Touch(entity);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);

	nonvirtual void SetItem(int i);
	nonvirtual int GetItem(void);
	nonvirtual void SetFloating(int);
	nonvirtual bool GetFloating(void);
	nonvirtual void SetSpinning(bool);
	nonvirtual bool GetSpinning(void);

	nonvirtual void PickupRespawn(void);

private:
	int m_iClip;
	int m_iWasDropped;

	/* spawn keys */
	int m_iInvItem;
	string m_sndAcquire;
	string m_sndRespawn;
	int m_bFloating;
	bool m_bSpins;
};
#endif