Local lista[1]
If bo.ndos=924
    Select bi
    u_sqlexec("SELECT bi.ref,bi.tabiva FROM bi (nolock) where bi.bostamp=?bo.bostamp and  bi.tabiva!=2 and bi.tabiva!=3","tsc")
    lista=""
    If Reccount("tsc")>0
        Select tsc
        Go Top
        Scan
            lista=lista+tsc.ref
        Endscan
        r=pergunta("Estes artigos na linha : "+Chr(13)+lista+" encontram-se  sem IVA, deseja continuar ?")
        If r=.T.
            Return .T.
        Else
            Return .F.
        Endif
    Else
 
    Endif
 
Endif
sbo.Refresh