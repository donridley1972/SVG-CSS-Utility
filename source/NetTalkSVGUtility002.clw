

   MEMBER('NetTalkSVGUtility.clw')                         ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('NETTALKSVGUTILITY002.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Projects
!!! </summary>
UpdateProjects PROCEDURE 

ProgressStr          STRING(50)                            ! 
CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
Dir1Loading          STRING(255),AUTO                      ! 
Dirs2AddSpot         LONG,AUTO                             ! 
Dir1Folder           STRING(256),AUTO                      ! 
Dir1Level            LONG,AUTO                             ! 
Dir1Q                QUEUE(FILE:Queue),PRE(Dir1Q)          ! 
                     END                                   ! 
AllQ                 QUEUE(FILE:Queue),PRE(AllQ)           ! 
Folder               STRING(256)                           ! 
PathBS               STRING(255)                           ! 
                     END                                   ! 
Dirs2LoadQ           QUEUE,PRE(D2LoadQ)                    ! 
Name                 STRING(255)                           ! 
Folder               STRING(256)                           ! 
Level                LONG                                  ! 
                     END                                   ! 
DisplayString        STRING(255)                           ! 
History::Pro:Record  LIKE(Pro:RECORD),THREAD
QuickWindow          WINDOW('Form Projects'),AT(,,365,61),FONT('Segoe UI',10,,FONT:regular,CHARSET:ANSI),RESIZE, |
  AUTO,CENTER,GRAY,IMM,HLP('UpdateProjects'),SYSTEM,WALLPAPER('ArcticBlueGradientBackgr' & |
  'ound1600x1084.jpg')
                       BUTTON('&OK'),AT(259,42,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window'),TRN
                       BUTTON('&Cancel'),AT(312,42,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
  TIP('Cancel operation'),TRN
                       ENTRY(@s50),AT(58,6,204,10),USE(Pro:Description),LEFT(2)
                       PROMPT('Description:'),AT(5,6),USE(?Pro:Description:Prompt),TRN
                       PROMPT('Output Folder:'),AT(5,24),USE(?Pro:OutputFolder:Prompt),TRN
                       ENTRY(@s255),AT(58,24,287,10),USE(Pro:OutputFolder),LEFT(2)
                       BUTTON('...'),AT(349,22,12,12),USE(?LookupFile),FLAT
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

FileLookup4          SelectFileClass
CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  CASE SELF.Request
  OF ChangeRecord OROF DeleteRecord
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (' & Pro:Description & ')' ! Append status message to window title text
  OF InsertRecord
    QuickWindow{PROP:Text} = QuickWindow{PROP:Text} & '  (New)'
  END
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateProjects')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?OK
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Pro:Record,History::Pro:Record)
  SELF.AddHistoryField(?Pro:Description,2)
  SELF.AddHistoryField(?Pro:OutputFolder,4)
  SELF.AddUpdateFile(Access:Projects)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Projects.SetOpenRelated()
  Relate:Projects.Open()                                   ! File Projects used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Projects
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Pro:Description{PROP:ReadOnly} = True
    ?Pro:OutputFolder{PROP:ReadOnly} = True
    DISABLE(?LookupFile)
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateProjects',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  FileLookup4.Init
  FileLookup4.ClearOnCancel = True
  FileLookup4.Flags=BOR(FileLookup4.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup4.Flags=BOR(FileLookup4.Flags,FILE:Directory)  ! Allow Directory Dialog
  FileLookup4.SetMask('All Files','*.*')                   ! Set the file mask
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Projects.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateProjects',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
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
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    OF ?LookupFile
      ThisWindow.Update()
      Pro:OutputFolder = FileLookup4.Ask(1)
      DISPLAY
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

