**STOCK

local w_date

m_file=Getfile("XLS","Ficheiro","Escolher",0,"Seleccione o ficheiro a importar")
if type("m_file")<>"C" or not file(m_file)
	messagebox("Ficheiro não encontrado !")
	return
endif

create cursor CONVSTK1(ref c(18), design c(60), STOCK n(18), armazem n(5))


create cursor meus_erros(ref c(18), design c(60))

set point to "."
select CONVSTK1
append from (m_file) XLS

select CONVSTK1
*go top
*mostrameisto("CONVSTK1")
*return 
scan
**if convstk1.no<>'no' then

do dbfusest
select stil
IF ALLTRIM(upper(CONVSTK1.REF)) <> 'REF'
	append blank
	replace stil.stilstamp with u_stamp(recno("convstk1"))
	replace stil.ref with convstk1.ref
	replace stil.design with convstk1.design
	replace stil.stock with convstk1.stock
        replace stil.armazem with convstk1.armazem
	
ENDIF


Wait window "A processar o Artigo "+convstk1.ref NoWait

if not u_tabupdate (.t.,.t.,"STIL")
	msg("Não consegui inserir o artigo "+convstk1.ref)
	Select meus_erros
	append blank
	replace meus_erros.ref with convstk1.ref
	replace meus_erros.design with convstk1.design
	tablerevert(.t.,"STIL")
	**messagebox("Não foi possível inserir os Artigos "+alltrim(upper(convstk1.ref)))
endif
**endif

select CONVSTK1
endscan

messagebox("Inserção de Artigos terminada.")

If pergunta("deseja visualizar a lista de erros")
	mostrameisto("meus_erros")
EndIf
