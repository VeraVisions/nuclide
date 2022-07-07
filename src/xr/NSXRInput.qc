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

vector
NSXRInput::GetOrigin(void)
{
	if (!m_xrSpace) {
		print("WARNING: XR Space not yet present!\n");
		return [0,0,0];
	}

	return m_xrSpace.RoomToWorldOrigin(m_vecOrigin);
}

vector
NSXRInput::GetAngles(void)
{
	if (!m_xrSpace) {
		print("WARNING: XR Space not yet present!\n");
		return [0,0,0];
	}

	if (m_inputType != XR_INPUT_HEAD)
		return m_xrSpace.RoomToWorldAngles(m_vecAngles);

	/* head only cares about reporting yaw right now */
	return m_xrSpace.RoomToWorldAngles([0, m_vecAngles[1], 0]);
}

vector
NSXRInput::GetVelocity(void)
{
	return m_vecVelocity;
}

vector
NSXRInput::GetAngularVelocity(void)
{
	return m_vecAVelocity;
}

unsigned int
NSXRInput::GetStatus(void)
{
	return m_iStatus;
}

unsigned int
NSXRInput::GetWeapon(void)
{
	return m_iWeapon;
}

xrinput_e
NSXRInput::GetType(void)
{
	return m_inputType;
}

void
NSXRInput::InputFrame(void)
{
	switch (m_inputType) {
	case XR_INPUT_HEAD:
		m_iStatus = input_head_status;
		
		if (m_iStatus & XR_STATUS_ORG)
			m_vecOrigin = input_head_origin;
		if (m_iStatus & XR_STATUS_ANG)
			m_vecAngles = input_head_angles;
		if (m_iStatus & XR_STATUS_VEL)
			m_vecVelocity = input_head_velocity;
		if (m_iStatus & XR_STATUS_AVEL)
			m_vecAVelocity = input_head_avelocity;
		m_iWeapon = input_head_weapon;
		break;
	case XR_INPUT_LEFT:
		m_iStatus = input_left_status;
		if (m_iStatus & XR_STATUS_ORG)
			m_vecOrigin = input_left_origin;
		if (m_iStatus & XR_STATUS_ANG)
			m_vecAngles = input_left_angles;
		if (m_iStatus & XR_STATUS_VEL)
			m_vecVelocity = input_left_velocity;
		if (m_iStatus & XR_STATUS_AVEL)
			m_vecAVelocity = input_left_avelocity;
		m_iWeapon = input_left_weapon;
		break;
	case XR_INPUT_RIGHT:
		m_iStatus = input_right_status;
		if (m_iStatus & XR_STATUS_ORG)
			m_vecOrigin = input_right_origin;
		if (m_iStatus & XR_STATUS_ANG)
			m_vecAngles = input_right_angles;
		if (m_iStatus & XR_STATUS_VEL)
			m_vecVelocity = input_right_velocity;
		if (m_iStatus & XR_STATUS_AVEL)
			m_vecAVelocity = input_right_avelocity;
		m_iWeapon = input_right_weapon;
		break;
	default:
		print(sprintf("NSXRInput: Cannot run InputFrame() on unknown type"));
	}

	//PrintInfo();
}

bool
NSXRInput::IsAvailable(void)
{
	/* if it's generating new origin/angles, then the device is very clearly available */
	return (m_iStatus & (XR_STATUS_ORG | XR_STATUS_ANG)) ? true : false;
}

void
NSXRInput::SetType(xrinput_e type)
{
	m_inputType = type;
}

void
NSXRInput::SetParentSpace(NSXRSpace xrSpace)
{
	m_xrSpace = xrSpace;
}

void
NSXRInput::PrintInfo(void)
{
	string deviceType = "UNKNOWN";

	switch (m_inputType) {
	case XR_INPUT_HEAD:
		deviceType = "HEAD";
		break;
	case XR_INPUT_LEFT:
		deviceType = "LEFT";
		break;
	case XR_INPUT_RIGHT:
		deviceType = "RIGHT";
		break;
	default:
		print(sprintf("NSXRInput: Cannot run PrintInfo() on unknown type"));
	}

	crossprint(sprintf("%s o: %v a: %v v:%v va:%v s:%i w:%i\n", deviceType, GetOrigin(), GetAngles(), GetVelocity(), GetAngularVelocity(), GetStatus(), GetWeapon()));
}

void
NSXRInput::NSXRInput(void)
{
}
