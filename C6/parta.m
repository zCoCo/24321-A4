function parta()
    T = ETable('A4_C6_A.xlsx', ["L","d","T","ID","h1","h2","Q"]);
    
    % Convert Units:
    T.edit('Q', T.Q .* 0.001); % L/s -> m^3/s
    T.edit('T', T.T + 273.15); % oC to K
    
    T.unitsList = ["m", "m", "K", "", "m", "m", "$^{m^3}/_{s}$"];
    
    % Set Proper Diameters:
    T.edit('d', ...
        + 15.2e-3 * (T.ID==7)...
        + 17.2e-3 * (T.ID==8)...
        + 10.9e-3 * (T.ID==9)...
        + 9.5e-3 * (T.ID==10)...
        + 6.4e-3 * (T.ID==11)...
    ); % m
    
    % Rename Fields:
    T.rename('L', 'Length of Tube [m]');
    T.rename('d', 'Diameter of Tube [m]');
    T.rename('T', 'Fluid Temperature [K]');
    T.rename('h1', 'Upstream Pressure Head [m]');
    T.rename('h2', 'Downstream Pressure Head [m]');
    T.rename('Q', 'Volumetric Flow Rate [$^{m^3}/_{s}$]');
    T.add('Volume Flow Rate [$^{L}/_{s}$]','QLs', T.Q/0.001);

    % Constants and Thermophysical Properties:
    g = 9.807;
    nu = 1.003e-6;
    es = 4.6e-5;
    er = 2.5e-4;
    
    % Computed Values:
    T.add('Average Fluid Velocity, $V_{av}$ [$^{m}/{s}$]', 'V', 4 .* T.Q ./ pi ./ (T.d.^2) );
    T.add('Reynolds Number, $Re$', 'Re', T.V .* T.d ./ nu );
    
    T.add('Empirical Head Loss, $h_e$ [m]', 'he', T.h1 - T.h2);
    T.add('Empirical Friction Factor, $f_e$', 'fe', 2.*g.*T.d.*T.he./T.L./(T.V.^2) );
    
    T.add('Tube Interior Surface Roughness, $\varepsilon$ [m]', 'e', er.*(T.ID==7) + es.*(T.ID~=7) );
    T.add('Theoretical Friction Factor, $f_c$', 'fc', ...
        + 64 ./ T.Re .* (T.Re <= 2500)...
        + ( -1.8.*log(6.9./T.Re + ((T.e./T.d)./3.7).^1.11) ).^-2 .* (T.Re > 2500)...
    );
    T.add('Theoretical Head Loss, $h_c$ [m]', 'hc', T.fc .* T.L .* (T.V.^2) ./ 2 ./ g ./ T.d );

    % Export Data:
    writetable(T.data, 'PartAData.xlsx');
    
    % Prepare Figures:
    figure();
    hold on
        plotBins(T, 'QLs','he', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==7);
        plotBins(T, 'QLs','he', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==8);
        plotBins(T, 'QLs','he', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==9);
        plotBins(T, 'QLs','he', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==10);
        h = plotBins(T, 'QLs','hc', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==7);
        h.LineStyle = '--';
        h = plotBins(T, 'QLs','hc', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==8);
        h.LineStyle = '--';
        h = plotBins(T, 'QLs','hc', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==9);
        h.LineStyle = '--';
        h = plotBins(T, 'QLs','hc', [0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05], 0.03, T.ID==10);
        h.LineStyle = '--';
    hold off
    title('Figure 1', 'Interpreter', 'latex');
    legend([cellstr("Measured, Tube " + (7:10)) cellstr("Calculated, Tube " + (7:10))], 'Interpreter', 'latex');
    ylabel('Head Loss [m]', 'Interpreter', 'latex');
    saveas(gcf, 'Figure 1.png', 'png');
    saveas(gcf, 'Figure 1.fig', 'fig');
   
    figure();
    hold on
        [Res, Rwindow] = translateRange(T,'QLs','Re',[0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.05],0.03);
        plotBins(T, 'Re','fe', Res, Rwindow, T.ID==7);
        plotBins(T, 'Re','fe', Res, Rwindow, T.ID==8);
        plotBins(T, 'Re','fe', Res, Rwindow, T.ID==9);
        plotBins(T, 'Re','fe', Res, Rwindow, T.ID==10);
        h = plotBins(T, 'Re','fc', Res, Rwindow, T.ID==7);
        h.LineStyle = '--';
        h = plotBins(T, 'Re','fc', Res, Rwindow, T.ID==8);
        h.LineStyle = '--';
        h = plotBins(T, 'Re','fc', Res, Rwindow, T.ID==9);
        h.LineStyle = '--';
        h = plotBins(T, 'Re','fc', Res, Rwindow, T.ID==10);
        h.LineStyle = '--';
    hold off
    title('Figure 2', 'Interpreter', 'latex');
    legend([cellstr("Measured, Tube " + (7:10)) cellstr("Calculated, Tube " + (7:10))], 'Interpreter', 'latex');
    ylabel('Friction Coefficient', 'Interpreter', 'latex');
    saveas(gcf, 'Figure 2.png', 'png');
    saveas(gcf, 'Figure 2.fig', 'fig');
    
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