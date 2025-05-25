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

/*! @file NSXRSpace.h
    @brief Managing of simulated Spaces.

    NSXRSpace manages the conversion between real-world
	 to game-world coordinates.

	 It's used to handle room to world translation for VR, for example.
*/

/** This class represents a local client space in the world.

@ingroup xr
*/
class NSXRSpace:ncEntity {
public:
	void NSXRSpace( void );

	/** Sets the placement of the space in the 3D world. */
	virtual void SetOrigin( vector );

	/** Sets the direction offset of the space in the 3D world. */
	virtual void SetAngles( vector );

	/** Get the forward facing direction in a normalized vector. */
	virtual vector GetForward( void );

	/** Get the right facing direction in a normalized vector. */
	virtual vector GetRight( void );

	/** Get the up facing direction in a normalized vector. */
	virtual vector GetUp( void );

	/** Takes a room-space position and translates it into world position. */
	virtual vector RoomToWorldOrigin( vector );

	/** Takes a room-space angle and translates it into world angles. */
	virtual vector RoomToWorldAngles( vector );

private:
	vector m_vecForward;
	vector m_vecRight;
	vector m_vecUp;
	vector m_vecOrigin;
};
