% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_HT11C_A_data()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    T = ETable('A4_HT11C_B.xlsx', ["N","t", "V","I", "Fw", "T1","T2","T3","T4","T5","T6","T7","T8"]);
    T.unitsList = ["", "day", "V","A", "$$\frac{L}{m}$$", "$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$","$$^{\circ}C$$"];
    
    % Compute Uncertainties for All Temperature Measurements (assuming
    % Special Type-K themocouples):
    T.add('Uncertainty in T1 [K]', 'dT1', max(1.1, 0.004.*T.T1));
    T.add('Uncertainty in T2 [K]', 'dT2', max(1.1, 0.004.*T.T2));
    T.add('Uncertainty in T3 [K]', 'dT3', max(1.1, 0.004.*T.T3));
    T.add('Uncertainty in T4 [K]', 'dT4', max(1.1, 0.004.*T.T4));
    T.add('Uncertainty in T5 [K]', 'dT5', max(1.1, 0.004.*T.T5));
    T.add('Uncertainty in T6 [K]', 'dT6', max(1.1, 0.004.*T.T6));
    T.add('Uncertainty in T7 [K]', 'dT7', max(1.1, 0.004.*T.T7));
    T.add('Uncertainty in T8 [K]', 'dT8', max(1.1, 0.004.*T.T8));
    
    % Convert Units:
    T.edit('t', T.t .* 1440); % Convert from Days to Minutes
    T.edit('T1', T.T1 + 273.15); % Convert to Kelvin
    T.edit('T2', T.T2 + 273.15); % Convert to Kelvin
    T.edit('T3', T.T3 + 273.15); % Convert to Kelvin
    T.edit('T4', T.T4 + 273.15); % Convert to Kelvin
    T.edit('T5', T.T5 + 273.15); % Convert to Kelvin
    T.edit('T6', T.T6 + 273.15); % Convert to Kelvin
    T.edit('T7', T.T7 + 273.15); % Convert to Kelvin
    T.edit('T8', T.T8 + 273.15); % Convert to Kelvin
    
    % Update Names (using latex syntax to pretify it):
    T.rename('t', 'Time Elapsed [min]');
    T.rename('T1', 'Temp, $$T_{1}$$ [K]');
    T.rename('T2', 'Temp, $$T_{2}$$ [K]');
    T.rename('T3', 'Temp, $$T_{3}$$ [K]');
    T.rename('T4', 'Temp, $$T_{4}$$ [K]');
    T.rename('T5', 'Temp, $$T_{5}$$ [K]');
    T.rename('T6', 'Temp, $$T_{6}$$ [K]');
    T.rename('T7', 'Temp, $$T_{7}$$ [K]');
    T.rename('T8', 'Temp, $$T_{8}$$ [K]');

end