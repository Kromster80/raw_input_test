unit UnitRawInput;
interface
uses
  Windows, Messages, SysUtils, Dialogs,
  UnitRawInputHeaders;


type
  TMouseInfo = record
    MouseId: Integer;
    RawMouseData: tagRAWMOUSE;
  end;

type
  TMyRawInput = class
  private
    fMouseInfo: TMouseInfo;

    fDeviceCount: Cardinal;
    fDevices: array of tagRAWINPUTDEVICELIST; // In one array populated by GetRawInputDeviceList
    fDeviceNames: array of string;

    function GetDeviceIndex(hDevice: THandle): Integer;
    procedure LoadDeviceList;
    procedure LoadDeviceDescriptions;
    procedure RegisterListener;
  public
    constructor Create;
    procedure DoMessage(var aMsg: TMsg; var aHandled: Boolean);
    property MouseInfo: TMouseInfo read fMouseInfo;
    property DeviceCount: Cardinal read fDeviceCount;
    function GetDeviceInfo(aIndex: Integer): string;
  end;


implementation


{ TMyRawInput }
constructor TMyRawInput.Create;
begin
  inherited;

  LoadDeviceList;
  LoadDeviceDescriptions;
  RegisterListener;
end;


function TMyRawInput.GetDeviceIndex(hDevice: THandle): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to fDeviceCount - 1 do
    if fDevices[I].hDevice = hDevice then
      Exit(I);
end;


procedure TMyRawInput.LoadDeviceList;
begin
  // See how many devices do we have
  if GetRawInputDeviceList(nil, fDeviceCount, SizeOf(RAWINPUTDEVICELIST)) <> 0 then
    ShowMessage('GetRawInputDeviceList error 1');

  SetLength(fDevices, fDeviceCount);
  if GetRawInputDeviceList(@fDevices[0], fDeviceCount, SizeOf(RAWINPUTDEVICELIST)) = UINT(-1) then
    ShowMessage('GetRawInputDeviceList error 2');
end;


procedure TMyRawInput.LoadDeviceDescriptions;
const
  MAX_DEVICE_NAME_LENGTH = 2048;
var
  I: Integer;
  max: Cardinal;
  p: array [0..MAX_DEVICE_NAME_LENGTH-1] of Byte;
  charCount: Cardinal;
  newDeviceName: string;
begin
  SetLength(fDeviceNames, fDeviceCount);
  for I := 0 to fDeviceCount - 1 do
  begin
    max := MAX_DEVICE_NAME_LENGTH;
    charCount := GetRawInputDeviceInfo(fDevices[I].hDevice, RIDI_DEVICENAME, @p[0], max);
    if charCount = Cardinal(-1) then
      ShowMessage(Format('Buffer too small (%d), should have been %d', [MAX_DEVICE_NAME_LENGTH, max]));

    SetString(newDeviceName, PWideChar(@p[0]), charCount);

    fDeviceNames[I] := newDeviceName;
  end;
end;


procedure TMyRawInput.RegisterListener;
const
  // https://docs.microsoft.com/en-us/windows-hardware/drivers/hid/hid-usages#usage-page
  HID_USAGE_PAGE_GENERIC = 1;
  HID_USAGE_PAGE_GAME = 5;
  HID_USAGE_PAGE_LED = 8;
  HID_USAGE_PAGE_BUTTON = 9;
  // https://docs.microsoft.com/en-us/windows-hardware/drivers/hid/hid-usages#usage-id
  HID_USAGE_GENERIC_MOUSE = 2;
  HID_USAGE_GENERIC_KEYBOARD = 6;
var
  rid: tagRAWINPUTDEVICE;
begin
  // To receive WM_INPUT messages, an application must first register the raw input devices using RegisterRawInputDevices.
  // By default, an application does not receive raw input.
  rid.usUsagePage := HID_USAGE_PAGE_GENERIC;
  rid.usUsage := HID_USAGE_GENERIC_MOUSE;
  rid.dwFlags := 0;
  rid.hwndTarget := 0; // If NULL it follows the keyboard focus
  RegisterRawInputDevices(@rid, 1, SizeOf(rid));
end;


procedure TMyRawInput.DoMessage(var aMsg: TMsg; var aHandled: Boolean);
var
  dwSize: Cardinal;
  ri: tagRAWINPUT;
begin
  if aMsg.message = WM_INPUT then
  begin
    // Reset
    fMouseInfo := default(TMouseInfo);

    GetRawInputData(HRAWINPUT(aMsg.lParam), RID_INPUT, nil, dwSize, SizeOf(RAWINPUTHEADER));

    if dwSize = 0 then
      ShowMessage('Can not allocate memory');

    if GetRawInputData(HRAWINPUT(aMsg.lParam), RID_INPUT, @ri, dwSize, SizeOf(RAWINPUTHEADER)) <> dwSize then
      ShowMessage('GetRawInputData doesn''t return correct size !');

    if ri.header.dwType = RIM_TYPEMOUSE then
    begin
      fMouseInfo.MouseId := GetDeviceIndex(ri.header.hDevice);
      fMouseInfo.RawMouseData := ri.mouse;
    end;
  end;
end;


function TMyRawInput.GetDeviceInfo(aIndex: Integer): string;
begin
  case fDevices[aIndex].dwType of
    RIM_TYPEMOUSE:    Result := 'mouse';
    RIM_TYPEKEYBOARD: Result := 'keyboard';
    RIM_TYPEHID:      Result := 'hid';
  else
    Result := 'unknown ' + IntToStr(fDevices[aIndex].dwType);
  end;

  Result := Result + ': ' + fDeviceNames[aIndex];
end;


end.
