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

/*QUAKED func_pushable (0 .5 .8) ? SF_TRIGGER SF_TOUCH SF_PRESSURE
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!

Trivia:
This entity was introduced in Half-Life (1998).
*/

class func_pushable:func_breakable
{
	void(void) func_pushable;

	virtual void(void) customphysics;
	virtual void(void) touch;
};

void
func_pushable::customphysics(void)
{
	tracebox(origin, mins, maxs, origin + (velocity * frametime), MOVE_NORMAL, this);
}

void
func_pushable::touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		
	}
	
	velocity = other.velocity * 0.25;
}

void
func_pushable::func_pushable(void)
{
	func_breakable::func_breakable();
}