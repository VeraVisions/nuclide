#ifdef CLIENT
class
NSDebris:NSPhysicsEntity
{
public:
	void NSDebris(void);

	virtual void Touch(entity);
	nonvirtual void SetImpactDecal(string);

private:
	string m_strImpactDecal;
};
#endif