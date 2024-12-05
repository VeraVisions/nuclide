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

/*! \brief Server-Entity: func_vehicle Controller */
/*!QUAKED func_vehiclecontrols (0 .5 .8) ?
# OVERVIEW
Brush that marks the usable region of a func_vehicle, in order
to gain control.

# KEYS
- "targetname" : Name
- "target" : Name of the func_vehicle to control

# NOTES
It's the same as func_tracktraincontrols, except that it's for
func_vehicle instead of func_tracktrain.

# TRIVIA
This entity was introduced in Counter-Strike (2000).

@ingroup serverentity
@ingroup brushentity
*/
class
func_vehiclecontrols:func_traincontrols
{
	void func_vehiclecontrols(void);
};

void
func_vehiclecontrols::func_vehiclecontrols(void)
{

}