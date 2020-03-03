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

/*QUAKED func_dustmotes (1 0 0) (-8 -8 -8) (8 8 8) ?

Dustmote emitting brush volume.
*/

class func_dustmotes:CBaseEntity
{
	void() func_dustmotes;
	virtual void(string, string) SpawnKey;
};

void func_dustmotes::customphysics(void)
{

}

void func_dustmotes::func_dustmotes(void)
{
	drawmask = MASK_ENGINE;
	Init();
}

void func_dustmotes::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}
