function table1()
    A2 = tableA2();
    R12 = tableR12();
    R12SH = tableR12SH();
    T = processedDataWorksheet();
    
    %% Add All State Data:
    %P,T,s,h
    T.interp('Entropy for State 1 [$^{J}/_{kgK}$]', 's1', R12, 'T','sg', 'T1');
    T.interp('Enthalpy for State 1 [$^{J}/_{kg}$]', 'h1', R12, 'T','hg', 'T1');
    T.interp('Pressure for State 1 [Pa]', 'P1', R12, 'T','P', 'T1');
    
    T.add('Pressure for State 2 [Pa]', 'P2', T.Pc);
    T.interpQ2('Entropy for State 2 [$^{J}/_{kgK}$]', 's2', R12SH, 'T','P','s', 'T2','P2');
    T.interpQ2('Enthalpy for State 2 [$^{J}/_{kg}$]', 'h2', R12SH, 'T','P','h', 'T2','P2');
    
    T.interp('Entropy for State 3 [$^{J}/_{kgK}$]', 's3', R12, 'T','sf', 'T3');
    T.interp('Enthalpy for State 3 [$^{J}/_{kg}$]', 'h3', R12, 'T','hf', 'T3');
    T.interp('Pressure for State 3 [Pa]', 'P3', R12, 'T','P', 'T3');
    
    T.interp('Entropy for State 4 [$^{J}/_{kgK}$]', 's4', R12, 'T','sf', 'T4');
    T.interp('Enthalpy for State 4 [$^{J}/_{kg}$]', 'h4', R12, 'T','hf', 'T4');
    T.interp('Pressure for State 4 [Pa]', 'P4', R12, 'T','P', 'T4');
    
    T.interp('Pressure for State 5 [Pa]', 'P5', R12, 'T','P', 'T5');
    T.add('Enthalpy for State 5 [$^{J}/_{kg}$]', 'h5', T.h4); % b/c throttle
    T.interp('Sat. Liq. Enthalpy at Temp. 5 [$^{J}/_{kg}$]', 'hf5', R12, 'T', 'hf', 'T5');
    T.interp('Evaporation Enthalpy at Temp. 5 [$^{J}/_{kg}$]', 'hfg5', R12, 'T', 'hfg', 'T5');
    T.add('Vapor Quality at State 5', 'x5', (T.h5 - T.hf5) ./ T.hfg5);
    T.interp('Sat. Liq. Entropy at Temp. 5 [$^{J}/_{kg}$]', 'sf5', R12, 'T', 'sf', 'T5');
    T.interp('Sat. Vap. Entropy at Temp. 5 [$^{J}/_{kg}$]', 'sg5', R12, 'T', 'sg', 'T5');
    T.add('Entropy for State 5 [$^{J}/_{kgK}$]', 's5', T.x5 .* (T.sg5-T.sf5) + T.sf5);
    
    T.interp('Entropy for State 6 [$^{J}/_{kgK}$]', 's6', R12, 'T','sg', 'T6');
    T.interp('Enthalpy for State 6 [$^{J}/_{kg}$]', 'h6', R12, 'T','hg', 'T6');
    T.interp('Pressure for State 6 [Pa]', 'P6', R12, 'T','P', 'T6');
    
    %% Produce Table 1:
    states = (1:6)';
    cols = ["T" + states, "P" + states, "h" + states, "s" + states]';
    cols = cellstr(cols(:));
    T.subColToExcel('Table 1.xlsx', cols{:});
    
    %% Produce T-s Curve(s):
    figure();
    Ts = cell2mat(T.get(cellstr("T"+(1:6))));
    ss = cell2mat(T.get(cellstr("s"+(1:6))));
    hold on
    plotTSVaporDome(min(min(ss))/1.5, max(max(ss))*1.5);
    for i = [10,6]
        T = Ts(i, :);
        s = ss(i, :);
        plot(s,T, '-o');
    end
    hold off
    legend({'Saturation Dome', 'Maximum Refrigeration Load (Rheostat: 98.5\%)', 'Minimum Refrigeration Load (Rheostat: 42.5\%)'}, 'Interpreter', 'latex');
    xlabel('Entropy [$^{J}/_{kgK}$]', 'Interpreter', 'latex');
    ylabel('Temperature [K]',  'Interpreter', 'latex');
    for j = 1:numel(T)
        if j == 3
            side = 'right';
            fact = 0.99;
        else
            side = 'left';
            fact = 1.01;
        end
        text(fact*s(j), T(j), char("T"+j), 'Interpreter', 'latex', 'HorizontalAlignment', side);
    end
    saveas(gcf, 'Figure 1.png', 'png');
    saveas(gcf, 'Figure 1.fig ', 'fig');
    
    % Plot the Vapor Dome on a T-s Diagram between smin and smax
    function plotTSVaporDome(smin,smax)
        s = linspace(smin, smax, 500);
        
        [R12sf, unique_sf] = unique(R12.sf);
        [R12sg, unique_sg] = unique(R12.sg);
        Tsf = R12.T(unique_sf);
        Tsg = R12.T(unique_sg);
        
        Tf = interp1(R12sf, Tsf, s);
        Tg = interp1(R12sg, Tsg, s);
        
        plot([s(~isnan(Tf)) s(~isnan(Tg))], [Tf(~isnan(Tf)) Tg(~isnan(Tg))], 'Color', [0.5 0.4 0.4]);
    end
end