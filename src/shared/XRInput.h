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

/*! @file NSXRInput.h
    @brief Managing of Input sources.

    An NSXRInput contains the state of a potential input source.
*/

/** Various input device types.
Right now each client will have a single head, a 'left' and a 'right' NSXRInput. */
typedef enum : __uint64
{
	XR_INPUT_UNKNOWN,	/**< Unknown device. Don't use! */
	XR_INPUT_HEAD,		/**< Device represents a single head. 
							A client will have a ncView camera tied to it. */
	XR_INPUT_LEFT,		/**< Device represents a left hand. */
	XR_INPUT_RIGHT		/**< Device represents a right hand. */
} xrinput_t;

/** The NSXRInput is updating its position within the NSXRSpace. */
#define XR_STATUS_ORG	(1u<<0u)
/** The NSXRInput is updating its aim direction within the NSXRSpace. */
#define XR_STATUS_ANG	(1u<<1u)
/** The NSXRInput is updating its velocity. */
#define XR_STATUS_VEL	(1u<<2u)
/** The NSXRInput is updating its angular velocity. */
#define XR_STATUS_AVEL	(1u<<3u)

/** This class represents an input device in the world.

An input device can be a few different things.
They can interpret updates from an external source, such as a VR headset
or a VR controller. In the case of a headset (XR_INPUT_HEAD) it will let
Nuclide know where we will position the client's ncView within the world.

Other sources, such as keyboard and mice can totally position and control
these inputs as well.

Each input has the ability to have a ncWeapon reference tied to it.
That way you can dual (or even triple) wield them.

@ingroup xr
*/
class NSXRInput {
  public:
	void NSXRInput( void );

	/** Sets the NSXRInput type. */
	virtual void SetType( xrinput_t );

	/** Sets which NSXRSpace this input belongs to. */
	virtual void SetParentSpace( NSXRSpace );

	/** Returns the world space position of this NSXRInput. */
	virtual vector GetOrigin( void );

	/** Returns the direction this NSXRInput is facing. */
	virtual vector GetAngles( void );

	/** Returns the current velocity of this NSXRInput. */
	virtual vector GetVelocity( void );

	/** Returns the rotational movement of this NSXRInput. */
	virtual vector GetAngularVelocity( void );

	/** Returns the status of the NSXRInput. */
	virtual unsigned int GetStatus( void );

	/** Returns the weapon this NSXRInput is wielding. */
	virtual unsigned int GetWeapon( void );

	/** Returns the type of NSXRInput, check xrinput_t for details. */
	virtual xrinput_t GetType( void );

	/** Returns if this NSXRInput is available/active. */
	virtual bool IsAvailable( void );

	/** Run every single input event. */
	virtual void InputFrame( void );

	/** Debug function that can be called every single frame. */
	virtual void PrintInfo( void );

  private:
	/** Reference to the space we belong to */
	NSXRSpace m_xrSpace;
	vector m_vecOrigin;
	vector m_vecAngles;
	vector m_vecVelocity;
	vector m_vecAVelocity;
	__uint64 m_iStatus;
	__uint64 m_iWeapon;

	xrinput_t m_inputType;
};
