#ifdef CLIENT
class NSDebris:NSRenderableEntity
{
public:
	void NSDebris(void);

	virtual void Touch(entity);
	nonvirtual void SetImpactDecal(string);

private:
	string m_strImpactDecal;
};
#endif