
LOCAL eqtt , lcimp
lcimp =""
*!*	lcimp = getprinter()
*!*	&lcimp 
	SELECT ft
	
	IF !empty(ft.fno) OR !empty(ft.total)
		
		=tableupdate(.t.,.t.,"ft")
		select fi
		=tableupdate(.t.,.t.,"fi")
	SELECT ft
			SET PRINTER TO NAME getprinter()			
			i=0
		 FOR i=0 TO m.nprint 
		 	i=i+1
			REPORT FORM ftrtalao.frx TO PRINTER  NOCONSOLE    
			NEXT
				SELECT ft
			replace impri WITH .t.
			=tableupdate(.t.,.t.,"ft")
		
		*SET SKIP TO 
		SELECT REF,FNO,QTT FROM FI WHERE FNO=m.xno INTO CURSOR FILIST
		SELEC FILIST
		SCAN
			UPDATE ST SET STSAIDA=STSAIDA+FILIST.QTT,ST.STOCK=(ST.STOCK-FILIST.QTT )WHERE ST.REF=FILIST.REF
		ENDSCAN
		SELECT FILIST
	    USE
		messagebox ("VENDA PROCESSADA COM SUCESSO ",0+48,"! ! !AVISO ! ! !")
		
	ELSE
		wait WINDOW "Impressão cancelada " TIMEOUT 1
	ENDIF 

*** LIMPAR VARIAVES ****
select max(FNO) AS numero FROM FT INTO CURSOR xfno
select xfno 
IF xfno.numero=m.xno
xno=xfno.numero+1
	select ft
	GO BOTTOM 
			APPEND BLANK 
			REPLACE fno WITH m.xno
			REPLACE nome WITH cl.nome
			REPLACE ncont WITH cl.ncont
			REPLACE tel WITH cl.tel
			REPLACE morada WITH cl.morada
			SET FILTER TO ft.fno=m.xno
ENDIF 	
	


