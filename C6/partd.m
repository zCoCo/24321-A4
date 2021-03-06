function partd()
    T = ETable('A4_C6_D.xlsx', ["Q","T","nu","ho1","ho2","hv1","hv2"]);
    
    % Convert Units:
    T.edit('Q', T.Q .* 0.001); % L/s -> m^3/s
    T.edit('T', T.T + 273.15); % C->K
    T.unitsList = ["$^{m^3}/_{s}$","K", "^{m^2}/{s}", "m","m", "m","m"];
    
    % Set Proper Diameters:
    
    % Rename Fields:
    T.rename('Q', 'Volumetric Flow Rate [$^{m^3}/_{s}$]');
    T.add('Volume Flow Rate [$^{L}/_{s}$]','QLs', T.Q/0.001);

    % Constants and Thermophysical Properties:
    g = 9.807;
    nu = 1.003e-6;
    Cdo = 0.62;
    Cdv = 0.98;
    dd = 0.2e-3; % m, Diameter Uncertainty
    d0o = 21e-3; % m, Orafice Choke Diameter
    d0v = 14.5e-3; % m, Venturi Throat Diameter
    d1 = 24e-3; % m, Upstream Pipe Diameter
    
    
    % Computed Values:
    T.add('Average Fluid Velocity, $V_{av}$ [$^{m}/{s}$]', 'V', 4 .* T.Q ./ pi ./ (d1.^2) );
    T.add('Reynolds Number, $Re$', 'Re', T.V .* d1 ./ T.nu );
    
    T.add('Orafice Head Loss, $h_o$ [m]', 'ho', T.ho1 - T.ho2);
    T.add('Venturi Head Loss, $h_v$ [m]', 'hv', T.hv1 - T.hv2);
    
    T.add('Qo,Calculated Volumetric Flow Rate through Orafice [L/s]', 'QLso', ...
        (Cdo.*pi.*d0o.^2./4)*sqrt(2.*g.*T.ho./(1-(d0o./d1).^4))./0.001...
    );
    T.add('dQo, Uncertainty in Calculated Volumetric Flow Rate through Orafice [L/s]', 'dQLso', ...
        (pi*sqrt(2)/2) .* sqrt(-Cdo^2*T.ho*d0o^2*d1^2*g*(d0o^10*dd^2+d1^10*dd^2)/((d0o^4-d1^4)^3)) ./ 0.001...
    );
    T.add('Qmo, Relative Uncertainty in Qo [%]', 'Qmo', 100*(T.QLs-T.QLso)./T.QLso );

    T.add('Qv, Calculated Volumetric Flow Rate through Venturi [L/s]', 'QLsv', ...
        (Cdv.*pi.*d0v.^2./4)*sqrt(2.*g.*T.hv./(1-(d0v./d1).^4))./0.001...
    );
    T.add('dQv, Uncertainty in Calculated Volumetric Flow Rate through Venturi [L/s]', 'dQLsv', ...
        (pi*sqrt(2)/2) .* sqrt(-Cdv^2*T.hv*d0v^2*d1^2*g*(d0v^10*dd^2+d1^10*dd^2)/((d0v^4-d1^4)^3))/0.001...
    );
    T.add('Qmv, Relative Uncertainty in Qv [%]', 'Qmv', 100*(T.QLs-T.QLsv)./T.QLsv );
    
    % Export Data:
    writetable(T.data, 'PartDData.xlsx');
    
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