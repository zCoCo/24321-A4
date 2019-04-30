function T = A4_HT36C_A_data()
    strs(1:2:2*10) = "x"+(1:10); % Create interleaved header strings (x1,T1,x2,T2,...)
    strs(2:2:2*10+1) = "T"+(1:10);
    T = ETable('Comp-A4_HT36C_A.xlsx', ["run","NTubes","L", "FHot","FCold", "Thi","Tho", "Tci","Tco", strs]);
    
    % Constants:
    DiH = 8.9e-3; % [m], Inner Diameter of the Hot Fluid Tube
    DoH = 9.5e-3; % [m], Outer Diameter of the Hot Fluid Tube
    DoC = 14e-3; % [m], Outer Diameter of the Cold Fluid Tube
    
    % Constant (or assumed constant) Uncertainties:
    dH = 
    
    % From Table A-6 in Incropera, et al:
    rhoH = 998.7; % [kg/m3], Density of Hot Fluid (water)
    cpH = 4181; % [J/kg/K], Specific Heat Capacity
    muH = 5.66e-4; % [Ns/m2], Viscosity
    
    rhoC = 997.6; % [kg/m3], Density of Cold Fluid (water)
    cpC = 4180; % [J/kg/K], Specific Heat Capacity
    muC = 9.12e-4; % [Ns/m2], Viscosity
    
    % Convert Units:
    T.edit('L', T.L/1000); % mm -> m
    
    T.edit('FHot', T.FHot*1.667e-5); % L/min -> m3/s
    T.edit('FCold', T.FCold*1.667e-5); % L/min -> m3/s
    
    % Compute Properties:
    T.add('Initial Temperature Difference', 'DT1', T.Thi - Tco); % For COUNTERFLOW
    T.add('Final Temperature Difference', 'DT2', T.Tho - Tci); % For COUNTERFLOW
    
    T.add('Hot Fluid Mass Flow Rate [^{kg}/_s]', 'mHot', T.FHot*rhoH);
    T.add('Cold Fluid Mass Flow Rate [^{kg}/_s]', 'mCold', T.FCold*rhoC);
    
    T.add('Hot Fluid Heat Capacity [W/K]', 'CH', T.mHot .* cpH);
    T.add('Cold Fluid Heat Capacity [W/K]', 'CC', T.mCold .* cpC);
    T.add('Min. Fluid Heat Capacity [W/K]', 'Cmin', min(T.CH, T.CC));
    T.add('Max. Fluid Heat Capacity [W/K]', 'Cmax', max(T.CH, T.CC));
    
    T.add('Heat Transfered based on Cold Fluid [W]', 'qCold', T.CC .* (T.Tco - Tci));
    T.add('Heat Transfered based on Hot Fluid [W]', 'qHot', T.CH .* (T.Thi - Tho));
    
    T.add('Heat Exchanger Effectiveness', 'eps', T.qHot ./ (T.Thi - T.Tci));
    
    T.add('Log Mean Temperature Difference', 'DTm', log(T.DT2 ./ T.DT1));
    T.add('Overall Heat Transfer Coefficient Measured from LMTD', 'Umeas', -T.DTm ./ A ./ (1./T.CH + 1./T.CC));
    
    Thi = T.Thi; Tho = T.Tho; % Shorthand for easier reading in following eq. (be careful using them outside of that)
    Tco = T.Tco; Tci = T.Tci;
    mH = T.mHot;
    D = DiH; L = T.L;
    T.add('Uncertainty in Measured Overall Heat Transfer Coefficient', 'dUmeas', ...
        sqrt(...
            ((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)))./(D.*L.*pi.*(Tci - Tco + Thi - Tho)) + (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tci - Tho).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2)).^2 .* dTho.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2) - (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tco - Thi).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dThi.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2) - (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tci - Tho).*(Tci - Tco + Thi - Tho))).^2 .* dTci.^2 ...
            +((cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tco - Thi).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2)).^2 .* dTco.^2 ...
            +((cpH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dmH.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.^2.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dDiH.^2 ...
            +((mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dcpH.^2 ...
        )...
    );
    
    %CONSTANTS NEEDED + equations
    %specific heat (c_) --> bigCH = T.mdotH.*T.cH
    %                   --> qHot = T.bigCH.*(T.T1-T.T5)
    %                   --> bigCC = T.mdotC.*T.cC
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