**************************************************************
*** Etiqueta artigos com alteração preços futuros
*** Criado por Rui Vale
*** Criado em 22/01/2018
**************************************************************
**************************************************************
*** DADOS DA ANÁLISE
**************************************************************

******* Definir dados do array com lojas para transferir
cvar = ''
TEXT TO sqle1 NOSHOW TEXTMERGE
	select distinct  convert(varchar(10),datai,121) + ' - ' + convert(varchar(10),dataf,121) + ' - ' +  descricao campo 
	from sp  (nolock)
	order by convert(varchar(10),datai,121) + ' - ' + convert(varchar(10),dataf,121) + ' - ' +  descricao desc 

ENDTEXT

IF NOT u_sqlexec(sqle1, "c_temparr")
	msg(sqle1)
	return 
ENDIF
IF RECCOUNT("c_temparr")>0
	DECLARE var_array(RECCOUNT("c_temparr"))
	SELECT c_temparr
	var_contador = 1
	SCAN
		var_array(var_contador) = c_temparr.campo
		var_contador = var_contador + 1
	ENDSCAN
	fecha("c_temparr")
ELSE
	mensagem("Não há registos!!!","DIRECTA")
ENDIF
******* Fim de Definir dados do array 
cvar = getnome('Introduza a promoção',"","","",1,.F.,"var_array")

IF  EMPTY(cvar)
	msg("Preencha a promoção.")
	RETURN 
ENDIF 


uNomeAnalise = "Etiqueta artigos com alteração preços futuros"
uStampuSql = "ADM18012248032,4000000-1"
uNomeTabTemp = "u_Tts_USQL_EtiqPrec"
uTipoAnalise = 3
**************************************
*** uTipoAnalise = 1  -> Normal
*** uTipoAnalise = 2  -> c/ IDU
*** uTipoAnalise = 3  -> c/ Etiquetas
**************************************
** Chamar as variáveis
If !Tts_uSqlValidaVariaveis(uStampuSql)
	Msg("Erro ao correr análise!!")
	Return .F.
Endif
**************************************************************
*** FIM DADOS DA ANÁLISE
**************************************************************
**************************************************************
*** CÓDIGO DA ANÁLISE (Substituir as variáveis #n# Por uUsqlVariaveln, Exmplo #1# -> uUsqlVariavel1)
**************************************************************
TEXT to uSql textmerge noshow
	Select CAST(0 as bit) as Selec,st.ref,st.design,st.codigo,u_preco.u_precostamp
		,u_preco.epv1, u_preco.epv1 epvp ,st.u_tpart,st.u_csubfam,u_preco.data datai
		,u_preco.data dataf
		,u_preco.dtetiq,Cast(1 as numeric(10)) as qtt
	From st (nolock)
	Inner join u_preco (nolock) on st.ref = u_preco.ref
	Where 1=2
ENDTEXT

If u_sqlexec(uSql,"SQLTMP")
Endif

TEXT to uSql textmerge noshow
	Select   CAST(0 as bit) as Selec,st.ref,st.design,st.codigo
	,st.ststamp
		,st.epv1
		,case when sp.porsp = 2 then st.epv1 * (1-(sp.desc1/100)) else epfixo end  epvp
		,st.u_tpart
		,st.u_csubfam
		,sp.datai
		, sp.dataf 
		--,u_preco.dtetiq
		,Cast(1 as numeric(10)) as qtt
		, sp.porsp
	From st (nolock)
	inner join  sp (nolock) on st.ref =  sp.refi  and  porst = 3    
	Where convert(varchar(10),datai,121) + ' - ' + convert(varchar(10),dataf,121) + ' - ' +  descricao = '<<cvar>>'
	order by st.u_csubfam,st.design,st.ref


ENDTEXT

If u_sqlexec(uSql,"uCurStPreco") And Reccount("uCurStPreco")>0
	uCols = 9
	uCol = 0
	Declare list_tit(uCols),list_cam(uCols),list_tam(uCols),list_pic(uCols),list_valid(uCols),list_ronly(uCols),list_rot(uCols),list_combo(uCols)
	uCol = uCol + 1
	list_tit(uCol)="Seleccionar"
	list_cam(uCol)="uCurStPreco.selec"
	list_tam(uCol)=10*8
	list_pic(uCol)='LOGIC'
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.F.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Referência"
	list_cam(uCol)="uCurStPreco.ref"
	list_tam(uCol)=18*8
	list_pic(uCol)=''
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Designação"
	list_cam(uCol)="uCurStPreco.design"
	list_tam(uCol)=40*8
	list_pic(uCol)=''
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''
	
	uCol = uCol + 1
	list_tit(uCol)="Sub-Familia"
	list_cam(uCol)="uCurStPreco.u_csubfam"
	list_tam(uCol)=18*8
	list_pic(uCol)=''
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''

	uCol = uCol + 1
	list_tit(uCol)="Qtd Etiquetas"
	list_cam(uCol)="uCurStPreco.qtt"
	list_tam(uCol)=10*8
	list_pic(uCol)='99999999'
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.F.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Preço"
	list_cam(uCol)="uCurStPreco.epv1"
	list_tam(uCol)=20*8
	list_pic(uCol)='999,999,999,999.99'
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Preço Promo"
	list_cam(uCol)="uCurStPreco.epvp"
	list_tam(uCol)=20*8
	list_pic(uCol)='999,999,999,999.99'
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Data Inicial promo"
	list_cam(uCol)="uCurStPreco.datai"
	list_tam(uCol)=10*8
	list_pic(uCol)=''
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''
	uCol = uCol + 1
	list_tit(uCol)="Data Final promo"
	list_cam(uCol)="uCurStPreco.dataf"
	list_tam(uCol)=10*8
	list_pic(uCol)=''
	list_valid(uCol)=''
	list_rot(uCol)=''
	list_ronly(uCol)=.T.
	list_combo(uCol)=''

	m.escolheu =.F.
	** Chamamos o browlist
	browlist('Etiquetas preços por imprimir','uCurStPreco','uCurStPreco',.T.,.F.,.F.,.T.,.F.,'',.T.,.T.)
	If !m.escolheu
		Msg("Cancelado pelo utilizador!!")
		Return
	Endif
	Select uCurStPreco
	Go Top
	Do While !Eof()
		If uCurStPreco.Selec
			Select uCurStPreco
			Scatter Memvar
			Insert Into SQLTMP From Memvar
		Endif
		Select uCurStPreco
		Skip
	Enddo
	Select SQLTMP
	Go Top
Else
	Msg("Não existem etiquetas por imprimir")
	Return
Endif
**************************************************************
*** FIM CÓDIGO DA ANÁLISE
**************************************************************

**************************************************************
*** CHAMAR A ANÁLISE
**************************************************************
If Reccount("SQLTMP")<=0
	Msg("Não existem dados para mostrar!!!")
	Return
Endif
If ! Tts_GuardaDadosTabelaTemp(uNomeTabTemp,"SQLTMP",uStampuSql)
	Msg("Erro ao correr análise!!")
	Return .F.
Endif
=Tts_correanaliseav(uTipoAnalise,uStampuSql)
**************************************
*** uTipo = 1  -> Normal
*** uTipo = 2  -> c/ IDU
*** uTipo = 3  -> c/ Etiquetas
**************************************

**************************************************************
*** FUNÇÕES
********************************************************

Function Tts_correanaliseav
	Lparameters uTipo,uStampuSql

	**************************************
	*** uTipo = 1  -> Normal
	*** uTipo = 2  -> c/ IDU
	*** uTipo = 3  -> c/ Etiquetas
	*** uStampuSql -> Stamp da análise
	**************************************

	Do Case
		Case uTipo = 1

			TEXT TO uSql TEXTMERGE noshow
				Select *,1 as lindex
				from usql (nolock)
				Where usqlstamp='<<uStampuSql>>'
			ENDTEXT

			If ! u_sqlexec(uSql,"tempsql") Or Reccount("tempsql")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			gensqlp("USQLIDU","IDU")

		Case uTipo = 2

			If Not Used("usql")
				Do dbfuseusql
			Endif

			v_usqlstamp = uStampuSql
			u_requery("USQL")

			TEXT TO uSql TEXTMERGE noshow
				Select <<usqlfields()>>
				from usql (nolock)
				Where usqlstamp='<<uStampuSql>>'
			ENDTEXT

			If ! u_sqlexec(uSql,"tempsql") Or Reccount("tempsql")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			Select tempsql
			Replace tempsql.lindex With 1

			TEXT TO uSql TEXTMERGE noshow
				<<tempsql.sqlexpr>>
			ENDTEXT

			If ! u_sqlexec(uSql,"sqltmp") Or Reccount("sqltmp")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			m.mvarsql = ""
			m.mselsql = ""

			idu_bdados = "iduusqlmdc"
			idu_bldados = "iduusqlmdl"
			idu_fdados = "sqltmp"
			idu_fldados = ""

			deftit= Alltrim(tempsql.grupo) + " " + Alltrim(tempsql.descricao)

			** IDU Etiquetas
			docomando([do form iduigen with .f.,"usqlcampos with 'TEMPSQL.','STD'","iduusqlcampos",.f.,.f.,.f.,.f.,.f.,"TOOLBARTOTAIS","IDUUSQL","",.t.,.f.,.t.,.f.,.f.,.f.])

		Case uTipo = 3
			PUBLIC IDUVALTSQL
			IDUVALTSQL = ""
			
			TEXT TO uSql TEXTMERGE noshow
				Select <<usqlfields()>>
				from usql (nolock)
				Where usqlstamp='<<uStampuSql>>'
			ENDTEXT

			If ! u_sqlexec(uSql,"tempsql") Or Reccount("tempsql")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			Select tempsql
			Replace tempsql.lindex With 1

			TEXT TO uSql TEXTMERGE noshow
				<<tempsql.sqlexpr>>
			ENDTEXT

			If ! u_sqlexec(uSql,"sqltmp") Or Reccount("sqltmp")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			m.mvarsql = ""
			m.mselsql = ""

			idu_bdados = "iduusqllbliduc"
			idu_bldados = "iduusqllblidul"
			idu_fdados = "sqltmp"
			idu_fldados = ""

			deftit= Alltrim(tempsql.grupo) + " " + Alltrim(tempsql.descricao)

			SELECT sqltmp
			GO top

			** IDU Etiquetas
			docomando([do form iduigen with .f.,"usqlcampos with 'TEMPSQL.','STD'","iduusqlcampos",.f.,.f.,.f.,.f.,.f.,"TOOLBARTOTAIS","IDUUSQL","",.t.,.f.,.f.,.t.,.f.,.f.])

		Otherwise

			TEXT TO uSql TEXTMERGE noshow
				Select *,1 as lindex
				from usql (nolock)
				Where usqlstamp='<<uStampuSql>>'
			ENDTEXT

			If ! u_sqlexec(uSql,"tempsql") Or Reccount("tempsql")<=0
				Msg("Erro ao correr análise!!")
				Return .F.
			Endif

			gensqlp("USQLIDU","IDU")

	Endcase

Endfunc

Function Tts_verificatabela
	Parameters uTabela

	TEXT TO uSql TEXTMERGE noshow
		SELECT table_name
		FROM INFORMATION_SCHEMA.TABLES
		Where table_name = '<<uTabela>>'
	ENDTEXT

	If u_sqlexec( uSql, "uCurTmp") And Reccount("uCurTmp")>0
		Return .T.
	Else
		Return .F.
	Endif
Endproc

Function Tts_criatabela
	Parameters uTabela

	uTabela = Alltrim(uTabela)

	If ! Tts_verificatabela(uTabela)
		TEXT TO uSql TEXTMERGE noshow
			Create table <<uTabela>>
			(<<ALLTRIM(UPPER(uTabela))>>stamp varchar(25) primary key default left(newid(),25))
		ENDTEXT

		If u_sqlexec(uSql)
			Return .T.
		Else
			Return .F.
		Endif
	Else
		Return .T.
	Endif

Endproc

Function Tts_verificacampo
	Parameters uTabela,uCampo

	uTabela = Alltrim(uTabela)

	TEXT TO uSql TEXTMERGE noshow
		SELECT column_name
		FROM INFORMATION_SCHEMA.COLUMNS
		Where table_name = '<<uTabela>>'
		and column_name = '<<uCampo>>'
	ENDTEXT

	If u_sqlexec( uSql, "uCurTmp") And Reccount("uCurTmp")>0
		Return .T.
	Else
		Return .F.
	Endif
Endproc

Function Tts_criacampo
	Parameters uTabela,uCampo,uTipo,uComprimento,uDecimais

	uTabela = Alltrim(uTabela)
	uCampo= Alltrim(uCampo)

	If Empty(uDecimais)
		uDecimais = 0
	Endif

	** Verifica se a rabela existe, ou se conseguiu criar
	If Tts_criatabela(uTabela)

		** Verifica se o campo não existe
		If ! Tts_verificacampo(uTabela,uCampo)

			Do Case
				Case uTipo = "C"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						varchar(<<Astr(uComprimento)>>)
					ENDTEXT

				Case uTipo = "M"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						text
					ENDTEXT

				Case uTipo = "I"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						int
					ENDTEXT

				Case uTipo = "N"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						numeric(<<Astr(uComprimento)>>,<<Astr(uDecimais)>>)
					ENDTEXT

				Case uTipo = "D" Or uTipo = "T"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						datetime
					ENDTEXT

				Case uTipo = "L"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						bit
					ENDTEXT

				Case uTipo = "B"

					TEXT TO uSql TEXTMERGE noshow
						Alter table <<uTabela>>
						add <<uCampo>>
						image
					ENDTEXT

				Otherwise
					Return .F.
			Endcase

			If u_sqlexec(uSql)
				Return .T.
			Else
				Return .F.
			Endif

		Else
			Return .T.
		Endif
	Else
		Return .F.
	Endif

	Return .T.

Endproc

Function Tts_GuardaDadosTabelaTemp
	Lparameters uTabela,uCursor,uStampuSql

	uListaCampos = ""

	Select &uCursor
	gnFieldcount = Afields(gaMyArray)
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

		If ! Tts_criacampo(uTabela,aCampos [nCount],aTipos [nCount],aTamanho[nCount],aCasas [nCount])
			Msg("Erro ao criar o campo " + aCampos [nCount] + " na tabela " + uTabela)
			Return .F.
		Endif

		If Empty(uListaCampos)
			uListaCampos = aCampos [nCount]
		Else
			uListaCampos = uListaCampos + "," + aCampos [nCount]
		Endif

	Endfor

	If ! Tts_criacampo(uTabela,"u_Tts_userno","N",10,0)
		Msg("Erro ao criar o campo u_Tts_userno na tabela " + uTabela)
		Return .F.
	Endif

	TEXT TO uSql TEXTMERGE noshow
		Delete <<uTabela>>
		Where u_Tts_userno = <<Astr(CH_USERNO)>>
	ENDTEXT

	If ! u_sqlexec(uSql)
		Msg("Erro ao correr análise!!")
		Return .F.
	Endif

	regua(0,Reccount(uCursor),"A guardar os registos!!")

	Select &uCursor
	Go Top
	Do While !Eof()

		regua(1,Recno(uCursor),"A guardar os registos!!")

		TEXT TO uSql TEXTMERGE noshow
			SELECT *
			From <<uTabela>>
			Where 1=2
		ENDTEXT

		If ! u_sqlexec(uSql,"uCurDadosSql")
			Msg("Erro ao correr análise!!")
			Return .F.
		Endif

		Select &uCursor
		Scatter Memo Memvar
		Insert Into uCurDadosSql From Memvar

		uCampoStamp = Alltrim(uTabela) + "stamp"

		Select uCurDadosSql
		Replace u_Tts_userno With CH_USERNO
		Replace &uCampoStamp With u_Stamp()

		If ! Tts_GuardaSql("uCurDadosSql",uTabela)
			Msg("Erro ao correr análise!!")
			Return .F.
		Endif

		Select &uCursor
		Skip
	Enddo

	regua(2)

	TEXT TO uQuery TEXTMERGE noshow
		Select <<uListaCampos>>
		from <<ALLTRIM(uNomeTabTemp)>> (nolock)
		Where u_Tts_userno = <<Astr(CH_USERNO)>>
	ENDTEXT

	TEXT TO uSql TEXTMERGE noshow
		Update usql set
		sqlexpr = '<<uQuery>>'
		,eprg=0
		Where usqlstamp='<<uStampuSql>>'
	ENDTEXT

	If ! u_sqlexec(uSql)
		Msg("Erro ao correr análise!!")
		Return .F.
	Endif

	Return .T.

Endfunc

Function Tts_uSqlValidaVariaveis
	Lparameters uStampuSql

	Public uUSqlNumVar,uUsqlVariavel1,uUsqlVariavel2,uUsqlVariavel3,uUsqlVariavel4,uUsqlVariavel5,uUsqlVariavel6
	Public uUsqlVariavel7,uUsqlVariavel8,uUsqlVariavel9,uUsqlVariavel10,uUsqlVariavel11,uUsqlVariavel12
	Public uUsqlVariavel13,uUsqlVariavel14,uUsqlVariavel15,uUsqlVariavel16,uUsqlVariavel17,uUsqlVariavel18
	Public uUsqlVariavel19,uUsqlVariavel20

	Create Cursor xVars ( no N(5), tipo c(1), Nome c(40), Pict c(100), lOrdem N(10), nValor N(18,5), cValor c(250), lValor l, dValor d, tbval m )

	TEXT TO uSql TEXTMERGE noshow
		Select *
		from usqlv (nolock)
		Where usqlstamp='<<uStampuSql>>'
	ENDTEXT

	If u_sqlexec(uSql,"uCurUsqlV") And Reccount("uCurUsqlV")>0

		uUSqlNumVar = 0

		Select uCurUsqlV
		Go Top
		Do While !Eof()

			uUSqlNumVar = uUSqlNumVar + 1

			Select xVars
			Append Blank
			Replace xVars.no With uUSqlNumVar
			Replace xVars.tipo With uCurUsqlV.tipo
			Replace xVars.Nome With uCurUsqlV.Nome
			Replace xVars.Pict With uCurUsqlV.Pict
			Replace xVars.lOrdem With uCurUsqlV.lOrdem
			Replace xVars.nValor With 0
			Replace xVars.cValor With ""
			Replace xVars.lValor With .F.
			Replace xVars.dValor With Date(1900,1,1)
			Replace xVars.tbval With uCurUsqlV.tbval

			Select uCurUsqlV
			Skip
		Enddo

		m.mCaption = uNomeAnalise
		m.escolheu=.F.
		docomando("do form usqlvar with 'xvars',m.mCaption")

		If m.escolheu
			Select xVars

			For uMeuReg = 1 To uUSqlNumVar
				uVariavel = "uUsqlVariavel" + Alltrim(Str(uMeuReg))
				Locate For no=uMeuReg
				Do Case
					Case xVars.tipo = "N"
						&uVariavel = xVars.nValor
					Case xVars.tipo = "L"
						&uVariavel = xVars.lValor
					Case xVars.tipo = "D"
						&uVariavel = Dtos(xVars.dValor)
					Otherwise
						&uVariavel = Alltrim(xVars.cValor)
				Endcase
			Next
		Else
			Msg("Cancelado pelo utilizador!!")
			Return .F.
		Endif
	Endif

	Return .T.

Endfunc


Function Tts_GuardaSql
	Parameter meucursor,uMinhaTabela,uBaseDados

	***************************************************
	** Função que guarda um registo do cursor, numa  **
	** tabela do sql						         **
	***************************************************

	**************** PARÂMETROS *******************
	** meucursor   : Nome do cursor a guardar
	** uMinhaTabela: Tabela onde vai guardar
	** uBDados     : Base de Dados onde vai guardar
	***********************************************

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

	If !Empty(uBaseDados)
		sSQLString = "select * from "+Alltrim(uBaseDados)+".."+Alltrim(uMinhaTabela)+Chr(13)
	Else
		sSQLString = "select * from "+Alltrim(uMinhaTabela)+Chr(13)
	Endif

	sSQLString =sSQLString +" (nolock) where 1=2"+Chr(13)

	If u_sqlexec(sSQLString,"uCURTEMP")

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

				If aCampos[nCount]==aCampos1[i]
					uNREG=uNREG+1
				Endif

			Endfor
		Endfor

		uNREG1=0
		For nCount = 1 To gnFieldcount

			uMENCOUTROU=.F.
			For i=1 To gnFieldcount1

				If aCampos[nCount]==aCampos1[i]
					uMENCOUTROU=.T.
				Endif

			Endfor

			If uMENCOUTROU

				uNREG1=uNREG1+1

				Select &meucursor

				cDado = Evaluate(aCampos[nCount])

				cTipo = aTipos[nCount]

				ucCampo = aCampos[nCount]

				If Alltrim(Upper(ucCampo))<>Alltrim(Upper(uMinhaTabela))+'ID' ;
						And Alltrim(Upper(ucCampo))<>'AUTOMATICOID';
						And Alltrim(Upper(ucCampo))<>'U_Tts_PHC';
						And Alltrim(Upper(ucCampo))<>'U_Tts_INT'

					If !Empty(sSQL)
						sSQL = sSQL + "," + Chr(13)
						cSQL = cSQL + "," + Chr(13)
					Endif

					If aTipos[nCount] = "N" Or aTipos[nCount] = "Y"
						cDado = Alltrim(Str(cDado,aTamanho[nCount],aCasas[nCount]))
					Endif

					If aTipos[nCount] = "I"
						cDado = Alltrim(Str(cDado))
					Endif

					If aTipos[nCount] = "T" Or aTipos[nCount] = "D"
						If Empty(cDado)
							cDado = "19000101"
						Else
							cDado = Alltrim(Dtos(Date(Year(cDado),Month(cDado),Day(cDado))))
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
						sSQL = sSQL + Strtran(Alltrim(astr(cDado)),",",".")
					Else
						sSQL = sSQL + "'" + Strtran(Alltrim(astr(cDado)),"'","''") + "'"
					Endif

					cSQL = cSQL + Alltrim(ucCampo)

				Endif
			Endif

		Endfor

		If !Empty(uBaseDados)
			sSQLString = "Insert Into "+Alltrim(uBaseDados)+".."+Alltrim(uMinhaTabela)
		Else
			sSQLString = "Insert Into "+Alltrim(uMinhaTabela)
		Endif

		sSQLString =sSQLString +" ("+cSQL
		sSQLString =sSQLString +") Values ("
		sSQLString =sSQLString + sSQL + ")"

		uNRTENTATIVAS=0
		merro=.T.
		Do While uNRTENTATIVAS<10 And merro

			If u_sqlexec(sSQLString)
				merro=.F.
			Else
				merro=.T.
			Endif

			uNRTENTATIVAS=uNRTENTATIVAS+1

			*			Wait Window "Estou a Guardar!!" Nowait Timeout 100

		Enddo

		If merro
			_Cliptext=sSQLString
			Messagebox("Não foi possivel guardar!")
			Return .F.
		Endif

	Endif

	Return .T.

Endfunc