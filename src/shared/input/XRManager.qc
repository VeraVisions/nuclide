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

static NSXRSpace
FindXRSpace(entity playerEntity)
{
	NSXRSpace foundSpace = __NULL__;

	for (NSXRSpace spaceList = world; (spaceList = find(spaceList, ::classname, "NSXRSpace"));) {
		if (spaceList.owner == playerEntity) {
			return (spaceList);
		}
	}

	foundSpace = spawn(NSXRSpace);
	foundSpace.solid = SOLID_NOT;
	foundSpace.touch = 0;
	foundSpace.owner = playerEntity;
	return (foundSpace);
}

static NSXRInput
FindXRInput(entity playerEntity, xrinput_t inputType)
{
	NSXRInput foundInput = __NULL__;

	/* See if it exists already */
	for (NSXRInput inputList = world; (inputList = find(inputList, ::classname, "NSXRInput"));) {
		if (inputList.owner != playerEntity) {
			continue;
		}
		if (inputList.GetType() != inputType) {
			continue;
		}

		foundInput = inputList;
		foundInput.SetParentSpace(FindXRSpace(playerEntity));
		foundInput.solid = SOLID_NOT;
		foundInput.touch = 0;
		foundInput.owner = playerEntity;
		return (foundInput);
	}

	/* Doesn't exist. Create it. */
	foundInput = spawn(NSXRInput);
	foundInput.SetType(inputType);
	foundInput.SetParentSpace(FindXRSpace(playerEntity));
	foundInput.solid = SOLID_NOT;
	foundInput.touch = 0;
	foundInput.owner = playerEntity;
	return (foundInput);
}

void
ncXRManager::Init(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;
	pl.m_xrSpace = FindXRSpace(pl);
	pl.m_xrInputHead = FindXRInput(pl, XR_INPUT_HEAD);
	pl.m_xrInputLeft = FindXRInput(pl, XR_INPUT_LEFT);
	pl.m_xrInputRight = FindXRInput(pl, XR_INPUT_RIGHT);
}

void
ncXRManager::Shutdown(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;
	pl.m_xrSpace = __NULL__;
	pl.m_xrInputHead = __NULL__;
	pl.m_xrInputLeft = __NULL__;
	pl.m_xrInputRight = __NULL__;
}

#ifdef CLIENT
void
ncXRManager::UpdateView(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	/* not yet ready */
	if (!pl.m_xrSpace) {
		ncXRManager::Init(ePlayer);
	}

	/* update our space */
	if (ncXRManager::Available(ePlayer)) {
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
ncXRManager::InputFrame(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	/* not yet ready */
	if (!pl.m_xrSpace) {
		ncXRManager::Init(ePlayer);
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
ncXRManager::Available(entity ePlayer)
{
	ncClient pl = (ncClient)ePlayer;

	if (!pl.m_xrInputHead) {
		return (false);
	}

	/* we only care about the HMD... otherwise why even bother? */
	return pl.m_xrInputHead.IsAvailable();
}
