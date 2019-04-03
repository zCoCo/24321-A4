function partb()
    T = ETable('A4_C6_B.xlsx', ["d","ID","h1","h2","Q"]);
    
    % Convert Units:
    T.edit('Q', T.Q .* 0.001); % L/s -> m^3/s
    
    T.unitsList = ["m","", "m", "m", "$^{m^3}/_{s}$"];
    
    % Set Proper Diameters:
    T.edit('d', 17.2e-3); % m
    
    % Rename Fields:
    T.rename('d', 'Diameter of Tube [m]');
    T.rename('h1', 'Upstream Pressure Head [m]');
    T.rename('h2', 'Downstream Pressure Head [m]');
    T.rename('Q', 'Volumetric Flow Rate [$^{m^3}/_{s}$]');
    T.add('Volume Flow Rate [$^{L}/_{s}$]','QLs', T.Q/0.001);

    % Constants and Thermophysical Properties:
    g = 9.807;
    nu = 1.003e-6;
    es = 0;
    
    % Computed Values:
    T.add('Average Fluid Velocity, $V_{av}$ [$^{m}/{s}$]', 'V', 4 .* T.Q ./ pi ./ (T.d.^2) );
    T.add('Reynolds Number, $Re$', 'Re', T.V .* T.d ./ nu );
    
    T.add('Empirical Head Loss, $h_K$ [m]', 'hk', T.h1 - T.h2);
    T.add('Minor Head Loss Coefficient, $K$', 'K', 2.*g.*T.hk./(T.V.^2) );
    T.add('Std. of K', 's_K', zeros(size(T.K)));
    
    T.add('Theoretical Friction Factor, $f_c$', 'fc', ...
        + 64 ./ T.Re .* (T.Re <= 2500)...
        + ( -1.8.*log(6.9./T.Re + ((es./T.d)./3.7).^1.11) ).^-2 .* (T.Re > 2500)...
    );
    T.add('Equivalent Tube Length, $L_{eq}$ [m]', 'Leq', T.K.*T.d./T.fc );

    % Compute Uncertainties:
    names = cellstr(["90 Bend" "45 Bend" "90 T" "Ball Valve" "Gate Valve" "Globe Valve" "90 Elbow" "In Line Strainer" "Contraction" "Enlargement"]);
    ids = 1:10;
    qs = (2:7)*0.1 + 0.05; % L/s
    for ii = 1:numel(ids)
        [K,S] = ab(T,'K','QLs', 's_K', qs, 0.03, T.ID==ids(ii));
        [L,~] = ab(T,'Leq','QLs', 's_K', qs, 0.03, T.ID==ids(ii));
        T.edit('K', K);
        T.edit('s_K', S);
        T.edit('Leq', L);
    end
    
    % Export Data:
    writetable(T.data, 'PartBData.xlsx');
    
    function [X,S] = aggressiveBin(tab, nameX, nameB, nameSTD, bins, window, range)
        if nargin < 5
            window = 0.15;
        end
        xdat = tab.get(nameX);
        X = xdat;
        xinrange = xdat(range);
        bdat = tab.get(nameB);
        binrange = bdat(range);
        S = tab.get(nameSTD);
        for b = bins
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
        end
    end
    function [X,S] = ab(T,x,b,s,bs,w,r)
        [X,S] = aggressiveBin(T,x,b,s,bs,w,r);
    end
    
    function [Bs, Bwindow] = translateRange(tab, nameA, nameB, values, window)
        adat = tab.get(nameA);
        bdat = tab.get(nameB);
        Bs = zeros(size(values));
        for i = 1:numel(values)
            Bs(i) = mean(bdat(ETable.inrange(adat, values(i)-window, values(i)+window)));
        end
        Bwindow = 2*mean(Bs./values)*window;
    end
    
    function ph = plotBins(tab, nameX, nameY, binsX, window, range)
        persistent nexec;
        if isempty(nexec)
            nexec=0;
        end
        if nargin < 5
            window = 0.15;
        end
        xdat = tab.get(nameX);
        xinrange = xdat(range);
        ydat = tab.get(nameY);
        yinrange = ydat(range);
        eys = zeros(size(xdat));
        for x = binsX
            s = std(yinrange(ETable.inrange(xinrange, x-window, x+window)));
            if isnan(s)
                s = 0;
            end
            eys = eys + 2*s .* ETable.inrange(xdat, x-window, x+window) .* range;
        end
        nameE = char("d"+nameY+"B"+nameX+"_"+nexec);
        tab.add(char("Error in " + nameY + " wrt " + nameX + "bins_"+nexec),nameE, eys);
        bincell =  num2cell(binsX);
        ph = tab.errorAvgAtplot(nameX, nameY, nameE, range, window, nameX, bincell{:});
        nexec = nexec + 1;
    end
end