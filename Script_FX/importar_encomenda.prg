**********************************
** Importação de encomendas
**********************************
If bo.ndos!=1 And bo.ndos!=3
    Return
Endif
If Empty(bo.no)
    msg("Tem que selecionar o cliente primeiro!")
    Return
Endif
m_file=Getfile("XLS","Ficheiro","Escolher",0,"Seleccione o Ficheiro a Importar")
If Type("m_file")<>"C" Or Not File(m_file)
    Messagebox("Ficheiro Não Encontrado")
    Return
Endif
Create Cursor nexiste(refg c(40), refc c(40), ean c(40), qtd N(4,0))
Create Cursor ARTIGO (refg c(40), refc c(40), ean c(40), qtd N(4,0))
Set Point To "."
Append From (m_file) Xls
Select ARTIGO
 
Select bi
Delete
**
** Verifica se tem tabela de preços
**
If u_sqlexec("select * from bo (nolock) where bo.no=?bo.no and bo.ndos=100","curtp") And Reccount("curtp")>0
    temtab=1
Else
    temtab=0
Endif
Select ARTIGO
Go Top
regua(0,Reccount(),"A importar artigos...")
Scan
    **
    refx=''
    If Empty(ARTIGO.refg)=.F.
        If Val(ARTIGO.refg)>0
            refx=ARTIGO.refg
            If Len(Alltrim(ARTIGO.refg))=1
                refx='00000'+Alltrim(ARTIGO.refg)
            Endif
            If Len(Alltrim(ARTIGO.refg))=2
                refx='0000'+Alltrim(ARTIGO.refg)
            Endif
            If Len(Alltrim(ARTIGO.refg))=3
                refx='000'+Alltrim(ARTIGO.refg)
            Endif
            If Len(Alltrim(ARTIGO.refg))=4
                refx='00'+Alltrim(ARTIGO.refg)
            Endif
            If Len(Alltrim(ARTIGO.refg))=5
                refx='0'+Alltrim(ARTIGO.refg)
            Endif
        Else
            refx=ARTIGO.refg
        Endif
    Else
        **
        ** Se Referencia Gumasa a Branco, fica com a referencia de cliente
        **
        refx=Iif(!Empty(ARTIGO.refc),Alltrim(ARTIGO.refc),Alltrim(ARTIGO.ean))
    Endif
    **
    regua[1,recno(),"A processar o artigo  "+alltrim(astr(refx))+"."]
    If !Empty(refx) And refx!="Ref.Gumasa"
        If temtab=1
            TEXT to msel noshow textmerge
    select st.ref from st left join bc on st.ststamp=bc.ststamp left join bi on bi.ref=st.ref and bi.no=<<bo.no>> and bi.ndos=100 where st.ref='<<refx>>' or st.codigo='<<refx>>' or bi.codigo='<<refx>>' or bc.codigo='<<refx>>' or bi.forref='<<refx>>'
            ENDTEXT
        Else
            TEXT to msel noshow textmerge
    select st.ref from st left join bc on st.ststamp=bc.ststamp where st.ref='<<refx>>' or st.codigo='<<refx>>' or bc.codigo='<<refx>>'
            ENDTEXT
        Endif
 
        If u_sqlexec(msel,"crsst") And Reccount("crsst")>0
            insere_bi()
        Else
            Select nexiste
            Append Blank
            Replace nexiste.refg With ARTIGO.refg
            Replace nexiste.refc With ARTIGO.refc
            Replace nexiste.ean With ARTIGO.ean
            Replace nexiste.qtd With ARTIGO.qtd
            Select ARTIGO
        Endif
    Endif
Endscan
regua(2)
 
Do botots With .T.
If Reccount("nexiste")>0
    mostrameisto("nexiste")
Endif
Set Point To se_pointer
 
Function insere_bi
    Select bi
    Go Bottom
    Do boine2in
    Replace bi.ref With Alltrim(Upper(refx))
    Do tsread With '', bo.ndos
    Do boactref With '', .T., 'OKPRECOS', 'bi'
    fecha("curconv")
    u_sqlexec("select isnull(conversao,0) conv from st where st.ref=?bi.ref","curconv")
    Replace bi.qtt With Round(ARTIGO.qtd*(1/curconv.Conv),1)
    Replace bi.uni2qtt With ARTIGO.qtd
    Replace bi.stipo With 4
    Replace bi.forref With Alltrim(Upper(ARTIGO.refc))
    Do u_bottdeb With 'bi'
Endfunc