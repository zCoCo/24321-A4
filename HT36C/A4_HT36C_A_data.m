function T = A4_HT36C_A_data()
    strs(1:2:2*10) = "x"+(1:10); % Create interleaved header strings (x1,T1,x2,T2,...)
    strs(2:2:2*10+1) = "T"+(1:10);
    T = ETable('Comp-A4_HT36C_A.xlsx', ["run","NTubes","L", "FHot","FCold", "Thi","Tho", "Tci","Tco", strs, "flowDir"]);
    
    % Constants:
    DiH = 8.9e-3; dDiH = 0.05e-3; % [m], Inner Diameter of the Hot Fluid Tube
    DoH = 9.5e-3; dDoH = 0.05e-3;% [m], Outer Diameter of the Hot Fluid Tube
    DiC = 14e-3; dDiC = 0.5e-3; % [m], Inner Diameter of the Outer Shell of Cold Fluid Annulus
    Tinf = 22.8 + 273.15; % [K] Ambient Atmospheric Temperature
    
    kSS = 14.9; % [W/m/K] Thermal Conductivity of Stainless Steel
    
    % From Table A-6 in Incropera, et al, eval at mean temps (321.15K for
    % hot, 297.27 for cold):
    rhoH = 998.7; drhoH = rhoH*0.0005; % [kg/m3], Density of Hot Fluid (water)
    cpH = 4181; dcpH = 0.5; % [J/kg/K], Specific Heat Capacity
    muH = 5.66e-4; dmuH = 0.5e-6; % [Ns/m2], Viscosity
    PrH = 3.69; dPrH = 0.005; % Prandtl Number
    kH = 641e-3; dkH = 0.5e-3; % [W/mK] Thermal Conductivity
    
    rhoC = 997.6; drhoC = rhoC*0.0005; % [kg/m3], Density of Cold Fluid (water)
    cpC = 4180; dcpC = 0.5; % [J/kg/K], Specific Heat Capacity
    muC = 9.12e-4; dmuC = 0.5e-6; % [Ns/m2], Viscosity
    PrC = 6.26; dPrC = 0.005; % Prandtl Number
    kC = 609e-3; dkC = 0.5e-3; % [W/mK] Thermal Conductivity
    
    % Calculated Constant (or assumed constant) Uncertainties:
    dF = 8.33e-7; % m^3/s
    dFH = dF; dFC = dF;
    
    % Convert Units:
    T.edit('L', T.L/1000); % mm -> m
    
    
    T.edit('FHot', T.FHot*1.667e-5); % L/min -> m3/s
    T.edit('FCold', T.FCold*1.667e-5); % L/min -> m3/s
    
    T.edit('Thi', T.Thi + 273.15); % degC -> K
    T.edit('Tho', T.Tho + 273.15);
    T.edit('Tci', T.Tci + 273.15);
    T.edit('Tco', T.Tco + 273.15);
    for i = 1:10
        name = char("T" + i);
        T.edit(name, T.get(name) + 273.15);
    end
    
    % Compute Uncertainties:
    T.add('Uncertainty in Hot Fluid Inlet Temperature', 'dThi', max(2.2, 0.0075*(T.Thi-Tinf)));
    T.add('Uncertainty in Hot Fluid Outlet Temperature', 'dTho', max(2.2, 0.0075*(T.Tho-Tinf)));
    T.add('Uncertainty in Cold Fluid Inlet Temperature', 'dTci', max(2.2, 0.0075*(T.Tci-Tinf)));
    T.add('Uncertainty in Cold Fluid Outlet Temperature', 'dTco', max(2.2, 0.0075*(T.Tco-Tinf)));
    for i = 1:10
        name = "T" + i;
        T.add(char("Uncertainty in Temperature "+i), char("d"+name), max(2.2, 0.0075*(T.get(char(name))-Tinf)));
    end
    
    % Compute Properties:
    if strcmp(string(T.flowDir(1)), "Countercurrent")
        T.add('Initial Temperature Difference', 'DT1', T.Thi - T.Tco); % For COUNTERFLOW
        T.add('Final Temperature Difference', 'DT2', T.Tho - T.Tci); % For COUNTERFLOW
    elseif strcmp(string(T.flowDir(1)), "Cocurrent")
        T.add('Initial Temperature Difference', 'DT1', T.Thi - T.Tci); % For PARALLELFLOW
        T.add('Final Temperature Difference', 'DT2', T.Tho - T.Tco); % For PARALLELFLOW
    else
        warning('Flow Not Specified as Countercurrent or Cocurrent');
    end
        
    
    T.add('Hot Fluid Mass Flow Rate [^{kg}/_s]', 'mHot', T.FHot*rhoH);
    T.add('Uncertainty in Hot Fluid Mass Flow Rate [^{kg}/_s]', 'dmH', sqrt(T.FHot.^2 * drhoH^2 + rhoH^2 * dF^2));
    T.add('Cold Fluid Mass Flow Rate [^{kg}/_s]', 'mCold', T.FCold*rhoC);
    
    T.add('Hot Fluid Reynolds Number', 'ReH', 4 .* rhoH * T.FHot ./ pi ./ DiH ./ muH);
    T.add('Cold Fluid Reynolds Number', 'ReC', 4 .* rhoC * T.FCold .* (DiC - DoH) ./ pi ./ (DiC^2 - DoH^2) ./ muC);
    
    T.add('Hot Fluid Thermal and Hydraulic Entry Entry  ', 'xfd', 10 * DiH);
    T.add('Cold Fluid Hydraulic Entry Length', 'xfdh', 0.05 .* T.ReC .* (DiC - DoH));
    T.add('Cold Fluid Thermodynamic Entry Length', 'xfdt', 0.05 .* T.ReC .* PrC .* (DiC - DoH));
    
    T.add('Hot Fluid Heat Capacity [W/K]', 'CH', T.mHot .* cpH);
    T.add('Cold Fluid Heat Capacity [W/K]', 'CC', T.mCold .* cpC);
    T.add('Min. Fluid Heat Capacity [W/K]', 'Cmin', min(T.CH, T.CC));
    T.add('Max. Fluid Heat Capacity [W/K]', 'Cmax', max(T.CH, T.CC));
    
    T.add('Heat Transfered based on Cold Fluid [W]', 'qCold', T.CC .* (T.Tco - T.Tci));
    T.add('Heat Transfered based on Hot Fluid [W]', 'qHot', T.CH .* (T.Thi - T.Tho));
    
    T.add('Heat Exchanger Effectiveness', 'eps', T.qHot ./ T.Cmin ./ (T.Thi - T.Tci));
    
    T.add('Log Mean Temperature Difference', 'DTm', (T.DT2 - T.DT1)./log(T.DT2 ./ T.DT1));
    T.add('Overall Heat Transfer Coefficient Measured from LMTD', 'Umeas', T.qHot ./ (pi.*DiH.*T.L) ./ T.DTm);
    
    Thi = T.Thi; Tho = T.Tho; % Shorthand for easier reading in following eq. (be careful using them outside of that)
    Tco = T.Tco; Tci = T.Tci;
    dThi = T.dThi; dTho = T.dTho;
    dTco = T.dTco; dTci = T.dTci;
    mH = T.mHot;
    D = DiH; L = T.L;
    T.add('Uncertainty in Measured Overall Heat Transfer Coefficient', 'dUmeas', ...
        sqrt(...
            ((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)))./(D.*L.*pi.*(Tci - Tco + Thi - Tho)) + (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tci - Tho).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2)).^2 .* dTho.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2) - (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tco - Thi).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dThi.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2) - (cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tci - Tho).*(Tci - Tco + Thi - Tho))).^2 .* dTci.^2 ...
            +((cpH.*mH.*(Thi - Tho))./(D.*L.*pi.*(Tco - Thi).*(Tci - Tco + Thi - Tho)) - (cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho).^2)).^2 .* dTco.^2 ...
            +((cpH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* T.dmH.^2 ...
            +((cpH.*mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.^2.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dDiH.^2 ...
            +((mH.*log((Tci - Tho)./(Tco - Thi)).*(Thi - Tho))./(D.*L.*pi.*(Tci - Tco + Thi - Tho))).^2 .* dcpH.^2 ...
        )...
    );

    T.add('Inner Tube Heat Transfer Coefficient', 'hin', (kH./DiH) .* 0.023.*(T.ReH.^(4/5)).*(PrH.^(0.3)));
    Nuoo = interp1([0.6,0.8],[5.099,5.24], DoH/DiC, 'linear');
    tho = interp1([0.6,0.8],[0.2455,0.298], DoH/DiC, 'linear');
    T.add('Outer Tube Heat Transfer Coefficient', 'hout', (kC./(DiC - DoH)) .* Nuoo ./ (1 - (T.qHot.*DoH./T.qCold./DiH).*tho));
    T.add('Tube Boundary Thermal Resistance', 'Rtube', log(DoH/DiH)./2./pi./kSS./T.L);
    
    T.add('Predicted Overall Heat Transfer Coefficient w.r.t. Inner Surface', 'Upred', 1./(1./T.hin + pi*DiH.*L.*T.Rtube + (DiH./DoH)./T.hout));
    T.add('Percentage Difference btwn. U_{meas} and U_{pred}', 'PDU', 100*(T.Umeas-T.Upred)./(T.Umeas));
    
    % Export Table 2:
    T.export2Excel('Table2', ["mCold" "mHot" "Tci" "Thi" "Tco" "Tho" "qCold" "qHot" "eps" "DTm" "Umeas" "dUmeas" "hin" "hout" "Rtube" "Upred" "PDU"], 4);
end