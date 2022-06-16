   PROGRAM


StringTheory:TemplateVersion equate('3.46')
ResizeAndSplit:TemplateVersion equate('5.10')
FM3:Version           equate('5.59')       !Deprecated - but exists for backward compatibility
FM3:TemplateVersion   equate('5.59')

   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
  include('StringTheory.Inc'),ONCE
  include('ResizeAndSplit.Inc'),ONCE

   MAP
     MODULE('NETTALKSVGUTILITY_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('NETTALKSVGUTILITY003.CLW')
SvgCssIconsGenerator   PROCEDURE   !
     END
       include('FM3map.clw')
   END

  include('StringTheory.Inc'),ONCE
glo:st               StringTheory
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
Projects             FILE,DRIVER('TOPSPEED'),NAME('Projects.tps'),PRE(Pro),CREATE,BINDABLE,THREAD !                     
ProjGuidKey              KEY(Pro:GUID),NOCASE,PRIMARY      !                     
ProjDescriptionKey       KEY(Pro:Description),DUP,NOCASE   !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
Description                 STRING(50)                     !                     
InputFolder                 STRING(255)                    !                     
OutputFolder                STRING(255)                    !                     
                         END
                     END                       

ProjectFiles         FILE,DRIVER('TOPSPEED'),NAME('ProjectFiles.tps'),PRE(ProjFiles),CREATE,BINDABLE,THREAD !                     
ProjFilesGuidKey         KEY(ProjFiles:GUID),NOCASE,PRIMARY !                     
FKProjectGuidKey         KEY(ProjFiles:ProjectGuid),DUP,NOCASE !                     
ProjFilesFileNameKey     KEY(ProjFiles:Name),DUP,NOCASE    !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
ProjectGuid                 STRING(16)                     !                     
Name                        STRING(500)                    !                     
Level                       LONG                           !                     
ShortName                   STRING(13)                     !                     
Date                        LONG                           !                     
Time                        LONG                           !                     
Size                        LONG                           !                     
Attrib                      BYTE                           !                     
Folder                      STRING(256)                    !                     
PathBS                      STRING(255)                    !                     
OutPath                     STRING(256)                    !                     
                         END
                     END                       

SvgIconLines         FILE,DRIVER('TOPSPEED'),NAME('SvgIconLines.tps'),PRE(Svg),CREATE,BINDABLE,THREAD !                     
GuidKey                  KEY(Svg:Guid),NOCASE,PRIMARY      !                     
FKProjectGuidKey         KEY(Svg:ProjectGuid),DUP,NOCASE   !                     
IconNameKey              KEY(Svg:IconName),DUP,NOCASE      !                     
Record                   RECORD,PRE()
Guid                        STRING(16)                     !                     
ProjectGuid                 STRING(16)                     !                     
IconName                    STRING(30)                     !                     
RowNum                      LONG                           !                     
ColumnNum                   LONG                           !                     
                         END
                     END                       

!endregion

ds_VersionModifier  long
ds_FMInited byte
gTopSpeedFile File,driver('TopSpeed',''),pre(__gtps)
record         record
a                byte
               end
             end



  compile ('****', _VER_C60)
  include('cwsynchc.inc'),once
  ****
  include('fm3equ.clw')
ds_FMQueue  Queue,pre(_dsf),type
Prefix        String(10)
FileName      String(255)
FromVersion   Long
ToVersion     Long
Reserved      String(255)
            end

ds_FM_Upgrading  &byte,thread                ! File Manager 2/3 upgrading flag
Access:Projects      &FileManager,THREAD                   ! FileManager for Projects
Relate:Projects      &RelationManager,THREAD               ! RelationManager for Projects
Access:ProjectFiles  &FileManager,THREAD                   ! FileManager for ProjectFiles
Relate:ProjectFiles  &RelationManager,THREAD               ! RelationManager for ProjectFiles
Access:SvgIconLines  &FileManager,THREAD                   ! FileManager for SvgIconLines
Relate:SvgIconLines  &RelationManager,THREAD               ! RelationManager for SvgIconLines

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\NetTalkSVGUtility.INI', NVD_INI)          ! Configure INIManager to use INI file
  DctInit()
   ! Generated using Clarion Template version v11.0  Family = abc
    ds_FM_Upgrading &= ds_PassHandleForUpgrading()
    if ds_FMInited = 0
      ds_FMInited = 1
        ds_SetOption('inifilename','.\fm3.ini')
      ds_SetOption('BadFile',0)
      ds_AddDriver('Tps',gTopSpeedFile,__gtps:record)
  
  
        ! Thisapp = 0
      ds_IgnoreDriver('AllFiles',1)
      ds_SetOption('SPCreate',1)
      ds_SetOption('GUIDsCaseInsensitive',1)
    ds_UsingFileEx('ProjectFiles',ProjectFiles,1+ds_VersionModifier,'ProjFiles')
    ds_UsingFileEx('Projects',Projects,2+ds_VersionModifier,'Pro')
    ds_UsingFileEx('SvgIconLines',SvgIconLines,1+ds_VersionModifier,'Svg')
              omit('***',FM2=1)
              !! Don't forget to add the FM2=>1 define to your project
              You did forget didn't you ?
              ! close this window - go to the app - click on project - click on properties -
              ! click on the defines tab - add FM2=>1 to the defines...
            !***
    End  !End of if ds_FMInited = 0
  SvgCssIconsGenerator
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

