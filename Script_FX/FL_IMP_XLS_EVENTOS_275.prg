CREATE CURSOR xresults (no n(10), nome c(65),  documento c(20) , nrdoc n(10), datalc d(8), dataven d(8), valor n(15,2) )
create cursor c_erros (obs c(100)) 
 


gcTable=GETFILE('XLS', 'Procurar ficheiro com a extensão .XLS:', 'Procurar', 0, 'Procurar')
if  'Untitled' $ gcTable or   EMPTY(gcTable)
	msg("Ficheiro Invalido.")
	fecha("sqltmp")
	return  
endif   



SELECT xresults
APPEND FROM (gcTable) for valor <> 0 XL5


SELECT  xresults 
SELECT  distinct no , nome,  0  nophc, 0 phcestab  FROM xresults INTO CURSOR c_temp READWRITE  
 
SCAN FOR  NOT EMPTY(xresults.no)
	TEXT TO msel NOSHOW TEXTMERGE
		SELECT  no , estab, nome FROM FL (nolock) WHERE no = <<c_temp.no>>
	ENDTEXT

	IF NOT  u_sqlexec(msel,"c_FL")
		msg(msel)
		RETURN  
	ENDIF  
	SELECT c_FL
	IF  RECCOUNT("c_FL") = 0 
		SELECT  c_erros
		APPEND  blank
		replace c_erros.obs WITH  'O Fornecedor nº ' + astr(c_temp.no) + " - " + ALLTRIM(c_temp.nome) + " não existe" 
	ELSE  
		SELECT c_temp 
		replace c_temp.nophc  WITH  c_FL.no 
		replace c_temp.phcestab WITH c_FL.estab   
		replace c_temp.nome WITH c_FL.nome    
	ENDIF  
ENDSCAN 

SELECT c_erros
IF  RECCOUNT("c_erros") > 0 
	msg("Fornecedores que não existem.")
	mostrameisto("c_erros")
	fecha("c_erros") 
	fecha("xresults")
	RETURN 
ENDIF 

SELECT  xresults 
SCAN
	SELECT  c_temp
	LOCATE FOR c_temp.no =  xresults.no 
	IF  FOUND()
		SELECT  xresults
		replace xresults.no WITH  c_temp.nophc
		replace xresults.nome WITH  c_temp.nome	
	ENDIF 
ENDSCAN

SELECT  xresults
mostrameisto("xresults")

IF not  pergunta("Pretende importar as contas corrente")
	msg("Operação  cancelada")
	RETURN  
endif 

mntotal =  reccount("xresults")
regua(0,mntotal,"A processar registo")



SELECT  xresults
SCAN 
	regua[1,recno(),"Processando registos"]
	TEXT TO msel NOSHOW TEXTMERGE
 		insert into fc
		(fcstamp, datalc, dataven , cmdesc, adoc
		, edeb, ecred, deb, cred
		, nome, moeda, no, cm,  origem  , pais, obs, ousrinis,ousrdata,ousrhora,usrinis,usrdata,usrhora, u_estab)
		values 
		 ('<<u_stamp()>>'
			, '<<DTOS(xresults.datalc)>>'
			, '<<DTOS(xresults.dataven)>>' 
			, '<<xresults.documento>>'
			, <<xresults.nrdoc>>
		 	, <<adec_tr(IIF(xresults.valor<0,xresults.valor,0))>>
		 	, <<adec_tr(IIF(xresults.valor>0,ABS(xresults.valor),0))>>
		 	, <<adec_tr(IIF(xresults.valor<0,xresults.valor,0))>>
			, <<adec_tr(IIF(xresults.valor>0,ABS(xresults.valor),0))>>		 
			, '<<xresults.nome>>'
			, 'AKZ'
			, <<xresults.no>>
			, <<adec_tr(IIF(xresults.valor>0,124,125))>> 
			,  'FC'  
			, 1
			, 'Saldos Iniciais'
			, '<<m.m_chinis>>', '<<DTOS(DATE())>>', '<<TIME()>>','<<m.m_chinis>>', '<<DTOS(DATE())>>', '<<TIME()>>'
			, <<p_estab>>
			) 
	ENDTEXT
	IF  NOT u_sqlexec(msel)
		msg(msel)
		RETURN  
	ENDIF  
	
ENDSCAN
regua(2)

fecha("c_temp")
fecha("xresults")
msg("Documentos Importados")