function R12 = tableR12()
    % Load Raw Data:
    R12 = ETable.loadFromLineFile('R12 - Saturated Freon 12 Temp Table', 12, ...
        ["Temperature", "Pressure", "Specific Volume, Sat. Liq.","Specific Volume, Sat. Vap.", "Density, Sat. Liq.", "Density, Sat. Vap.", "Specific Enthalpy, Sat. Liq.", "Specific Enthalpy, Evap.", "Specific Enthalpy, Sat. Vap.","Specific Entropy, Sat. Liq.","Specific Entropy, Sat. Vap.", "Temperature2 (ignore me)"],...
        ["T","P", "vf","vg", "df","dg", "hf","hfg","hg", "sf","sg", "T2"]);
    
    % Convert Units to SI Base Units:
    R12.edit('T', R12.T + 273.15); % C -> K
    R12.edit('P', R12.P * 1e3); % kPa -> Pa
    
    R12.edit('hf', R12.hf * 1e3); % kJ -> J
    R12.edit('hfg', R12.hfg * 1e3); % kJ -> J
    R12.edit('hg', R12.hg * 1e3); % kJ -> J
    
    R12.edit('sf', R12.sf * 1e3); % kJ -> J
    R12.edit('sg', R12.sg * 1e3); % kJ -> J
    
    % Apply Appropriate Titles:
    R12.rename('T', 'Fluid Temperature [K]');
    R12.rename('P', 'Fluid Pressure [Pa]');
    
    R12.rename('vf', 'Sat. Liquid Specific Volume [$^{m^3}/_{kg}$]');
    R12.rename('vg', 'Sat. Vapour Specific Volume [$^{m^3}/_{kg}$]');
    
    R12.rename('hf', 'Sat. Liquid Specific Enthalpy [$^{J}/_{kg}$]');
    R12.rename('hfg', 'Evaporation Specific Enthalpy [$^{J}/_{kg}$]');
    R12.rename('hg', 'Sat. Vapour Specific Enthalpy [$^{J}/_{kg}$]');
    
    R12.rename('sf', 'Sat. Liquid Specific Entropy [$^{J}/_{kgK}$]');
    R12.rename('sg', 'Sat. Vapour Specific Entropy [$^{J}/_{kgK}$]');
end