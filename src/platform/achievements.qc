/* unlock an achievement */
void
Achievement_Set(string strName)
{
}

/* clea an achievement (development purposes mainly) */
void
Achievement_Clear(string strName)
{
}

/* returns whether or not an achievement has been achieved */
int
Achievement_Get(string strName)
{
}

/* get the icon of an achievement */
string
Achievement_GetIcon(string strName)
{
}

/* STUB, returns how many other users achieved this */
float
Achievement_GetPercentage(string strName)
{
}

/* called when you want to show a pop-up indicating progress */
void
Achievement_IndicateProgress(string strName, int iCurrent, int iMax)
{
}

/* updates the achievement_t pointer with what's been achieved and what's not been achieved */
void
Achievement_RequestStats(achievement_t *ptr, int count)
{
}
