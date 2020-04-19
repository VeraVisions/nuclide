float GamePMove_Maxspeed(player target)
{
	return (target.flags & FL_CROUCHING) ? 135 : 270;
}
