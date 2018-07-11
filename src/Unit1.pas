unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GlobalHotKey, StdCtrls, ComObj, Excel2000;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GlobalHotKey1: TGlobalHotKey;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure GlobalHotKey1HotKey(Sender: TObject);
  private
    { Private 宣言 }
    FHotKey: TGlobalHotKey;
    procedure OnHotKey(Sender: TObject);
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

uses
  Clipbrd;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FHotKey := TGlobalHotKey.Create(Self);
  FHotKey.OnHotKey := OnHotKey;
  FHotKey.VKCode := VK_PAUSE;
  FHotKey.Enabled := True;

//  if FHotKey.IsRegistered then
//    Memo1.Lines.add('reged');

//  GlobalHotKey1.VKCode := 19;
//  GlobalHotKey1.Enabled := True;
end;

procedure GetScreenShot(BMP: Graphics.TBitmap);
var
  DC: hdc;

begin
  BMP.Width := Screen.Width;
  BMP.Height := Screen.Height;

  DC := GetDC(0);
  try
    BitBlt(BMP.Canvas.Handle, 0, 0, BMP.Width, BMP.Height, DC, 0, 0, SRCCOPY);
  finally
    ReleaseDC(0, DC);
  end;
end;


procedure TForm1.OnHotKey(Sender: TObject);
var
  bmp: Graphics.TBitmap;

  Excel: Variant;
  xlApplication: Variant;
  xlWorkBook: Variant;
  xlWorkSheet: Variant;

begin

  bmp := Graphics.TBitmap.Create();
  try

    GetScreenShot(bmp);

    //bmp.SaveToFile('I:\test000000000.bmp');
    ClipBoard.Assign(bmp);


    // エクセル起動
    try
      Excel := CreateOleObject('Excel.Application');
      xlApplication := Excel.Application;
    except
      // 起動失敗時の処理
      on EOleSysError do
      begin
        ShowMessage('Excelを起動できません');
        Excel := Unassigned;
        Exit;
      end;
    end;

    // ブックの新規作成
    xlWorkBook := xlApplication.Workbooks.Add;

    // Sheet1 を選択
    xlWorkSheet := xlWorkBook.Worksheets['Sheet1'];

    // シートをアクティブにする
    xlWorkSheet.Activate;

    // A1に貼り付け
    xlWorkSheet.Range['A1','A1'].Select;
    xlWorkSheet.Paste;

    // 用紙の向きを横に
    xlWorkSheet.PageSetup.Orientation := 2; // xlLandscape=2

    // 位置を中央に
    xlWorkSheet.PageSetup.CenterHorizontally := True;
    xlWorkSheet.PageSetup.CenterVertically := True;

    // １頁に収まるように
    xlWorkSheet.PageSetup.Zoom := False;
    xlWorkSheet.PageSetup.FitToPagesWide := 1;
    xlWorkSheet.PageSetup.FitToPagesTall := 1;

    // ウィンドウの表示
    xlApplication.Visible := True;

    // Excelを終了する
    //xlApplication.Quit;

    // 明示的に破棄
    Excel := Unassigned;
    xlApplication := Unassigned;

  finally
    bmp.Free;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i1, i2: integer;
  e: double;

begin
  i1 := 5;
  i2 := 0;

  e := i1 / i2;

  memo1.Lines.Add(inttostr(trunc(e)));

end;

procedure TForm1.GlobalHotKey1HotKey(Sender: TObject);
begin
  showmessage('!!!');
end;

end.
