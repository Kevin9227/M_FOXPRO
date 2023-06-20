** Criado por: Paulo Ricardo Martins  em 25/09/2017
** Atribuição de pontos a clientes
******************************************************************

m.escolheu = 0

MPTS = GETNOME("Quantos pontos deseja atribuir ao cartão",0)
IF m.escolheu =.t.
	select CL

	TEXT TO MSQL TEXTMERGE NOSHOW
	SELECT CL.NOME, CL.NO, CL.ESTAB, CL.U_PONTOS, CL2.u_ncartao
	FROM CL (nolock)
	INNER JOIN CL2 (NOLOCK) ON CL2.CL2STAMP = CL.CLSTAMP
	WHERE CL.NO = <<ASTR(CL.NO)>>
	ORDER BY CL.NO
	ENDTEXT

	IF !U_SQLEXEC(MSQl,'CR_CLTMP')
		MSG('ERRO ENCONTRADO')
		MSG(MSQL)
		RETURN
	ENDIF
	
	
	MCLPTS = CR_CLTMP.u_PONTOS	

	MPONTOS = MCLPTS + MPTS

	U_SQLEXEC('BEGIN TRANSACTION')
	
	TEXT TO MSQL TEXTMERGE NOSHOW
	insert into u_ctm (u_ctmstamp ,data ,cmdesc ,nrdoc ,debito ,credito ,loja  ,no ,nome ,saldo ,ftstamp ,tipo ,ncartao ) 
            select left(replace(newid(),'-',''),24), GETDATE(), 'Vale em Cartão', (SELECT isnull(MAX(nrdoc),0)+1 FROM u_CTM (nolock) WHERE cmdesc = 'Vale em Cartão')  
            ,  <<STRTRAN(STR(MPTS,14,2),',','.')>> as debito 
            , 0 as credito                   
            , 0 , <<ASTR(Cr_CLTMP.no)>>, '<<CR_CLTMP.nome>>', 0, '','','<<CR_CLTMP.u_ncartao>>'  
	ENDTEXT
	IF !U_SQLEXEC(MSQL)
		MSG('ERRO ENCONTRADO')
		MSG(MSQL)
		U_SQLEXEC('ROLLBACK')
		RETURN
	ENDIF			
						
	TEXT TO MSQL TEXTMERGE NOSHOW
	UPDATE CL
	SET U_PONTOS = <<STRTRAN(STR(MPONTOS,14,2),',','.')>>
	WHERE CL.NO = <<ASTR(CL.NO)>>
	ENDTEXT
	IF !U_SQLEXEC(MSQL)
		MSG('ERRO ENCONTRADO')
		MSG(MSQL)
		U_SQLEXEC('ROLLBACK')
		RETURN
	ENDIF			
		
	IF !U_SQLEXEC('COMMIT TRANSACTION')
		MSG('ERRO ENCONTRADO NO COMMIT')
		U_SQLEXEC('ROLLBACK')
		RETURN
	ENDIF
	msg('Atribuição de pontos finalizada')		
ENDIF