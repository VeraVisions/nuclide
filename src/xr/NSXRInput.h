/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

typedef enum
{
	XR_INPUT_UNKNOWN,
	XR_INPUT_HEAD,
	XR_INPUT_LEFT,
	XR_INPUT_RIGHT
} xrinput_e;

#define XR_STATUS_ORG	(1u<<0)
#define XR_STATUS_ANG	(1u<<1)
#define XR_STATUS_VEL	(1u<<2)
#define XR_STATUS_AVEL	(1u<<3)

class
NSXRInput
{
	NSXRSpace m_xrSpace;
	vector m_vecOrigin;
	vector m_vecAngles;
	vector m_vecVelocity;                                                                                     
	vector m_vecAVelocity;
	unsigned int m_iStatus;
	unsigned int m_iWeapon;

	xrinput_e m_inputType;

	void(void) NSXRInput;
	virtual void(xrinput_e) SetType;
	virtual void(NSXRSpace) SetParentSpace;

	virtual vector(void) GetOrigin;
	virtual vector(void) GetAngles;
	virtual vector(void) GetVelocity;
	virtual vector(void) GetAngularVelocity;
	virtual unsigned int(void) GetStatus;
	virtual unsigned int(void) GetWeapon;
	virtual xrinput_e (void) GetType;

	virtual bool(void) IsAvailable;
	virtual void(void) InputFrame;

	virtual void(void) PrintInfo;
};