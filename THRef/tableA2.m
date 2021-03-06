function A2 = tableA2()
    % Load Raw Data:
    A2 = ETable.loadFromLineFile('Table A2 - Saturated DHMO Temp Table', 12, ...
        ["Temperature", "Pressure", "Specific Volume, Sat. Liq.","Specific Volume, Sat. Vap.", "Specific Internal Energy, Sat. Liq.", "Specific Internal Energy, Sat. Vap.", "Specific Enthalpy, Sat. Liq.", "Specific Enthalpy, Evap.", "Specific Enthalpy, Sat. Vap.","Specific Entropy, Sat. Liq.","Specific Entropy, Sat. Vap.", "Temperature2 (ignore me)"],...
        ["T","P", "vf","vg", "uf","ug", "hf","hfg","hg", "sf","sg", "T2"]);
    
    % Convert Units to SI Base Units:
    A2.edit('T', A2.T + 273.15); % C -> K
    A2.edit('P', A2.P * 1e5); % bar -> Pa
    
    A2.edit('vf', A2.vf * 1e-3); % to m^3/kg
    
    A2.edit('uf', A2.uf * 1e3); % kJ -> J
    A2.edit('ug', A2.ug * 1e3); % kJ -> J
    
    A2.edit('hf', A2.hf * 1e3); % kJ -> J
    A2.edit('hfg', A2.hfg * 1e3); % kJ -> J
    A2.edit('hg', A2.hg * 1e3); % kJ -> J
    
    A2.edit('sf', A2.sf * 1e3); % kJ -> J
    A2.edit('sg', A2.sg * 1e3); % kJ -> J
    
    % Apply Appropriate Titles:
    A2.rename('T', 'Fluid Temperature [K]');
    A2.rename('P', 'Fluid Pressure [Pa]');
    
    A2.rename('vf', 'Sat. Liquid Specific Volume [$^{m^3}/_{kg}$]');
    A2.rename('vg', 'Sat. Vapour Specific Volume [$^{m^3}/_{kg}$]');
    
    A2.rename('uf', 'Sat. Liquid Specific Internal Energy [$^{J}/_{kg}$]');
    A2.rename('ug', 'Sat. Vapour Specific Internal Energy [$^{J}/_{kg}$]');
    
    A2.rename('hf', 'Sat. Liquid Specific Enthalpy [$^{J}/_{kg}$]');
    A2.rename('hfg', 'Evaporation Specific Enthalpy [$^{J}/_{kg}$]');
    A2.rename('hg', 'Sat. Vapour Specific Enthalpy [$^{J}/_{kg}$]');
    
    A2.rename('sf', 'Sat. Liquid Specific Entropy [$^{J}/_{kgK}$]');
    A2.rename('sg', 'Sat. Vapour Specific Entropy [$^{J}/_{kgK}$]');
end