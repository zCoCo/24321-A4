function T = A4_HT36C_A_data()
    T = ETable('A4_HT36C_A.xlsx', ["NumTube", "T1", "T2", "T3", "T4", "T5",...
        "T6","T7","T8","T9","T10","HPump","FHot","CValve","FCold","Orient",...
        "Notes","H_SpecHeat","C_SpecHeat","HPoint","HTemp","CPoint","CTemp",...
        "DHot","HAvg","RhoH","HVisc","ReH","CAvg","RhoC","CVisc","ReC","HLoss",...
        "CGain","mdotH","mdotC","Qe","Qa","Qf","Eff","HEff","CEff","MeanEff","LMTD","U","Score",...
        "AvT1","AvT2","AvT3","AvT8","AvT9","AvT10","T6","T7","T8","T3","T4","T5"]);
    T.unitsList = ["",repmat("$$^{\circ}C$$",1:10),"%","$$^{L}/{min}$$","%",...
        "$$^{L}/{min}$$","","","","$$^{J}/_{kJ*K}$$","$$^{J}/_{kJ*K}$$","",...
        "$$^{\circ}C$$","","$$^{\circ}C$$","mm","$$^{\circ}C$$","$$^{kg}/_{m^{3}}$$",...
        "$$^{Pa*s}^$$","","$$^{\circ}C$$","$$^{kg}/_{m^{3}}$$","$$^{Pa*s}^$$","",...
        "$$^{\circ}C$$","$$^{kg}/_{m^{3}}$$","$$^{\circ}C$$","$$^{\circ}C$$",...
        "$$^{kg}/{s}$$","$$^{kg}/{s}$$","W","W","W",repmat("%",1:4),"","",""...
        "%",repmat("$$^{\circ}C$$",1:6),repmat("$$^{\circ}C$$",1:6)];
        
    %Convert Units
    T.edit('HVisc', T.HVisc * 0.001);
    T.edit('CVisc', T.CVisc * 0.001);
    T.edit('FHot',T.FHot * 60); %assume 1kg = 1L
    T.edit('FCold',T.FCold * 60);
    T.edit('mdotH',T.mdotH/T.rohH);
    T.edit('mdotC',T.mdotC/T.rohC);
    %need to add the densities from the temps we find!!!
    
    %CONSTANTS NEEDED + equations
    %specific heat (c_) --> bigCH = T.mdotH*T.cH
    %                   --> qHot = T.bigCH*(T.T1-T.T5)
    %                   --> bigCC = T.mdotC*T.cC
    %                   --> qCold = T.bigCC * (T.T10-T.T6)
    %                   --> qMax = max([T.bigCH,T.bigCC])
    %                   --> eff = mean([T.qHot,T.qCold])/T.qMax
    %                   --> T_lm = abs(T.dT1-T.dT2)/log(abs(T.dT1-T.dT2))
    %if(T.orient==char('countercurrent'))
    %   T.add(deltaT1,"dT1",T.T5-T.T10)
    %   T.add(deltaT2,"dT2",T.T1-T.T6)
    %else
    %   T.add(deltaT1,"dT1",T.T5-T.T6)
    %   T.add(deltaT2,"dT2",T.T1-T.T10)
  
end