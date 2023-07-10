Declare Integer DeleteUrlCacheEntry In wininet String lpszUrlName

Local loXMLHTTP As MSXML2.XMLHTTP
#Define clAsync .F.
#Define ccCRLF Chr(13)+Chr(10)
#Define ccTAB Chr(9)

m_Status = 0
m_Response = ''

fecha("curpar")
u_sqlexec("select u_idcli, u_idloja from e1 where estab = 0", "curpar")
If Reccount("curpar")<1 Or Empty(curpar.u_idcli)
	msg("Não estão definidos os parametros na ficha da empresa!")
	Return
Endif

idcl=curpar.u_idcli

*****************************************
** Ver quais as lojas
*****************************************
m_Url="https://ncsync.novoscanais.com/"+Alltrim(idcl)+"/getStores"

*******************************************************************************
** Limpar Cache
*******************************************************************************
DeleteUrlCacheEntry(m_Url)

loXMLHTTP = Createobject( "Microsoft.XMLHTTP" )
loXMLHTTP.Open( "GET", m_Url, clAsync )
**loXMLHTTP.setRequestHeader("content-type", "multipart/form-data; boundary=" +boundary)
**loXMLHTTP.setRequestHeader("Content-Type", "application/json")
loXMLHTTP.Send()

Do While loXMLHTTP.readyState <>4
	DoEvents Force && when using VFP9
Enddo
m_Response = Alltrim(Left(loXMLHTTP.responseText,5000))
m_Status = loXMLHTTP.Status									&& 200 means ok, 404 not found etc. http status numbers see wikipedia, w3c, google them, etc.

*msg(astr(m_status))
If m_Status<>200
	msg(m_Response)
	Return
Endif

Strtofile(m_Response,"respcsv.csv",0)

Alines(arrayini,m_Response)

lin1=(arrayini[1])
lin_aux = Strtran( lin1, ["], [] )
lin_aux = Strtran( lin_aux, [.], [] )

Alines(arrayflds,lin_aux,",")

lnFlds=Alen(arrayflds)

xcrec=''
For i=1 To lnFlds
	xcrec=xcrec+Alltrim(arrayflds[i])+" c(254),"
Next i

xcrecf=Left(xcrec,Len(xcrec)-1)
xcrec="("+xcrecf+")"
Create Cursor xresp &xcrec
Append From respcsv.Csv Type Csv
xrec=Reccount("xresp")

Create Cursor xVars ( no N(5), tipo c(1), Nome c(40), Pict c(100), lOrdem N(10), nValor N(18,5), cValor c(100), lValor l, dValor d, tBval M)
x=1
Select xresp
Scan
	Select xVars
	Append Blank
	Replace xVars.no With Val(xresp.Id)
	Replace xVars.tipo With "L"
	Replace xVars.Nome With xresp.Name
	Replace xVars.lValor With .T.
	Replace xVars.lOrdem With x
	x=x+1
Endscan

m.Escolheu = .F.
m.mCaption = "Escolha a(s) loja(s) para ver stock do artigo "+Alltrim(st.ref)
docomando("do form usqlvar with 'xvars',m.mCaption,.t.")

If m.Escolheu=.F.
	Return
Else
	idlj=''
	Select xVars
	Go Top
	Scan
		If xVars.lValor=.T.
			idlj=idlj+Alltrim(Str(xVars.no))+','
		Endif
	Endscan

	If Empty(idlj)
		msg("Não escolheu nenuma loja. Não posso continuar!")
		Return
	Endif
Endif

idlj=Left(idlj,Len(idlj)-1)

*****************************************
** Ver stocks das lojas
*****************************************

m_Url="https://ncsync.novoscanais.com/"+Alltrim(idcl)+"/getStockByStore/"+Alltrim(idlj)+"/"+Alltrim(st.ref)

*msg(m_Url)

*******************************************************************************
** Limpar Cache
*******************************************************************************
DeleteUrlCacheEntry(m_Url)

loXMLHTTP = Createobject( "Microsoft.XMLHTTP" )
loXMLHTTP.Open( "GET", m_Url, clAsync )
**loXMLHTTP.setRequestHeader("content-type", "multipart/form-data; boundary=" +boundary)
**loXMLHTTP.setRequestHeader("Content-Type", "application/json")
loXMLHTTP.Send()

Do While loXMLHTTP.readyState <>4
	DoEvents Force && when using VFP9
Enddo
m_Response = Alltrim(Left(loXMLHTTP.responseText,5000))
m_Status = loXMLHTTP.Status									&& 200 means ok, 404 not found etc. http status numbers see wikipedia, w3c, google them, etc.

*msg(astr(m_Status))
*msg(m_Response)

Strtofile(m_Response,"respcsv.csv",0)

Alines(arrayini,m_Response)

lin1=(arrayini[1])
lin_aux = Strtran( lin1, ["], [] )
lin_aux = Strtran( lin_aux, [.], [] )

Alines(arrayflds,lin_aux,",")

lnFlds=Alen(arrayflds)

xcrec=''
For i=1 To lnFlds
	xcrec=xcrec+Alltrim(arrayflds[i])+" c(254),"
Next i

xcrecf=Left(xcrec,Len(xcrec)-1)
xcrec="("+xcrecf+")"
Create Cursor xresp &xcrec
Append From respcsv.Csv Type Csv

If m_Status=200
	x2=0
	T=4
	Declare list_tit(T),list_cam(T),list_pic(T),list_tam(T),list_ali(T),list_ronly(T), list_rot(T),list_DyCurrControl(T)
	x2=x2+1
	list_tit(x2) = "Loja"
	list_cam(x2) = "xresp.storename"
	list_pic(x2) = ""
	list_tam(x2) = 8*10
	list_ronly(x2)=.F.

	x2=x2+1
	list_tit(x2) = "Nr. Armazem"
	list_cam(x2) = "xresp.whsnumber"
	list_pic(x2) = ""
	list_tam(x2) = 8*10
	list_ronly(x2)=.T.

	x2=x2+1
	list_tit(x2) = "Nome Armazem"
	list_cam(x2) = "xresp.whsname"
	list_pic(x2) = ""
	list_tam(x2) = 8*15
	list_ronly(x2)=.T.

	x2=x2+1
	list_tit(x2) = "Stock"
	list_cam(x2) = "xresp.stock"
	list_pic(x2) = ""
	list_tam(x2) = 8*10
	list_DyCurrControl(x2)="CheckColor()"
	list_ronly(x2)=.T.


	browlist('Consulta de Stock','xresp','xresp',.F.,.F.,.F.,.T.,.F.,'',.T.,,,,,,.T.,)
Else
	msg(astr(m_Status))
	msg(m_Response)
Endif



Procedure CheckColor()
	Lparameters oGrid, nPos, cValue

	browlist.Grid1.SetAll("DynamicBackColor",'iif(AT("NÃO",upper(xresp.stock))>0, RGB(255,136,136),iif(val(xresp.stock)=0,RGB(255,136,136),RGB(150,255,150)))',"Column")

	*	Return .T.
Endproc
