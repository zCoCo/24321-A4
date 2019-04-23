% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_TF_data()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    T = ETable('A4_TF.xlsx', ["t", "TB_" + string(1:5), "TC_" + string(1:5), "TS_" + string(1:5), "TA_" + string(1:5)]);
    
    T.unitsList = ["sec",repmat("K",1,20)];
   
    %% Convert Units:
    for sym = ["B","C","S","A"]
        for i=1:5
            name = char("T" + sym + "_" + i);
            T.edit(name,T.get(name)+273.15);
        end
    end
        
    %% Update Names (using latex syntax to pretify it):
    T.rename('Tamb', 'Ambient Temperature [K]');
    T.rename('Hstat', 'Static Pressure Head [m]');
    T.rename('Hp', 'Pitot Pressure Head [m]');
    T.rename('Vp', 'Pitot Velocity from Software [$$^{m}/{s}$$]');
    
    %% Compress Table so only one entry with approp. uncertainty per measurement set:
    T = binCompressTable(T, ["SampNum", "ID", "FanSpeed", "Hstat", "Tamb", "rho", "Vinf", "Y", "Hp", "Vp"], 'ID', 1:198, 0.1, T.ID==T.ID);

    %% Set Experimental IDs:
    % Fin IDs:
    T.addprop('SMOOTH'); T.addprop('ROUGH'); T.addprop('OBSTACLE');
    T.set('SMOOTH', 1); T.set('ROUGH', 2); T.set('OBSTACLE', 3);
    % Placement IDs:
    T.addprop('UPSTREAM'); T.addprop('CENTERSTREAM'); T.addprop('DOWNSTREAM');
    T.set('UPSTREAM', 1); T.set('CENTERSTREAM', 2); T.set('DOWNSTREAM', 3);
    
    T.add('Fin ID', 'Fin', mod(floor((T.ID-1)/66),3)+1);
    T.add('Velocity Setting [$^{m}/{s}$]', 'Vset', 5.^(mod(floor((T.ID-1)/33),2)+1));
    T.add('Position ID', 'Pos', mod(floor((T.ID-1)/11),3)+1);
    T.add('X Position [mm]', 'X', 0 + (T.Pos==2).*8.0 + (T.Pos==3)*12.6);

    
    %% Add Calculated Columns:
    % Constants:
    g = 9.81;
    rho_fluid = 997; % Assume Water
    nu_air = 15.32e-6; % [m2 /s] Kinematic Viscosity of Air
    dx = 0.05e-3; % [m] Uncertainty in x-Measurement
    
    T.add('Calculated Static Pressure [Pa]', 'Pstat', rho_fluid .* g .* T.Hstat);
    T.add('Calculated Pitot Pressure [Pa]', 'Pp', rho_fluid .* g .* T.Hp);
    T.add('Calculated Dynamic Pressure [Pa]', 'Pdyn', T.Pstat - T.Pp);
    
    T.add('Calculated Flow Velocity from Given Pressure Heads [$$^{m}/{s}$$]', 'Vcalc', sqrt(2 .* abs(T.Pdyn) ./ T.rho));
    T.add('Uncertainty in Calculated Flow Velocity[$$^{m}/{s}$$]', 'dVcalc', ...
        sqrt(...
            + (g*rho_fluid*sign(T.Hp - T.Hstat).^2)./(2*T.rho.*abs(T.Hp - T.Hstat)) .* T.dHstat.^2 ...
            + (g*rho_fluid*sign(T.Hp - T.Hstat).^2)./(2*T.rho.*abs(T.Hp - T.Hstat)) .* T.dHp.^2 ...
            + (g*rho_fluid*abs(T.Hp - T.Hstat))./(2*T.rho.^3) .* T.drho.^2 ...
        )...
    );
    % Enforce No-Slip Condition:
    Vns = T.Vcalc; dVns = T.dVcalc;
    Vns(T.Y == 0) = 0;
    dVns(T.Y == 0) = 0;
    T.edit('Vcalc', Vns);
    T.edit('dVcalc', dVns);
    
   
    T.add('Reynolds Number', 'Rex', T.rho .* T.Vinf .* (T.X/1000) ./ nu_air);
    T.add('Uncertainty in Reynolds Number', 'dRex', ...
        sqrt(...
            + (T.Vinf .* (T.X/1000) ./ nu_air).^2 .* T.drho.^2 ...
            + (T.rho .* (T.X/1000) ./ nu_air).^2 .* T.dVinf.^2 ...
            + (T.rho .* T.Vinf ./ nu_air).^2 .* dx^2 ...
        )...
    );
end

function tab2 = binCompressTable(tab, namesX, nameB, bins, window, range)
    tab2 = ETable(array2table([]), []);
    for nx = namesX
        if nx == "X"
        end
        tab.add(char("Std. of " + tab.cosmeticFullName(char(nx))), char("s"+nx), zeros(size(tab.get(char(nx)))));
        [~,~,X,S] = aggressiveBin(tab, nx, nameB, char("s"+nx), bins, window, range);
        tab2.add(tab.cosmeticFullName(char(nx)), char(nx), X);
        tab2.add(char("Std. of " + tab.cosmeticFullName(char(nx))), char("s"+nx), S);
        tab2.add(char("Uncertainty in " + tab.cosmeticFullName(char(nx))), char("d"+nx), 2.*S);
    end
end

function [X,S,x_sm,s_sm] = aggressiveBin(tab, nameX, nameB, nameSTD, bins, window, range)
    if nargin < 5
        window = 0.15;
    end
    x_sm = nan(numel(bins),1); % Small x range (on entry per bin)
    s_sm = nan(numel(bins),1);
    
    xdat = tab.get(char(nameX));
    X = xdat;
    xinrange = xdat(range);
    bdat = tab.get(char(nameB));
    binrange = bdat(range);
    S = tab.get(nameSTD);
    for i = 1:numel(bins)
        b = bins(i);
        
        brange = ETable.inrange(bdat, b-window, b+window) .* range;
        s = std(xinrange(ETable.inrange(binrange, b-window, b+window)));
        if isnan(s)
            s = 0;
        end
        S = S.*~brange + s .* brange;
        m = mean(xinrange(ETable.inrange(binrange, b-window, b+window)));
        if isnan(m)
            m = 0;
        end
        X = X.*~brange + m .* brange;
        x_sm(i) = m;
        s_sm(i) = s;
    end
end
function [X,S] = ab(T,x,b,s,bs,w,r)
    [X,S] = aggressiveBin(T,x,b,s,bs,w,r);
end