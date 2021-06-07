
SELECT bc
APPEND BLANK
SELECT cl
IF !EMPTY(cl.nome)
	REPLACE bc.titular WITH cl.nome
	REPLACE bc.nmtitular WITH cl.idcl
	REPLACE bc.ctnm WITH cl.ctnm
	REPLACE bc.iban WITH cl.iban
	REPLACE bc.saldo WITH 00.00
	REPLACE bc.dtdp WITH DATETIME()
ELSE
	MESSAGEBOX("Não foi possivel iserir os dados..",64,"ERRO")
ENDIF 

*SELECT cl
*INSERT INTO bc(titular,nmtitular,ctnm,iban,saldo,dtdp) VALUES (cl.nome,cl.idcl,cl.ctnm,cl.iban,0000,DATETIME( ))
	