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

#ifdef SERVER

/*! \brief Shared-Entity: Camera System Trigger */
/*!QUAKED point_viewcontrol (.5 .5 .5) (-8 -8 -8) (8 8 8)
# OVERVIEW
Forces a camera change when triggered.

# KEYS
- "targetname" : Name
- "target" : Camera aims at this target.
- "moveto" : First path_corner entity, if present.
- "wait" : The total time the camera effect is active.

# NOTES
The client who triggers it will get its camera perspective changed to this
point_viewcontrol. It is capable of following a track in case "moveto" is set.
The movement finishes independently of the "wait" key.
In case you are follow a path, the triggers of the respective path_corners will
be respected.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup pointentity
*/
class point_viewcontrol:trigger_camera
{
public:
	void point_viewcontrol(void);

};

void
point_viewcontrol::point_viewcontrol(void)
{

}
#endif
