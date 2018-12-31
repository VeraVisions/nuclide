/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

// TODO: Complete this once damage is done

/*
 * cycler - Point Entity
The cycler entity is a model viewer of sorts. It places a model within the map which, when attacked, will cycle its animation.
Attributes
Name (targetname) - Name is a general attribute used to identify entities.
Pitch Yaw Roll (Y Z X) (angles) - Sets the pitch, yaw and roll angles of the model.
Animation Sequence (editor) (sequence) - Sets the animation the model should start in. Setting this to anything other than 0 seems to place the cycler into its triggered mode (see notes).
Model (model) - This defines which model file will be displayed by the entity. This accepts an input of the form "path/filename.mdl" (starting from the root folder). (Example: "models/scientist.mdl").
Render FX (renderfx) - Gives the model certain visual effects depending on Render Mode.
Render Mode (rendermode) - Allows special rendering modes to be applied to the given entity.
FX Amount (1 - 255) (renderamt) - In all but "Normal" Render Mode, alters how transparent the model is. Scales from 0 (invisible) to 255 (solid, normal).
FX Color (R G B) (rendercolour) - Seemingly unused.
Notes
	Triggering or pressing use on the cycler will freeze the model in its current animation. In this state, shooting the cycler will have it step through frames of the animation it was in. Triggering it or using it again will return it to its normal function.
	Given the way this entity behaves, there is little practical use for this entity beyond viewing animations (for which there are programs that are far more convenient).
*/

class CCycler : CBaseEntity
{
	void() CCycler;
};

void CCycler :: CCycler ( void )
{
	precache_model( model );
	CBaseEntity::CBaseEntity();
	setmodel( this, model );
	solid = SOLID_BBOX;
}


