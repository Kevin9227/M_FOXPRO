
ddata =  DATE()
ddata = getnome("Introduza a data",ddata)
if p_estab =  1 
	cdb = "polluxpos.."
else  
	cdb = ""
endif  
TEXT TO msel NOSHOW TEXTMERGE
	select convert(bit,0) sel,   cxstamp, site , pnome, ausername, dabrir, habrir 
	from <<alltrim(cdb)>>cx  (nolock)
	where  dabrir  = '<<DTOS(ddata)>>'
	and  cxstamp not  in (select  cxstamp  from u_caixa)
ENDTEXT

IF NOT  u_sqlexec(msel,"c_cxt")
	msg(msel)
	RETURN 
ENDIF  
var_i = 6
DECLARE list_tit(var_i),list_cam(var_i),list_pic(var_i),list_tam(var_i),list_ronly(var_i), list_pic(var_i), list_combo(var_i) ,list_rot(var_i)
** Agora preenchemos os Arrays
var_i = 1    
list_tit(var_i)="sel?"
list_cam(var_i)="c_cxt.sel"
list_pic(var_i)="LOGIC"
list_tam(var_i)=8*8
list_ronly(var_i)=.f.
var_i = var_i +1 
list_tit(var_i)="Loja"
list_cam(var_i)="c_cxt.site"
list_pic(var_i)=""
list_tam(var_i)=8*50
list_ronly(var_i)=.t.
var_i = var_i +1 
list_tit(var_i)="Caixa"
list_cam(var_i)="c_cxt.pnome"
list_pic(var_i)=""
list_tam(var_i)=8*50
list_ronly(var_i)=.t.
var_i = var_i +1 
list_tit(var_i)="Utilizador"
list_cam(var_i)="c_cxt.ausername"
list_pic(var_i)=""
list_tam(var_i)=8*50
list_ronly(var_i)=.t.
var_i = var_i +1 
list_tit(var_i)="Data"
list_cam(var_i)="c_cxt.dabrir"
list_pic(var_i)=""
list_tam(var_i)=8*50
list_ronly(var_i)=.t.
var_i = var_i +1 
list_tit(var_i)="Hora"
list_cam(var_i)="c_cxt.habrir"
list_pic(var_i)=""
list_tam(var_i)=8*50
list_ronly(var_i)=.t.
=CURSORSETPROP('Buffering',5,"c_cxt")	
m.escolheu = .f. 
browlist("Caixa","c_cxt","c_cxtbrow",.T.,.F.,.T.,.T.,.F.,'',.t.,.t.)
IF m.escolheu = .f. 
	msg("Operação cancelada")
	RETURN  
ENDIF  
ccxstamp  = ''
SELECT c_cxt
SCAN FOR  c_cxt.sel = .t. 
	ccxstamp = c_cxt.cxstamp
ENDSCAN  
fecha("c_cxt")
IF  EMPTY(ccxstamp )
	msg("Operação cancelada")
	RETURN 
ENDIF 
TEXT TO msel NOSHOW TEXTMERGE
	SELECT TOP 1 * FROM <<alltrim(cdb)>>fcx(nolock) WHERE cxstamp = '<<ccxstamp>>'
ENDTEXT
u_sqlexec(msel,"c_fcx")
SELECT  c_fcx
npno = c_fcx.pno  
csite = c_fcx.site
cpnome = c_fcx.pnome
fecha("c_fcx")
*IF  upper(CPNOME)  <> 'CAIXA21'
*	RETURN  
*ENDIF  
TEXT TO msel NOSHOW TEXTMERGE
	SELECT TOP 1 * FROM <<alltrim(cdb)>>cx(nolock) WHERE cxstamp = '<<ccxstamp>>'
ENDTEXT
u_sqlexec(msel,"c_cx1")
ccxusername = c_cx1.fusername 
fecha("c_cx1")
	
	usrform("ADM05081261391,906940272")
	TEXT TO  msel NOSHOW TEXTMERGE
		SELECT  u_caixastamp FROM  u_caixa (nolock)
		where u_caixastamp = '<<ccxstamp>>'
	ENDTEXT
	IF NOT  u_sqlexec(msel,"c_cx")
		msg(msel)
		RETURN 
	ENDIF 
	IF RECCOUNT("c_cx") = 0   
		su_caixa.dointroduzir()
		SELECT u_caixa  
		replace  u_caixa.u_caixastamp  WITH  ccxstamp
		replace  u_caixa.cxstamp  WITH  ccxstamp
		replace u_caixa.pno  WITH  npno  
		replace u_caixa.site  WITH  csite
		replace u_caixa.pnome  WITH  cpnome
		replace u_caixa.data  WITH  ddata
		replace u_caixa.cxusername	WITH  ccxusername 
		** preenche o piso  
		if p_estab = 1
			cpiso = ''  
			if  LIKE('*HOT*',upper(cpnome))
				cpiso = 'HOTELARIA'
			else 
				cpiso = 'PISO ' + SUBSTR(cpnome,6,1)
			endif  
			select u_caixa 
			Replace u_caixa.piso With  cpiso 
		endif  
		
		
		** preenche o fundo maneio  
		TEXT TO msel NOSHOW TEXTMERGE
			SELECT efundocx, fcxstamp, POS.IDUCPVAZIO  
			 FROM <<alltrim(cdb)>>fcx (nolock)
			inner  join <<alltrim(cdb)>>pos (nolock)  on  fcx.pnome  =  pos.pnome  and  fcx.site  = pos.site  and  fcx.pno = pos.pno    
			where  fcx.cxstamp = '<<ccxstamp>>' and operacao = 'A'
		ENDTEXT
		IF NOT  u_sqlexec(msel,"c_cxf")
			msg(msel)
			RETURN 
		ENDIF  
		SELECT  c_cxf
		IF  RECCOUNT("c_cxf") > 0 
			SELECT  u_caixa
		*	replace  u_caixa.maneio  WITH  c_cxf.efundocx
			replace  u_caixa.multibanco  WITH  c_cxf.IDUCPVAZIO  
		ENDIF 
		fecha("c_cxf") 
	ELSE  
		navega("u_caixa",ccxstamp)
	ENDIF 
	su_caixa.refresh()
	fecha("c_cx") 
SU_CAIXA.Pageframe1.udcPage5.setfocus()
SU_CAIXA.Painelfundo.Page1.Btnfolhacx.visible = .f.
