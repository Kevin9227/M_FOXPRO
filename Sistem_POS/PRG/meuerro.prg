PARAMETERS m.mensagem, m.programa, m.numero

*Comandos que podem ser usados:

* Retry	 - Retorna a execu��o do programa para a mesma linha
*		de onde ocorreu o erro.
* Return   - Retorna a execu��o do programa para a linha
*		seguinte de onde ocorreu o erro.
*!*	IF m.numero = 108 OR  m.numero = 109
*!*		MESSAGEBOX("Registro sendo utilizado por outro usu�rio.",;
*!*			64+0+0,"Gerenciador de Tarefas")
*!*		RETURN .F.
*!*	ENDIF
*!*	= MESSAGEBOX("Erro no sistema: "+CHR(13)+CHR(13)+;
*!*		m.mensagem+CHR(13)+;
*!*		"Programa: "+m.programa+CHR(13)+;
*!*		"N�mero: "+STR(m.numero),48+0+0,;
*!*		"Gerenciador de Erros...")



PROCEDURE errores  
Parameter meRror, Mess, meSs1, mpRog, mlIneno
Do Case

	Otherwise
		 = MSG("O sistema causou O siguiente error :"         + Chr(13) + ;
			"N�mero :"     + Padr(Alltrim(Str(meRror)),40)  + Chr(13) + ;
			"Tipo       :" + Padr(Mess,40)                  + Chr(13) + ;
			"C�digo   :"   + Padr(meSs1,40) 				  + Chr(13) + ;
			"L�nha      :" + Padr(Alltrim(Str(mlIneno)),40) + Chr(13) + ;
			"M�todo  :"    + Padr(mpRog,40))&&,64,"")
		return	
Endcase
ENDPROC
*CLEAR EVENTS		&& Limpa o Read Events do programa Inicio

