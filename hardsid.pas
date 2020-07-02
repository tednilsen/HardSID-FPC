unit hardsid;

{-------------------------------------------------------------------------

  unit hardsid.pas

  * HardSID library headers for FPC
    https://github.com/tednilsen/HardSID-FPC

  * Supports SIDBlaster
    https://github.com/Galfodo/SIDBlasterUSB_HardSID-emulation-driver

  * Unit supports static and dynamic loading of the library,
    see hardsid.inc for settings.

-------------------------------------------------------------------------}

{$MODE objfpc}{$H+}
{$I hardsid.inc}            // <- edit for settings

interface

  {$IFDEF HS_STATIC_LIB}    // static hardsid library

  //..........................  hardsid.dll v1.x  ..........................\\
  procedure InitHardSID_Mapper; EXTDECL 'InitHardSID_Mapper';
  function  GetDLLVersion: Word; EXTDECL 'GetDLLVersion';
  function  GetHardSIDCount: Byte; EXTDECL 'GetHardSIDCount';                           // Tells you the number of HardSID's in the machine (depends on the HardSIDConfig.exe !). if 0, no HardSID is configured.
  procedure MuteHardSID(deviceID, channel: Byte; mute: Boolean); EXTDECL 'MuteHardSID';
  procedure MuteHardSID_Line(mute: Boolean); EXTDECL 'MuteHardSID_Line';                // If you selected a HardSID line in HardSIDConfig.exe, you can mute/demute it TRUE/FALSE. USE IT WHILE NOT PLAYING!!!
  procedure MuteHardSIDAll(deviceID: Byte; mute: Boolean); EXTDECL 'MuteHardSIDAll';
  function  ReadFromHardSID(deviceID, sidReg: Byte): Byte; EXTDECL 'ReadFromHardSID';  // Reads data from the HardSID's specified register 0-28 ($00 - $1C), the last two regs are read-only. $1B = Waveform generator, $1C = ADSR generator (for voice #3).
  procedure WriteToHardSID(deviceID, sidReg, data: Byte); EXTDECL 'WriteToHardSID';    // Writes data to the HardSID's specified register 0-28 ($00 - $1C), the last two regs are read-only. Valid DeviceID = 0 to (GetHardSIDCount - 1).
  procedure SetDebug(enabled: Boolean); EXTDECL 'SetDebug';                            // You can display a SID debug window which will show you the states of the SID registers

  //..........................  hardsid.dll v2.x  ..........................\\
  function  HardSID_Read(deviceID: Byte; cycles: Word; sidReg: Byte): Byte; EXTDECL 'HardSID_Read';
  procedure HardSID_Write(deviceID: Byte; cycles: Word; sidReg, data: Byte); EXTDECL 'HardSID_Write';
  procedure HardSID_Delay(deviceID: Byte; cycles: Word); EXTDECL 'HardSID_Delay';
  procedure HardSID_Sync(deviceID: Byte); EXTDECL 'HardSID_Sync';
  procedure HardSID_Filter(deviceID: Byte; Filter: Boolean); EXTDECL 'HardSID_Filter';
  procedure HardSID_Flush(deviceID: Byte); EXTDECL 'HardSID_Flush';
  procedure HardSID_Mute(deviceID, channel: Byte; mute: Boolean); EXTDECL 'HardSID_Mute';
  procedure HardSID_MuteAll(deviceID: Byte; mute: Boolean); EXTDECL 'HardSID_MuteAll';
  procedure HardSID_Reset(deviceID: Byte); EXTDECL 'HardSID_Reset';
  function  HardSID_Devices: Byte; EXTDECL 'HardSID_Devices';
  function  HardSID_Version: Word; EXTDECL 'HardSID_Version';

  //..........................  hardsid.dll v2.0.3  ........................\\
  procedure HardSID_Reset2(deviceID, volume : Byte); EXTDECL 'HardSID_Reset2';        // Click reduction
  function  HardSID_Lock(deviceID : Byte): Boolean; EXTDECL 'HardSID_Lock';           // Lock SID to application
  procedure HardSID_Unlock(deviceID : Byte); EXTDECL 'HardSID_Unlock';
  function  HardSID_Group(deviceID: Byte; Enable: Boolean; groupID: Byte): Boolean; EXTDECL 'HardSID_Group';  // Add SID to group when enable is true.  SID can only be added or moved to an existing group. If deviceID = groupID then a new group is created with the SID device becoming group master. Only writes to the master are played on the other grouped SIDs.

  //..........................  hardsid.dll v2.0.6  ........................\\
  procedure HardSID_Mute2(deviceID, channel: Byte; mute, manual: Boolean); EXTDECL 'HardSID_Mute2';  // Support whether the channel change was a request from the user or the program (auto or manual respectively). External mixers can use this to prioritise requests

  //..........................  hardsid.dll v2.0.7  ........................\\
  procedure HardSID_OtherHardware; EXTDECL 'HardSID_OtherHardware';                   // Enable support for non hardsid hardware (e.g. Catweasel MK3/4)

  //..........................  hardsid.dll v3.x  ..........................\\
  procedure HardSID_SoftFlush(deviceID: Byte); EXTDECL 'HardSID_SoftFlush';
  procedure HardSID_AbortPlay(deviceID: Byte); EXTDECL 'HardSID_AbortPlay';
  procedure HardSID_Try_Write(deviceID: Byte; cycles: Word; sidReg, data: Byte); EXTDECL 'HardSID_Try_Write';

  //..........................  hardsid.dll v3.0.2  ........................\\
  {$IFDEF HS_SIDBLASTER}
  procedure HardSID_ExternalTiming(deviceID: Byte); EXTDECL 'HardSID_ExternalTiming';
  {$ENDIF HS_SIDBLASTER}

implementation

  {$ELSE HS_STATIC_LIB}     // else, dynamic loading of hardsid library

uses
  dynlibs;

  function  HS_InitializeLib: Boolean;
  procedure HS_FinalizeLib;
  function  HS_Initialized: Boolean; inline;
  function  HS_GetLibHandle: TLibHandle; inline;
  procedure HS_SetLibHandle(libHandle: TLibHandle);
  function  HS_GetLibName: string; inline;
  procedure HS_SetLibName(const name: string); inline;

var

  //..........................  hardsid.dll v1.x  ..........................\\
  InitHardSID_Mapper: procedure; EXTDECL;
  GetDLLVersion: function: Word; EXTDECL;
  GetHardSIDCount: function: Byte; EXTDECL;  // Tells you the number of HardSID's in the machine (depends on the HardSIDConfig.exe !). if 0, no HardSID is configured.
  MuteHardSID: procedure(deviceID, channel: byte; mute: Boolean); EXTDECL;
  MuteHardSID_Line: procedure(mute: Boolean); EXTDECL;  // If you selected a HardSID line in HardSIDConfig.exe, you can mute/demute it TRUE/FALSE. USE IT WHILE NOT PLAYING!!!
  MuteHardSIDAll: procedure(deviceID: byte; mute: Boolean); EXTDECL;
  ReadFromHardSID: function(deviceID, sidReg: Byte): Byte; EXTDECL;  // Reads data from the HardSID's specified register 0-28 ($00 - $1C), the last two regs are read-only. $1B = Waveform generator, $1C = ADSR generator (for voice #3).
  WriteToHardSID: procedure(deviceID, sidReg, data: Byte); EXTDECL;  // Writes data to the HardSID's specified register 0-28 ($00 - $1C), the last two regs are read-only. Valid DeviceID = 0 to (GetHardSIDCount - 1).
  SetDebug: procedure(Enabled: Boolean); EXTDECL;  // You can display a SID debug window which will show you the states of the SID registers

  //..........................  hardsid.dll v2.x  ..........................\\
  HardSID_Read: function(deviceID: Byte; cycles: Word; sidReg: Byte): Byte; EXTDECL;
  HardSID_Write: procedure(deviceID: Byte; cycles: Word; sidReg, data: Byte); EXTDECL;
  HardSID_Delay: procedure(deviceID: Byte; cycles: Word); EXTDECL;
  HardSID_Sync: procedure(deviceID: Byte); EXTDECL;
  HardSID_Filter: procedure(deviceID: Byte; Filter: Boolean); EXTDECL;
  HardSID_Flush: procedure(deviceID: Byte); EXTDECL;
  HardSID_Mute: procedure(deviceID, channel: Byte; mute: Boolean); EXTDECL;
  HardSID_MuteAll: procedure(deviceID: Byte; mute: Boolean); EXTDECL;
  HardSID_Reset: procedure(deviceID: Byte); EXTDECL;
  HardSID_Devices: function: Byte; EXTDECL;
  HardSID_Version: function: Word; EXTDECL;

  //..........................  hardsid.dll v2.0.3  ........................\\
  HardSID_Reset2: procedure(deviceID, volume : Byte); EXTDECL;  // Click reduction
  HardSID_Lock: function(deviceID : Byte): Boolean; EXTDECL;  // Lock SID to application
  HardSID_Unlock: procedure(deviceID : Byte); EXTDECL;
  HardSID_Group: function(deviceID: Byte; Enable: Boolean; groupID: Byte): Boolean; EXTDECL;  // Add SID to group when enable is true.  SID can only be added or moved to an existing group. If deviceID = groupID then a new group is created with the SID device becoming group master. Only writes to the master are played on the other grouped SIDs.

  //..........................  hardsid.dll v2.0.6  ........................\\
  HardSID_Mute2: procedure(deviceID, channel: byte; mute, Manual: Boolean); EXTDECL;  // Support whether the channel change was a request from the user or the program (auto or manual respectively). External mixers can use this to prioritise requests

  //..........................  hardsid.dll v2.0.7  ........................\\
  HardSID_OtherHardware: procedure; EXTDECL;  // Enable support for non hardsid hardware (e.g. Catweasel MK3/4)

  //..........................  hardsid.dll v3.x  ..........................\\
  HardSID_SoftFlush: procedure(deviceID: Byte); EXTDECL;
  HardSID_AbortPlay: procedure(deviceID: Byte); EXTDECL;
  HardSID_Try_Write: procedure(deviceID: Byte; cycles: Word; sidReg, data: Byte); EXTDECL;

  //..........................  hardsid.dll v3.0.2  ........................\\
  {$IFDEF HS_SIDBLASTER}
  HardSID_ExternalTiming: procedure(deviceID: Byte); EXTDECL;
  {$ENDIF HS_SIDBLASTER}

implementation

const
  LIB_HARDSID = 'hardsid';

var
  libHS: TLibHandle = NilHandle;      // library handle
  libName: string   = LIB_HARDSID;    // name of the library


//-------------------------------------------------------------------------
//  _initProc
//-------------------------------------------------------------------------
procedure _initProc(var procPointer; procName: PChar);
begin
  pointer(procPointer) := dynlibs.GetProcAddress(libHS, procName);
end;

//-------------------------------------------------------------------------
//  HS_Initialized
//  * Returns True if hardsid library is loaded and present
//-------------------------------------------------------------------------
function HS_Initialized: boolean;
begin
  Result := libHS <> NilHandle;
end;

//-------------------------------------------------------------------------
//  HS_GetLibHandle
//  * Returns the handle of EGL library.
//-------------------------------------------------------------------------
function HS_GetLibHandle: TLibHandle;
begin
  Result := libHS;
end;

//-------------------------------------------------------------------------
//  HS_GetLibName
//  - Returns the library's name (without suffix).
//-------------------------------------------------------------------------
function HS_GetLibName: string;
begin
  Result := libName;
end;

//-------------------------------------------------------------------------
//  HS_SetLibName
//  - Set the name for the library (without suffix).
//-------------------------------------------------------------------------
procedure HS_SetLibName(const name: string);
begin
  libName := name;
end;

//-------------------------------------------------------------------------
//  HS_SetLibHandle
//  - Set the handle of hardsid library.
//-------------------------------------------------------------------------
procedure HS_SetLibHandle(libHandle: TLibHandle);
begin
  libHS := libHandle;
end;

//-------------------------------------------------------------------------
//  HS_NilLib
//  - Nil all the function variables
//-------------------------------------------------------------------------
procedure HS_NilLib;
begin

  //..........................  hardsid.dll v1.x  ..........................\\
  InitHardSID_Mapper := nil;
  GetDLLVersion := nil;
  GetHardSIDCount := nil;
  MuteHardSID := nil;
  MuteHardSID_Line := nil;
  MuteHardSIDAll := nil;
  ReadFromHardSID := nil;
  WriteToHardSID := nil;
  SetDebug := nil;

  //..........................  hardsid.dll v2.x  ..........................\\
  HardSID_Read := nil;
  HardSID_Write := nil;
  HardSID_Delay := nil;
  HardSID_Sync := nil;
  HardSID_Filter := nil;
  HardSID_Flush := nil;
  HardSID_Mute := nil;
  HardSID_Mute2 := nil;
  HardSID_MuteAll := nil;
  HardSID_Reset := nil;
  HardSID_Reset2 := nil;
  HardSID_Group := nil;
  HardSID_Devices := nil;
  HardSID_Lock := nil;
  HardSID_Unlock := nil;
  HardSID_Version := nil;
  HardSID_OtherHardware := nil;

  //..........................  hardsid.dll v3.x  ..........................\\
  HardSID_SoftFlush := nil;
  HardSID_AbortPlay := nil;
  HardSID_Try_Write := nil;

  //..........................  hardsid.dll v3.0.2  ........................\\
  {$IFDEF HS_SIDBLASTER}
  HardSID_ExternalTiming := nil;
  {$ENDIF HS_SIDBLASTER}

end;

//-------------------------------------------------------------------------
//  HS_LoadLib
//  - Set the function variables (if available)
//-------------------------------------------------------------------------
procedure HS_LoadLib;
var version: word = $0000;
begin

  //..........................  hardsid.dll v1.x  ..........................\\
  _initProc(GetDLLVersion, 'GetDLLVersion');
  if Assigned(GetDLLVersion)
    then version := GetDLLVersion()
    else exit;

  if version >= $0100 then begin
    _initProc(InitHardSID_Mapper, 'InitHardSID_Mapper');
    _initProc(GetHardSIDCount, 'GetHardSIDCount');
    _initProc(MuteHardSID, 'MuteHardSID');
    _initProc(MuteHardSID_Line, 'MuteHardSID_Line');
    _initProc(MuteHardSIDAll, 'MuteHardSIDAll');
    _initProc(ReadFromHardSID, 'ReadFromHardSID');
    _initProc(WriteToHardSID, 'WriteToHardSID');
    _initProc(SetDebug, 'SetDebug');
  end;

  //..........................  hardsid.dll v2.x  ..........................\\
  if version >= $0200 then begin
    _initProc(HardSID_Read, 'HardSID_Read');
    _initProc(HardSID_Write, 'HardSID_Write');
    _initProc(HardSID_Delay, 'HardSID_Delay');
    _initProc(HardSID_Sync, 'HardSID_Sync');
    _initProc(HardSID_Filter, 'HardSID_Filter');
    _initProc(HardSID_Flush, 'HardSID_Flush');
    _initProc(HardSID_Mute, 'HardSID_Mute');
    _initProc(HardSID_MuteAll, 'HardSID_MuteAll');
    _initProc(HardSID_Reset, 'HardSID_Reset');
    _initProc(HardSID_Devices, 'HardSID_Devices');
    _initProc(HardSID_Version, 'HardSID_Version');
  end;

  //..........................  hardsid.dll v2.0.3  ........................\\
  if version >= $0203 then begin
    _initProc(HardSID_Reset2, 'HardSID_Reset2');
    _initProc(HardSID_Lock, 'HardSID_Lock');
    _initProc(HardSID_Unlock, 'HardSID_Unlock');
    _initProc(HardSID_Group, 'HardSID_Group');
  end;

  //..........................  hardsid.dll v2.0.6  ........................\\
  if version >= $0206 then begin
    _initProc(HardSID_Mute2, 'HardSID_Mute2');
  end;

  //..........................  hardsid.dll v2.0.7  ........................\\
  if version >= $0207 then begin
    _initProc(HardSID_OtherHardware, 'HardSID_OtherHardware');
  end;

  //..........................  hardsid.dll v3.x  ..........................\\
  if version >= $0300 then begin
    _initProc(HardSID_SoftFlush, 'HardSID_SoftFlush');
    _initProc(HardSID_AbortPlay, 'HardSID_AbortPlay');
    _initProc(HardSID_Try_Write, 'HardSID_Try_Write');
  end;

  //..........................  hardsid.dll v3.0.2  ........................\\
  {$IFDEF HS_SIDBLASTER}
  if version >= $0302 then begin
    _initProc(HardSID_ExternalTiming, 'HardSID_ExternalTiming');
  end;
  {$ENDIF HS_SIDBLASTER}

end;

//-------------------------------------------------------------------------
//  HS_InitializeLib
//  - Load and Initialize the hardsid library.
//-------------------------------------------------------------------------
function HS_InitializeLib: boolean;
begin

  try

    HS_NilLib;

    if libHS = NilHandle
      then libHS:= dynlibs.LoadLibrary(libName + '.' + dynlibs.SharedSuffix);

    if libHS <> NilHandle
      then HS_LoadLib;

  finally
    Result := libHS <> NilHandle;
  end;

end;

//-------------------------------------------------------------------------
//  HS_FinalizeLib
//  - Unloads the hardsid library (if loaded and not shared)
//-------------------------------------------------------------------------
procedure HS_FinalizeLib;
begin

  if libHS <> NilHandle then begin
    dynlibs.FreeLibrary(libHS);
    libHS := NilHandle;
    HS_NilLib;
  end;

end;

{$IFDEF HS_AutoInitialize}      // <--- define to automatic initialize the unit

//=========================================================
//  initialization
//=========================================================
initialization
begin
  HS_InitializeLib;
end;

//=========================================================
//  finalization
//=========================================================
finalization
begin
  HS_FinalizeLib;
end;

{$ENDIF HS_AutoInitialize}

{$ENDIF HS_STATIC_LIB}

end.


