//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// None.
//==============================================================================

!!ver 110
!!permu FRAMEBLEND
!!permu SKELETAL

#include "sys/defs.h"

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	void main ()
	{
		gl_Position = skeletaltransform();
	}
#endif

#ifdef FRAGMENT_SHADER
	void main ()
	{
		gl_FragColor = vec4(0, 0, 0, 1);
	}
#endif

