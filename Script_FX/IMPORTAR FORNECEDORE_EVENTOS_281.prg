*************************************
*** Importação de dados de clientes
*** Criado em 27/01/2018
*** Criado por Rui Vale
*************************************

uFechar = .f.

Create Cursor uCurErros ( Erro C(254) )
Create Cursor uDadosFL (noold C(10),cpais C(10),tipo C(20),Nome C(60),morada C(55),local C(50),telefone C(20),tlmvl C(20),fax C(20),grupo C(20) ;
	,fornec C(10),idioma C(10),NIF C(20))

** Vou pedir o ficheiro para importar
uNomeFicheiroZip = Getfile("","Ficheiro a abrir","Abrir",2,"Abrir")

If Empty(uNomeFicheiroZip)
	Msg("Cancelado pelo utilizador!!!")
	Return
Endif

uFolhas = ""

uNomeFolha = "Folha1"

uNomeFicheiroZip = ["] + uNomeFicheiroZip + ["]
uNomeFolha = ["] + Alltrim(uNomeFolha) + ["]

*Try
	Select uDadosFL
	Append From &uNomeFicheiroZip Type Xl5 && Sheet &uNomeFolha
*Catch
*	Msg("Os dados a importar não estão de acordo com o esperado!!!")
*	uFechar = .T.
*Endtry

If uFechar
	Return
Endif

uComecou = .f.

Select uDadosFL
Go Top
Skip
Do While !Eof()

	If VAL(uDadosFL.noold)>0 OR uComecou
		uComecou = .t.

		TEXT TO uSql TEXTMERGE noshow
			Select ISNULL(MAX(no)+1,1) as no
			From FL (nolock)
		ENDTEXT

		If u_Sqlexec(uSql,"uCurNumFL") And Reccount("uCurNumFL")>0
			uNumFL = uCurNumFL.No
		Endif

		TEXT TO uSql TEXTMERGE noshow
			Select *
			From FL (nolock)
			Where 1=2
		ENDTEXT

		If u_Sqlexec(uSql,"uCurFL")
			Select uCurFL
			APPEND BLANK			
			uStamp = u_stamp()
			Replace uCurFL.FLstamp With uStamp
			Replace uCurFL.No With uNumFL
			Replace uCurFL.Nome With uDadosFL.Nome
			Replace uCurFL.u_noold With VAL(uDadosFL.noold)
			Replace uCurFL.Morada With uDadosFL.Morada 
			Replace uCurFL.local With uDadosFL.local 
			Replace uCurFL.telefone With uDadosFL.telefone 
			Replace uCurFL.tlmvl With uDadosFL.tlmvl 
			Replace uCurFL.fax With uDadosFL.fax 
			Replace uCurFL.tipo With uDadosFL.tipo 
			Replace uCurFL.ncont With uDadosFL.NIF 
			Replace uCurFL.pais With iif(uDadosFL.cpais='AO',1,3)
		
			Replace uCurFL.saldo With 0
			Replace uCurFL.esaldo With 0
			Replace uCurFL.eplafond With 0
			Replace uCurFL.plafond With 0

			Replace uCurFL.RADICALTIPOEMP With 1
			
			Replace uCurFL.ousrdata With Date()
			Replace uCurFL.ousrhora With Time()
			Replace uCurFL.ousrinis With m_chinis
			Replace uCurFL.usrdata With Date()
			Replace uCurFL.usrhora With Time()
			Replace uCurFL.usrinis With m_chinis

			If !Tts_GuardaSql("uCurFL","FL")
				Select uCurErros
				Append Blank
				Replace uCurErros.Erro With "Erro ao criar o cliente " + Alltrim(uDadosFL.Nome) + "!!"
			Endif


*!*				TEXT TO uSql TEXTMERGE noshow
*!*					Select *
*!*					From FL2 (nolock)
*!*					Where 1=2
*!*				ENDTEXT

*!*				If u_Sqlexec(uSql,"uCurFL2") And Reccount("uCurFL2")>0
*!*				Endif

*!*				Select uCurFL2
*!*				APPEND BLANK
*!*				Replace uCurFL2.FL2stamp With uStamp 

*!*				Replace uCurFL2.ousrdata With Date()
*!*				Replace uCurFL2.ousrhora With Time()
*!*				Replace uCurFL2.ousrinis With m_chinis
*!*				Replace uCurFL2.usrdata With Date()
*!*				Replace uCurFL2.usrhora With Time()
*!*				Replace uCurFL2.usrinis With m_chinis

*!*				If !Tts_GuardaSql("uCurFL2","FL2")
*!*					Select uCurErros
*!*					Append Blank
*!*					Replace uCurErros.Erro With "Erro ao criar o FLiente " + Alltrim(uDadosFL.Nome) + "!!"
*!*				ENDIF
*!*				
		Endif
	Endif

	Select uDadosFL
	Skip
Enddo

If Reccount("uCurErros")>0
	mostrameisto("uCurErros")
Endif


Function Tts_GuardaSql
	Parameter meucursor,uMinhaTabela
	************************************************
	** Função para guardar cursor numa tabela SQL **
	************************************************

	Local uMENCOUTROU,uNREG,uNREG1,uNRTENTATIVAS

	merro=.F.

	Select &meucursor

	gnFieldcount = Afields(gaMyArray)  && Create array
	Clear
	Dimension aCampos  [gnFieldcount]
	Dimension aTipos   [gnFieldcount]
	Dimension aTamanho [gnFieldcount]
	Dimension aCasas   [gnFieldcount]

	For nCount = 1 To gnFieldcount
		aCampos [nCount] = gaMyArray[nCount,1]
		aTipos  [nCount] = gaMyArray[nCount,2]
		aTamanho[nCount] = gaMyArray[nCount,3]
		aCasas  [nCount] = gaMyArray[nCount,4]
	Endfor

	sSQL=""
	cSQL=""
	inicSQL=""

	sSQLString = "select * from "+Alltrim(uMinhaTabela)+Chr(13)
	sSQLString =sSQLString +" (nolock) where 1=2"+Chr(13)

	If u_Sqlexec(sSQLString,"uCURTEMP")

		Select uCURTEMP

		gnFieldcount1 = Afields(uCURTEMP)  && Create array
		Clear
		Dimension aCampos1  [gnFieldcount1]
		Dimension aTipos1   [gnFieldcount1]
		Dimension aTamanho1 [gnFieldcount1]
		Dimension aCasas1   [gnFieldcount1]

		For nCount = 1 To gnFieldcount1
			aCampos1 [nCount] = uCURTEMP[nCount,1]
			aTipos1  [nCount] = uCURTEMP[nCount,2]
			aTamanho1[nCount] = uCURTEMP[nCount,3]
			aCasas1  [nCount] = uCURTEMP[nCount,4]
		Endfor


		** verifica quantos registos são iguais
		uNREG=0
		For nCount = 1 To gnFieldcount

			For i=1 To gnFieldcount1

				If aCampos[nCount]==aCampos1[i] And !Like(Alltrim(uMinhaTabela)+"ID",Alltrim(Upper(aCampos[nCount])))
					uNREG=uNREG+1
				Endif

			Endfor
		Endfor

		uNREG1=0
		For nCount = 1 To gnFieldcount

			uMENCOUTROU=.F.
			For i=1 To gnFieldcount1

				If aCampos[nCount]==aCampos1[i] And !Like(Alltrim(uMinhaTabela)+"ID",Alltrim(Upper(aCampos[nCount])))
					uMENCOUTROU=.T.
				Endif

			Endfor

			If uMENCOUTROU And !Like(Alltrim(uMinhaTabela)+"ID",Alltrim(Upper(aCampos[nCount])))

				uNREG1=uNREG1+1

				Select &meucursor

				cDado = Evaluate(aCampos[nCount])

				cTipo = aTipos[nCount]

				ucCampo = aCampos[nCount]


				If aTipos[nCount] = "N" Or aTipos[nCount] = "Y"
					cDado = Alltrim(Str(cDado,aTamanho[nCount],aCasas[nCount]))
				Endif

				If aTipos[nCount] = "I"
					cDado = Alltrim(Str(cDado))
				Endif

				If aTipos[nCount] = "T" Or aTipos[nCount] = "D"
					If Empty(cDado)
						cDado = "1900-01-01"
					Else
						cData = Alltrim(Str(Year(cDado)))+"-"+Padl(Alltrim(Str(Month(cDado))),2,"0")+"-"+Padl(Alltrim(Str(Day(cDado))),2,"0")
						cDado = cData
					Endif
				Endif

				If aTipos[nCount] = "L"
					If cDado = .T.
						cDado = Alltrim(Str(1))
					Else
						cDado = Alltrim(Str(0))
					Endif
				Endif

				If aTipos[nCount] = "N" Or aTipos[nCount] = "I" Or ;
						aTipos[nCount] = "Y" Or aTipos[nCount] = "B" Or ;
						aTipos[nCount] = "L"
					sSQL = sSQL + Strtran(Alltrim(cDado),",",".")
				Else
					sSQL = sSQL + "'" + Strtran(Alltrim(cDado),"'","'+char(39)+'")+ "'"
				Endif

				cSQL = cSQL + Alltrim(ucCampo)

				If uNREG1 < uNREG
					sSQL = sSQL + "," +Chr(13)
					cSQL = cSQL + ","+Chr(13)
				Endif

			Endif

		Endfor

		sSQLString = "Insert Into "+Alltrim(uMinhaTabela)+Chr(13)
		sSQLString =sSQLString +" ("+cSQL
		sSQLString =sSQLString +") Values ("
		sSQLString =sSQLString + sSQL + ")"
		If !Empty(inicSQL)
			sSQLString = sSQLString + inicSQL+Chr(13)
		Endif

		uNRTENTATIVAS=0
		merro=.T.
		Do While uNRTENTATIVAS<10 And merro

			If u_Sqlexec(sSQLString,"")
				merro=.F.
			Else
				merro=.T.
			Endif

			uNRTENTATIVAS=uNRTENTATIVAS+1

			Wait Window "Estou a Guardar!!" Nowait Timeout 100

		Enddo

		If merro
			_Cliptext=sSQLString
			= Aerror(aErrorArray)
			msgerro=aErrorArray(2)
			erros=.T.
			*!*				msg="O Registo Não foi gravado!!!"
		Endif

	Endif

	Return !merro
Endfunc
