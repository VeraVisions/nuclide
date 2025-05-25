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

/*
   The engine provides us with 3 devices right now, each giving us
   their position, angle etc. as well as field stating which bits
   of information have gotten updated.

   If no updates are happening from the HMD/head, that means we're
   most like not in VR, or the player has taken the headset off and
   laid it down.

   If we have no updates from the left and right XR devices, we
   will use the regular input_angles and view position for weapons.
*/

void
XR_Init(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	if (!pl.m_xrSpace) {
		pl.m_xrSpace = spawn(NSXRSpace);
		pl.m_xrSpace.solid = SOLID_NOT;
		pl.m_xrSpace.touch = 0;
	}

	/* the only 3 devices that matter right now */
	if (!pl.m_xrInputHead) {
		pl.m_xrInputHead = spawn(NSXRInput);
		pl.m_xrInputHead.SetType(XR_INPUT_HEAD);
		pl.m_xrInputHead.SetParentSpace(pl.m_xrSpace);
		pl.m_xrInputHead.solid = SOLID_NOT;
		pl.m_xrInputHead.touch = 0;
	}

	if (!pl.m_xrInputLeft) {
		pl.m_xrInputLeft = spawn(NSXRInput);
		pl.m_xrInputLeft.SetType(XR_INPUT_LEFT);
		pl.m_xrInputLeft.SetParentSpace(pl.m_xrSpace);
		pl.m_xrInputLeft.solid = SOLID_NOT;
		pl.m_xrInputLeft.touch = 0;
	}

	if (!pl.m_xrInputRight) {
		pl.m_xrInputRight = spawn(NSXRInput);
		pl.m_xrInputRight.SetType(XR_INPUT_RIGHT);
		pl.m_xrInputRight.SetParentSpace(pl.m_xrSpace);
		pl.m_xrInputRight.solid = SOLID_NOT;
		pl.m_xrInputRight.touch = 0;
	}
}

void
XR_Shutdown(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;
	pl.m_xrInputHead.Destroy();
	pl.m_xrInputLeft.Destroy();
	pl.m_xrInputRight.Destroy();
	
}

#ifdef CLIENT
void
XR_UpdateView(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	/* not yet ready */
	if (!pl.m_xrSpace) {
		return;
	}

	/* update our space */
	if (XR_Available(ePlayer)) {
		pl.m_xrSpace.SetOrigin(g_view.GetCameraOrigin());
		pl.m_xrSpace.SetAngles(view_angles);

		/* now we get the HMD's org/ang and send that off to the renderer */
		setviewprop(VF_ANGLES, pl.m_xrInputHead.GetAngles());
		setviewprop(VF_ORIGIN, pl.m_xrInputHead.GetOrigin() + [0,0, autocvar_xr_viewHeight]);
	} else {
		pl.m_xrSpace.SetOrigin(g_view.GetCameraOrigin());
		pl.m_xrSpace.SetAngles(input_angles);

	/*
		setviewprop(VF_ANGLES, pl.m_xrInputHead.GetAngles());
		setviewprop(VF_ORIGIN, pl.m_xrInputHead.GetOrigin());
	*/
	}
}
#endif

void
XR_InputFrame(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	/* not yet ready */
	if (!pl.m_xrSpace) {
		return;
	}

	if (autocvar_xr_testInputs) {
		input_head_status = (XR_STATUS_ORG | XR_STATUS_ANG);
		input_left_status = (XR_STATUS_ORG | XR_STATUS_ANG);
		input_right_status = (XR_STATUS_ORG | XR_STATUS_ANG);

		input_head_angles = [sin(time), sin(time * 1.25) * 5, sin(time * 1.45)];
		input_left_angles = [cos(time) * 5,cos(time) * 25,sin(time) * 5];
		input_right_angles = [cos(time) * 5,cos(time) * 25,sin(time) * 5];
		
		input_head_origin = [sin(time)*5,cos(time)*5,sin(time)*5];
		input_left_origin = input_head_origin + [cos(time*8) * 2,4,sin(time*8) * 2];
		input_right_origin = input_head_origin + [cos(time*8) * 2,-4,sin(time*8) * 2];
	}

	/* update the input internals for keeping track*/
	pl.m_xrInputHead.InputFrame();
	pl.m_xrInputLeft.InputFrame();
	pl.m_xrInputRight.InputFrame();
}

bool
XR_Available(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	/* we only care about the HMD... otherwise why even bother? */
	return pl.m_xrInputHead.IsAvailable();
}
