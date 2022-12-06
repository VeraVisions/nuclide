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

/*QUAKED func_traincontrols (0 .5 .8) ?
Brush that marks the usable region of a func_tracktrain, in order
to gain control.

-------- KEYS --------
"targetname" : Name
"target" : Name of the func_vehicle to control

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class
func_traincontrols:NSBrushTrigger
{
public:
	void func_traincontrols(void);
	
	virtual void Respawn(void);

};

void
func_traincontrols::func_traincontrols(void)
{
}

void
func_traincontrols::Respawn(void)
{
	InitBrushTrigger();
	ClearAngles();
}
