

   MEMBER('NetTalkSVGUtility.clw')                         ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('NETTALKSVGUTILITY005.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
RuntimeFileManager PROCEDURE 

FilesOpened          BYTE                                  ! 
ListQueue            QUEUE,PRE(lq)                         ! 
Tagged               BYTE                                  ! 
TagIcon              SHORT                                 ! 
FileDesc             STRING(40)                            ! 
FileRecords          STRING(10)                            ! 
DiskName             STRING(255)                           ! 
Filename             STRING(255)                           ! 
Owner                STRING(40)                            ! 
Tag                  BYTE                                  ! 
oem                  STRING(2)                             ! 
NotFixable           BYTE                                  ! 
NotFreshenable       BYTE                                  ! 
FileHandle           &FILE                                 ! This is only for Clarion 6 and up.
FileDriver           STRING(40)                            ! 
                     END                                   ! 
lenable              BYTE                                  ! 
FileAction               STRING(10),AUTO
i_                       LONG,AUTO
found_                   BYTE,AUTO
LocFMx:WorkFileName             string(255)
LocFMx:WorkFile                 &File
LocFMx:WorkFilePrefix           string(16)
CurrentFile              string(255)
FilesLeft                long
Progress                 long
CurrentAction            string(255)
ProgressWindow WINDOW('Progress...'),AT(70,28,346,71),GRAY,FONT('Arial',10,,FONT:regular),DOUBLE
    STRING('Current File :'),AT(9,5,47,10),USE(?Str10)
    STRING(@s255),AT(58,5,277,10),USE(CurrentFile)
    STRING('Action :'),AT(9,16),USE(?Str5)
    STRING(@s255),AT(58,16),USE(currentaction)
    STRING('Progress :'),AT(9,27),USE(?Str6)
    PROGRESS,AT(58,27,239,8),USE(Progress),RANGE(0,100)
    STRING(@n3),AT(58,40),USE(filesleft)
    STRING(@n4),AT(301,27,18),USE(progress,, ?progress:2),HIDE
    BUTTON('&Cancel'),AT(293,54,50,14),USE(?Cancel)
    STRING('Files Left '),AT(9,40,48,10),USE(?Str20)
  END
TPEName              string(144)
WorkKey              &key
PleaseStop           byte
FileOpened           byte
loc:counter          Long
XMLDirectory         String(255)
XMLName              String(255)
lnobuild             byte
window               WINDOW('Runtime File Manager'),AT(,,321,233),FONT('Tahoma',8,,FONT:regular),DOUBLE,AUTO,CENTER, |
  GRAY,SYSTEM
                       LIST,AT(5,4,254,223),USE(?ListQueue),HVSCROLL,FORMAT('11L(2)I@s2@93L(2)|M~File~@s40@40L' & |
  '(2)|M~Records~@s10@576L(2)|M~Disk name~@s144@'),FROM(ListQueue),MARK(lq:Tag)
                       BUTTON('&Tag All'),AT(265,4,50,14),USE(?tagall),MSG('Tag all the files'),TIP('Tag all the files')
                       BUTTON('&Untag All'),AT(265,23,50,14),USE(?Untagall),MSG('Untag all of the files'),TIP('Untag all ' & |
  'of the files')
                       BUTTON('&Build'),AT(265,42,50,14),USE(?Build),MSG('Build the key files for the tagged data files'), |
  TIP('Build the key files for the tagged data files')
                       BUTTON('&Pack'),AT(265,61,50,14),USE(?Pack),MSG('Pack the tagged data files'),TIP('Pack the t' & |
  'agged data files')
                       BUTTON('&Release'),AT(265,80,50,14),USE(?Release),MSG('Release any held records in the ' & |
  'tagged files'),TIP('Release any held records in the tagged files')
                       BUTTON('&Fix'),AT(265,99,50,14),USE(?Fix),MSG('Interface to TPSFix utility'),TIP('Interface ' & |
  'to TPSFix utility')
                       BUTTON('Fre&shen'),AT(265,118,50,14),USE(?Freshen),MSG('Copy the records into a new file'), |
  TIP('Copy the records into a new file')
                       BUTTON('&Info'),AT(265,137,50,14),USE(?Info),MSG('Get information about each file'),TIP('Get inform' & |
  'ation about each file')
                       BUTTON('&Create'),AT(265,156,50,14),USE(?Create),MSG('Create any non-existent files'),TIP('Create any' & |
  ' non-existent files')
                       BUTTON('Import'),AT(265,175,50,14),USE(?Import),DISABLE,MSG('Import records from XML'),TIP('Import rec' & |
  'ords from XML')
                       BUTTON('Export'),AT(265,194,50,14),USE(?Export),DISABLE,MSG('Export data to XML'),TIP('Export data to XML')
                       BUTTON('Cl&ose'),AT(265,213,50,14),USE(?Done),MSG('Close this window'),TIP('Close this window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
!---------------------------------------------------------------------------
EnableDisableButtons   routine
  lenable = 0
  lnobuild = 0
  loop i_ = 1 to records(ListQueue)
    get(ListQueue,i_)
    if lq:tagged = 1
      lenable = 1
      !break
      case lower(lq:filehandle{prop:driver})
      of 'mssql'
      orof 'oracle'
      orof 'sqlanywhere'
      orof 'odbc'
        lnobuild = 1
      end
    end
  end
  if lenable
    if lnobuild = 1
      ?Build{prop:disable} = 1
    else
      ?Build{prop:disable} = 0
    end
    ?Pack{prop:disable} = 0
    ?Release{prop:disable} = 0
    ?Fix{prop:disable} = 0
    ?Freshen{prop:disable} = 0
    ?Info{prop:disable} = 0
    ?Create{prop:disable} = 0
    ?Import{prop:disable} = 0
    ?Export{prop:disable} = 0
  else
    ?Build{prop:disable} = 1
    ?Pack{prop:disable} = 1
    ?Release{prop:disable} = 1
    ?Fix{prop:disable} = 1
    ?Freshen{prop:disable} = 1
    ?Info{prop:disable} = 1
    ?Create{prop:disable} = 1
    ?Import{prop:disable} = 1
    ?Export{prop:disable} = 1
  end
  ?Import{prop:hide} = 1
  ?Export{prop:hide} = 1

BuildListQueue  Routine
  clear(ListQueue)
  lq:filename = 'Projects'
  lq:filedesc = 'Projects'
  lq:FileRecords  = '?'
  lq:FileHandle &= Projects
  lq:FileDriver = 'TOPSPEED'
    lq:owner = ''
    lq:oem = ''
    lq:NotFixable = 0
    lq:NotFreshenable = 0
  add(ListQueue)
  lq:filename = 'SvgIconLines'
  lq:filedesc = 'SvgIconLines'
  lq:FileRecords  = '?'
  lq:FileHandle &= SvgIconLines
  lq:FileDriver = 'TOPSPEED'
    lq:owner = ''
    lq:oem = ''
    lq:NotFixable = 0
    lq:NotFreshenable = 0
  add(ListQueue)
  sort(listQueue,lq:filedesc)
  !do EnableDisableButtons
!---------------------------------------------------------------------------
AutoFix  Routine

!---------------------------------------------------------------------------
ManageFiles ROUTINE
  ! count the number of files we're going to work on
  FilesLeft = 0
  loop i_ = 1 to records(listqueue)
    get(listqueue,i_)
    if lq:tagged = 1 then FilesLeft += 1.
  End
  open(ProgressWindow)
  pleasestop = 0
  accept
    case event()
    of event:openwindow
      if filesleft = 0  ! no files tagged, so choose highlighted file
        filesleft = 1
        get(listqueue,choice(?listqueue))
        CurrentFile = lq:Filename
        do ManageFile
      else
        i_ = 0
        filesleft += 1
        fileopened = 0
        post(event:user)
      end
    of event:buildfile
      if pleasestop
        pleasestop = 0
        post(event:user)
        cycle
      end
      if LocFMx:WorkFile{prop:completed} <> 0
        progress = LocFMx:WorkFile{prop:completed}
      else
        progress = (progress + 1) % 100
      end
      display()
    of event:buildkey
      if pleasestop
        pleasestop = 0
        post(event:user)
        cycle
      end
      workkey &= LocFMx:WorkFile{prop:currentkey}
      currentaction = 'Key :' & workkey{prop:label}
      if LocFMx:WorkFile{prop:completed} <> 0
        progress = LocFMx:WorkFile{prop:completed}
      else
        progress = (progress + 1) % 100
      end
      display()
    of event:builddone
      post(event:user)
    of event:user
      display
      if fileopened
        lq:FileRecords  = records(LocFMx:WorkFile)
        put(listqueue)
        close(LocFMx:WorkFile)
        fileopened = 0
      End
      FilesLeft -= 1
      ! now start the next one
      loop
        i_ += 1
        if i_ > records(listqueue) then break.
        get(listqueue,i_)
        if lq:tagged = 1 then break.
      End
      if lq:tagged <> 1 or i_ > records(listqueue) then break.  ! break out of accept loop
      CurrentFile = lq:filename
      display(?currentfile)
      do ManageFile
    of event:accepted
      pleasestop = 1
      post(event:user)
    end
  end
  close(progressWindow)
!---------------------------------------------------------------------------
ManageFile ROUTINE
  case upper(lq:filename)
  of upper('Projects')
    LocFMx:WorkFile &= Projects
    LocFMx:WorkFilePrefix = 'Pro'
  of upper('SvgIconLines')
    LocFMx:WorkFile &= SvgIconLines
    LocFMx:WorkFilePrefix = 'Svg'
  else
    post(event:user)
    exit
  End
  do work
  found_ = 1
!---------------------------------------------------------------------------
Work  routine
  case fileaction
  of 'Build'
    open(LocFMx:WorkFile,12h) ! open with exclusive access
    case errorcode()
    of NoError
    orof BadKeyErr
      fileopened = 1
      send(LocFMx:WorkFile,'FULLBUILD=on')
      if upper(LocFMx:WorkFile{prop:driver}) = 'TOPSPEED' or upper(LocFMx:WorkFile{prop:driver}) = 'CLARION'
        LocFMx:WorkFile{PROP:ProgressEvents} = 100
        Build(LocFMx:WorkFile)
      else    ! btrieve definitly doesn't send an event:builddone
        LocFMx:WorkFile{PROP:ProgressEvents} = 0
        Build(LocFMx:WorkFile)
        post(event:user)
      end
      currentaction = 'Building File'
      progress = LocFMx:WorkFile{prop:completed}
      display()
    of NoFileErr
      post(event:user)
    else
      DO InvalidAccess
    End
  of 'Pack'
    open(LocFMx:WorkFile,12h) ! open with exclusive access
    case errorcode()
    of NoError
    orof BadKeyErr
      fileopened = 1
     ! LocFMx:WorkFile{PROP:ProgressEvents} = 50
      currentaction = 'Packing File'
      progress = LocFMx:WorkFile{prop:completed}
      display()
      Pack(LocFMx:WorkFile)
      post(event:user)
    of NoFileErr
      post(event:user)
    else
      DO InvalidAccess
    End
  of 'Release'
    send(LocFMx:WorkFile,'RECOVER=1')       ! unlocks files and rollsback transactions
    open(LocFMx:WorkFile,12h)               ! open with exclusive access
    if errorcode() = 0
      fileopened = 1
      lq:FileRecords  = records(LocFMx:WorkFile)
      loc:counter = 0
      send(LocFMx:WorkFile,'IGNORESTATUS=ON') ! need to read though file including held records
      set(LocFMx:WorkFile)
      loop
        next(LocFMx:WorkFile)
        if errorcode() then break.
        loc:counter += 1
        progress = (loc:counter * 100 / lq:fileRecords)
        if send(LocFMx:WorkFile,'HELD') = 'ON'
          SEND(LocFMx:WorkFile,'RECOVER=1')   ! "unhold" the next record
          REGET(LocFMx:WorkFile,POSITION(LocFMx:WorkFile)) ! ie this one
        end
      end
      send(LocFMx:WorkFile,'RECOVER=0')       ! disable recovery
      send(LocFMx:WorkFile,'IGNORESTATUS=OFF')! disable reading deleted and held records
      post(event:user)
    elsif errorcode() = NoFileErr
      post(event:user)
    else
      DO InvalidAccess
    end
  of 'Fix'
    if lq:NotFixable = 0
      If lq:owner = '1'
        message('Can''t fix encrypted file : ' & lq:filename)
      else
        LocFMx:WorkFileName = clip(name(LocFMx:WorkFile))
        do CallTpsFix
      End
    end
    fileopened = 0
    post(event:user)
  of 'Freshen'
    if lq:NotFreshenable = 0
      ds_UpgradeFileEx(LocFMx:WorkFile,1)
      do GetNumberOfRecords
    end
    post(event:user)
  of 'Info'
    do GetNumberOfRecords
    fileopened = 0
    post(event:user)
  of 'Create'
    do GetNumberOfRecords
    fileopened = 0
    post(event:user)
  of 'Export'
    If XMLDirectory <> ''
      XMLName = clip(XMLDirectory) & '\' & clip(lq:filename) & '.xml'
      currentaction = 'Exporting ' & xmlname
      display()
      LocFMx:WorkFileName = 'Table-' & lq:filedesc
      Do ExportXML
      Post(Event:User)
    End

  Of 'Import'
    If XMLDirectory <> ''
      XMLName = clip(XMLDirectory) & '\' & clip(lq:filename) & '.xml'
      currentaction = 'Importing ' & xmlname
      Display()
      LocFMx:WorkFileName = 'Table-' & lq:filedesc
      Do ImportXML
      Post(event:user)
    End
  End
!---------------------------------------------------------------------------
ExportXML  routine
!---------------------------------------------------------------------------
ImportXML  routine
!---------------------------------------------------------------------------
GetNumberOfRecords  Routine
  open(LocFMx:WorkFile,40h) ! open with read only, deny none
  case errorcode()
  of IsOpenErr
    lq:FileRecords  = records(LocFMx:WorkFile)
    lq:DiskName = name(LocFMx:WorkFile)
    Do ShortenDiskName
    put(listqueue)
  of 0
    lq:FileRecords  = records(LocFMx:WorkFile)
    lq:DiskName = name(LocFMx:WorkFile)
    Do ShortenDiskName
    put(listqueue)
    close(LocFMx:WorkFile)
  of 2
    if fileaction = 'Create'
      create(LocFMx:WorkFile)
      if errorcode() = 0
        lq:DiskName = name(LocFMx:WorkFile)
        lq:FileRecords  = 0
      else
        lq:DiskName = 'Error ' & Errorcode() & ' : ' & Error()
        lq:FileRecords  = '?'
      end
      put(listqueue)
    else
      lq:FileRecords  = '?'
      lq:DiskName = 'Error ' & Errorcode() & ' : ' & Error()
      put(listqueue)
    end
  else
    lq:FileRecords  = '?'
    lq:DiskName = 'Error ' & Errorcode() & ' : ' & Error()
    put(listqueue)
  end
!---------------------------------------------------------------------------
CallTpsFix  Routine
  LocFMx:WorkFileName = LocFMx:WorkFile{prop:name}
  if instring('!',LocFMx:WorkFileName,1,1)
    if message('This is a multi-table TPS file. You can try using Fix, but the results are not ' & |
      'guaranteed and could damage your file further.  Do you want to continue ? ','Warning', |
      Icon:Question,Button:yes + Button:No, Button:No) = Button:no
      exit
    .
    LocFMx:WorkFileName = sub(LocFMx:WorkFileName,1,instring('!',LocFMx:WorkFileName,1,1)-2)
  .
  tpeName = ds_MakeTPE(LocFMx:WorkFile)
  if tpeName = '1'
    message('Unable to create TPE Example file.','Error',Icon:Asterisk)
    exit
  elsif tpeName = '2'
    message('Not a TOPSPEED file.','Error',Icon:Asterisk)
    exit
  elsif tpeName = '3'
    message('Error creating TPE file : ' & clip(error()),'Error',Icon:Asterisk)
    exit
  .
  if instring('.',LocFMx:WorkFileName,1,1)
      if instring(' ',clip(LocFMx:WorkFileName),1,1) > 0 ! is this a long file name (allows spaces etc..)
        Run('tpsfix "' & clip(LocFMx:WorkFileName) & '"' & '' & ' ' & '' & ' /E:"' & sub(LocFMx:WorkFileName,1, |
        instring('.',LocFMx:WorkFileName,-1,255)-1) & '.tpe"' & '' & ' /K /A '& lq:oem)
      else
        Run('tpsfix ' & clip(LocFMx:WorkFileName) & '' & ' ' & '' & ' /E:' & sub(LocFMx:WorkFileName,1, |
        instring('.',LocFMx:WorkFileName,-1,255)-1) & '.tpe' & '' & ' /K /A '& lq:oem)
      end
  else
      if instring(' ',clip(LocFMx:WorkFileName),1,1) > 0 ! is this a long file name (allows spaces etc..)
        Run('tpsfix "' & clip(LocFMx:WorkFileName) & '.tps"' & '' & ' ' & '' & ' /E:"' & clip(LocFMx:WorkFileName) |
        & '.tpe"' & '' & ' /K /A '& lq:oem)
      else
        Run('tpsfix ' & clip(LocFMx:WorkFileName) & '.tps' & '' & ' ' & '' & ' /E:' & clip(LocFMx:WorkFileName) |
        & '.tpe' & '' & ' /K /A '& lq:oem)
      end
  end

!---------------------------------------------------------------------------
ShortenDiskName   Routine
  if instring('!',lq:diskname,1,1)
    lq:diskname = sub(lq:diskname,1,instring('!',lq:diskname,1,1)-2)
  .
!---------------------------------------------------------------------------
InvalidAccess     Routine
  MESSAGE('This option requires exclusive file access.|Please ensure no other users are in the system. |An error occured trying to open the file : Error ' & Error(),'File Access Error',ICON:Asterisk,BUTTON:OK,1)
  post(event:user)
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('RuntimeFileManager')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?ListQueue
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.Open(window)                                        ! Open window
  Do DefineListboxStyle
    do BuildListQueue
    do EnableDisableButtons
    do AutoFix
    ?ListQueue{prop:iconlist,1} = '~smalltik.ico'
    if ds_DoFullUpgrade()
      post(event:accepted,?tagall)
    end
  INIMgr.Fetch('RuntimeFileManager',window)                ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('RuntimeFileManager',window)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?Build
        fileaction = 'Build'
        do ManageFiles
    OF ?Pack
        fileaction = 'Pack'
        do ManageFiles
    OF ?Release
        fileaction = 'Release'
        do ManageFiles
    OF ?Fix
        fileaction = 'Fix'
        do ManageFiles
    OF ?Freshen
        fileaction = 'Freshen'
        do ManageFiles
    OF ?Info
        fileaction = 'Info'
        do ManageFiles
        if ds_DoFullUpgrade(0)
          post(event:accepted,?Done)
        end
    OF ?Create
        fileaction = 'Create'
        do ManageFiles
    OF ?Import
        fileaction = 'Import'
        If FileDialog(,XMLDirectory,'*.xml',FILE:LongName + FILE:Directory + FILE:KeepDir)
          do ManageFiles
        End
    OF ?Export
        fileaction = 'Export'
        If FileDialog(,XMLDirectory,'*.xml',FILE:LongName + FILE:Directory + FILE:Save + FILE:KeepDir)
          do ManageFiles
        End
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?ListQueue
        ! catching the auto tag
          get(listqueue,choice(?listQueue))
          if lq:tagged = 0
             lq:tagicon = 1
             lq:tagged = 1
          else
             lq:tagicon = 0
             lq:tagged = 0
          End
          put(listQueue)
          do EnableDisableButtons
    OF ?tagall
      ThisWindow.Update()
        ! Tag all the files
        loop i_ = 1 to records(listqueue)
          get(listqueue,i_)
          lq:tag = 1
          lq:tagged = 1
          lq:TagIcon = 1
          put(listqueue)
        End
      !  select(?ListQueue)
        do EnableDisableButtons
        if ds_DoFullUpgrade()
          post(event:accepted,?Info)
        end
    OF ?Untagall
      ThisWindow.Update()
        ! Untag all the files
        loop i_ = 1 to records(listqueue)
          get(listqueue,i_)
          lq:tag = 0
          lq:tagged = 0
          lq:TagIcon = 0
          put(listqueue)
        End
      !  ?ListQueue{prop:selected} = 0
        do EnableDisableButtons
    OF ?Done
      ThisWindow.Update()
        post(event:closewindow)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

