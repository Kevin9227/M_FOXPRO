**
DEFINE CLASS registry AS custom
 nuserkey = -2147483647
 cvfpoptpath = ""
 cregdllfile = ""
 cinidllfile = ""
 codbcdllfile = ""
 ncurrentos = 0
 ncurrentkey = 0
 lloadeddlls = .F.
 lloadedinis = .F.
 lloadedodbcs = .F.
 capppathkey = ""
 lcreatekey = .F.
 lhaderror = .F.
**
   FUNCTION Init
    this.cvfpoptpath = "Software\Microsoft\VisualFoxPro\"+_VFP.version+"\Options"
    DO CASE
       CASE _DOS .OR. _UNIX .OR. _MAC
          RETURN .F.
       CASE ATC("Windows 3", OS(1))<>0
          this.ncurrentos = 1
          this.cregdllfile = "W32SCOMB.DLL"
          this.cinidllfile = "W32SCOMB.DLL"
          this.codbcdllfile = "ODBC32.DLL"
          this.nuserkey = -2147483648 
       CASE ATC("Windows NT", OS(1))<>0
          this.ncurrentos = 2
          this.cregdllfile = "ADVAPI32.DLL"
          this.cinidllfile = "KERNEL32.DLL"
          this.codbcdllfile = "ODBC32.DLL"
       OTHERWISE
          this.ncurrentos = 3
          this.cregdllfile = "ADVAPI32.DLL"
          this.cinidllfile = "KERNEL32.DLL"
          this.codbcdllfile = "ODBC32.DLL"
    ENDCASE
   ENDFUNC
**
   PROCEDURE Error
    LPARAMETERS nerror, cmethod, nline
    this.lhaderror = .T.
    = MESSAGEBOX(MESSAGE())
   ENDPROC
**
   FUNCTION LoadRegFuncs
    LOCAL nhkey, csubkey, nresult
    LOCAL hkey, ivalue, lpszvalue, lpcchvalue, lpdwtype, lpbdata, lpcbdata
    LOCAL lpcstr, lpszval, nlen, lpdwreserved
    LOCAL lpszvaluename, dwreserved, fdwtype
    LOCAL isubkey, lpszname, cchname
    IF this.lloadeddlls
       RETURN 0
    ENDIF
    DECLARE INTEGER RegOpenKey IN Win32API INTEGER, STRING @, INTEGER @
    IF this.lhaderror
       RETURN -1
    ENDIF
    DECLARE INTEGER RegCreateKey IN Win32API INTEGER, STRING @, INTEGER @
    DECLARE INTEGER RegDeleteKey IN Win32API INTEGER, STRING @
    DECLARE INTEGER RegDeleteValue IN Win32API INTEGER, STRING
    DECLARE INTEGER RegCloseKey IN Win32API INTEGER
    DECLARE INTEGER RegSetValueEx IN Win32API INTEGER, STRING, INTEGER, INTEGER, STRING, INTEGER
    DECLARE INTEGER RegQueryValueEx IN Win32API INTEGER, STRING, INTEGER, INTEGER @, STRING @, INTEGER @
    DECLARE INTEGER RegEnumKey IN Win32API INTEGER, INTEGER, STRING @, INTEGER @
    DECLARE INTEGER RegEnumKeyEx IN Win32API INTEGER, INTEGER, STRING @, INTEGER @, INTEGER, STRING @, INTEGER @, STRING @
    DECLARE INTEGER RegEnumValue IN Win32API INTEGER, INTEGER, STRING @, INTEGER @, INTEGER, INTEGER @, STRING @, INTEGER @
    this.lloadeddlls = .T.
    RETURN 0
   ENDFUNC
**
   FUNCTION OpenKey
    LPARAMETERS clookupkey, nregkey, lcreatekey
    LOCAL nsubkey, nerrcode, npcount, lsavecreatekey
    nsubkey = 0
    npcount = PARAMETERS()
    IF TYPE("m.nRegKey")<>"N" .OR. EMPTY(m.nregkey)
       m.nregkey = -2147483648 
    ENDIF
    nerrcode = this.loadregfuncs()
    IF m.nerrcode<>0
       RETURN m.nerrcode
    ENDIF
    lsavecreatekey = this.lcreatekey
    IF m.npcount>2 .AND. TYPE("m.lCreateKey")="L"
       this.lcreatekey = m.lcreatekey
    ENDIF
    IF this.lcreatekey
       nerrcode = regcreatekey(m.nregkey, m.clookupkey, @nsubkey)
    ELSE
       nerrcode = regopenkey(m.nregkey, m.clookupkey, @nsubkey)
    ENDIF
    this.lcreatekey = m.lsavecreatekey
    IF nerrcode<>0
       RETURN m.nerrcode
    ENDIF
    this.ncurrentkey = m.nsubkey
    RETURN 0
   ENDFUNC
**
   PROCEDURE CloseKey
    = regclosekey(this.ncurrentkey)
    this.ncurrentkey = 0
   ENDPROC
**
   FUNCTION SetRegKey
    LPARAMETERS coptname, coptval, ckeypath, nuserkey
    LOCAL ipos, coptkey, coption, nerrnum
    ipos = 0
    coption = ""
    nerrnum = 0
    m.nerrnum = this.openkey(m.ckeypath, m.nuserkey)
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    nerrnum = this.setkeyvalue(m.coptname, m.coptval)
    this.closekey()
    RETURN m.nerrnum
   ENDFUNC
**
   FUNCTION GetRegKey
    LPARAMETERS coptname, coptval, ckeypath, nuserkey
    LOCAL ipos, coptkey, coption, nerrnum
    ipos = 0
    coption = ""
    nerrnum = 0
    m.nerrnum = this.openkey(m.ckeypath, m.nuserkey)
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    nerrnum = this.getkeyvalue(coptname, @coptval)
    this.closekey()
    RETURN m.nerrnum
   ENDFUNC
**
   FUNCTION GetKeyValue
    LPARAMETERS cvaluename, ckeyvalue
    LOCAL lpdwreserved, lpdwtype, lpbdata, lpcbdata, nerrcode
    STORE 0 TO lpdwreserved, lpdwtype
    STORE SPACE(256) TO lpbdata
    STORE LEN(m.lpbdata) TO m.lpcbdata
    DO CASE
       CASE TYPE("THIS.nCurrentKey")<>'N' .OR. this.ncurrentkey=0
          RETURN -105
       CASE TYPE("m.cValueName")<>"C"
          RETURN -103
    ENDCASE
    m.nerrcode = regqueryvalueex(this.ncurrentkey, m.cvaluename, m.lpdwreserved, @lpdwtype, @lpbdata, @lpcbdata)
    IF m.nerrcode<>0
       RETURN m.nerrcode
    ENDIF
    IF lpdwtype<>1
       RETURN -106
    ENDIF
    m.ckeyvalue = LEFT(m.lpbdata, m.lpcbdata-1)
    RETURN 0
   ENDFUNC
**
   FUNCTION SetKeyValue
    LPARAMETERS cvaluename, cvalue
    LOCAL nvaluesize, nerrcode
    DO CASE
       CASE TYPE("THIS.nCurrentKey")<>'N' .OR. this.ncurrentkey=0
          RETURN -105
       CASE TYPE("m.cValueName")<>"C" .OR. TYPE("m.cValue")<>"C"
          RETURN -103
       CASE EMPTY(m.cvaluename) .OR. EMPTY(m.cvalue)
          RETURN -103
    ENDCASE
    cvalue = m.cvalue+CHR(0)
    nvaluesize = LEN(m.cvalue)
    m.nerrcode = regsetvalueex(this.ncurrentkey, m.cvaluename, 0, 1, m.cvalue, m.nvaluesize)
    IF m.nerrcode<>0
       RETURN m.nerrcode
    ENDIF
    RETURN 0
   ENDFUNC
**
   FUNCTION DeleteKey
    LPARAMETERS nuserkey, ckeypath
    LOCAL nerrnum
    nerrnum = 0
    m.nerrnum = regdeletekey(m.nuserkey, m.ckeypath)
    RETURN m.nerrnum
   ENDFUNC
**
   FUNCTION EnumOptions
    LPARAMETERS aregopts, coptpath, nuserkey, lenumkeys
    LOCAL ipos, coptkey, coption, nerrnum
    ipos = 0
    coption = ""
    nerrnum = 0
    IF PARAMETERS()<4 .OR. TYPE("m.lEnumKeys")<>"L"
       lenumkeys = .F.
    ENDIF
    m.nerrnum = this.openkey(m.coptpath, m.nuserkey)
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    IF m.lenumkeys
       nerrnum = this.enumkeys(@aregopts)
    ELSE
       nerrnum = this.enumkeyvalues(@aregopts)
    ENDIF
    this.closekey()
    RETURN m.nerrnum
   ENDFUNC
**
   FUNCTION IsKey
    LPARAMETERS ckeyname, nregkey
    nerrnum = this.openkey(m.ckeyname, m.nregkey)
    IF m.nerrnum=0
       this.closekey()
    ENDIF
    RETURN m.nerrnum=0
   ENDFUNC
**
   FUNCTION EnumKeys
    PARAMETER akeynames
    LOCAL nkeyentry, cnewkey, cnewsize, cbuf, nbuflen, crettime
    nkeyentry = 0
    DIMENSION akeynames[1]
    DO WHILE .T.
       nkeysize = 0
       cnewkey = SPACE(100)
       nkeysize = LEN(m.cnewkey)
       cbuf = SPACE(100)
       nbuflen = LEN(m.cbuf)
       crettime = SPACE(100)
       m.nerrcode = regenumkeyex(this.ncurrentkey, m.nkeyentry, @cnewkey, @nkeysize, 0, @cbuf, @nbuflen, @crettime)
       DO CASE
          CASE m.nerrcode=259
             EXIT
          CASE m.nerrcode<>0
             EXIT
       ENDCASE
       cnewkey = ALLTRIM(m.cnewkey)
       cnewkey = LEFT(m.cnewkey, LEN(m.cnewkey)-1)
       IF  .NOT. EMPTY(akeynames(1))
          DIMENSION akeynames[ALEN(akeynames)+1]
       ENDIF
       akeynames[ALEN(akeynames)] = m.cnewkey
       nkeyentry = m.nkeyentry+1
    ENDDO
    IF m.nerrcode=259 .AND. m.nkeyentry<>0
       m.nerrcode = 0
    ENDIF
    RETURN m.nerrcode
   ENDFUNC
**
   FUNCTION EnumKeyValues
    LPARAMETERS akeyvalues
    LOCAL lpszvalue, lpcchvalue, lpdwreserved
    LOCAL lpdwtype, lpbdata, lpcbdata
    LOCAL nerrcode, nkeyentry, larraypassed
    STORE 0 TO nkeyentry
    IF TYPE("THIS.nCurrentKey")<>'N' .OR. this.ncurrentkey=0
       RETURN -105
    ENDIF
    IF this.ncurrentos=1
       RETURN -107
    ENDIF
    DO WHILE .T.
       STORE 0 TO lpdwreserved, lpdwtype, nerrcode
       STORE SPACE(256) TO lpbdata, lpszvalue
       STORE LEN(lpbdata) TO m.lpcchvalue
       STORE LEN(lpszvalue) TO m.lpcbdata
       nerrcode = regenumvalue(this.ncurrentkey, m.nkeyentry, @lpszvalue, @lpcchvalue, m.lpdwreserved, @lpdwtype, @lpbdata, @lpcbdata)
       DO CASE
          CASE m.nerrcode=259
             EXIT
          CASE m.nerrcode<>0
             EXIT
       ENDCASE
       nkeyentry = m.nkeyentry+1
       DIMENSION akeyvalues[m.nkeyentry, 2]
       akeyvalues[m.nkeyentry, 1] = LEFT(m.lpszvalue, m.lpcchvalue)
       DO CASE
          CASE lpdwtype=1
             akeyvalues[m.nkeyentry, 2] = LEFT(m.lpbdata, m.lpcbdata-1)
          CASE lpdwtype=3
             akeyvalues[m.nkeyentry, 2] = "*Binary*"
          CASE lpdwtype=4
             akeyvalues[m.nkeyentry, 2] = LEFT(m.lpbdata, m.lpcbdata-1)
          OTHERWISE
             akeyvalues[m.nkeyentry, 2] = "*Unknown type*"
       ENDCASE
    ENDDO
    IF m.nerrcode=259 .AND. m.nkeyentry<>0
       m.nerrcode = 0
    ENDIF
    RETURN m.nerrcode
   ENDFUNC
**
ENDDEFINE
**
DEFINE CLASS oldinireg AS registry
**
   FUNCTION GetINISection
    PARAMETER asections, csection, cinifile
    LOCAL cinivalue, ntotentries, i, nlastpos
    cinivalue = ""
    IF TYPE("m.cINIFile")<>"C"
       cinifile = ""
    ENDIF
    IF this.getinientry(@cinivalue, csection, 0, m.cinifile)<>0
       RETURN -110
    ENDIF
    ntotentries = OCCURS(CHR(0), m.cinivalue)
    DIMENSION asections[m.ntotentries]
    nlastpos = 1
    FOR i = 1 TO m.ntotentries
       ntmppos = AT(CHR(0), m.cinivalue, m.i)
       asections[m.i] = SUBSTR(m.cinivalue, m.nlastpos, m.ntmppos-m.nlastpos)
       nlastpos = m.ntmppos+1
    ENDFOR
    RETURN 0
   ENDFUNC
**
   FUNCTION GetINIEntry
    LPARAMETERS cvalue, csection, centry, cinifile
    LOCAL cbuffer, nbufsize, nerrnum, ntotparms
    ntotparms = PARAMETERS()
    nerrnum = this.loadinifuncs()
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    IF m.ntotparms<3
       m.centry = 0
    ENDIF
    m.cbuffer = SPACE(2000)
    IF EMPTY(m.cinifile)
       m.nbufsize = getwinini(m.csection, m.centry, "", @cbuffer, LEN(m.cbuffer))
    ELSE
       m.nbufsize = getprivateini(m.csection, m.centry, "", @cbuffer, LEN(m.cbuffer), m.cinifile)
    ENDIF
    IF m.nbufsize=0
       RETURN -109
    ENDIF
    m.cvalue = LEFT(m.cbuffer, m.nbufsize)
    RETURN 0
   ENDFUNC
**
   FUNCTION WriteINIEntry
    LPARAMETERS cvalue, csection, centry, cinifile
    LOCAL nerrnum
    nerrnum = this.loadinifuncs()
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    IF EMPTY(m.cinifile)
       nerrnum = writewinini(m.csection, m.centry, m.cvalue)
    ELSE
       nerrnum = writeprivateini(m.csection, m.centry, m.cvalue, m.cinifile)
    ENDIF
    RETURN IIF(m.nerrnum=1, 0, m.nerrnum)
   ENDFUNC
**
   FUNCTION LoadINIFuncs
    IF this.lloadedinis
       RETURN 0
    ENDIF
    DECLARE INTEGER GetPrivateProfileString IN Win32API AS GetPrivateINI STRING, STRING, STRING, STRING, INTEGER, STRING
    IF this.lhaderror
       RETURN -1
    ENDIF
    DECLARE INTEGER GetProfileString IN Win32API AS GetWinINI STRING, STRING, STRING, STRING, INTEGER
    DECLARE INTEGER WriteProfileString IN Win32API AS WriteWinINI STRING, STRING, STRING
    DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivateINI STRING, STRING, STRING, STRING
    this.lloadedinis = .T.
    RETURN 0
   ENDFUNC
**
ENDDEFINE
**
DEFINE CLASS foxreg AS registry
**
   FUNCTION SetFoxOption
    LPARAMETERS coptname, coptval
    RETURN this.setregkey(coptname, coptval, this.cvfpoptpath, this.nuserkey)
   ENDFUNC
**
   FUNCTION GetFoxOption
    LPARAMETERS coptname, coptval
    RETURN this.getregkey(coptname, @coptval, this.cvfpoptpath, this.nuserkey)
   ENDFUNC
**
   FUNCTION EnumFoxOptions
    LPARAMETERS afoxopts
    RETURN this.enumoptions(@afoxopts, this.cvfpoptpath, this.nuserkey, .F.)
   ENDFUNC
**
ENDDEFINE
**
DEFINE CLASS odbcreg AS registry
**
   FUNCTION LoadODBCFuncs
    IF this.lloadedodbcs
       RETURN 0
    ENDIF
    IF EMPTY(this.codbcdllfile)
       RETURN -112
    ENDIF
    LOCAL henv, fdirection, szdriverdesc, cbdriverdescmax
    LOCAL pcbdriverdesc, szdriverattributes, cbdrvrattrmax, pcbdrvrattr
    LOCAL szdsn, cbdsnmax, pcbdsn, szdescription, cbdescriptionmax, pcbdescription
    DECLARE SHORT SQLDrivers IN (this.codbcdllfile) INTEGER, INTEGER, STRING @, INTEGER, INTEGER, STRING @, INTEGER, INTEGER
    IF this.lhaderror
       RETURN -1
    ENDIF
    DECLARE SHORT SQLDataSources IN (this.codbcdllfile) INTEGER, INTEGER, STRING @, INTEGER, INTEGER @, STRING @, INTEGER, INTEGER
    this.lloadedodbcs = .T.
    RETURN 0
   ENDFUNC
**
   FUNCTION GetODBCDrvrs
    PARAMETER adrvrs, ldatasources
    LOCAL nodbcenv, nretval, dsn, dsndesc, mdsn, mdesc
    ldatasources = IIF(TYPE("m.lDataSources")="L", m.ldatasources, .F.)
    nretval = this.loadodbcfuncs()
    IF m.nretval<>0
       RETURN m.nretval
    ENDIF
    nodbcenv = VAL(SYS(3053))
    IF INLIST(nodbcenv, 527, 528, 182)
       RETURN -113
    ENDIF
    DIMENSION adrvrs[1, IIF(m.ldatasources, 2, 1)]
    adrvrs[1] = ""
    DO WHILE .T.
       dsn = SPACE(100)
       dsndesc = SPACE(100)
       mdsn = 0
       mdesc = 0
       IF m.ldatasources
          nretval = sqldatasources(m.nodbcenv, 1, @dsn, 100, @mdsn, @dsndesc, 255, @mdesc)
       ELSE
          nretval = sqldrivers(m.nodbcenv, 1, @dsn, 100, @mdsn, @dsndesc, 100, @mdesc)
       ENDIF
       DO CASE
          CASE m.nretval=100
             nretval = 0
             EXIT
          CASE m.nretval<>0 .AND. m.nretval<>1
             EXIT
          OTHERWISE
             IF  .NOT. EMPTY(adrvrs(1))
                IF m.ldatasources
                   DIMENSION adrvrs[ALEN(adrvrs, 1)+1, 2]
                ELSE
                   DIMENSION adrvrs[ALEN(adrvrs, 1)+1, 1]
                ENDIF
             ENDIF
             dsn = ALLTRIM(m.dsn)
             adrvrs[ALEN(adrvrs, 1), 1] = LEFT(m.dsn, LEN(m.dsn)-1)
             IF m.ldatasources
                dsndesc = ALLTRIM(m.dsndesc)
                adrvrs[ALEN(adrvrs, 1), 2] = LEFT(m.dsndesc, LEN(m.dsndesc)-1)
             ENDIF
       ENDCASE
    ENDDO
    RETURN nretval
   ENDFUNC
**
   FUNCTION EnumODBCDrvrs
    LPARAMETERS adrvropts, codbcdriver
    LOCAL csourcekey
    csourcekey = "Software\ODBC\ODBCINST.INI\"+m.codbcdriver
    RETURN this.enumoptions(@adrvropts, m.csourcekey, -2147483646, .F.)
   ENDFUNC
**
   FUNCTION EnumODBCData
    LPARAMETERS adrvropts, cdatasource
    LOCAL csourcekey
    csourcekey = "Software\ODBC\ODBC.INI\"+cdatasource
    RETURN this.enumoptions(@adrvropts, m.csourcekey, -2147483647, .F.)
   ENDFUNC
**
ENDDEFINE
**
DEFINE CLASS filereg AS registry
**
   FUNCTION GetAppPath
    LPARAMETERS cextension, cextnkey, cappkey, lserver
    LOCAL nerrnum, coptname
    coptname = ""
    IF TYPE("m.cExtension")<>"C" .OR. LEN(m.cextension)>3
       RETURN -103
    ENDIF
    m.cextension = "."+m.cextension
    nerrnum = this.openkey(m.cextension)
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    nerrnum = this.getkeyvalue(coptname, @cextnkey)
    this.closekey()
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    RETURN this.getapplication(cextnkey, @cappkey, lserver)
   ENDFUNC
**
   FUNCTION GetLatestVersion
    LPARAMETERS cclass, cextnkey, cappkey, lserver
    LOCAL nerrnum, coptname
    coptname = ""
    nerrnum = this.openkey(m.cclass+"\CurVer")
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    nerrnum = this.getkeyvalue(coptname, @cextnkey)
    this.closekey()
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    RETURN this.getapplication(cextnkey, @cappkey, lserver)
   ENDFUNC
**
   FUNCTION GetApplication
    PARAMETER cextnkey, cappkey, lserver
    LOCAL nerrnum, coptname
    coptname = ""
    IF TYPE("m.lServer")="L" .AND. m.lserver
       this.capppathkey = "\Protocol\StdFileEditing\Server"
    ELSE
       this.capppathkey = "\Shell\Open\Command"
    ENDIF
    m.nerrnum = this.openkey(m.cextnkey+this.capppathkey)
    IF m.nerrnum<>0
       RETURN m.nerrnum
    ENDIF
    nerrnum = this.getkeyvalue(coptname, @cappkey)
    this.closekey()
    RETURN m.nerrnum
   ENDFUNC
**
ENDDEFINE
**
