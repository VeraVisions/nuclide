class ncCapturePoint:ncRenderableEntity
{
public:
	void ncCapturePoint(void);

	virtual void Respawn(void);
	virtual void Touch(entity);
	nonvirtual void Captured(string classTarget, float teamNumber);

private:
	string m_desiredItem;
	int m_playerScore;
	int m_teamScore;
	float m_goalNo;
};
