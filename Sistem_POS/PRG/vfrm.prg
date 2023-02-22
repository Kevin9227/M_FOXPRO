PARAMETERS oForm
*
* Verifica se o formulário já está sendo executado
*
IF TYPE(oForm) = "O" AND ! ISNULL(&oForm)	&& Se estiver sendo executado... ativa
	messagebox("O ECRÃ ESTÁ A SER UTILIZADO",0+48,"AVISO")
	RETURN .F.
	cSHOW = oForm + ".SHOW"
	&cSHOW
ELSE					&& Caso não tenha sido executado... executa
	RELEASE &oForm
	PUBLIC &oForm
	DO FORM &oForm
ENDIF


