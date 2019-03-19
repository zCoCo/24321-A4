function Fig1()
tab = A4_C15G_data();

% Compute Error in FLift as Std. Deviation at each Velocity Measurement:
% (Multiply by binary matrix of valid regions and then use addition to
% combine):
%     std( tab.FLift(ETable.is(tab.Veloc,5)) ) * ETable.is(tab.Veloc,5)...
%     + std( tab.FLift(ETable.is(tab.Veloc,10)) ) * ETable.is(tab.Veloc,10)...
%     + std( tab.FLift(ETable.is(tab.Veloc,15)) ) * ETable.is(tab.Veloc,15)...
%     + std( tab.FLift(ETable.is(tab.Veloc,20)) ) * ETable.is(tab.Veloc,20)...
%     + std( tab.FLift(ETable.is(tab.Veloc,25)) ) * ETable.is(tab.Veloc,25)...


%tab.plot('Veloc', 'FLift', ETable.within(tab.Ang, 0.12, 5));

nameXs = ["Veloc","Veloc","Veloc","Veloc","Veloc"];
nameYs = ["FLift", "CL", "FDrag", "CD", "CDL"];
for i = 1:numel(nameXs)
    plotAgainst(char(nameXs(i)), char(nameYs(i)));
    minititle = "Figure " +num2str(i);
    titl = char(minititle + ": " + nameYs(i) + " vs " + nameXs(i));
    title(titl, 'Interpreter', 'latex');
    saveas(gcf, char(minititle + ".png"), 'png'); 
    saveas(gcf, char(minititle + ".fig"), 'fig');
end

function plotAgainst(nameX, nameY)
    xdat = tab.get(nameX);
    ydat = tab.get(nameY);
    tab.add(char("Error in " + nameY),char("d"+nameY),...
        std( ydat(ETable.within(xdat, 0.26,5)) ) * ETable.within(xdat,0.26, 5)...
        + std( ydat(ETable.within(xdat, 0.26,10)) ) * ETable.within(xdat, 0.26,10)...
        + std( ydat(ETable.within(xdat, 0.26,15)) ) * ETable.within(xdat, 0.26,15)...
        + std( ydat(ETable.within(xdat, 0.26,20)) ) * ETable.within(xdat, 0.26,20)...
        + std( ydat(ETable.within(xdat, 0.26,25)) ) * ETable.within(xdat, 0.26,25)...
    );
    figure()
    hold on
    tab.errorAvgAtplot(nameX, nameY, char("d" + nameY), ETable.inrange(tab.Ang, -0.1, 0.1), nameX, 6,10,15,20,25);
    tab.errorAvgAtplot(nameX, nameY, char("d" + nameY), ETable.within(tab.Ang, 0.12, 5), nameX, 6,10,15,20,25);
    tab.errorAvgAtplot(nameX, nameY, char("d" + nameY), ETable.within(tab.Ang, 0.12, 10), nameX, 6,10,15,20,25);
    tab.errorAvgAtplot(nameX, nameY, char("d" + nameY), ETable.within(tab.Ang, 0.12, 20), nameX, 5,10,15,20,25);
    tab.errorAvgAtplot(nameX, nameY, char("d" + nameY), ETable.within(tab.Ang, 0.12, 30), nameX, 5,10,15,20,25);
    legend({'$$\theta = 0^{\circ}$$','$$\theta = 5^{\circ}$$','$$\theta = 10^{\circ}$$','$$\theta = 20^{\circ}$$','$$\theta = 30^{\circ}$$'}, 'Location', 'NorthWest', 'Interpreter', 'latex');
    hold off
end
%tab.caption({'Errors computed using std-dev of', 'all values measured at each V'});
end