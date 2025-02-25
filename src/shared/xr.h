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

/** @defgroup xr Extended Reality
    @ingroup shared
    @brief Extended reality framework, handling **Virtual Reality (VR)**, **Augmented Reality (AR)** and **Mixed Reality (MR)** support

You can take advantage of **Extended Reality**, aka **XR** by using the `openxr` engine plugin.
*/

#include "XRSpace.h"
#include "XRInput.h"

/** Called internally by client/server modules for when a player joins. */
void XR_Init(entity);
/** Called internally by client/server modules for when a player leaves. */
void XR_Shutdown(entity);
/** Returns if XR features are available on the entity. */
bool XR_Available(entity);
/** Called on client/server modules after an input packet has been dispatched. */
void XR_InputFrame(entity);

#ifdef CLIENT
/** Sets up view properties from a client entity before a rendering call. */
void XR_UpdateView(entity);
#endif

var float autocvar_xr_roomScale = 1.0f;
var float autocvar_xr_viewHeight = -48.0f;
var bool autocvar_xr_testInputs = false;