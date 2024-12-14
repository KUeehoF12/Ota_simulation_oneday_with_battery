%PV余剰を吸収するバッテリの充放電を模擬
clear
Date = 20170502;
PVDir = 'D:\data\CRESTデータセット\44071_東京都練馬区\住宅PV実測\'; %PV出力のフォルダ
LoadDir = 'D:\data\CRESTデータセット\44071_東京都練馬区\住宅負荷実測\';%負荷データのフォルダ
NumNodes = 44; NumHouses = NumNodes*3*4; %配電系統のノード数，住宅の件数
period=24; %シミュレーションする時間
BatEfficiency=0.9; %バッテリの充放電

%太田データ読み込み
%変数の初期化
PVpower=zeros(1440,NumHouses);
Load=PVpower;
BatCharge = PVpower;
BatRemain = zeros(1440,NumHouses);
%パラメタ設定
BatCapacity = 5;
BatInverter = 3;
ReverseFlowLimit = 0.9;

PVpower=readmatrix([PVDir,'Individual_ResidentialPV_Real_1m_44071_',num2str(Date),'.csv']);%元の範囲：A1:TN24->A1:TZ24
Load=readmatrix([LoadDir,'Individual_ResidentialLoad_Real_1m_44071_',num2str(Date),'.csv']);

[BatRemain,BatCharge,Load]=battery_operation(period*60,NumHouses,PVpower,Load,BatInverter,BatCapacity,BatEfficiency,ReverseFlowLimit); %定義しておいたbattery_operation関数を実行