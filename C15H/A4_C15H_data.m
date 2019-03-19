% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_C15H_data()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    T = ETable('A5_C15_H.xlsx', ["SampNum", "notes", "FanSpeed", "Hstat", "Tamb", "rho", "Vinf", "y", "Hp", "Vp", "d"]);
    
    T.unitsList = ["","%", "mm", "$$^{\circ}C$$", "$$^{kg}/_{m^{3}}$$", "$$^{m}/{s}$$", "mm", "mm", "$$^{m}/{s}$$", "mm"];

    % Convert Units:
    T.edit('Hstat', T.Hstat * 0.001); % Convert to Meters
    T.edit('Hp', T.Hp * 0.001); % Convert to Meters
    T.edit('Tamb', T.Tamb + 273.15); % Convert to Kelvin
    
    % Update Names (using latex syntax to pretify it):
    T.rename('Tamb', 'Ambient Temperature [K]');
    T.rename('Hstat', 'Static Pressure Head [m]');
    T.rename('Hp', 'Pitot Pressure Head [m]');
    T.rename('Vp', 'Pitot Velocity from Software [$$^{m}/{s}$$]');
    
    % Constants:
    g = 9.81;
    rho_fluid = 1000; % Assume Water
    
    % Add Calculated Columns:
    T.add('Calculated Static Pressure [Pa]', 'Pstat', rho_fluid .* g .* T.Hstat);
    T.add('Calculated Pitot Pressure [Pa]', 'Pp', rho_fluid .* g .* T.Hp);
    T.add('Calculated Dynamic Pressure [Pa]', 'Pdyn', T.Pstat - T.Pp);
    
    T.add('Calculated Flow Velocity from Given Pressure Heads [$$^{m}/{s}$$]', 'Vcalc', sqrt(2 .* T.Pdyn ./ T.rho));
end