% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_C15G_data()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    T = ETable('A4_C15_G.xlsx', ["SampNum", "FanSpeed", "Ang", "FLift", "FDrag", "Hstat", "Tamb", "rho", "Veloc", "Re", "CL", "CD", "CD0", "CL0", "k", "Pdyn"]);
    
    T.unitsList = ["","%", "$$^{\circ}$$","N", "N","mm","$$^{\circ}C$$", "$$^{kg}/_{m^{3}}$$","$$^{m}/_{s}$$","","","","","","","Pa"];
    
    
    % Convert Units:
    T.edit('Hstat', T.Hstat * 0.001); % Convert to Meters
    T.edit('Tamb', T.Tamb + 273.15); % Convert to Kelvin
    
    % Update Names (using latex syntax to pretify it):
    T.rename('Tamb', 'Ambient Temperature [K]');
    T.rename('FLift', 'Vertical Lift Force [N]');
    T.rename('FDrag', 'Drag Force [N]');
    T.rename('Ang', 'Angle of Attack [$$^{\circ}$$]');
    T.rename('Veloc', 'Velocity, [$$^{m}/_{s}$$]');
    T.rename('CL', '$$C_{L}$$');
    T.rename('CD', '$$C_{D}$$');
    T.rename('CD0', '$$C_{D0}$$');
    T.rename('CL0', '$$C_{L0}$$');
    T.rename('Pdyn', 'Dynamic Pressure [Pa]');
end