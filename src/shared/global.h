void
_NSLog(string msg)
{
	if (cvar("g_developer") == 1)
		print(sprintf("%f %s\n", time, msg));
}
#define NSLog(x, ...) _NSLog(sprintf(x, __VA_ARGS__))

enumflags
{
       SEARCH_INSENSITIVE,
       SEARCH_FULLPACKAGE,
       SEARCH_ALLOWDUPES,
       SEARCH_FORCESEARCH,
       SEARCH_MULTISEARCH,
       SEARCH_NAMESORT
};