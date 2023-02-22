*****
****-----Fun��es da aplica��o
*********

PROCEDURE Browlist  &&FN��O DE LUISTAGEM
 LPARAMETERS udescricao
 PUBLIC uformdesc
 uformdesc = udescricao
 DO FORM SLISTAGEM.SCX
ENDPROC
**
PROCEDURE fecha  && FECHAR CURSORES OU TABELAS
 PARAMETER ucursor
 IF USED(ucursor)
    SELECT &ucursor
    USE
 ENDIF
ENDPROC

PROCEDURE msg  && MENSAGENS PERSONALISADAS
 LPARAMETERS umsgtxt
 umsg = umsgtxt
 DO FORM msg.scx
ENDPROC
**
FUNCTION u_stamp  && GERAR STAMP
 PUBLIC uvalunicostamp
 IF EMPTY(uvalunicostamp) .OR. uvalunicostamp>99999
    uvalunicostamp = 0
 ENDIF
 uvalunicostamp = uvalunicostamp+1
 RETURN STRTRAN(ALLTRIM(SUBSTR(ALLTRIM(STR(uvalunicostamp))+TTOC(DATETIME(), 1)+SUBSTR(SYS(2015), 6, 5), 1, 25)), " ", "X")
ENDFUNC 
**
PROCEDURE mensagem
 LPARAMETERS umsgtxt, umsgtxt1
 umsg = umsgtxt
 DO FORM msg.scx
ENDPROC
**
FUNCTION questao
 LPARAMETERS uquestaotxt
 uquestaoresp = 0
 uquestao = uquestaotxt+" ?"
 DO FORM questao.scx
 IF uquestaoresp=1
    RETURN .T.
 ELSE
    RETURN .F.
 ENDIF
ENDFUNC


*!*	STORE date(2022,12,31) TO dtfinala
*!*	STORE date(2022,12,31) TO dtinicio

*!*	IF (MONTH(date()) != MONTH(dtinicio) OR year(date()) != year(dtinicio ))
*!*	?dtfinala-dtinicio
*!*	?date()
*!*		messagebox("DATA N�O VALIDA")
*!*	ELSE
*!*	?dtfinala-dtinicio
*!*		IF dtfinala-dtinicio=15 OR 
*!*			messagebox("FALTAM "+STR(dtfinala-dtinicio,2)+" DIAS PARA UTILIZAR O PROGRMA")
*!*		ELSE
*!*			messagebox("TERMINOU O TEMPO DE UTILIZAA��O DO PROGRAMA ... ")
*!*			RETURN .f.
*!*		ENDIF 
*!*		messagebox("DATA VALIDA")
*!*	ENDIF 
*!*	DEFINE CLASS odbcreg AS registry
*!*	**
*!*	   FUNCTION LoadODBCFuncs
*!*	    IF this.lloadedodbcs
*!*	       RETURN 0
*!*	    ENDIF
*!*	    IF EMPTY(this.codbcdllfile)
*!*	       RETURN -112
*!*	    ENDIF
*!*	    LOCAL henv, fdirection, szdriverdesc, cbdriverdescmax
*!*	    LOCAL pcbdriverdesc, szdriverattributes, cbdrvrattrmax, pcbdrvrattr
*!*	    LOCAL szdsn, cbdsnmax, pcbdsn, szdescription, cbdescriptionmax, pcbdescription
*!*	    DECLARE SHORT SQLDrivers IN (this.codbcdllfile) INTEGER, INTEGER, STRING @, INTEGER, INTEGER, STRING @, INTEGER, INTEGER
*!*	    IF this.lhaderror
*!*	       RETURN -1
*!*	    ENDIF
*!*	    DECLARE SHORT SQLDataSources IN (this.codbcdllfile) INTEGER, INTEGER, STRING @, INTEGER, INTEGER @, STRING @, INTEGER, INTEGER
*!*	    this.lloadedodbcs = .T.
*!*	    RETURN 0
*!*	   ENDFUNC
*!*	**
*!*	   FUNCTION GetODBCDrvrs
*!*	    PARAMETER adrvrs, ldatasources
*!*	    LOCAL nodbcenv, nretval, dsn, dsndesc, mdsn, mdesc
*!*	    ldatasources = IIF(TYPE("m.lDataSources")="L", m.ldatasources, .F.)
*!*	    nretval = this.loadodbcfuncs()
*!*	    IF m.nretval<>0
*!*	       RETURN m.nretval
*!*	    ENDIF
*!*	    nodbcenv = VAL(SYS(3053))
*!*	    IF INLIST(nodbcenv, 527, 528, 182)
*!*	       RETURN -113
*!*	    ENDIF
*!*	    DIMENSION adrvrs[1, IIF(m.ldatasources, 2, 1)]
*!*	    adrvrs[1] = ""
*!*	    DO WHILE .T.
*!*	       dsn = SPACE(100)
*!*	       dsndesc = SPACE(100)
*!*	       mdsn = 0
*!*	       mdesc = 0
*!*	       IF m.ldatasources
*!*	          nretval = sqldatasources(m.nodbcenv, 1, @dsn, 100, @mdsn, @dsndesc, 255, @mdesc)
*!*	       ELSE
*!*	          nretval = sqldrivers(m.nodbcenv, 1, @dsn, 100, @mdsn, @dsndesc, 100, @mdesc)
*!*	       ENDIF
*!*	       DO CASE
*!*	          CASE m.nretval=100
*!*	             nretval = 0
*!*	             EXIT
*!*	          CASE m.nretval<>0 .AND. m.nretval<>1
*!*	             EXIT
*!*	          OTHERWISE
*!*	             IF  .NOT. EMPTY(adrvrs(1))
*!*	                IF m.ldatasources
*!*	                   DIMENSION adrvrs[ALEN(adrvrs, 1)+1, 2]
*!*	                ELSE
*!*	                   DIMENSION adrvrs[ALEN(adrvrs, 1)+1, 1]
*!*	                ENDIF
*!*	             ENDIF
*!*	             dsn = ALLTRIM(m.dsn)
*!*	             adrvrs[ALEN(adrvrs, 1), 1] = LEFT(m.dsn, LEN(m.dsn)-1)
*!*	             IF m.ldatasources
*!*	                dsndesc = ALLTRIM(m.dsndesc)
*!*	                adrvrs[ALEN(adrvrs, 1), 2] = LEFT(m.dsndesc, LEN(m.dsndesc)-1)
*!*	             ENDIF
*!*	       ENDCASE
*!*	    ENDDO
*!*	    RETURN nretval
*!*	   ENDFUNC
*!*	**
*!*	   FUNCTION EnumODBCDrvrs
*!*	    LPARAMETERS adrvropts, codbcdriver
*!*	    LOCAL csourcekey
*!*	    csourcekey = "Software\ODBC\ODBCINST.INI\"+m.codbcdriver
*!*	    RETURN this.enumoptions(@adrvropts, m.csourcekey, -2147483646, .F.)
*!*	   ENDFUNC
*!*	**
*!*	   FUNCTION EnumODBCData
*!*	    LPARAMETERS adrvropts, cdatasource
*!*	    LOCAL csourcekey
*!*	    csourcekey = "Software\ODBC\ODBC.INI\"+cdatasource
*!*	    RETURN this.enumoptions(@adrvropts, m.csourcekey, -2147483647, .F.)
*!*	   ENDFUNC
*!*	**
*!*	ENDDEFINE