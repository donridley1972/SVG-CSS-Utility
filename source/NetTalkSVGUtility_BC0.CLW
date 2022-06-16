  MEMBER('NetTalkSVGUtility.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
NetTalkSVGUtility_BC0:DctInit    PROCEDURE()
NetTalkSVGUtility_BC0:DctKill    PROCEDURE()
NetTalkSVGUtility_BC0:FilesInit  PROCEDURE()
  END

Hide:Access:Projects CLASS(FileManager),TYPE               ! FileManager for Projects
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Projects CLASS(RelationManager),TYPE           ! RelationManager for Projects
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:ProjectFiles CLASS(FileManager),TYPE           ! FileManager for ProjectFiles
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:ProjectFiles CLASS(RelationManager),TYPE       ! RelationManager for ProjectFiles
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:SvgIconLines CLASS(FileManager),TYPE           ! FileManager for SvgIconLines
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:SvgIconLines CLASS(RelationManager),TYPE       ! RelationManager for SvgIconLines
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:Projects &Hide:Access:Projects,AUTO,THREAD
_Hide:Relate:Projects &Hide:Relate:Projects,AUTO,THREAD
_Hide:Access:ProjectFiles &Hide:Access:ProjectFiles,AUTO,THREAD
_Hide:Relate:ProjectFiles &Hide:Relate:ProjectFiles,AUTO,THREAD
_Hide:Access:SvgIconLines &Hide:Access:SvgIconLines,AUTO,THREAD
_Hide:Relate:SvgIconLines &Hide:Relate:SvgIconLines,AUTO,THREAD


NetTalkSVGUtility_BC0:DctInit PROCEDURE()
  CODE
  _Hide:Access:Projects &= NEW(Hide:Access:Projects)
  _Hide:Relate:Projects &= NEW(Hide:Relate:Projects)
  _Hide:Access:ProjectFiles &= NEW(Hide:Access:ProjectFiles)
  _Hide:Relate:ProjectFiles &= NEW(Hide:Relate:ProjectFiles)
  _Hide:Access:SvgIconLines &= NEW(Hide:Access:SvgIconLines)
  _Hide:Relate:SvgIconLines &= NEW(Hide:Relate:SvgIconLines)
  Relate:Projects &= _Hide:Relate:Projects
  Relate:ProjectFiles &= _Hide:Relate:ProjectFiles
  Relate:SvgIconLines &= _Hide:Relate:SvgIconLines


NetTalkSVGUtility_BC0:FilesInit PROCEDURE()
  CODE
  _Hide:Relate:Projects.Init
  _Hide:Relate:ProjectFiles.Init
  _Hide:Relate:SvgIconLines.Init


NetTalkSVGUtility_BC0:DctKill PROCEDURE()
  CODE
  _Hide:Relate:Projects.Kill
  DISPOSE(_Hide:Relate:Projects)
  _Hide:Relate:ProjectFiles.Kill
  DISPOSE(_Hide:Relate:ProjectFiles)
  _Hide:Relate:SvgIconLines.Kill
  DISPOSE(_Hide:Relate:SvgIconLines)


Hide:Relate:Projects.Init PROCEDURE()
  CODE
  _Hide:Access:Projects.Init
  SELF.Init(Access:Projects,1)


Hide:Access:Projects.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pro:Record
  SELF.FileNameValue = 'Projects'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Projects
  PARENT.Init
  Access:Projects &= SELF


Hide:Access:Projects.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Projects &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Projects.PrimeFields PROCEDURE

  CODE
  Pro:GUID = glo:St.MakeGuid()                             ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Projects.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Projects,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pro:ProjGuidKey,'Pro:ProjGuidKey',0)
    SELF.AddKey(Pro:ProjDescriptionKey,'Pro:ProjDescriptionKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Projects.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:ProjectFiles,RI:CASCADE,RI:None,ProjFiles:FKProjectGuidKey)
  SELF.AddRelationLink(Pro:GUID,ProjFiles:ProjectGuid)


Hide:Relate:Projects.Kill PROCEDURE

  CODE
  _Hide:Access:Projects.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Projects &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Projects)                           ! destroy the file manager


Hide:Relate:ProjectFiles.Init PROCEDURE()
  CODE
  _Hide:Access:ProjectFiles.Init
  SELF.Init(Access:ProjectFiles,1)


Hide:Access:ProjectFiles.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= ProjFiles:Record
  SELF.FileNameValue = 'ProjectFiles'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= ProjectFiles
  PARENT.Init
  Access:ProjectFiles &= SELF


Hide:Access:ProjectFiles.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:ProjectFiles &= NULL                              ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:ProjectFiles.PrimeFields PROCEDURE

  CODE
  ProjFiles:GUID = glo:st.MakeGuid()                       ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:ProjectFiles.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(ProjectFiles,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(ProjFiles:ProjFilesGuidKey,'ProjFiles:ProjFilesGuidKey',0)
    SELF.AddKey(ProjFiles:FKProjectGuidKey,'ProjFiles:FKProjectGuidKey',0)
    SELF.AddKey(ProjFiles:ProjFilesFileNameKey,'ProjFiles:ProjFilesFileNameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:ProjectFiles.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Projects)

  SELF.AddRelation(Relate:SvgIconLines,RI:CASCADE,RI:None,Svg:FKProjectGuidKey)
  SELF.AddRelationLink(ProjFiles:GUID,Svg:ProjectGuid)


Hide:Relate:ProjectFiles.Kill PROCEDURE

  CODE
  _Hide:Access:ProjectFiles.Kill                           ! Kill the file manager
  PARENT.Kill
  Relate:ProjectFiles &= NULL                              ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:ProjectFiles)                       ! destroy the file manager


Hide:Relate:SvgIconLines.Init PROCEDURE()
  CODE
  _Hide:Access:SvgIconLines.Init
  SELF.Init(Access:SvgIconLines,1)


Hide:Access:SvgIconLines.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Svg:Record
  SELF.FileNameValue = 'SvgIconLines'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= SvgIconLines
  PARENT.Init
  Access:SvgIconLines &= SELF


Hide:Access:SvgIconLines.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:SvgIconLines &= NULL                              ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:SvgIconLines.PrimeFields PROCEDURE

  CODE
  Svg:Guid = glo:st.MakeGuid()                             ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:SvgIconLines.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(SvgIconLines,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Svg:GuidKey,'Svg:GuidKey',0)
    SELF.AddKey(Svg:FKProjectGuidKey,'Svg:FKProjectGuidKey',0)
    SELF.AddKey(Svg:IconNameKey,'Svg:IconNameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:SvgIconLines.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:ProjectFiles)


Hide:Relate:SvgIconLines.Kill PROCEDURE

  CODE
  _Hide:Access:SvgIconLines.Kill                           ! Kill the file manager
  PARENT.Kill
  Relate:SvgIconLines &= NULL                              ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:SvgIconLines)                       ! destroy the file manager

