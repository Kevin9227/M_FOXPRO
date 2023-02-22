************************************************************
*Programa desenvolvido pela HENDASOFT
*Desenvolvido por Joaquim de Campos	
*desenvolvedores em visual foxpro
************************************************************
* Programa Inicio
PUBLIC nid,nprint, aodbcdata, cdatasource, uusername, upassword, uodbc, ufechar, utentativas, usql2000, ubdados, uncriatriggers
 PUBLIC usql, ucurtmp, unomebdpropria, upesquisawbs, umsg, uquestaoresp, uquestao, uowner, usoftwarename, usoftwarebersion, ubdsinc, usqlversion
 LOCAL oreg, regfile, nerrnum, ldrivers, adrvropts, csourcekey
 DIMENSION aodbcdata[200]
 DIMENSION cdatasource[200]
 uusername = ""
 upassword = ""
 uodbc = ""
 ufechar = .F.
 utentativas = 0
 upesquisawbs = ''
 umsg = ''
 nprint =0
 uquestaoresp = 0
 uquestao = ''
 uowner = 'Software HendaSoft'
 usoftwarename = 'HnedaSoft'
 usoftwarebersion = ''
 usql2000 = .F.
 uncriatriggers = .F.
 *usftpass = "TTS_totalsoft"
 *ubdsinc = "TotalSincro"
 usqlversion = ""
*--Limpeza do Ambiente
_SCREEN.visible = .F.
***--- ATRIBUR NOME DA EMPRESA NA VARIAVEL
USE pos!emp
 select emp
 GO TOP 
 usoftwarename = emp.nome
 nprint = emp.printno
 utentativas = Emp.Cont

USE 
*** FIM 
 DO FORM formSplash.scx
*_SCREEN.visible = .F.
 SET DEFAULT TO SYS(5)+SYS(2003)
 ucaminho = ""
 ucaminho = "'"+SYS(5)+SYS(2003)+"'"
 READ EVENTS
 
SET MULTILOCKS ON
SET DATE TO BRITISH
SET REPROCESS TO AUTOMATIC
SET SYSMENU OFF 
SET EXCLUSIVE ON 
SET AUTOSAVE ON 
SET UNIQUE ON 
SET ANSI ON 
SET HOURS TO 24
SET CLOCK STATUS
SET MESSAGE ON
*SET STATUS ON
SET CONSOLE OFF
SET NOTIFY OFF
SET TALK OFF
SET SAFETY OFF
SET CENTURY ON
SET BELL OFF
SET CONFIRM OFF
SET STATUS BAR OFF 
SET STEP ON 

SET PROCEDURE TO configurasets ADDITIVE
 SET PROCEDURE TO meuerro ADDITIVE
 SET PROCEDURE TO ft_open ADDITIVE
 SET PROCEDURE TO pagamento ADDITIVE
 SET PROCEDURE TO funcoes ADDITIVE
SET PROCEDURE TO registry ADDITIVE

*SET DEFAULT TO SYS(5)+SYS(2003)
*SET DEFAULT TO (ADDBS(JUSTPATH(SYS(16,0))))  && para executar o programa dentro da pasta de instala��o
*SET PATH TO cla;forms;Dados;MENU



*-- Verifica se o aplicativo est� sendo
*	rodado dentro do Visual FoxPro

*	FILE() Verifica se um determinado
*	arquivo existe em disco
*	HOME() Retorna o diretorio de onde
*	foi inicializado o FoxPro
IF utentativas <=0
	infox=.T.
	messagebox("TERMINOU O TREMPO DE USO DO PROGRAMA.."+chr(13)+"Lige para o Apoio ao Cliente 924112838 / 990112838",0+64,"ALERTA")
	RETURN .F.
	CLEAR EVENTS 
ELSE
	infox=.F.
ENDIF
**


 ldrivers = .F.
 IF PARAMETERS()=1 .AND. TYPE("m.lODBCType")="L" .AND. m.lodbctype
    m.ldrivers = .T.
 ENDIF
 oreg = CREATEOBJECT("ODBCReg")
 m.nerrnum = oreg.getodbcdrvrs(@aodbcdata, .T.)
 y = 1
 FOR x = 1 TO ALEN(aodbcdata, 1)
    IF aodbcdata(x, 2)='SQL Server'
       cdatasource[y] = aodbcdata(x, 1)
       y = y+1
    ENDIF
 ENDFOR
 DIMENSION cdatasource[y-1]

*-- Prepara��o de Ambiente
ON SHUTDOWN QUIT 
* salva configura��es
oldfundo     = _SCREEN.PICTURE
oldtalk      = SET("Talk")
oldpath      = SET("Path")
olddate      = SET("Date")
olddel       = SET("Deleted")
oldcurrency  = SET("Currency",1)
oldpoint     = SET("Point")
oldseparator = SET("Separator")
oldexclusive = SET("Exclusive")
oldreprocess = SET("Reprocess")
oldrefresh   = SET("Refresh")
olderror     = ON ("Error")

*-- Reconfigura o Ambiente

_SCREEN.Icon        = SYS(5)+SYS(2003)+'\favicon.ico'
_SCREEN.PICTURE     =SYS(5)+SYS(2003)+'\img\bg.jpg'   && Papel de parede
_SCREEN.WINDOWSTATE = 2 	&& Executar maximizada
_SCREEN.CAPTION     = usoftwarename + "SOFTWARE HENDASOFT" 	&& Titulo 

SET CLASSLIB TO SYS(5)+SYS(2003)+'\class\classes'

_SCREEN.visible = .T.

tudo_ok = .F.
DO FORM entrada	
	&& Formul�rio do Registro de Usu�rio - windowType = modal
	
IF tudo_ok
WAIT "Entrando ao Sistema..." WINDOW AT 100,20 TIMEOUT 2

	oob=createobject("inicio")
_SCREEN.WINDOWSTATE = 2
_SCREEN.CLOSABLE    = .T.
_SCREEN.CAPTION     =  usoftwarename +' HendaSoft ' + DTOC( DATE() )	 + '   Vers�o Demo' &&Colocar data e hora no topo do programa
_SCREEN.VISIBLE     = .T. 
_SCREEN.ICON        = SYS(5)+SYS(2003)+'\favicon.ico' 
_SCREEN.MAXBUTTON   = .T.
_SCREEN.FORECOLOR   = RGB (   0,   0, 255 )
_SCREEN.Picture     = SYS(5)+SYS(2003)+'\img\loja.jpg'
_Screen.AddObject("oob","inicio")
_Screen.oob.visible = .T. 
_Screen.oob.width =_Screen.width
_Screen.oob.Pageframe1.width = _Screen.width
*_Screen.ShowWindow  = 2
_Screen.Closable = .T. 
_Screen.Enabled = .T. 
*DO PRG\ConfiguraSets.prg	&& configura os comandos SET
msg ("BEM VINDO AO SISTEMA HENDASOFT..."+chr(13)+"PRONTO PARA COME�AR ?")&&,0+32,"....BEMVINDO...")
	     && �ncora. Faz com que o programa fique esperando as a��es ;
		*DO operador. no .EXE, sem este comando, o MENU aparece e ;
		-desaparece em seguida, terminando o programa. ;
		*na op��o sair, � emitido CLEAR EVENTS PARA terminar o READ
	USE pos!emp
 select emp
 GO TOP 
 REPLACE Emp.Cont WITH Emp.Cont-1
USE 	
ENDIF
 READ EVENTS	

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
*--	Fim da restaura��o da configura��o
*-- Fim do programa in�cio