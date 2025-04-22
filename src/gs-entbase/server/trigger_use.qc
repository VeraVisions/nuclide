class
trigger_use:ncBrushTrigger
{
	void trigger_use(void);

	virtual void Respawn(void);
};

void
trigger_use::trigger_use(void)
{

}

void
trigger_use::Respawn(void)
{
	InitBrushTrigger();
}

