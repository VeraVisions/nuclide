class
ncDispenser:ncItem
{
	void ncDispenser(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
#endif

#ifdef SERVER
private:
	float m_nextDispenseTime;
	float m_dispenseDelay;
#endif
};

