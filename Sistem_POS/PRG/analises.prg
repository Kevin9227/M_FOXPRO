*CLEAR 
*vendas(inputbox("Entrada"),inputbox("Saida"))

PROCEDURE   vendas
LPARAMETERS dtinicio ,dtfinal &&, flistagem
IF used("ft")
	select fdate as data,nmdoc as documento,fno as numero,Tipo,totaliva,total,operador FROM ft ;
	WHERE cast(fdate as char(10)) >=dtinicio  AND cast(fdate as char(10)) <=dtfinal;
	 INTO CURSOR ftlistagem
	select ftlistagem
	GO TOP 
	RETURN 
		
ELSE 
	USE pos!ft 
	select fdate as data,nmdoc as documento,fno as numero,Tipo,totaliva,total,operador FROM ft ;
	WHERE fdate>=dtinicio  AND fdate  <=dtfinal;
	 INTO CURSOR ftlistagem
	select ftlistagem
	RETURN 
ENDIF 
*RETURN ftlistagem 

	RETURN .t.
ENDPROC 

