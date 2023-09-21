** Criado por Joaquim Campos
** Data da Cria��o: 31-07-2023
** Tecla para Criar Ficheiro XML

Local ldir,xNomeFile,Xfile,lcXML
m.ldir = Getdir("C:\","Escolher uma Directoria","Directoria(s)",0,.F.)
If Empty(m.ldir)
	mensagem("Desculpe, n�o foi escolhida nenhuma directoria")
Else
	Select '' As ref,'MONDEGO - COM�RCIO INTERNACIONAL, LDA ' As Design,3 As qtt,'Un' As Unidade,0 As pvuni,0 iva,0 as tabiva From Ft Union All ;
	SELECT fi.ref, fi.Design,fi.qtt ,fi.unidade ,fi.epv ,fi.iva ,fi.tabiva  From FI Into Cursor xmlbo

  **** GRAVAR FICHEIRO NA DIRETORIA ****
	xNomeFile = alltrim(ft.nmdoc)+"_"+alltrim(STR(ft.fno))+"_"+alltrim(STR(ft.ftano))
	Xfile =xNomeFile+".XML"
	Set Default To ALLTRIM(ldir)
	=Cursortoxml("xmlbo", "fatura", 1, 8, 0)
	Strtofile(fatura,Xfile)
	msg("Dados Exportado com Sucesso...")
Endif