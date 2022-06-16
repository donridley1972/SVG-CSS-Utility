

   MEMBER('NetTalkSVGUtility.clw')                         ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('NETTALKSVGUTILITY003.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('NETTALKSVGUTILITY002.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('NETTALKSVGUTILITY004.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
SvgCssIconsGenerator PROCEDURE 

RootUrl              STRING(255)                           ! 
RowCount             LONG                                  ! 
ColCnt               LONG                                  ! 
RowGroupCnt          LONG                                  ! 
NumberOfRows         LONG                                  ! 
InputFilePath        STRING(255)                           ! 
st                  StringTheory
BRW5::View:Browse    VIEW(Projects)
                       PROJECT(Pro:Description)
                       PROJECT(Pro:GUID)
                       PROJECT(Pro:OutputFolder)
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?List
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Pro:GUID               LIKE(Pro:GUID)                 !Browse hot field - type derived from field
Pro:OutputFolder       LIKE(Pro:OutputFolder)         !Browse hot field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
BRW7::View:Browse    VIEW(SvgIconLines)
                       PROJECT(Svg:IconName)
                       PROJECT(Svg:Guid)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?List:2
Svg:IconName           LIKE(Svg:IconName)             !List box control field - type derived from field
Svg:Guid               LIKE(Svg:Guid)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
Window               WINDOW('SVG - CSS Icons Generator'),AT(,,447,265),FONT('Segoe UI',10),RESIZE,AUTO,ICON('ntsvg.ico'), |
  GRAY,MAX,SYSTEM,WALLPAPER('ArcticBlueGradientBackground1600x1084.jpg'),IMM
                       BUTTON('Close'),AT(411,243),USE(?Close)
                       PROMPT('Root URL'),AT(2,44),USE(?RootUrl:Prompt),TRN
                       ENTRY(@s255),AT(105,40,240,13),USE(RootUrl),LEFT(2)
                       LIST,AT(2,57,98,60),USE(?List),LEFT(2),VSCROLL,FORMAT('200L(2)|M~Projects~@s50@'),FROM(Queue:Browse), |
  IMM
                       BUTTON('&Insert'),AT(2,121,31,12),USE(?Insert)
                       BUTTON('&Change'),AT(36,121,31,12),USE(?Change)
                       BUTTON('&Delete'),AT(70,121,31,12),USE(?Delete)
                       LIST,AT(2,136,98,104),USE(?List:2),LEFT(2),VSCROLL,FORMAT('120L(2)|M~Icon Name~@s30@'),FROM(Queue:Browse:1), |
  IMM
                       BUTTON('&Insert'),AT(2,243,31,12),USE(?Insert:2)
                       BUTTON('&Change'),AT(36,243,31,12),USE(?Change:2)
                       BUTTON('&Delete'),AT(70,243,31,12),USE(?Delete:2)
                       BUTTON('Generate'),AT(349,40),USE(?GenerateBtn)
                       TEXT,AT(105,57,339,183),USE(?TEXT1),HVSCROLL
                       IMAGE('ntsvg.png'),AT(2,1,45,35),USE(?IMAGE1)
                       IMAGE('title.png'),AT(50,1,239,35),USE(?IMAGE2)
                       BUTTON('Save'),AT(398,40,46),USE(?SaveBtn)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
! ----- csResize --------------------------------------------------------------------------
csResize             Class(csResizeClass)
    ! derived method declarations
Fetch                  PROCEDURE (STRING Sect,STRING Ent,*? Val),VIRTUAL
Update                 PROCEDURE (STRING Sect,STRING Ent,STRING Val),VIRTUAL
Init                   PROCEDURE (),VIRTUAL
                     End  ! csResize
! ----- end csResize -----------------------------------------------------------------------
BRW5                 CLASS(BrowseClass)                    ! Browse using ?List
Q                      &Queue:Browse                  !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

BRW7                 CLASS(BrowseClass)                    ! Browse using ?List:2
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('SvgCssIconsGenerator')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Close
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  ! Restore preserved local variables from non-volatile store
  RootUrl = INIMgr.TryFetch('SvgCssIconsGenerator_PreservedVars','RootUrl')
  InputFilePath = INIMgr.TryFetch('SvgCssIconsGenerator_PreservedVars','InputFilePath')
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Projects.SetOpenRelated()
  Relate:Projects.Open()                                   ! File Projects used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW5.Init(?List,Queue:Browse.ViewPosition,BRW5::View:Browse,Queue:Browse,Relate:Projects,SELF) ! Initialize the browse manager
  BRW7.Init(?List:2,Queue:Browse:1.ViewPosition,BRW7::View:Browse,Queue:Browse:1,Relate:SvgIconLines,SELF) ! Initialize the browse manager
  SELF.Open(Window)                                        ! Open window
  Do DefineListboxStyle
  BRW5.Q &= Queue:Browse
  BRW5.AddSortOrder(,)                                     ! Add the sort order for  for sort order 1
  BRW5.AddField(Pro:Description,BRW5.Q.Pro:Description)    ! Field Pro:Description is a hot field or requires assignment from browse
  BRW5.AddField(Pro:GUID,BRW5.Q.Pro:GUID)                  ! Field Pro:GUID is a hot field or requires assignment from browse
  BRW5.AddField(Pro:OutputFolder,BRW5.Q.Pro:OutputFolder)  ! Field Pro:OutputFolder is a hot field or requires assignment from browse
  BRW7.Q &= Queue:Browse:1
  BRW7.AddSortOrder(,)                                     ! Add the sort order for  for sort order 1
  BRW7.SetFilter('(Svg:ProjectGuid=Pro:GUID)')             ! Apply filter expression to browse
  BRW7.AddField(Svg:IconName,BRW7.Q.Svg:IconName)          ! Field Svg:IconName is a hot field or requires assignment from browse
  BRW7.AddField(Svg:Guid,BRW7.Q.Svg:Guid)                  ! Field Svg:Guid is a hot field or requires assignment from browse
  csResize.Init('SvgCssIconsGenerator',Window,1)
  INIMgr.Fetch('SvgCssIconsGenerator',Window)              ! Restore window settings from non-volatile store
  BRW5.AskProcedure = 1                                    ! Will call: UpdateProjects
  BRW7.AskProcedure = 2                                    ! Will call: UpdateSvgLines(Pro:GUID)
  BRW5.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  BRW7.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  csResize.Open()
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
    INIMgr.Update('SvgCssIconsGenerator',Window)           ! Save window data to non-volatile store
  END
  ! Save preserved local variables in non-volatile store
  INIMgr.Update('SvgCssIconsGenerator_PreservedVars','RootUrl',RootUrl)
  INIMgr.Update('SvgCssIconsGenerator_PreservedVars','InputFilePath',InputFilePath)
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    EXECUTE Number
      UpdateProjects
      UpdateSvgLines(Pro:GUID)
    END
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

x               Long
LneSt           StringTheory
Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?List
      !get(Queue:Browse,choice(?List))     
      ?TEXT1{PROP:Text} = ''
      BRW7.ResetSort(true)       
    OF ?GenerateBtn
      st.SetValue(|
      ':root {{ 												/* using ci- as the prefix here, use your own prefix in your own files */ <13,10>' & |
      '	--ci-url: url("'&clip(RootUrl)&'");		/* call your own icon file something unique */ <13,10>' & |
      '	--ci-size: 24px; 								/* could be var(--icon-size), or a specific value as it is here */ <13,10>' & |
      ' }<13,10><13,10>')
      RowGroupCnt = 1
      Set(BRW7::View:Browse)
      st.Append('/* row 1 */<13,10>')      
      LOOP
        Next(BRW7::View:Browse)
        If Errorcode() Then Break END
        If RowCount = 0 and ColCnt = 0
            st.Append('.ui-icon-' & clip(Svg:IconName) & '      {{ background-image:var(--ci-url) ; width: var(--ci-size); height:var(--ci-size);background-position: '&ColCnt&' '&RowCount&'; }<13,10>')
        ElsIf ColCnt > 0 and RowCount = 0 !RowCount > and ColCnt = 0
            st.Append('.ui-icon-' & clip(Svg:IconName) & '      {{ background-image:var(--ci-url) ; width: var(--ci-size); height:var(--ci-size);background-position: calc(-'&ColCnt&' * var(--ci-size)) '&RowCount&'; }<13,10>')
        ElsIf ColCnt = 0 and RowCount > 0
            st.Append('<13,10>/* row '&RowCount+1&' */<13,10>')
            st.Append('.ui-icon-' & clip(Svg:IconName) & '      {{ background-image:var(--ci-url) ; width: var(--ci-size); height:var(--ci-size);background-position: '&ColCnt&'                         calc(-'&RowCount&' * var(--ci-size)); }<13,10>')
        Elsif ColCnt > 0 and RowCount > 0
            st.Append('.ui-icon-' & clip(Svg:IconName) & '      {{ background-image:var(--ci-url) ; width: var(--ci-size); height:var(--ci-size);background-position: calc(-'&ColCnt&' * var(--ci-size)) calc(-'&RowCount&' * var(--ci-size)); }<13,10>')
        End
      
        If ColCnt = 15 
            ColCnt = 0 
            RowCount+=1
        ELSE
            ColCnt+=1   ! 16 Max
        End
      END
      ?TEXT1{Prop:Text} = st.GetValue()
      !st.SaveFile('dwr_customicons' & RANDOM(1,999) & '.css')
    OF ?SaveBtn
      If st.Length() > 0
        st.SaveFile(Clip(Pro:OutputFolder) & '\' & clip(Pro:Description)&'.css')      
      End
    END
  ReturnValue = PARENT.TakeAccepted()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  csResize.TakeEvent()
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

!----------------------------------------------------
csResize.Fetch   PROCEDURE (STRING Sect,STRING Ent,*? Val)
  CODE
  INIMgr.Fetch(Sect,Ent,Val)
  PARENT.Fetch (Sect,Ent,Val)
!----------------------------------------------------
csResize.Update   PROCEDURE (STRING Sect,STRING Ent,STRING Val)
  CODE
  INIMgr.Update(Sect,Ent,Val)
  PARENT.Update (Sect,Ent,Val)
!----------------------------------------------------
csResize.Init   PROCEDURE ()
  CODE
  PARENT.Init ()
  Self.CornerStyle = Ras:CornerDots
  SELF.GrabCornerLines() !
  SELF.SetStrategy(?Close,100,100,0,0)
  SELF.SetStrategy(?List,,0,,50)
  SELF.SetStrategy(?Insert,,50,,0)
  SELF.SetStrategy(?Change,,50,,0)
  SELF.SetStrategy(?Delete,,50,,0)
  SELF.SetStrategy(?List:2,,50,,50)
  SELF.SetStrategy(?Insert:2,,100,,0)
  SELF.SetStrategy(?Change:2,,100,,0)
  SELF.SetStrategy(?Delete:2,,100,,0)
  SELF.SetStrategy(?TEXT1,0,0,100,100)

BRW5.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


BRW7.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END

