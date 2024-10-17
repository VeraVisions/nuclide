void
Platform_Init(void)
{
	Platform_RegisterCommands();
	GameLibrary_Init();
	MapLibrary_Init();
	Saves_Init();
	Platform_RendererRestarted();
}

void
Platform_RendererRestarted(void)
{
	Background_RendererRestarted();
}
