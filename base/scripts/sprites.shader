sprites/glow_test02
{
	surfaceParm trans
	surfaceParm nomarks
	surfaceParm nolightmap
	surfaceParm nonsolid
	cull none

	{
		clampmap "gfx/sprites/glow_test02.tga"
		blendFunc add
		rgbGen vertex
	}
}

sprites/light_glow03
{
	surfaceParm trans
	surfaceParm nomarks
	surfaceParm nolightmap
	surfaceParm nonsolid
	cull none

	{
		clampmap "gfx/sprites/light_glow03.tga"
		rgbGen vertex
		blendFunc add
	}
}

sprites/muzzle_front
{
	surfaceParm trans
	surfaceParm nonsolid
	cull none

	{
		clampmap "gfx/sprites/muzzle_front.tga"
		blendFunc add
		alphaGen vertex
	}
}

sprites/shotgun_front
{
	surfaceParm trans
	surfaceParm nonsolid
	cull none

	{
		clampmap "gfx/sprites/shotgun_front.tga"
		blendFunc add
		alphaGen vertex
	}
}

sprites/laser
{
	surfaceParm trans
	surfaceParm nomarks
	surfaceParm nolightmap
	surfaceParm nonsolid
	cull none

	{
		clampmap "gfx/sprites/laser.tga"
		rgbGen vertex
		blendFunc add
	}
}
