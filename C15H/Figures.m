function Figures()
tab = A4_C15H_data();

%tab.plot('Veloc', 'FLift', ETable.within(tab.Ang, 0.12, 5));

for i = 1:6
    createFig(i);
    saveas(gcf, char("A5 - Figure " + i + ".png"), 'png');
end

function createFig(n)
figure()
plotAgainstY('Vp',1+n-1)
plotAgainstY('Vp',7+n-1)
plotAgainstY('Vp',13+n-1)

vels = [5,25];
pos = ["Leading Edge", "Center", "Trailing Edge"];
title({char("\textbf{Figure "+n+":} Measured Velocity of Flow over Object at " + pos(mod(n-1,3)+1)), char("Subject to a Free-Stream Velocity of "+vels(1.0*(n>3) + 1)+" $$^{m}/_{s}$$")}, 'Interpreter', 'latex');
ylabel('Flow Velocity [$$^{m}/{s}$$]');
legend({'Smooth Plate', 'Rough Plate', 'Smooth Plate with Obstacle'}, 'Location', 'SouthEast', 'Interpreter', 'latex');
% ETable.caption({'\textbf{Note}: Only one data set appears ', 'to be visible since both data sets overlap nearly completely'});
end
%         std( dat(ETable.inrange(tab.y,-0.1,0.1)) ) * ETable.inrange(tab.y,-0.1,0.1)...
%         + std( dat(ETable.is(tab.y,0.5)) ) * ETable.is(tab.y,0.5)...
%         + std( dat(ETable.is(tab.y,1.0)) ) * ETable.is(tab.y,1.0)...
%         + std( dat(ETable.is(tab.y,1.5)) ) * ETable.is(tab.y,1.5)...
%         + std( dat(ETable.is(tab.y,2.0)) ) * ETable.is(tab.y,2.0)...

function plotAgainstY(name,section)
%     dat = tab.get(name);
    tab.add(char("Error in " + name + section),char("d"+name+section),...
        zeros(size(tab.SampNum))...
    );
    hold on
    tab.errorAvgAtplot('y', name, char("d" + name+section), ETable.is(tab.notes, section), 'y', 0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0);
    hold off
end
%tab.caption({'Errors computed using std-dev of', 'all values measured at each V'});
end