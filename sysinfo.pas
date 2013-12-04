unit sysinfo;

interface

uses
Windows,SysUtils,Registry,Nb30;

function GetMACAdress: string;
function GetBitWindows: string;
function GetComputerNetName: string;
function GetCpuName:string;
function GetCPUCount: string;
implementation


function GetMACAdress: string;
 var
   NCB: PNCB;
   Adapter: PAdapterStatus;
   URetCode: PAnsiChar;
   RetCode: Ansichar;
   I: integer;
   Lenum: PlanaEnum;
   _SystemID: string;
   TMPSTR: string;
 begin
   Result    := '';
   _SystemID := '';
   Getmem(NCB, SizeOf(TNCB));
   Fillchar(NCB^, SizeOf(TNCB), 0);

   Getmem(Lenum, SizeOf(TLanaEnum));
   Fillchar(Lenum^, SizeOf(TLanaEnum), 0);

   Getmem(Adapter, SizeOf(TAdapterStatus));
   Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);

   Lenum.Length    := chr(0);
   NCB.ncb_command := chr(NCBENUM);
   NCB.ncb_buffer  := Pointer(Lenum);
   NCB.ncb_length  := SizeOf(Lenum);
   RetCode         := Netbios(NCB);

   i := 0;
   repeat
     Fillchar(NCB^, SizeOf(TNCB), 0);
     Ncb.ncb_command  := chr(NCBRESET);
     Ncb.ncb_lana_num := lenum.lana[I];
     RetCode          := Netbios(Ncb);

     Fillchar(NCB^, SizeOf(TNCB), 0);
     Ncb.ncb_command  := chr(NCBASTAT);
     Ncb.ncb_lana_num := lenum.lana[I];
     // Must be 16
    Ncb.ncb_callname := '*               ';

     Ncb.ncb_buffer := Pointer(Adapter);

     Ncb.ncb_length := SizeOf(TAdapterStatus);
     RetCode        := Netbios(Ncb);
     //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
    if (RetCode = chr(0)) or (RetCode = chr(6)) then
     begin
       _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' +
         IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' +
         IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' +
         IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' +
         IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
         IntToHex(Ord(Adapter.adapter_address[5]), 2);
     end;
     Inc(i);
   until (I >= Ord(Lenum.Length)) or (_SystemID <> '00-00-00-00-00-00');
   FreeMem(NCB);
   FreeMem(Adapter);
   FreeMem(Lenum);
   GetMacAdress := _SystemID;
 end;

function GetBitWindows: string;
var
 IsWow64Process: function(hProcess: THandle; out Wow64Process: Bool): Bool; stdcall;
 Wow64Process: Bool;
begin
 {$IF Defined(CPU64)}
 Result := '64';
 {$ELSEIF Defined(CPU16)}
 Result := '32';
 {$ELSE}
 @IsWow64Process := GetProcAddress(GetModuleHandle('Kernel32.dll'), PAnsiChar('IsWow64Process'));
 Wow64Process := False;
 if Assigned(IsWow64Process) then
   Wow64Process := IsWow64Process(GetCurrentProcess, Wow64Process) and Wow64Process;
 if Wow64Process then  Result:='64'
 else Result := '32';
 {$IFEND}
end;

function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

function GetCpuName:string;
var
  reg:tregistry;
begin
  reg := tregistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.OpenKeyReadOnly('HARDWARE\DESCRIPTION\System\CentralProcessor\0');
  Result := reg.ReadString('ProcessorNameString');
  reg.Free;
end;

function GetCPUCount: string;
var
  si: TSystemInfo;
begin
   GetSystemInfo( si );
   Result := IntToStr(si.dwNumberOfProcessors);
end;

end.
