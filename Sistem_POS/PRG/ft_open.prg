*!*	select max(idft) as numero FROM FT INTO CURSOR ftfno
*!*	select ftfno 
*!*	ultimo=ftfno.numero
*!*	USE 
*!*	select ft
*!*	APPEND BLANK
*!*	GO BOTTOM 
*!*	REPLACE FNO WITH ultimo+1
*!*	REPLACE nome WITH 'Consumidor final'

*!*	IF !empty(fi.ref)
*!*	m=messagebox("Deseja eliminar este artigo ?"+fi.ref,4+64,"Atencão")
*!*	DO CASE  
*!*		CASE m =6
*!*		DELETE 
*!*		*=tableupdate(.T.,.T.,"FI")
*!*		
*!*		OTHERWISE 
*!*			RETURN .F.
*!*	ENDCASE 
*!*	ENDIF 

CLEAR 

*DISPLAY PROCEDURES
* DELETE TRIGGER ON ft FOR INSERT 

* an.codigo

*CREATE TRIGGER ON fi FOR INSERT AS _stqtt

*PROCEDURE _stqtt 
*UPDATE ST SET STSAIDA=STSAIDA+fi.QTT,ST.STOCK=(ST.STOCK-fi.QTT )WHERE ST.REF=fi.REF

*RETURN .t. 
*ENDPROC 
****GRAVAR OS ARTIGOS
select fN 
GO TOP 
SCAN 

*CREATE TRIGGER ON fn FOR INSERT AS _stinsert_fn

*PROCEDURE _st_compra
*UPDATE ST SET STSAIDA=STSAIDA+fi.QTT,ST.STOCK=(ST.STOCK-fi.QTT );
WHERE ST.REF=fi.REF

UPDATE ST SET ST.STOCK=(ST.STOCK+fn.Qtt),st.Taixaiva=fn.Taxaiva,st.Unidade=fn.Unidade,st.Expira=fn.Dtvalidade, ;
st.Qttc =(st.Qttc+fn.Qttc),st.codigo=fn.codigo,st.Stentrada=fn.Qtt,st.Dtentrada=date(),st.Pvcompra=fn.pv ;
WHERE ST.REF=fN.REF
ENDSCAN 
tableupdate(.T.,.T.,"FN")
RETURN .t. 
