************************************************************
** Escolhe artigo(s) do documento, para colocar nos serviços
**
** Criado por Rui Vale
** Criado em  27/01/2018
************************************************************

If !Empty(u_sc.ftstamp)

	TEXT to uSql textmerge noshow
		Select CAST(0 as bit) as selec,fi.ref,fi.design,fi.qtt,st.usr1,st.fornec,st.fornecedor,st.u_tpart
		From fi (nolock)
		inner join st (nolock) on st.ref = case when fi.ref = '' then fi.oref else fi.ref end
		where ftstamp = '<<u_sc.ftstamp>>'
	ENDTEXT

	If u_sqlexec(uSql,"uCurFi") And Reccount("uCurFi")>0
		uCols = 6
		uCol = 0
		Declare list_tit(uCols),list_cam(uCols),list_tam(uCols),list_pic(uCols),list_valid(uCols),list_ronly(uCols),list_rot(uCols),list_combo(uCols)
		uCol = uCol + 1
		list_tit(uCol)="Seleccionar"
		list_cam(uCol)="uCurFi.selec"
		list_tam(uCol)=10*8
		list_pic(uCol)='LOGIC'
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.F.
		list_combo(uCol)=''
		uCol = uCol + 1
		list_tit(uCol)="Referência"
		list_cam(uCol)="uCurFi.ref"
		list_tam(uCol)=18*8
		list_pic(uCol)=''
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.T.
		list_combo(uCol)=''
		uCol = uCol + 1
		list_tit(uCol)="Designação"
		list_cam(uCol)="uCurFi.design"
		list_tam(uCol)=30*8
		list_pic(uCol)=''
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.T.
		list_combo(uCol)=''
		uCol = uCol + 1
		list_tit(uCol)="Qtt"
		list_cam(uCol)="uCurFi.qtt"
		list_tam(uCol)=10*8
		list_pic(uCol)='999,999,999.999'
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.F.
		list_combo(uCol)=''
		uCol = uCol + 1
		list_tit(uCol)="Fornecedor"
		list_cam(uCol)="uCurFi.fornecedor"
		list_tam(uCol)=30*8
		list_pic(uCol)=''
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.T.
		list_combo(uCol)=''
		uCol = uCol + 1
		list_tit(uCol)="Tipo artigo"
		list_cam(uCol)="uCurFi.u_tpart"
		list_tam(uCol)=20*8
		list_pic(uCol)=''
		list_valid(uCol)=''
		list_rot(uCol)=''
		list_ronly(uCol)=.T.
		list_combo(uCol)=''

		m.escolheu =.F.
		** Chamamos o browlist
		browlist('Escolha do(s) artigo(s)','uCurFi','uCurFi',.T.,.F.,.F.,.T.,.F.,'',.T.,.T.)
		If !m.escolheu
			Msg("Cancelado pelo utilizador!!")
			Return
		Endif
		Select uCurFi
		Go Top
		Do While !Eof()
			If uCurFi.Selec
				Select u_scl
				Append Blank
				Replace u_scl.u_sclstamp With u_stamp()
				Replace u_scl.u_scstamp With u_sc.u_scstamp
				Replace u_scl.ref With uCurFi.ref
				Replace u_scl.Design With uCurFi.Design
				Replace u_scl.qtt With uCurFi.qtt 
				Replace u_scl.usr1 With uCurFi.usr1
				Replace u_scl.fornec With uCurFi.fornec
				Replace u_scl.fornecedor With uCurFi.fornecedor
				Replace u_scl.tpart With uCurFi.u_tpart
				Replace u_scl.estado With "PENDENTE"
				Replace u_scl.Data With Date()
				Replace u_scl.us With m_chnome
				Replace u_scl.ousrdata With Date()
				Replace u_scl.ousrhora With Time()
				Replace u_scl.ousrinis With m_chinis
				Replace u_scl.usrdata With Date()
				Replace u_scl.usrhora With Time()
				Replace u_scl.usrinis With m_chinis
			Endif
			Select uCurFi
			Skip
		Enddo
	Endif
Endif