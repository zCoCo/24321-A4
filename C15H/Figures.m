function Figures()
    tab = A4_C15H_data();

    % Out 
    
    for i = 1:6
        createFig(i);
        saveas(gcf, char("Figure " + i + ".png"), 'png');
        saveas(gcf, char("Figure " + i + ".fig"), 'fig');
    end

    function createFig(n)
        figure();

        vels = [5,25];
        hold on
        for fin = [tab.SMOOTH, tab.ROUGH, tab.OBSTACLE]
            tab.errorplot('Y', 'Vcalc', 'dVcalc', 1, tab.Fin == fin & tab.Vset == vels(floor((n-1)/3)+1) & tab.Pos == mod(n-1, 3)+1);
        end
        hold off
        legend({'Smooth Plate', 'Rough Plate', 'Smooth Plate with Obstacle'}, 'Location', 'SouthEast', 'Interpreter', 'latex');

        pos = ["Leading Edge (Upstream)", "Center", "Trailing Edge (Downstream)"];
        title({char("\textbf{Figure "+n+":} Measured Velocity of Flow over Object at " + pos(mod(n-1,3)+1) + ", Subject to a Free-Stream Velocity of "+vels(1.0*(n>3) + 1)+" $$^{m}/_{s}$$")}, 'Interpreter', 'latex');
        ylabel('Flow Velocity [$$^{m}/{s}$$]');
        ETable.caption({'\textbf{Note}: No-slip condition was enforced by replacing all data at $y=0$ with $V=0$'});
    end
end