m_file=Getfile("XLS","Ficheiro","Escolher",0,"Seleccione o Ficheiro a Importar")    
  
If Type("m_file")<>"C" Or Not File(m_file)   
	Messagebox("Ficheiro N�o Encontrado")   
	Return  
Endif    
Create cursor ARTIGO (ref C(18), design C(60), epv1 N(16,6),stock I(4),codigo C(30))  
set point to "."  
APPEND FROM (m_file) XLS  
select artigo  
BROWSE 

go top    
WAIT "A importar artigos... "+CAST(reccount() as varchar(115)) WINDOW TIMEOUT 2
Scan   
	WAIT  "A processar o artigo  "+alltrim(cast(artigo.ref as varchar(115)))+"."+cast(recno() as varchar(115)) WINDOWS TIMEOUT 1
	if !empty(artigo.ref) and artigo.ref!="codigo" 
		select * from st where st.ref=?artigo.ref INTO CURSOR  crsst    
		if  RECCOUNT("crsst") > 0      
			select crsst     
			** Actualiza��o dos dados principais da ficha do artigo     
			text to msel noshow textmerge       				
				update st 
				set    
					design=replace(?artigo.design,'*',''),  
					epv1=?artigo.epv1,
					stock=?artio.stock
				where ref=ltrim(rtrim(?artigo.ref))     
			endtext     
			*sqlexec(msel)    
		else     
			SELECT st 
			GO BOTTOM    
			Append blank     
			replace st.ref with alltrim(upper(artigo.ref))       			
*			replace st.familia   with alltrim(artigo.grupo)+alltrim(artigo.familia)     			
			replace st.descri  with alltrim(strtran(artigo.design,'*',''))     
			replace st.pv1   with artigo.epv1   
			replace st.stock  with artigo.stock  
			replace st.codigo 	WITH artigo.codigo
			     			
			if !TABLEUPDATE(.t.,.t.,"ST")      
				Tablerevert(.t.,"ST")      
				Messagebox("N�o foi poss�vel inserir o artigo "+alltrim(upper(artigo.ref)))      
				return     
*!*				else      
*!*	     					
*!*						Messagebox("N�o foi poss�vel inserir as observa��es do artigo "+alltrim(upper(artigo.ref)))       								
*!*						Messagebox(artigo.ref)       					
*!*						*return .t.     
				EndIf     
			endif    
		endif   

endscan  
reccount(2)    
*u_sqlexec("update stobs set motiseimp = descricao from stobs inner join miseimp on stobs.codmotiseimp = miseimp.codigo")    
set point to  