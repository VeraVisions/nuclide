class
trigger_damage:ncBrushTrigger
{
	void trigger_damage(void);

	virtual void Respawn(void);
};

void
trigger_damage::trigger_damage(void)
{

}

void
trigger_damage::Respawn(void)
{
	InitBrushTrigger();
}


