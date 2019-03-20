% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_C15G_velocData()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    T = ETable('A4_C15_G_pressureHeadData.xlsx', ["N","Ang","V","Hstat","H1","H2","H3","H4","H5","H6","H7","H8","H9","H10","H11","H12"]);
    
    T.unitsList = ["","$$^{\circ}$$","$$^{m}/_{s}$$","mm","mm","mm","mm","mm","mm","mm","mm","mm","mm","mm","mm","mm"];
    
    % Fetch Density of Air [kg m-3] from Other Table and Compute Error
    T2 = A4_C15G_data();
    rhoa = mean(T2.rho) * ones(size(T.N)); % populate with default value
    drhoa = 2*std(T2.rho) * ones(size(T.N)); % populate with default value
    for ang = [0,5,10,19.8,30.3]
        for vel = [5.5 10 15 20 25]
            range1 = ETable.is(T.V, vel) & ETable.is(T.Ang, ang);
            range2 = ETable.within(T2.Veloc, 0.15, vel) & ETable.is(T2.Ang, ang);
            rhoa(range1) = mean(T2.rho(range2)) * ones(sum(range1),1);
            drhoa(range1) = 2*std(T2.rho(range2)) * ones(sum(range1),1);
        end
    end
    T.add('Density of Air, $$\rho_{a}$$ [$$^{kg}/_{m^{3}}$$', 'rhoa', rhoa);
    T.add('Uncertainty in Density of Air, $$\delta\rho_{a}$$ [$$^{kg}/_{m^{3}}$$', 'drhoa', drhoa);
    
    % Update Names (using latex syntax to pretify it):
    T.rename('Ang', 'Angle of Attack [deg]');
    T.rename('V', 'Free Stream Velocity [$$^{m}/_{s}$$]');
    
    %% Constants:
    g = 9.81; % [m s-1] Gravitational Acceleration
    rhom = 997; % [kg m-3] Density of Pitot Tube Fluid (assuming water)
    
    dH = 1; % [mm] Uncertainty in Pitot Tube (Pressure Head) Readings
    dP = rhom * g * dH / 1000; % [mm] Uncertainty in Pitot Tube (Pressure) Calculations
    
    %% Add Calculated Fields:
    T.add('Static Pressure [Pa]', 'Pstat', rhom .* g .* T.Hstat ./ 1000);
    for i = 1:12
        T.add(char("Total Pressure at Tapping " + i + " [Pa]"), char("P"+i), rhom .* g .* T.get(char("H"+i)) ./ 1000 );
        T.add(char("Dynamic Pressure at Tapping " + i + " [Pa]"), char("Pdyn"+i), abs(T.Pstat - T.get(char("P"+i))) );
        T.add(char("Uncertainty in Dynamic Pressure at Tapping " + i + " [Pa]"), char("dPdyn"+i), sqrt(2)*dP );
        T.add(char("Velocity at Tapping " + i + " [$$^{m}/_{s}$$"), char("v"+i), sqrt(2 .* T.get(char("Pdyn"+i)) ./ T.rhoa) );
        T.add(char("Uncertainty in Velocity at Tapping " + i + " [$$^{m}/_{s}$$"), char("dv"+i), ...
            sqrt(...
                + T.get(char("dPdyn"+i)).^2 ./ (2 .* T.rhoa .* T.get(char("Pdyn"+i))) ...
                + T.drhoa.^2 .* T.get(char("Pdyn"+i)) ./ 2 ./ (T.rhoa .^ 3) ...
            ) ...
        );
    end
end