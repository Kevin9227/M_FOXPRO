** JR
**2013-07-06
** Alterado por: Amândio Pacheco
** Data alteração: 05.06.2017
** Alterado por: Rui Vale
** Data alteração: 29.01.2018

crestamp = ''
Local m_USER, m_FUNCAO, m_CAMPO, m_TABELA, m_STAMP, m_OBSERV, M_SSUSERNAME, M_PNOME 

********************VARIAVEIS*******************************************

m_TABELA = 'FPOSL'
m_CAMPO = 'FPOSLSTAMP'

Select &m_TABELA
m_STAMP = &m_TABELA..&m_CAMPO

m_FUNCAO = 'Pagar Vale'
p_supervisor = ""

M_SSUSERNAME = FPOSC.SSUSERNAME
M_PNOME = FPOSC.PNOME

*************************************************************************

**42128EC6C1D04C66AD23
m_PASS = GETNOME('Introduza PASSWORD para efectuar '+astr(m_FUNCAO)+'! ','','','',1,.T.)

If Empty(m_PASS)
	msg('Acção cancelada pelo Utilizador')
	fecha('CR_ACESSO')
	Return
Endif


TEXT TO MSQL TEXTMERGE NOSHOW
  SELECT US.USERNO, US.USERNAME, US.USRINIS, US.USSTAMP
  FROM US (NOLOCK)
  WHERE US.PWPOS = '<<m_PASS>>'
        and U_GERENTE  = 1
ENDTEXT

If !U_SQLEXEC(MSQL,'CR_ACESSO')
	msg('Erro Encontrado')
	msg(MSQL)
	Return
Endif

Select CR_ACESSO
If Reccount() = 0
	msg('O utilizador digitado não tem permissao para terminar a acção '+astr(m_FUNCAO)+'! Por favor contacte o supervisor!')
	fecha('CR_ACESSO')
	Return
Endif

p_supervisor = CR_ACESSO.USERNAME

m_OBSERV = 'PAGAMENTO VALE - autorizado por: '+Alltrim(CR_ACESSO.USERNAME)

TEXT TO MINS TEXTMERGE NOSHOW
  INSERT INTO u_HISTALT
     ([u_histaltstamp]
     ,[userno]
     ,[username]
     ,[usstamp]
     ,[otabela]
     ,[oregstamp]
     ,[observ]
     ,[Tipo]
     ,[ousrinis]
     ,[ousrdata]
     ,[ousrhora]
     ,[usrinis]
     ,[usrdata]
     ,[usrhora]
     ,[marcada]
	,[pnome]
	,[ssusername])
  SELECT '<<u_STAMP()>>',<<CR_ACESSO.USERNO>>,'<<CR_ACESSO.USERNAME>>','<<CR_ACESSO.USSTAMP>>','<<M_TABELA>>','<<M_STAMP>>','<<M_OBSERV>>','Pagar Vale',
        '<<CR_ACESSO.USRINIS>>',getdate(),convert(char(10),getdate(),108),
        '<<CR_ACESSO.USRINIS>>',getdate(),convert(char(10),getdate(),108),0,'<<m_pnome>>','<<m_ssusername>>'
ENDTEXT

If !U_SQLEXEC(MINS)
	msg('ERRO ENCONTRADO')
	msg(MINS)
	Return
Endif

fecha('CR_ACESSO')


***************************
**104018000000001
cref = ''
cref = GETNOME("Introduza o Código do vale a pagar",'')

nLOJAFT =0
nFtano  = 0
nFno  = 0


If Empty(cref)

	Do While 1 =1
		*************************************************************************************************
		*** pede o nº da V.D.      *************************************************************************
		*************************************************************************************************
		num_ft = GETNOME('Introduza o Ano + Nº do Vale correspondente(exemplo : 2004.19001234)','')
		If m.escolheu = .F.
			Return
		Endif

		If  ( ( Substr(num_ft,5,1) = '.' And Val(Left(num_ft,4))>0 And Val(Substr(num_ft,6,Len(num_ft)))>0 ) Or (num_ft = '0' ) )
			Exit
		Else
			***** pergunta se utilizador ker repetir o numero ou sair
			rr = pergunta('ERRO ! ! !' + Chr(13) + 'NÚMERO INVÁLIDO'+ Chr(13)+'DESEJA TENTAR DE NOVO')
			If rr = .F.
				var_procura = .F.
				Exit
			Endif
		Endif
	Enddo

	nFtano = Val(Left(num_ft,4))
	nFno = Val(Substr(num_ft,6,Len(num_ft) ))
Endif


If Not Empty(cref)
	TEXT TO msel  NOSHOW TEXTMERGE
	     SELECT  ftstamp  FROM ft (nolock) inner join  ft3(nolock) on  ft.ftstamp =  ft3.ft3stamp   WHERE barcode = '<<cref>>' AND tipodoc = 3
	ENDTEXT

Else
	TEXT TO msel  NOSHOW TEXTMERGE
	     SELECT  ftstamp  FROM ft (nolock) WHERE ftano = replace('<<nFtano>>',',','.') and  fno = replace('<<nFno>>',',','.') and tipodoc = 3
	ENDTEXT
Endif

If Not  U_SQLEXEC(msel,"c_tempft")
	msg(msel)
	Return
Endif

If  Reccount("c_tempft") = 0
	msg("O vale não existe")
	fecha("c_tempft")
	Return
Endif

cftstamp = c_tempft.ftstamp
fecha("c_tempft")

TEXT TO msel NOSHOW TEXTMERGE
	select ecred-ecredf div
	from cc (nolock)
	where  ccstamp =  '<<cftstamp>>'
ENDTEXT

*msg(msel)

If Not U_SQLEXEC(msel,"c_div")
	msg(msel)
	Return
Endif

If c_div.div = 0
	msg("O documento está totalmente regularizado")
	fecha("c_div")
	Return
Endif

ldinheiro = 1

If U_SQLEXEC("select left(replace(newid(),'-',''),24) as restamp", "c_retmp")
	Select c_retmp
	m.cRestamp = c_retmp.restamp
Else
	msg("Erro: " + m.msel)
	Return
Endif
fecha("c_retmp")

If Not Inlist(p_estab,1,22)
	cquery_cc = 'cc'
Else
	cquery_cc = 'view_cc'
Endif

TEXT TO msel NOSHOW TEXTMERGE
    DECLARE @ndoc numeric(5), @nmdoc varchar(30)

	select @ndoc = ndoc , @nmdoc = nmdoc  from tsre (nolock) where nmdoc like '%Devoluções Pos' and u_estab = <<p_estab>>

    declare  @rno numeric(10,0)
    declare  @restamp  char(25)
    set @restamp = '<<m.cRestamp>>' -- left(replace(newid(),'-',''),24)
    select @rno = isnull(max(rno),<<aSTR(p_estab)+'000000' >>)+1  from re (nolock) where reano = year(getdate()) and ndoc = @ndoc

    insert into re
    (ndoc, nmdoc, restamp, rno, rdata, nome, no, morada, local, codpost, ncont, reano, olcodigo, telocal, moeda, contado,
    process, procdata,ollocal
    , etotal, tipo, pais, eivav1, eivav2, eivav3 ,eivav4 , eivav5, eivav6
    , total, ivav1, ivav2, ivav3 ,ivav4 , ivav5, ivav6
    ,vdata ,memissao  ,chmoeda ,moeda2
    ,evdinheiro, echtotal, EPAGA1
    ,vdinheiro, chtotal, PAGA1,  ccusto  
    , ousrinis, ousrdata, ousrhora , usrinis, usrdata, usrhora, site, pnome, pno, cxstamp, cxusername, ssstamp, plano ,u_estab
    )
    select @ndoc, @nmdoc, @restamp, @rno rno , convert(char(8),getdate(),112) rdata, ft.nome, ft.no, ft.morada , ft.local, ft.codpost, ft.ncont
    , year(getdate()) reano
    , 'R00001' olcodigo
    , 'C' telocal, 'AKZ' moeda, 0 contado , 1 process, convert(char(8),getdate(),112)procdata
    ,'Caixa' ollocal
    , (edeb)-edebf-(ecred-ecredf)etotal, ft.tipo, ft.pais , 0 eivav1, 0 eivav2, 0 eivav3 ,0 eivav4 , 0 eivav5, 0 eivav6
    , (deb)-debf-(cred-credf)total, 0 eivav1, 0 eivav2, 0 eivav3 ,0 eivav4 , 0 eivav5, 0 eivav6
    ,convert(char(8),getdate(),112) , 'EURO' ,'AKZ'
    , 'AKZ'
    , case when <<astr(ldinheiro)>> = 1  then (edeb)-edebf-(ecred-ecredf) else 0 end
    , case when <<astr(ldinheiro)>> = 0  then (edeb)-edebf-(ecred-ecredf) else 0 end
    , case when <<astr(ldinheiro)>> = 2  then (edeb)-edebf-(ecred-ecredf) else 0 end
    , case when <<astr(ldinheiro)>> = 1  then (deb)-debf-(cred-credf) else 0 end
    , case when <<astr(ldinheiro)>> = 0  then (deb)-debf-(cred-credf) else 0 end
    , case when <<astr(ldinheiro)>> = 2  then (deb)-debf-(cred-credf) else 0 end
	, '<<p_ccusto>>'
    ,'<<m.m_chinis>>'
    ,convert(char(8),getdate(),112)
    ,convert(char(10), getdate(), 108)
    ,'<<m.m_chinis>>'
    ,convert(char(8),getdate(),112)
    ,convert(char(10), getdate(), 108)
    , '<<fposc.site>>', '<<fposc.pnome>>', '<<fposc.pno>>', '<<fposc.cxstamp>>', '<<fposc.cxusername>>', ''
    , 0 plano , <<p_estab>>
    from ft  (nolock)
    inner join <<cquery_cc>> cc (nolock) on cc.ftstamp = ft.ftstamp
    where ft.ftstamp = '<<cftstamp>>'

    insert into  rl
    (ndoc, rlstamp, rno, cdesc, nrdoc, datalc, dataven, restamp, ccstamp, cm, eval, erec, val, rec
    , process, moeda, rdata, eivav1, eivav2,eivav3,eivav4,eivav5,eivav6
    , ivav1, ivav2,ivav3,ivav4,ivav5,ivav6
    , ousrinis, ousrdata, ousrhora , usrinis, usrdata, usrhora)
    select @ndoc,  @restamp, @rno rno, cmdesc , nrdoc, datalc, dataven, @restamp restamp
    ,  ccstamp, cm , -ecred eval , -(ecred-ecredf) erec, -cred val , -(cred-credf) rec
    , 1 process, moeda,convert(char(8),getdate(),112) rdata
    , 0 eivav1,  0 eivav2,0 eivav3,0 eivav4,0 eivav5,0 eivav6
    , 0 ivav1,  0 ivav2,0 ivav3,0 ivav4,0 ivav5,0 ivav6
    ,'<<m.m_chinis>>'
    ,convert(char(8),getdate(),112)
    ,convert(char(10), getdate(), 108)
    ,'<<m.m_chinis>>'
    ,convert(char(8),getdate(),112)
    ,convert(char(10), getdate(), 108)
    from <<cquery_cc>> cc (nolock)
    where  ccstamp =  '<<cftstamp>>'

	select @restamp restamp  
ENDTEXT

If Not U_SQLEXEC(msel,"c_tempre")
	_cliptext=msel
	MESSAGEBOX(msel)
	Return
Else
	crestamp = c_tempre.restamp 
	fecha("c_tempre")
	msg("Recibo emitido")
	navega('re',crestamp)
Endif