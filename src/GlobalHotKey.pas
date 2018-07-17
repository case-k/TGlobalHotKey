unit GlobalHotKey;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms;

type
  TModifier = (modALT, modCONTROL, modSHIFT, modWIN);
  TModifiers = set of TModifier;

  TGlobalHotKey = class(TComponent)
  private
    FEnabled: Boolean;
    FWindowHandle: HWND;
    FID: LongWord;
    FOnHotKey: TNotifyEvent;
    FVKCode: LongWord;
    FModifiers: TModifiers;
    FIsRegistered: Boolean;
    FDelegateMsg: UINT;
    procedure SetVKCode(const Value: Cardinal);
    procedure RegHotKey();
    procedure WndProc(var Msg: TMessage);
    procedure SetModifiers(const Value: TModifiers);
    procedure SetID(const Value: LongWord);
    procedure SetEnabled(const Value: Boolean);
    procedure SetOnHotKey(const Value: TNotifyEvent);
    function GetModifiersNum(): Integer;
  protected
    procedure DoHotkey(AKey, AShift: Word); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IsRegistered: Boolean read FIsRegistered;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property ID: LongWord read FID write SetID default 0;
    property Modifiers: TModifiers read FModifiers write SetModifiers default [];
    property VKCode: LongWord read FVKCode write SetVKCode default 0;
    property OnHotKey: TNotifyEvent read FOnHotKey write SetOnHotKey;
  end;

procedure Register;


implementation

procedure Register;
begin
  RegisterComponents('SEED', [TGlobalHotKey]);
end;

{ TGlobalHotKey }

constructor TGlobalHotKey.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FEnabled := True;
  FID := 0;
  FVKCode := 0;
  FModifiers := [];
  FIsRegistered := False;
  FOnHotKey := nil;
  FDelegateMsg := RegisterWindowMessage('TGlobalHotKey');

  // メッセージ受信用のウィンドウを作る
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TGlobalHotKey.Destroy;
begin
  if FIsRegistered then
  begin
    UnRegisterHotKey(FWindowHandle, FID);
    // 破棄したことを競合アプリに通知する
    PostMessage(HWND_BROADCAST, FDelegateMsg, FVKCode, GetModifiersNum);
  end;
  DeallocateHWnd(FWindowHandle);
  inherited;
end;

procedure TGlobalHotKey.DoHotkey(AKey, AShift: Word);
begin
  if Assigned(FOnHotKey) then
    FOnHotKey(Self);
end;

function TGlobalHotKey.GetModifiersNum: Integer;
begin
  Result := 0;
  if modALT in FModifiers then Result := Result or MOD_ALT;
  if modCONTROL in FModifiers then Result := Result or MOD_CONTROL;
  if modSHIFT in FModifiers then Result := Result or MOD_SHIFT;
  if modWIN in FModifiers then Result := Result or MOD_WIN;
end;

procedure TGlobalHotKey.RegHotKey;
var
  mods: UINT;

begin

  UnRegisterHotKey(FWindowHandle, FID);
  FIsRegistered := False;

  if (FVKCode <> 0) and FEnabled and Assigned(FOnHotKey) then
  begin
    // ホットキー登録
    mods := GetModifiersNum;
    FIsRegistered := RegisterHotKey(FWindowHandle, FID, mods, FVKCode);
  end;

// RegisterHotKeyについて
// サンプルだと第二引数のIDにATOMを渡してるけど
// ようはハンドル＋IDでユニークならＯＫ
// 複数登録したい場合はここをずらしながら登録する
// メッセージ受信時もwParam=Indexで判定しながら処理する
end;

procedure TGlobalHotKey.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    RegHotKey();
  end;
end;

procedure TGlobalHotKey.SetID(const Value: LongWord);
begin
  if FID <> Value then
  begin
    UnRegisterHotKey(FWindowHandle, FID);
    FID := Value;
    RegHotKey();
  end;
end;

procedure TGlobalHotKey.SetModifiers(const Value: TModifiers);
begin
  if FModifiers <> Value then
  begin
    FModifiers := Value;
    RegHotkey();
  end;
end;

procedure TGlobalHotKey.SetOnHotKey(const Value: TNotifyEvent);
begin
  FOnHotKey := Value;
  RegHotKey();
end;

procedure TGlobalHotKey.SetVKCode(const Value: Cardinal);
begin
  if FVKCode <> Value then
  begin
    FVKCode := Value;
    RegHotKey();
  end;
end;

procedure TGlobalHotKey.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_HOTKEY) and (UINT(Msg.WParam) = FID) then
    try
      DoHotkey(Msg.LParamHi, Msg.LParamLo)
    except
      Application.HandleException(Self)
    end
  else
  if (Msg.Msg = FDelegateMsg) and (FDelegateMsg <> 0) then
  begin
    if not FIsRegistered and FEnabled and (UINT(Msg.WParam) = FVKCode) and (Msg.LParam = GetModifiersNum) then
      // 競合していた他アプリがホットキーを破棄したので再登録を試みる
      RegHotKey;
  end else
    Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

end.
