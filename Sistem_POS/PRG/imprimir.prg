*!*	* Beginning of program for Example 2
*!*	********************­********************­*****************
*!*	* This program assumes a report called Test which has been
*!*	* saved with the default printer in the Print Setup dialog.
*!*	*
PUBLIC OFORM
OFORM=CREATEOBJECT("form1")
OFORM.SHOW

DEFINE CLASS FORM1 AS FORM
	AUTOCENTER = .T.
	HEIGHT = 158
	WIDTH = 327
	SHOWWINDOW=2
	CAPTION = "Imprimir"
	NAME = "Imprimir"
	DIMENSION APRINTARRAY[1]
****Combo box*** add
	ADD OBJECT COMBO1 AS COMBOBOX WITH ;
		ROWSOURCETYPE = 5, ;
		ROWSOURCE = "thisform.aPrintArray", ;
		HEIGHT = 25, ;
		LEFT = 24, ;
		STYLE = 2, ;
		TOP = 48, ;
		WIDTH = 276, ;
		NAME = "Combo1"




	ADD OBJECT COMMAND1 AS COMMANDBUTTON WITH ;
		TOP = 108, ;
		LEFT = 48, ;
		HEIGHT = 27, ;
		WIDTH = 88, ;
		CAPTION = "Imprimir", ;
		PICTURE = "C:\POS\img\ICO\printer.png",;
		PICTUREMARGIN=1,;
		PICTUREPOSITION=1,;
		DEFAULT = .T., ;
		NAME = "Command1"

	ADD OBJECT COMMAND2 AS COMMANDBUTTON WITH ;
		TOP = 108, ;
		LEFT = 180, ;
		HEIGHT = 25, ;
		WIDTH = 84, ;
		CANCEL = .T., ;
		CAPTION = "Cancel", ;
		NAME = "Command2"

*****Add Label

	ADD OBJECT LABEL1 AS LABEL WITH ;
		CAPTION ="Impressora",;
		LEFT = 24, ;
		TOP = 30, ;
		WIDTH = 276, ;
		NAME = "Label1"

	PROCEDURE COMBO1.INIT

	LOCAL LNI
	FOR LNI = 1 TO APRINTERS(THISFORM.APRINTARRAY)
* Note below that you are adding a leading space. This
* prevents a network printer in Windows NT from appearing
* disabled in the combo due the leading "\"
		THISFORM.APRINTARRAY[lnI,1] = SPACE(1) + ;
			THISFORM.APRINTARRAY[lnI,1]
	ENDFOR
* Set initial value of combo
	THIS.REQUERY()

	IF '5.0' $ VERSION()
* This sets the combo initial value of the dropdown to the
* default printer - This will not work in 3.0/3.0b since
* SET('PRINTER', 2) is not available
		FOR EACH A_ELEMENT IN THISFORM.APRINTARRAY
			IF UPPER(SET('PRINTER',2))$UPPER(A_ELEMENT)
				THIS.VALUE = A_ELEMENT
			ENDIF
		ENDFOR
	ELSE
* If in 3.0/3.0b, set to first element in list.
		THIS.VALUE = THISFORM.APRINTARRAY[1]
	ENDIF
	ENDPROC

	PROCEDURE COMMAND1.CLICK
	SET PRINTER TO NAME (ALLTRIM(THISFORM.COMBO1.VALUE))
	REPORT FORM TALAO TO PRINTER NOCONSOLE
*RELEASE THISFORM
	ENDPROC

	PROCEDURE COMMAND2.CLICK
	RELEASE THISFORM
	ENDPROC

ENDDEFINE
*teste= getprinter()

*SET PRINTER TO teste 
*TYPE [c:\pos\teste.txt] TO PRINTER 
*
* End of program for Example 2




*!*	SET PRINTER TO LPT2 with PDSETUP Active
*!*	    Outputs to the LPT2 port in char mode using the PDSETUP
*!*	SET PRINTER TO LPT2 with no PDSETUP Active
*!*	    Ignores the LPT2 port and instead prints to the port defined for the
*!*	    current Windows Printer Driver using the current SET PRINTER FONT
*!*	SET PRINTER TO E:\MYDIR\LPTTEST.DUM with PDSETUP active
*!*	    Outputs to that filename using the PDSETUP
*!*	SET PRINTER TO E:\MYDIR\LPTTEST.DUM with no PDSETUP active
*!*	    Ignores the filename stipulated and instead prints to the port
*!*	    defined for the current Windows Printer Driver using the current
*!*	    SET PRINTER FONT
*!*	SET PRINTER TO C:\TEST\TEST.TXT with PDSETUP Active
*!*	    Outputs to that filename in char mode using the PDSETUP
*!*	SET PRINTER TO C:\TEST\TEST.TXT with no PDSETUP Active
*!*	    Outputs to that filename in character mode