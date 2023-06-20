*************************************************
*** Valida se pode criar ou alterar fornecedor
***
*** Criado por Rui Vale
***  Criado em 28/09/2017
*************************************************

TEXT TO uSql TEXTMERGE noshow
	Select e1.u_noflini,e1.u_noflfim
	From e1 (nolock)
	Where e1.estab = 0
	And u_noflini <> 0
	And u_noflfim <> 0
ENDTEXT

If u_sqlexec(uSql,"uCurE1") And Reccount("uCurE1")>0
	Select fl
	If ! Between(fl.no,uCurE1.u_noflini,uCurE1.u_noflfim)
		Msg("O fornecedor não é deste estabelecimento, não pode alterar!!")
		Return .F.
	Endif
Endif

TEXT TO uSql TEXTMERGE noshow
	Select flstamp
	From fl (nolock)
	Where flstamp = '<<fl.flstamp>>'
ENDTEXT

If !u_sqlexec(uSql,"uCurNumFl") Or Reccount("uCurNumFl")<=0
	Select fl
	If Alltrim(Lower(fl.tipo))!=Alltrim(Lower("Serviços"))
		Msg("Só pode criar fornecedores de serviços!!")
		Return .F.
	Endif
Endif

Return .T.
