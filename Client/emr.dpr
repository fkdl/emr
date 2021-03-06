program emr;

{$IFDEF not DEBUG}
  {$IF CompilerVersion >= 21.0}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$IFEND}
{$ENDIF}

uses
  System.ShareMem,
  Vcl.Forms,
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,
  Winapi.Windows,
  Winapi.ShellAPI,
  emr_UpDownLoadClient,
  emr_Common,
  frm_Hint,
  frm_ConnSet,
  frm_Emr in 'frm_Emr.pas' {frmEmr},
  frm_DM in '..\Common\frm_DM.pas' {dm: TDataModule};

{$R *.res}

const
  STR_UNIQUE = '{CC1EB815-7992-41F5-B112-571DE13CD8DF}';

var
  vFrmHint: TfrmHint;

{$REGION 'DownLoadUpdateExe下载Update.exe文件'}
function DownLoadUpdateExe: Boolean;
var
  vFileStream: TFileStream;
  vUpDownLoadClient: TUpDownLoadClient;
begin
  Result := False;
  vUpDownLoadClient := TUpDownLoadClient.Create;
  try
    vUpDownLoadClient.Host := ClientCache.ClientParam.UpdateServerIP;  // 更新服务器IP
    vUpDownLoadClient.Port := ClientCache.ClientParam.UpdateServerPort;  // 更新服务器端口
    try
      vUpDownLoadClient.Connect;
    except
      ShowMessage('异常：连接升级服务器失败，请检查('
        + ClientCache.ClientParam.UpdateServerIP + ':'
        + ClientCache.ClientParam.UpdateServerPort.ToString + ')！');

      Exit;
    end;

    if vUpDownLoadClient.Connected then  // 连接更新服务器成功
    begin
      vFileStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'update.exe', fmCreate or fmShareDenyWrite);
      try
        if vUpDownLoadClient.DownLoadFile('update.exe', vFileStream,
          procedure(const AReciveSize, AFileSize: Integer)
          begin
            vFrmHint.UpdateHint('正在下载更新程序，请稍候...' + Round(AReciveSize / AFileSize * 100).ToString + '%');
          end)
        then  // 下载update.exe成功
          Result := True
        else
          raise Exception.Create('异常：下载升级文件update.exe失败！' + vUpDownLoadClient.CurError);
      finally
        vFileStream.Free;
      end;
    end
    else
    begin
      raise Exception.Create('异常：连接升级服务器失败，请检查('
        + ClientCache.ClientParam.UpdateServerIP + ':'
        + ClientCache.ClientParam.UpdateServerPort.ToString + ')！');
    end;
  finally
    vUpDownLoadClient.Free;
  end;
end;
{$ENDREGION}

var
  vMutHandle: THandle;
  vLastVerID: Integer;
  vLastVerStr: string;
  vFrmConnSet: TfrmConnSet;
begin
  vMutHandle := OpenMutex(MUTEX_ALL_ACCESS, False, STR_UNIQUE);  // 打开互斥对象
  if vMutHandle = 0 then
    vMutHandle := CreateMutex(nil, False, STR_UNIQUE) // 建立互斥对象
  else
  begin
    ShowMessage('EMR客户端已经在运行！');
    Exit;
  end;

  Application.Initialize;
  Application.Title := '电子病历';
  Application.MainFormOnTaskbar := False;

  vFrmHint := TfrmHint.Create(nil);
  try
    vFrmHint.Show;
    vFrmHint.UpdateHint('正在启动EMR客户端，请稍候...');

    if not Assigned(ClientCache) then
      ClientCache := TClientCache.Create;

    GetClientParam;  // 获取本地参数

    // 校验升级
    try
      GetLastVersion(vLastVerID, vLastVerStr);  // 服务端当前最新的客户端版本号

      if ClientCache.ClientParam.VersionID <> vLastVerID then  // 版本不一致
      begin
        if ClientCache.ClientParam.VersionID > vLastVerID then  // 客户端版高于服务端当前最新的客户端版本号
          ShowMessage('EMR客户端版高于服务端版本，程序不配套！')
        else
        if ClientCache.ClientParam.VersionID < vLastVerID then  // 需要升级
        begin
          if DownLoadUpdateExe then  // 下载Update.exe文件，内部会处理错误和下载失败时提示信息
          begin
            vFrmHint.UpdateHint('正在启动EMR更新程序，请稍候...');
            ShellExecute(GetDesktopWindow, nil, 'update.exe', nil, nil, SW_SHOWNORMAL);  // 启动Update.exe更新程序
          end;
        end;

        if Assigned(ClientCache) then
          FreeAndNil(ClientCache);

        Exit;
      end;
    except
      on E: Exception do
      begin
        if MessageDlg('EMR客户端启动出现异常，打开连接配置界面？' + #13#10 + #13#10
          + '异常信息：' + E.Message,
          TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes
        then
        begin
          FreeAndNil(vFrmHint);
          Application.CreateForm(TFrmConnSet, vFrmConnSet);  // 创建连接配置界面
          Application.Run;
        end;

        FreeAndNil(vFrmConnSet);
        if Assigned(ClientCache) then
          FreeAndNil(ClientCache);

        Exit;
      end;
    end;

    dm := Tdm.Create(nil);

    vFrmHint.UpdateHint('正在加载缓存，请稍候...');
    ClientCache.GetCacheData;

    vFrmHint.UpdateHint('正在启动程序，请稍候...');
    Application.CreateForm(TfrmEmr, frmEmr);
  finally
    FreeAndNil(vFrmHint);
  end;

  if frmEmr.LoginPluginExecute then  // 登录成功
    Application.Run;

  FreeAndNil(frmEmr);
  FreeAndNil(dm);
  if Assigned(ClientCache) then
    FreeAndNil(ClientCache);
end.
