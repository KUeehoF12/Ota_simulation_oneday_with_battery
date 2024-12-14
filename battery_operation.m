function [BatRemain, BatteryCharge, Load] = battery_operation(period, NumHouses, PVpower, Load, BatInverter, BatCapacity, BatEfficiency, ReverseFlowLimit)
  % 仕様2: 配列のサイズを定義
  BatRemain = zeros(period, NumHouses);  % バッテリ残量の配列
  BatteryCharge = zeros(period, NumHouses); % バッテリ充電量の配列
  PreBatRemain_array=zeros(period, NumHouses); %1つ前のタイムステップにおけるバッテリ残量の配列
  SurplusPower_array=zeros(period, NumHouses); %余剰電力の配列
  AvailableChargeCapacity_array=zeros(period, NumHouses); %充電可能な容量の配列
  ChargePower_array=zeros(period, NumHouses); %バッテリに蓄えられる電力の配列
  DischargePower_array=zeros(period, NumHouses); %バッテリから出ていく電力の配列
  %引数をExcelに出力
  writematrix(Load,'variables.xlsx','Sheet','Load_input','Range','A1') %入力した負荷データをExcelに出力
  writematrix(PVpower,'variables.xlsx','Sheet','PVpower','Range','A1') %PV発電量をExcelに出力

  % 仕様3: 初期化は上記で実施済み

  % 仕様8: タイムステップと住宅ごとにループ処理
  for t = 1:period
    for h = 1:NumHouses
      % 前のタイムステップのバッテリ残量を取得 (最初のタイムステップは0)
      if t > 1
        PreBatRemain = BatRemain(t-1, h);
      else
        PreBatRemain = 0;
      end
      PreBatRemain_array(t,h)=PreBatRemain;

      % 余剰電力を計算
      SurplusPower = PVpower(t, h) - Load(t, h);
      SurplusPower_array(t,h)=SurplusPower;

      % 仕様4, 7: 余剰電力がある場合の処理
      if SurplusPower > ReverseFlowLimit
        % 充電可能量を計算
        AvailableChargeCapacity = BatCapacity - PreBatRemain;
        AvailableChargeCapacity_array(t,h)=AvailableChargeCapacity;
        
        if AvailableChargeCapacity > 0
          % 逆潮流を考慮した充電電力
          ChargePower = min((SurplusPower - ReverseFlowLimit) * BatEfficiency, AvailableChargeCapacity*60);
          ChargePower_array(t,h)=ChargePower;

          % 仕様4: バッテリーが満充電になるか、余剰電力をすべて吸収できるか
          if ChargePower/BatEfficiency + ReverseFlowLimit <= SurplusPower
            BatteryCharge(t, h) = ChargePower/BatEfficiency;
            %Load(t, h) = Load(t, h) + ReverseFlowLimit; 
          else
             BatteryCharge(t, h) = ChargePower/BatEfficiency;
             Load(t, h) = Load(t, h) + ChargePower/BatEfficiency;
          end

          BatRemain(t, h) = PreBatRemain + ChargePower/60;
        else
          % バッテリーが満充電の場合は、余剰電力はそのまま逆潮流させる
          Load(t, h) = Load(t,h);
        end
       

      % 仕様5, 7: 負荷がPV発電量を上回る場合の処理
      elseif SurplusPower < 0
        % 放電可能量を計算
        AvailableDischargeCapacity = min(BatInverter, PreBatRemain*BatEfficiency*60);
        AvailableDischargeCapacity_array(t,h)=AvailableDischargeCapacity;

        % 仕様5: 負荷の不足分と放電可能量の小さい方を放電
        DischargePower = min(abs(SurplusPower), AvailableDischargeCapacity);
        DischargePower_array(t,h)=DischargePower;

        if DischargePower > 0
          BatteryCharge(t, h) = -DischargePower/BatEfficiency;
          BatRemain(t, h) = PreBatRemain + BatteryCharge(t, h)/60;
          Load(t, h) = Load(t, h) - DischargePower;
        end
        
      % 仕様7: 充放電しない場合
      else
        BatRemain(t, h) = PreBatRemain;
      end
    end
  end
  %ローカル変数を格納した配列をExcelに
  writematrix(PreBatRemain_array,'variables.xlsx','Sheet','PreBatRemain_array','Range','A1')
  writematrix(SurplusPower_array,'variables.xlsx','Sheet','SurplusPower_array','Range','A1')
  writematrix(AvailableChargeCapacity_array,'variables.xlsx','Sheet','AvailableChargeCapacity_array','Range','A1')
  writematrix(ChargePower_array,'variables.xlsx','Sheet','ChargePower_array','Range','A1')
  writematrix(DischargePower_array,'variables.xlsx','Sheet','DischargePower_array','Range','A1')
  %戻り値をExcelに
  writematrix(Load,'variables.xlsx','Sheet','Load_output','Range','A1') %蓄電池の充放電を加味した負荷をExcelに出力
  writematrix(BatRemain,'variables.xlsx','Sheet','BatRemain','Range','A1') %PV発電量をExcelに出力
  writematrix(BatteryCharge,'variables.xlsx','Sheet','BatteryCharge','Range','A1') %蓄電池の充放電を加味した負荷をExcelに出力
end