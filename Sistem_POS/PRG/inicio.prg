****INICIO ****





CLEAR
CLEAR ALL

*-- Verifica se o aplicativo est� sendo
*	rodado dentro do Visual FoxPro

*	FILE() Verifica se um determinado
*	arquivo existe em disco
*	HOME() Retorna o diretorio de onde
*	foi inicializado o FoxPro

**




On Error Do errores With  Error( ), Message( ), Message(1), Program( ), Lineno( )
tudo_ok = .F.
DO FORM entrada		&& Formul�rio do Registro de Usu�rio - windowType = modal

	** Desabilita op��es de Desenvolvimento
IF tudo_ok =.f.
	PUSH MENU _MSYSMENU  && Armazena o menu ativo.

	DEACTIVATE WINDOW ;
		"gerenciador de projetos",;
		"project manager",;
		"padr�o",;
		"standard",;
		"dbibar",;
		"layout",;
		"form controls",;
		"controles de formul�rio",;
		"report controls",;
		"controles de relat�rio"

	RELEASE WINDOWS;
		"criador de formul�rios",;
		"form designer",;
		"criador de relat�rios",;
		"report designer",;
		"criador de banco de dados",;
		"database designer",;
		"criador de visualiza��es",;
		"view designer",;
		"criador de consultas",;
		"query designer",;
		"paleta de cores",;
		"color palette"
ENDIF 

_SCREEN.ICON        = 'c:\pos\img\testepn32.ico' 
_SCREEN.Picture     = 'c:\pos\img\loja.jpg'

IF tudo_ok

&& configura os comandos SET


oob=createobject("inicio")
 
 
*!*	DO FORM CUSTOMER.SCX

*!*	IF CUSTOMER.VISIBLE= .T. 
*!*		_Screen.Enabled = .F. 
*!*	ELSE 

*!*		
*!*	ENDIF 
*!*		READ EVENTS

* TELA


_SCREEN.WINDOWSTATE = 2
_SCREEN.CLOSABLE    = .T.
_SCREEN.CAPTION     =  ' HENDASOFT ' + DTOC( DATE() )	 + '    vers�o 05.10' &&Colocar data e hora no topo do programa
_SCREEN.VISIBLE     = .T. 
_SCREEN.ICON        = 'c:\pos\img\testepn32.ico' 
_SCREEN.MAXBUTTON   = .T.
_SCREEN.FORECOLOR   = RGB (   0,   0, 255 )
_SCREEN.Picture     = 'c:\pos\img\loja.jpg'
_Screen.AddObject("oob","inicio")
_Screen.oob.visible = .T. 
_Screen.oob.width =_Screen.width
_Screen.oob.Pageframe1.width = _Screen.width
*_Screen.ShowWindow  = 2
_Screen.Closable = .T. 
_Screen.Enabled = .T. 

DO PRGS\ConfiguraSets.prg	
ON SHUTDOWN QUIT 

 	

ENDIF 
READ EVENTS

PROCEDURE errores  
Parameter meRror, Mess, meSs1, mpRog, mlIneno
Do Case

	Otherwise
		k = Messagebox("O sistema causou O siguiente error :"         + Chr(13) + ;
			"N�mero :"     + Padr(Alltrim(Str(meRror)),40)  + Chr(13) + ;
			"Tipo       :" + Padr(Mess,40)                  + Chr(13) + ;
			"C�digo   :"   + Padr(meSs1,40) 				  + Chr(13) + ;
			"L�nha      :" + Padr(Alltrim(Str(mlIneno)),40) + Chr(13) + ;
			"M�todo  :"    + Padr(mpRog,40),64,"")
		return	
Endcase
ENDPROC
