PARAMETERS oForm
*
* Verifica se o formul�rio j� est� sendo executado
*
IF TYPE(oForm) = "O" AND ! ISNULL(&oForm)	&& Se estiver sendo executado... ativa
	messagebox("O ECR� EST� A SER UTILIZADO",0+48,"AVISO")
	RETURN .F.
	cSHOW = oForm + ".SHOW"
	&cSHOW
ELSE					&& Caso n�o tenha sido executado... executa
	RELEASE &oForm
	PUBLIC &oForm
	DO FORM &oForm
ENDIF


