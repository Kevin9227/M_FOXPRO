** Criado por: Vasco Rocha
** Data de criação: 11.09.2017
** Novo Inventário Geral

LOCAL cRefini, cReffim, cLocalini, cLocalfim, cFini, cFfim
m.cRefini = ""
m.cReffim = ""
m.cLocalini = ""
m.cLocalfim = ""
m.cFini = ""
m.cFfim = ""

** Verifica o tipo de filtro a aplicar
m.mFiltro = dpergunta(2,1,"Inventário Geral","Escolha os artigos a inventariar","","Entre Referências","Entre Localizações")
IF m.mFiltro <> 0
	DO CASE
	CASE m.mFiltro = 1
		CREATE CURSOR xVars ( no N(5), tipo c(1), NOME c(40), PICT c(100), lOrdem N(10), nValor N(18,5), cValor c(250), lValor l, dValor d,tBval M)
* prencher os dados de cada variavel a pedir
		SELECT xVars
		APPEND BLANK
		REPLACE xVars.no WITH 1
		REPLACE xVars.tipo WITH "C"
		REPLACE xVars.NOME WITH "Ref. Inicial"
		REPLACE xVars.PICT WITH ""
		REPLACE xVars.lOrdem WITH 1
		REPLACE xVars.cValor WITH ""
		SELECT xVars
		APPEND BLANK
		REPLACE xVars.no WITH 2
		REPLACE xVars.tipo WITH "C"
		REPLACE xVars.NOME WITH "Ref. Final"
		REPLACE xVars.PICT WITH ""
		REPLACE xVars.lOrdem WITH 2
		REPLACE xVars.cValor WITH ""
		m.Escolheu = .F.
		m.mCaption = "Filtro entre Referências"
		docomando("do form usqlvar with 'xvars',m.mCaption")
		IF NOT m.Escolheu
			mensagem("Atribuição interrompida!","DIRECTA")
			RETURN .F.
		ELSE
			SELECT xVars
			LOCATE
			m.cRefini = xVars.cValor
			SELECT xVars
			SKIP
			m.cRefFim = xVars.cValor
		ENDIF
	CASE m.mFiltro = 2
		TEXT TO m.msel NOSHOW TEXTMERGE
			select top 1 bostamp from bo (nolock) where ndos = 82 and fechada = 0
		ENDTEXT
		IF NOT u_sqlexec(m.msel, 'c_bolocal')
			msg('Erro ao verificar localizações.')
			return
		ENDIF
		SELECT c_bolocal
		TEXT TO m.msel NOSHOW TEXTMERGE
			select	bi.u_locais local, case when bi.atedata = '19000101' then '' else convert(varchar(10), bi.atedata, 121) end ultimo_inventario
			from	bo (nolock)
			inner	join bi (nolock) on bo.bostamp = bi.bostamp
			where	bo.bostamp = '<<ALLTRIM(c_bolocal.bostamp)>>'
			order	by bi.design
		ENDTEXT
		
		IF u_sqlexec(m.msel,"c_local") AND RECCOUNT("c_local") > 0
			m.Escolheu=.F.
			m.m_titulo = "Escolha a localização inicial"
			mostrameisto("c_local", m.m_titulo)
			IF NOT m.Escolheu
				msg("Desculpe, mas tem de escolher uma localização!")
				return
			ELSE
				SELECT c_local
				m.cLocalini = c_local.local
				
				TEXT TO m.msel NOSHOW TEXTMERGE
					select	bi.u_locais local, case when bi.atedata = '19000101' then '' else convert(varchar(10), bi.atedata, 121) end ultimo_inventario
					from	bo (nolock)
					inner	join bi (nolock) on bo.bostamp = bi.bostamp
					where	bo.bostamp = '<<ALLTRIM(c_bolocal.bostamp)>>' and bi.u_locais >= '<<ALLTRIM(m.cLocalini)>>'
					order	by bi.design
				ENDTEXT
				IF u_sqlexec(m.msel,"c_localf") AND RECCOUNT("c_localf") > 0
					m.Escolheu=.F.
					m.m_titulo = "Escolha a localização final"
					mostrameisto("c_localf", m.m_titulo)
					IF NOT m.Escolheu
						msg("Desculpe, mas tem de escolher uma localização!")
						return
					ELSE	
						SELECT c_localf
						m.cLocalfim = c_localf.local
					ENDIF
				ELSE
					msg("Desculpe, mas não encontrei localizações!")
					RETURN
				ENDIF	
			ENDIF
		ELSE
			msg("Desculpe, mas não encontrei localizações!")
			RETURN	
		ENDIF
	
	ENDCASE
ELSE
	msg('Operação Cancelada.')
	RETURN
ENDIF
** Faz a pesquisa da informação de acordo com o filtro escolhido
m.cWhere = ''
IF m.mFiltro = 1
** Verifico se as referências existem
	TEXT TO m.msel NOSHOW TEXTMERGE
		SELECT 	st.ref
		from 	st (nolock)
		where 	st.ref = '<<ALLTRIM(m.cRefini)>>'
	ENDTEXT
	IF u_sqlexec(m.msel, 'c_RefOk') AND RECCOUNT('c_RefOk') < 1
		msg('A referência inicial não existe.')
		RETURN
	ENDIF
	fecha('c_RefOk')
	TEXT TO m.msel NOSHOW TEXTMERGE
		SELECT 	st.ref
		from 	st (nolock)
		where 	st.ref = '<<ALLTRIM(m.cReffim)>>'
	ENDTEXT
	IF u_sqlexec(m.msel, 'c_RefOk') AND RECCOUNT('c_RefOk') < 1
		msg('A referência final não existe.')
		RETURN
	ENDIF
	fecha('c_RefOk')
** Construo a clausula where
	m.cWhere = "where st.inactivo = 0 and st.stns = 0 and st.ref between '" + ALLTRIM(m.cRefini) + "' and '" + ALLTRIM(m.cRefFim) + "'"
	m.cFini = ALLTRIM(m.cRefini)
	m.cFfim = ALLTRIM(m.cRefFim)
ENDIF
IF m.mFiltro = 2
	m.cWhere = "where st.inactivo = 0 and st.stns = 0 and st.local between '" + ALLTRIM(m.cLocalini) + "' and '" + ALLTRIM(m.cLocalfim) + "'"
	m.cFini = ALLTRIM(m.cLocalini)
	m.cFfim = ALLTRIM(m.cLocalfim)
ENDIF
** Mostra os artigos a inventariar de acordo com o filtro escolhido
TEXT TO m.msel NOSHOW TEXTMERGE
	SELECT 	CAST(1 as bit) as SEL, st.ref, st.design design, 0 as stock, 1 as armazem, '' as ccusto, st.local
			,st.u_local2 as local2
			,st.u_local3 as local3,st.u_local4 as local4,st.u_local5 as local5,st.u_local6 as local6
			, 0 as preco, st.unidade
			, st.usalote, st.texteis, st.cpoc, st.pcpond, st.epcpond
	from	st (nolock)
	<<ALLTRIM(m.cWhere)>>
	order 	by local, ref
ENDTEXT
IF u_sqlexec(m.msel, "c_refs") AND RECCOUNT("c_refs") > 0
	=CURSORSETPROP('Buffering',5,"c_refs")
	m.ncol = 14
	DECLARE list_tit(m.ncol),list_cam(m.ncol),list_tam(m.ncol),list_pic(m.ncol), list_ronly(m.ncol)
	m.ncol = 1
	list_tit(m.ncol)   = "Sel"
	list_cam(m.ncol)   = "c_refs.Sel"
	list_tam(m.ncol)   = 50
	list_pic(m.ncol)   = "LOGIC"
	list_ronly(m.ncol) = .F.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Referência"
	list_cam(m.ncol)   = "c_refs.Ref"
	list_tam(m.ncol)   = 8*30
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Designação"
	list_cam(m.ncol)   = "c_refs.design"
	list_tam(m.ncol)   = 8*50
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Stock"
	list_cam(m.ncol)   = "c_refs.stock"
	list_tam(m.ncol)   = 8*10
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Armazem"
	list_cam(m.ncol)   = "c_refs.armazem"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Centro de Custo"
	list_cam(m.ncol)   = "c_refs.ccusto"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 1"
	list_cam(m.ncol)   = "c_refs.local"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
		
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 2"
	list_cam(m.ncol)   = "c_refs.local2"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.

	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 3"
	list_cam(m.ncol)   = "c_refs.local3"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.

	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 4"
	list_cam(m.ncol)   = "c_refs.local4"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.

	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 5"
	list_cam(m.ncol)   = "c_refs.local5"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.

	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Localização 6"
	list_cam(m.ncol)   = "c_refs.local6"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Preço"
	list_cam(m.ncol)   = "c_refs.preco"
	list_tam(m.ncol)   = 8*20
	list_pic(m.ncol)   = m_eurpic
	list_ronly(m.ncol) = .T.
	m.ncol = m.ncol + 1
	list_tit(m.ncol)   = "Unidade"
	list_cam(m.ncol)   = "c_refs.unidade"
	list_tam(m.ncol)   = 8*30
	list_pic(m.ncol)   = ''
	list_ronly(m.ncol) = .T.
	m.Escolheu=.F.
	browlist('Lista de artigos a inventariar','c_refs', 'c_refsTemp',.T.,.F.,.F.,.T.,.T.,'',.T.,.T.)
ENDIF
IF m.Escolheu
** Verifico o próximo número de inventário a inserir
	TEXT TO m.msel TEXTMERGE noshow
		select	case when isnull(max(left(descricao,6)),0) = 0 then '000001' else RIGHT('00000' + convert(varchar(6),CONVERT(NUMERIC(6), max(left(descricao,6))) + 1),6) end as nostic
        from	stic (nolock)
        where	right(stic.descricao,3) = 'PHC'
	ENDTEXT
	IF NOT u_sqlexec(m.msel, 'c_nrstic')
		msg(m.msel)
		RETURN
	ENDIF
	SELECT	c_nrstic
	m.nNoStic = c_nrstic.nostic
** Gera código de barras
	mcodbarra=''
	mcodbarrackd=''
	mcodbarra=(strzero(VAL(m.nNoStic),6,0))+strzero(VAL(m.nNoStic),6,0)
	mcodbarrackd=Ean13ckd(mcodbarra)
** FIM
	m.NewStamp = u_stamp(RECNO('c_nrstic'))
** Insiro o cabeçalho do novo Inventário
	TEXT TO m.msel NOSHOW TEXTMERGE
		INSERT INTO stic (sticstamp, data, descricao, lanca, stamp, ousrinis, ousrdata, ousrhora, usrinis, usrdata, usrhora
						, marcada, ccusto, u_diquebra, u_disobra, exportado, impresso, userimpresso, u_updst, hora, u_terminal, u_codebar
						, u_esticg, u_tipostic, u_fini, u_ffim)
		values ('<<ALLTRIM(m.NewStamp)>>', convert(char(8),getdate(),112)
				, '<<alltrim(c_nrstic.nostic)>>' + '-PHC'
				, 0, ''
				, '<<alltrim(m.m_chinis)>>'
				, convert(char(8),getdate(),112)
				, convert(char(10), getdate(), 108)
				, '<<alltrim(m.m_chinis)>>'
				, convert(char(8),getdate(),112)
				, convert(char(10), getdate(), 108)
				, 0, '', 0, 0, 0, 0, '', 0, '', ''
				, '<<ALLTRIM(mcodbarrackd)>>'
				, 1, <<astr(m.mFiltro)>>, '<<m.cFini>>', '<<m.cFfim>>')
	ENDTEXT
	IF 	NOT u_sqlexec(m.msel)
		msg("Erro ao inserir cabeçalho do inventário! Verifique.") 
		msg(m.msel)
		RETURN
	ENDIF
** Insiro as linhas do novo Inventário
	SELECT c_refs
	m.nlordem = 0
	SCAN FOR c_refs.sel

		*** TTS-RPM 08-01-2018 - Vamos desdobrar por localizações
		*** Vamos desdobrar as linhas pelas localizações
		TEXT TO msel NOSHOW TEXTMERGE
			Select distinct a.ref,a.design,a.local,a.unidade,a.cpoc
			from (
				Select ref,design,local as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
				union all
				Select ref,design,u_local2 as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
				union all
				Select ref,design,u_local3 as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
				union all
				Select ref,design,u_local4 as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
				union all
				Select ref,design,u_local5 as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
				union all
				Select ref,design,u_local6 as local,unidade,cpoc from st(nolock) where st.ref = '<<c_refs.Ref>>'
			) a					
			where a.local<>''
		ENDTEXT
		IF NOT  u_sqlexec(msel,"uCurLocais")
			msg(msel)
			RETURN
		ENDIF
		Select uCurLocais
		If reccount("uCurLocais") > 0	
			**** Tem localizações
			Select uCurLocais
			Goto top
			Scan

				m.nlordem =	m.nlordem + 1000
				TEXT TO m.msel NOSHOW TEXTMERGE
					INSERT INTO stil (stilstamp, ref, design, data, stock, stamp, sticstamp
							, armazem, lote, cor, tam, usalote, texteis
							, ousrinis, ousrdata, ousrhora, usrinis, usrdata, usrhora
							, marcada, cpoc, ccusto, valstock, evalstock, szzstamp, zona, alvstamp, identificacao, pcpond, epcpond
							, lordem, unidade, local)
					values ((right(newid(),11) + left(newid(),8) + right(newid(),5))
							, '<<alltrim(c_refs.Ref)>>', '<<alltrim(c_refs.design)>>', convert(char(8), getdate(), 112), 0, '', '<<ALLTRIM(m.NewStamp)>>'
							, 1, '', '', '', <<IIF(c_refs.usalote = .t.,1,0)>>, <<IIF(c_refs.texteis = .t., 1,0)>>
							, '<<alltrim(m.m_chinis)>>'
							, convert(char(8),getdate(),112)
							, convert(char(10), getdate(), 108)
							, '<<alltrim(m.m_chinis)>>'
							, convert(char(8),getdate(),112)
							, convert(char(10), getdate(), 108)
							, 0, <<c_refs.cpoc>>,'<<uCurLocais.local>>',0, 0, '', '', '', '', <<adec_tr(c_refs.pcpond)>>, <<adec_tr(c_refs.epcpond)>>
							, <<m.nlordem>>, '<<ALLTRIM(c_refs.unidade)>>','<<uCurLocais.local>>'
							)
				ENDTEXT
				IF 	NOT u_sqlexec(m.msel)
					msg("Erro ao inserir linhas do inventário! Verifique.") 
					msg(m.msel)
					RETURN
				ENDIF			
			Endscan
		Else
			*** Não tem localizações
			m.nlordem =	m.nlordem + 1000
			TEXT TO m.msel NOSHOW TEXTMERGE
				INSERT INTO stil (stilstamp, ref, design, data, stock, stamp, sticstamp
						, armazem, lote, cor, tam, usalote, texteis
						, ousrinis, ousrdata, ousrhora, usrinis, usrdata, usrhora
						, marcada, cpoc, ccusto, local, valstock, evalstock, szzstamp, zona, alvstamp, identificacao, pcpond, epcpond
						, lordem, unidade)
				values ((right(newid(),11) + left(newid(),8) + right(newid(),5))
						, '<<alltrim(c_refs.Ref)>>', '<<alltrim(c_refs.design)>>', convert(char(8), getdate(), 112), 0, '', '<<ALLTRIM(m.NewStamp)>>'
						, 1, '', '', '', <<IIF(c_refs.usalote = .t.,1,0)>>, <<IIF(c_refs.texteis = .t., 1,0)>>
						, '<<alltrim(m.m_chinis)>>'
						, convert(char(8),getdate(),112)
						, convert(char(10), getdate(), 108)
						, '<<alltrim(m.m_chinis)>>'
						, convert(char(8),getdate(),112)
						, convert(char(10), getdate(), 108)
						, 0, <<c_refs.cpoc>>, '', '<<ALLTRIM(c_refs.local)>>', 0, 0, '', '', '', '', <<adec_tr(c_refs.pcpond)>>, <<adec_tr(c_refs.epcpond)>>
						, <<m.nlordem>>, '<<ALLTRIM(c_refs.unidade)>>'
						)
			ENDTEXT
			IF 	NOT u_sqlexec(m.msel)
				msg("Erro ao inserir linhas do inventário! Verifique.") 
				msg(m.msel)
				RETURN
			ENDIF
		Endif
	ENDSCAN
	** Mostra o registo inserido
	navega('STIC', m.NewStamp)
ENDIF
fecha('c_nrstic')
fecha('c_local')
fecha('c_local')
fecha('c_Refini')
fecha('c_Reffim')
fecha('c_refs')