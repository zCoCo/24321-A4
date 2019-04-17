function R12SH = tableR12SH()
    % Load Raw Data:
    R12SH = ETable('Table R12SH.xlsx', ["T","P", "v","h","s"]);
    
    % Convert Units to SI Base Units:
    R12SH.edit('T', R12SH.T + 273.15); % C -> K
    R12SH.edit('P', R12SH.P * 1e3); % kPa -> Pa
    
    R12SH.edit('h', R12SH.h * 1e3); % kJ -> J
    R12SH.edit('s', R12SH.s * 1e3); % kJ -> J
    
    % Apply Appropriate Titles:
    R12SH.rename('T', 'Temperature [K]');
    R12SH.rename('P', 'Pressure [Pa]');
    
    R12SH.rename('v', 'Specific Volume [$^{m^3}/_{kg}$]');
    R12SH.rename('h', 'Specific Enthalpy [$^{J}/_{kg}$]');
    R12SH.rename('s', 'Specific Entropy [$^{J}/_{kgK}$]');
end