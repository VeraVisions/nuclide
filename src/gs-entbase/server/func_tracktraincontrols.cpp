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

/*QUAKED func_tracktraincontrols (0 .5 .8) ?
"targetname"    Name
"target"        Name of the func_vehicle to control

Brush that marks the usable region of a func_tracktrain, in order
to gain control.

Trivia:
This entity was introduced in Half-Life (1998).
*/

class func_tracktraincontrols:CBaseTrigger
{
	void(void) func_tracktraincontrols;
};

void
func_tracktraincontrols::func_tracktraincontrols(void)
{
	precache_model(model);
	SetModel(model);
	SetOrigin(origin);

#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif

	SetSolid(SOLID_NOT);
	CBaseTrigger::CBaseTrigger();
}
