{*******************************************************}
{                                                       }
{         基于HCView的电子病历程序  作者：荆通          }
{                                                       }
{ 此代码仅做学习交流使用，不可用于商业目的，由此引发的  }
{ 后果请使用者承担，加入QQ群 649023932 来获取更多的技术 }
{ 交流。                                                }
{                                                       }
{*******************************************************}

unit emr_BLLServerProxy;

interface

uses
  Classes, diocp_tcp_blockClient, emr_MsgPack;

const
  BLL_CMD = 'b.cmd';
  //BACKDATA = 'p.data';  // 用于返回调用方法返回的数据集
  BLL_PROXYTYPE = 'b.type';  // 服务代理类型
  BLL_VER = 'b.ver';  // 业务版本
  BLL_METHODRESULT = 'b.ret';  // 服务端方法返回给客户端的方法执行是否成功
  BLL_RECORDCOUNT = 'b.rcount';  // 存放服务端方法执行时数据集的个数
  BLL_METHODMSG = 'b.msg';  // 服务端服方法执行时回传给给客户端的消息(如失败原因等)
  BLL_EXECPARAM = 'b.exp';  // 存放客户端调用业务时传递的：Sql字段参数数据
  BLL_REPLACEPARAM = 'b.rep';  // 存放客户端调用业务时传递的：Sql替换参数数据

  BLL_BATCH = 'b.bat';  // 存放客户端调用业务时是否是批量操作
  BLL_BATCHDATA = 'b.batdata';  // 存放客户端调用业务时批量传递的数据集

  BLL_BACKDATASET = 'b.bkds';  // 存放客户端调用业务时传递的：通知服务端需要返回数据集(优先级高于BLLBACKPARAM)
  BLL_DATASET = 'b.ds';   // 存放客户端调用业务时传递的：服务端返回的数据集
  BLL_BACKFIELD = 'b.field';  // 存放客户端调用业务时传递的：通知需要返回的数据字段(优先级低于BLLBACKDATA)
  BLL_DEVICE = 'b.dc';      // 连接服务端的设备类型
  BLL_DEVICEINFO = 'b.dcf'; // 连接服务端的设备信息
  BLL_ERROR = 'b.err';  // 错误信息，供调用业务失败时方便调用处提示

  /// <summary> 获取服务器当前时间 </summary>
  BLL_SRVDT = 1;

  /// <summary> 执行Sql语句 </summary>
  BLL_EXECSQL = 2;

  /// <summary> 获取所有表和表说明 </summary>
  BLL_GETAllTABLE = 3;

  BLL_BASE = 1000;  // 业务常量起始值

  { 业务常量(从1000开始) }
  /// <summary> 全部用户 </summary>
  BLL_COMM_ALLUSER = BLL_BASE;

  /// <summary> 验证账号密码匹配 </summary>
  BLL_CERTIFICATE = BLL_BASE + 1;

  /// <summary> 获取指定用户信息 </summary>
  BLL_GETUSERINFO = BLL_BASE + 2;

  /// <summary> 获取用户的工作组 </summary>
  BLL_GETUSERGROUPS = BLL_BASE + 3;

  /// <summary> 获取用户的角色 </summary>
  BLL_GETUSERROLES = BLL_BASE + 4;

  /// <summary> 获取指定用户配置的所有功能 </summary>
  BLL_GETUSERFUNS = BLL_BASE + 5;

  /// <summary> 获取指定用户所有工作组对应的科室 </summary>
  BLL_GETUSERGROUPDEPTS = BLL_BASE + 6;

  /// <summary> 获取参数 </summary>
  BLL_COMM_GETPARAM = BLL_BASE + 7;

  /// <summary> 获取服务端缓存表数据 </summary>
  BLL_GETCLIENTCACHE = BLL_BASE + 8;

  /// <summary> 获取指定窗体上所有受权限控制的控件 </summary>
  BLL_GETCONTROLSAUTH = BLL_BASE + 9;

  /// <summary> 获取要升级的最新版本号 </summary>
  BLL_GETLASTVERSION = BLL_BASE + 10;

  /// <summary> 获取要升级的文件 </summary>
  BLL_GETUPDATEINFO = BLL_BASE + 11;

  /// <summary> 上传升级信息 </summary>
  BLL_UPLOADUPDATEINFO = BLL_BASE + 12;

  /// <summary> 获取在院患者 </summary>
  BLL_HIS_GETINPATIENT = BLL_BASE + 13;

  /// <summary> 获取数据集(根目录)信息 </summary>
  BLL_GETDATAELEMENTSETROOT = BLL_BASE + 14;

  /// <summary> 获取数据集(全目录)信息 </summary>
  BLL_GETDATAELEMENTSETALL = BLL_BASE + 15;

  /// <summary> 获取指定数据集对应的模板 </summary>
  BLL_GETTEMPLATELIST = BLL_BASE + 16;

  /// <summary> 新建模板 </summary>
  BLL_NEWTEMPLATE = BLL_BASE + 17;

  /// <summary> 获取模板内容 </summary>
  BLL_GETTEMPLATECONTENT = BLL_BASE + 18;

  /// <summary> 保存模板内容 </summary>
  BLL_SAVETEMPLATECONTENT = BLL_BASE + 19;

  /// <summary> 删除模板及内容 </summary>
  BLL_DELETETEMPLATE = BLL_BASE + 20;

  /// <summary> 获取数据元 </summary>
  BLL_GETDATAELEMENT = BLL_BASE + 21;

  /// <summary> 获取数据元值域选项 </summary>
  BLL_GETDOMAINITEM = BLL_BASE + 22;

  /// <summary> 保存数据元选项值域对应的内容 </summary>
  BLL_SAVEDOMAINITEMCONTENT = BLL_BASE + 23;

  /// <summary> 获取数据元选项值域对应的内容 </summary>
  BLL_GETDOMAINITEMCONTENT = BLL_BASE + 24;

  /// <summary> 删除数据元选项值域对应的内容 </summary>
  BLL_DELETEDOMAINITEMCONTENT = BLL_BASE + 25;

  /// <summary> 获取指定的住院患者病历列表 </summary>
  BLL_GETINCHRECORDLIST = BLL_BASE + 26;

  /// <summary> 新建住院病历 </summary>
  BLL_NEWINCHRECORD = BLL_BASE + 27;

  /// <summary> 获取指定住院病历内容 </summary>
  BLL_GETINCHRECORDCONTENT = BLL_BASE + 28;

  /// <summary> 保存指定住院病历内容 </summary>
  BLL_SAVERECORDCONTENT = BLL_BASE + 29;

  /// <summary> 获取指定患者数据集(根目录)对应的病历内容 </summary>
  BLL_GETDESETRECORDCONTENT = BLL_BASE + 30;

  /// <summary> 删除指定的住院病历 </summary>
  BLL_DELETEINCHRECORD = BLL_BASE + 31;

  /// <summary> 获取指定数据元的属性信息 </summary>
  BLL_GETDEPROPERTY = BLL_BASE + 32;

  /// <summary> 住院病历签名 </summary>
  BLL_INCHRECORDSIGNATURE = BLL_BASE + 33;

  /// <summary> 获取住院病历签名信息 </summary>
  BLL_GETINCHRECORDSIGNATURE = BLL_BASE + 34;

  /// <summary> 获取模板信息 </summary>
  BLL_GETTEMPLATEINFO = BLL_BASE + 35;

  /// <summary> 修改模板信息 </summary>
  BLL_SETTEMPLATEINFO = BLL_BASE + 36;

  /// <summary> 获取指定数据元信息 </summary>
  BLL_GETDEINFO = BLL_BASE + 37;

  /// <summary> 修改指定数据元信息 </summary>
  BLL_SETDEINFO = BLL_BASE + 38;

  /// <summary> 新建数据元 </summary>
  BLL_NEWDE = BLL_BASE + 39;

  /// <summary> 删除数据元 </summary>
  BLL_DELETEDE = BLL_BASE + 40;

  /// <summary> 获取指定据元值域选项 </summary>
  BLL_GETDOMAINITEMINFO = BLL_BASE + 41;

  /// <summary> 修改数据元值域选项 </summary>
  BLL_SETDOMAINITEMINFO = BLL_BASE + 42;

  /// <summary> 新建数据元值域选项 </summary>
  BLL_NEWDOMAINITEM = BLL_BASE + 43;

  /// <summary> 删除数据元值域选项 </summary>
  BLL_DELETEDOMAINITEM = BLL_BASE + 44;

  /// <summary> 获取所有值域 </summary>
  BLL_GETDOMAIN = BLL_BASE + 45;

  /// <summary> 新建值域 </summary>
  BLL_NEWDOMAIN = BLL_BASE + 46;

  /// <summary> 修改值域 </summary>
  BLL_SETDOMAIN = BLL_BASE + 47;

  /// <summary> 删除值域 </summary>
  BLL_DELETEDOMAIN = BLL_BASE + 48;

  /// <summary> 删除值域对应的所有选项 </summary>
  BLL_DELETEDOMAINALLITEM = BLL_BASE + 49;

  /// <summary> 获取数据集包含的所有数据元 </summary>
  BLL_GETDATASETELEMENT = BLL_BASE + 50;

type
  /// <summary> 调用的服务代理类型 </summary>
  TProxyType = (
    /// <summary> 数据库中业务语句 </summary>
    cptDBL,
    /// <summary> 服务端支持的业务 </summary>
    cptSBL);

  TBLLServerProxy = class(TObject)
  private
    FReconnect: Boolean;
    FTcpClient: TDiocpBlockTcpClient;
    FDataStream: TMemoryStream;
    FErrCode: Integer;  // 错误代码
    FErrMsg: string;  // 发生错误时的 ip和端口
    procedure CheckConnect;
    function SendStream(pvStream: TStream): Integer;
    procedure DoError(const AErrCode: Integer; const AParam: string);
    /// <summary>
    /// 获取指定的参数
    /// </summary>
    function Param(const AParamName: string): TMsgPack;
  protected
    FMsgPack: TMsgPack;
    function GetHost: string;
    procedure SetHost(const AHost: string);
    function GetPort: Integer;
    procedure SetPort(const APort: Integer);
    function GetActive: Boolean;
    function GetCmd: Integer;
    procedure SetCmd(const Value: Integer);
    function GetBackDataSet: Boolean;
    procedure SetBackDataSet(const Value: Boolean);

    function GetBatch: Boolean;
    procedure SetBatch(const Value: Boolean);

    function GetTimeOut: Integer;
    procedure SetTimeOut(const Value: Integer);
    //
    function SendDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
    function RecvDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
    function PeekDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
  public
    constructor Create; virtual;
    constructor CreateEx(const AHost: string; const APort: Integer;
      AReconnect: Boolean = True);
    destructor Destroy; override;

    function Connected: Boolean;
    procedure ReConnectServer;
    function SendDataStream: Integer;
    function RecvDataStream: Boolean;

    /// <summary>
    /// 向服务端传递客户端调用数据
    /// </summary>
    /// <param name="AMsgPack"></param>
    /// <returns>服务端处理此次调用是否成功(仅表示服务端响应客户端调用成功，不代表方法执行的结果)</returns>
    function DispatchPack(const AMsgPack: TMsgPack): Boolean; overload;
    function DispatchPack: Boolean; overload;

    /// <summary>
    /// 存放客户端调用服务端方法时Sql语句的字段参数
    /// </summary>
    function ExecParam: TMsgPack;

    /// <summary>
    /// 存放客户端调用服务端方法时Sql语句的替换参数
    /// </summary>
    /// <returns></returns>
    function ReplaceParam: TMsgPack;

    /// <summary>
    /// 向服务端调用的方法添加一个要返回的字段
    /// </summary>
    procedure AddBackField(const AFieldName: string);

    /// <summary>
    /// 获取服务端方法返回的指定字段数据
    /// </summary>
    function BackField(const AFieldName: string): TMsgPack;

    /// <summary>
    /// 客户端调用的服务端具体方法执行是否成功
    /// </summary>
    function MethodRunOk: Boolean;

    // 记录服务端响应方法错误时的信息(BACKMSG)或响应成功时方法执行结果错误时的信息(BLL_METHODMSG)
    function MethodError: string;

    // 记录服务端响应成功时方法执行结果数据集的个数
    function RecordCount: Integer;

    /// <summary> 将返回的业务数据集写入内存流 </summary>
    /// <param name="AStream">存放数据集</param>
    procedure GetBLLDataSet(const AStream: TMemoryStream);

    //property MsgPack: TMsgPack read FMsgPack;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    //property TcpClient: TDiocpBlockTcpClient read FTcpClient;
    property DataStream: TMemoryStream read FDataStream;

    /// <summary>
    /// 每次调用服务时重连服务器(调用完服务后断开节省资源)
    /// </summary>
    property Reconnect: Boolean read FReconnect write FReconnect;
    property Active: Boolean read GetActive;
    property Cmd: Integer read GetCmd write SetCmd;
    /// <summary> 服务端是否返回数据集 </summary>
    property BackDataSet: Boolean read GetBackDataSet write SetBackDataSet;

    /// <summary> 是否批量处理数据 </summary>
    property Batch: Boolean read GetBatch write SetBatch;

    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property ErrCode: Integer read FErrCode;
    property ErrMsg: string read FErrMsg;
  end;

  //  function GetBLLMethodName(const AMethodID: Integer): string;

implementation

uses
  SysUtils, utils_zipTools, utils_byteTools, DiocpError;

//function GetBLLMethodName(const AMethodID: Integer): string;
//begin
//  case AMethodID of
//    BLL_SRVDT: Result := 'BLL_SRVDT(1 获取数据库时间)';
//    BLL_EXECSQL: Result := 'BLL_EXECSQL(2 执行Sql语句)';
//    BLL_GETAllTABLE: Result := 'BLL_GETAllTABLE(3 获取所有表和表说明)';
//    BLL_LOGIN: Result := 'BLL_LOGIN(1001 核对登录信息)';
//    BLL_GETUSERINFO: Result := 'BLL_GETUSERINFO(1002 获取指定用户的信息)';
//    BLL_GETUSERGROUPS: Result := 'BLL_GETUSERGROUPS(1003 获取用户的工作组)';
//    BLL_GETUSERROLES: Result := 'BLL_GETUSERROLES(1004 获取用户的角色)';
//    BLL_GETUSERFUNS: Result := 'BLL_GETUSERFUNS(1005 获取指定用户配置的所有功能)';
//    BLL_GETUSERGROUPDEPTS: Result := 'BLL_GETUSERGROUPDEPTS(1006 获取指定用户所有工作组对应的科室)';
//    BLL_COMM_GETPARAM: Result := 'BLL_COMM_GETPARAM(1007 获取参数)';
//    BLL_GETCLIENTCACHE: Result := 'BLL_GETCLIENTCACHE(1008 获取服务端缓存表数据)';
//    BLL_GETCONTROLSAUTH: Result := 'BLL_GETCONTROLSAUTH(1009 获取指定窗体上所有受权限控制的控件)';
//    BLL_GETLASTVERSION: Result := 'BLL_GETLASTVERSION(1010 获取要升级的最新版本号)';
//    BLL_GETUPDATEINFO: Result := 'BLL_GETUPDATEINFO(1011 获取要升级的文件)';
//    BLL_UPLOADUPDATEINFO: Result := 'BLL_UPLOADUPDATEINFO(1012 上传升级信息)';
//    BLL_HIS_GETINPATIENT: Result := 'BLL_HIS_GETPATIENT(1013 获取在院患者)';
//    BLL_GETDATAELEMENTSET: Result := 'BLL_GETDATAELEMENTSET(1014 获取数据集目录)';
//    BLL_GETTEMPLATELIST: Result := 'BLL_GETTEMPLATELIST(1015 获取模板分组包含的子分组和模板)';
//    BLL_NEWTEMPLATE: Result := 'BLL_NEWTEMPLATE(1016 新建模板)';
//    BLL_GETTEMPLATECONTENT: Result := 'BLL_GETTEMPLATECONTENT(1017 获取模板内容)';
//    BLL_SAVETEMPLATECONTENT: Result := 'BLL_SAVETEMPLATECONTENT(1018 保存模板内容)';
//    BLL_DELETETEMPLATE: Result := 'BLL_DELETETEMPLATE(1019 删除模板及内容)';
//    BLL_GETDATAELEMENT: Result := 'BLL_GETDATAELEMENT(1020 获取数据元列表)';
//    BLL_GETDATAELEMENTDOMAIN: Result := 'BLL_GETDATAELEMENTDOMAIN(1021 获取数据元值域选项)';
//    BLL_SAVEDOMAINCONTENT: Result := 'BLL_SAVEDOMAINCONTENT(1022 保存数据元选项值域对应的内容)';
//    BLL_GETDOMAINCONTENT: Result := 'BLL_GETDOMAINCONTENT(1023 获取数据元选项值域对应的内容)';
//    BLL_GETINCHRECORDLIST: Result := 'BLL_GETINCHRECORDLIST(1024 获取指定的住院患者病历列表)';
//    BLL_NEWINCHRECORD: Result := 'BLL_NEWINCHRECORD(1025 新建住院病历)';
//    BLL_GETINCHRECORDCONTENT: Result := 'BLL_GETINCHRECORDCONTENT(1026 获取指定住院病历内容)';
//    BLL_SAVERECORDCONTENT: Result := 'BLL_SAVERECORDCONTENT(1027 保存指定住院病历内容)';
//  else
//    Result := '未定义[' + IntToStr(AMethodID) + ']';
//  end;
//end;

{ TBLLServerProxy }

procedure TBLLServerProxy.AddBackField(const AFieldName: string);
begin
  Param(BLL_BACKFIELD).Add(AFieldName);
end;

function TBLLServerProxy.BackField(const AFieldName: string): TMsgPack;
begin
  Result := Param(BLL_BACKFIELD).O[AFieldName];
end;

procedure TBLLServerProxy.CheckConnect;
begin
  if (not FTcpClient.Active) then
    FTcpClient.Connect;
end;

function TBLLServerProxy.Connected: Boolean;
begin
  Result := FTcpClient.Active;
end;

constructor TBLLServerProxy.Create;
begin
  inherited Create;
  FErrCode := -1;
  FErrMsg := '';
  FReconnect := True;
  FTcpClient := TDiocpBlockTcpClient.Create(nil);
  FTcpClient.ReadTimeOut := 1000 * 60;  // 设置超时等待1分钟
  FTcpClient.OnError := DoError;
  FDataStream := TMemoryStream.Create;
  FMsgPack := TMsgPack.Create;
end;

constructor TBLLServerProxy.CreateEx(const AHost: string;
  const APort: Integer; AReconnect: Boolean = True);
begin
  Create;
  FTcpClient.Host := AHost;
  FTcpClient.Port := APort;
  FReconnect := AReconnect;
end;

destructor TBLLServerProxy.Destroy;
begin
  FTcpClient.Disconnect;
  FTcpClient.Free;
  FDataStream.Free;
  FMsgPack.Free;
  inherited Destroy;
end;

function TBLLServerProxy.ExecParam: TMsgPack;
begin
  Result := Param(BLL_EXECPARAM);
end;

function TBLLServerProxy.DispatchPack: Boolean;
begin
  Result := DispatchPack(FMsgPack);
end;

procedure TBLLServerProxy.DoError(const AErrCode: Integer; const AParam: string);
begin
  FErrCode := AErrCode;
  FErrMsg := AParam;
end;

function TBLLServerProxy.DispatchPack(const AMsgPack: TMsgPack): Boolean;
begin
  FErrCode := -1;
  FErrMsg := '';

  CheckConnect;
  // 初始化连接时用到的对象
  FDataStream.Clear;
  // 设置调用时各对象值
  if AMsgPack.I[BLL_VER] < 1 then
    AMsgPack.ForcePathObject(BLL_VER).AsInteger := 1;  // 业务版本
  //AMsgPack.ForcePathObject(BLL_DEVICE).AsInteger := Ord(TDeviceType.cdtMobile);  // 设备类型
  AMsgPack.EncodeToStream(FDataStream);  // 打包传输的调用数据
  TZipTools.ZipStream(FDataStream, FDataStream);  // 压缩传输的调用数据
  SendDataStream;  // 数据发送到服务端
  RecvDataStream;  // 获取服务端返回数据
  TZipTools.UnZipStream(FDataStream, FDataStream);  // 解压缩返回的数据
  FDataStream.Position := 0;
  AMsgPack.DecodeFromStream(FDataStream);  // 解包返回的数据
  Result := AMsgPack.Result;  // 服务端处理此次调用是否成功(仅表示服务端响应客户端调用成功，不代表方法执行的结果)
  if not Result then  // 服务端处理此次调用出错
  begin
    if AMsgPack.ForcePathObject(BACKMSG).AsString <> '' then  // 出错信息
    begin
      FMsgPack.ForcePathObject(BLL_ERROR).AsString := '【服务端错误】'
        + sLineBreak + AMsgPack.ForcePathObject(BACKMSG).AsString;
    end;
  end
  else  // 方法执行返回错误信息
  begin
    if AMsgPack.ForcePathObject(BLL_METHODMSG).AsString <> '' then
    begin
      FMsgPack.ForcePathObject(BLL_ERROR).AsString := '【执行方法错误】'
        + sLineBreak + AMsgPack.ForcePathObject(BLL_METHODMSG).AsString;
    end;
  end;

  if FReconnect then  // 调用完服务后断开，节省资源，以后可改为代理池
    FTcpClient.Disconnect;;
end;

function TBLLServerProxy.GetActive: Boolean;
begin
  Result := FTcpClient.Active;
end;

function TBLLServerProxy.GetBackDataSet: Boolean;
begin
  Result := Param(BLL_BACKDATASET).AsBoolean;
end;

function TBLLServerProxy.GetBatch: Boolean;
begin
  Result := Param(BLL_BATCH).AsBoolean;
end;

procedure TBLLServerProxy.GetBLLDataSet(const AStream: TMemoryStream);
begin
  if FMsgPack.O[BLL_DATASET] <> nil then
    FMsgPack.O[BLL_DATASET].SaveBinaryToStream(AStream)
  else
    AStream.Size := 0;
end;

function TBLLServerProxy.GetCmd: Integer;
begin
  Result := FMsgPack.ForcePathObject(BLL_CMD).AsInteger
end;

function TBLLServerProxy.GetHost: string;
begin
  Result := FTcpClient.Host;
end;

function TBLLServerProxy.GetPort: Integer;
begin
  Result := FTcpClient.Port;
end;

function TBLLServerProxy.GetTimeOut: Integer;
begin
  Result := FTcpClient.ReadTimeOut;
end;

function TBLLServerProxy.MethodError: string;
begin
  Result := Param(BLL_ERROR).AsString;
end;

function TBLLServerProxy.MethodRunOk: Boolean;
begin
  Result := Param(BLL_METHODRESULT).AsBoolean;
end;

function TBLLServerProxy.Param(const AParamName: string): TMsgPack;
begin
  Result := FMsgPack.ForcePathObject(AParamName);
end;

procedure TBLLServerProxy.ReConnectServer;
begin
  CheckConnect;
end;

function TBLLServerProxy.PeekDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      FTcpClient.Recv(buf, len);
      Result := len;
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    FTcpClient.Recv(buf, len);
    Result := len;
  end;
end;

function TBLLServerProxy.RecvDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      FTcpClient.Recv(buf, len);
      Result := len;
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    FTcpClient.Recv(buf, len);
    Result := len;
  end;
end;

function TBLLServerProxy.RecvDataStream: Boolean;
var
  vBytes: TBytes;
  vReadLen, vTempLen: Integer;
  vPACK_FLAG: Word;
  vDataLen: Integer;
  vVerifyValue, vVerifyDataValue: Cardinal;
  vPByte: PByte;
begin
  RecvDataBuffer(@vPACK_FLAG, 2);

  if vPACK_FLAG <> PACK_FLAG then  // 错误的包数据
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorFlag);
  end;

  //veri value
  RecvDataBuffer(@vVerifyValue, SizeOf(vVerifyValue));

  //headlen
  RecvDataBuffer(@vReadLen, SizeOf(vReadLen));
  vDataLen := TByteTools.swap32(vReadLen);

  if vDataLen > MAX_OBJECT_SIZE then  // 文件头过大，错误的包数据
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorData);
  end;

  SetLength(vBytes,vDataLen);
  vPByte := PByte(@vBytes[0]);
  vReadLen := 0;
  while vReadLen < vDataLen do
  begin
    vTempLen := RecvDataBuffer(vPByte, vDataLen - vReadLen);
    if vTempLen = -1 then
    begin
      RaiseLastOSError;
    end;
    Inc(vPByte, vTempLen);
    vReadLen := vReadLen + vTempLen;
  end;

{$IFDEF POSIX}
  vVerifyDataValue := verifyData(lvBytes[0], lvDataLen);
{$ELSE}
  vVerifyDataValue := verifyData(vBytes[0], vDataLen);
{$ENDIF}

  if vVerifyDataValue <> vVerifyValue then
    raise Exception.Create(strRecvException_VerifyErr);

  FDataStream.Clear;
  FDataStream.Write(vBytes[0], vDataLen);
  Result := true;
end;

function TBLLServerProxy.ReplaceParam: TMsgPack;
begin
  Result := Param(BLL_REPLACEPARAM);
end;

function TBLLServerProxy.RecordCount: Integer;
begin
  Result := Param(BLL_RECORDCOUNT).AsInteger;
end;

function TBLLServerProxy.SendDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      Result := FTcpClient.SendBuffer(buf, len);
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    Result := FTcpClient.SendBuffer(buf, len);
  end;
end;

function TBLLServerProxy.SendDataStream: Integer;
var
  lvPACK_FLAG: WORD;
  lvDataLen, lvWriteIntValue: Integer;
  lvBuf: TBytes;
  lvStream: TMemoryStream;
  lvVerifyValue: Cardinal;
begin
  lvPACK_FLAG := PACK_FLAG;

  lvStream := TMemoryStream.Create;
  try
    FDataStream.Position := 0;

    if FDataStream.Size > MAX_OBJECT_SIZE then
      raise Exception.CreateFmt(strSendException_TooBig, [MAX_OBJECT_SIZE]);

    lvStream.Write(lvPACK_FLAG, 2);  // 包头

    lvDataLen := FDataStream.Size;

    // stream data
    SetLength(lvBuf, lvDataLen);
    FDataStream.Read(lvBuf[0], lvDataLen);
    //veri value
    lvVerifyValue := verifyData(lvBuf[0], lvDataLen);

    lvStream.Write(lvVerifyValue, SizeOf(lvVerifyValue));

    lvWriteIntValue := TByteTools.swap32(lvDataLen);

    // stream len
    lvStream.Write(lvWriteIntValue, SizeOf(lvWriteIntValue));

    // send pack
    lvStream.write(lvBuf[0], lvDataLen);

    Result := SendStream(lvStream);
  finally
    lvStream.Free;
  end;
end;

function TBLLServerProxy.SendStream(pvStream: TStream): Integer;
var
  lvBufBytes: array[0..BUF_BLOCK_SIZE - 1] of byte;
  l, j, r, lvTotal: Integer;
  P: PByte;
begin
  Result := 0;
  if pvStream = nil then Exit;
  if pvStream.Size = 0 then Exit;
  lvTotal :=0;

  pvStream.Position := 0;
  repeat
    //FillMemory(@lvBufBytes[0], SizeOf(lvBufBytes), 0);
    l := pvStream.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) then
    begin
      P := PByte(@lvBufBytes[0]);
      j := l;
      while j > 0 do
      begin
        r := SendDataBuffer(P, j);
        if r = -1 then
          RaiseLastOSError;
        Inc(P, r);
        Dec(j, r);
      end;
      lvTotal := lvTotal + l;
    end
    else
      Break;
  until (l = 0);
  Result := lvTotal;
end;

procedure TBLLServerProxy.SetBackDataSet(const Value: Boolean);
begin
  Param(BLL_BACKDATASET).AsBoolean := Value;
end;

procedure TBLLServerProxy.SetBatch(const Value: Boolean);
begin
  Param(BLL_BATCH).AsBoolean := Value;
end;

procedure TBLLServerProxy.SetCmd(const Value: Integer);
begin
  FMsgPack.ForcePathObject(BLL_CMD).AsInteger := Value;
end;

procedure TBLLServerProxy.SetHost(const AHost: string);
begin
  FTcpClient.Host := AHost;
end;

procedure TBLLServerProxy.SetPort(const APort: Integer);
begin
  FTcpClient.Port := APort;
end;

procedure TBLLServerProxy.SetTimeOut(const Value: Integer);
begin
  FTcpClient.ReadTimeOut := Value;
end;

end.
