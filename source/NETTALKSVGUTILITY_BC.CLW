  MEMBER('NetTalkSVGUtility.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('NetTalkSVGUtility_BC0.CLW')
NetTalkSVGUtility_BC0:DctInit             PROCEDURE()
NetTalkSVGUtility_BC0:DctKill             PROCEDURE()
NetTalkSVGUtility_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  NetTalkSVGUtility_BC0:DctInit
  NetTalkSVGUtility_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  NetTalkSVGUtility_BC0:DctKill

