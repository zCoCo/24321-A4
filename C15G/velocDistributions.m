function velocDistributions()
    T = A4_C15G_velocData();
    writetable(T.data, 'RawVelocityProfileData.xlsx');
    
    vels = [5,25];
    for i = 1:numel(vels)
        figure();

        ns = 1:10;
        hs = (ns-5.5) * 5; % [mm] Height across Airfoil
        angs = [0,5,10,20,30];
        for ang = angs, hold on
            curve = ETable.is(T.Ang, ang) & ETable.is(T.V, vels(i)); % valid row(s) for this curve
            vs = zeros(size(ns)); % velocity
            evs = zeros(size(ns)); % uncertainty in velocity
            for n = ns
                vsn = T.get(char("v"+n));
                evsn = T.get(char("dv"+n));
                vs(n) = mean(vsn(curve));
                evs(n) = mean(evsn(curve));
            end
            errorbar(hs, vs, evs);
        end, hold off

        xlabel('Height across Airfoil [mm]', 'Interpreter', 'latex');
        ylabel('Velocity [$$^{m}/_{s}$$]', 'Interpreter', 'latex');
        ETable.vline(0, 'Centerline');
        legend(cellstr("+" + string(angs) + "$$^{\circ}$$"), 'Interpreter', 'latex', 'Location', 'SouthEast');

        titl = char("Figure " + (5+i));
        %title(titl, 'Interpreter', 'latex');
        saveas(gcf, char(titl + ".png"), 'png');
        saveas(gcf, char(titl + ".fig"), 'fig');
    end
end