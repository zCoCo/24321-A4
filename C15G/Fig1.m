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

plotAgainstVel('FLift')
plotAgainstVel('CL')
plotAgainstVel('CD')

function plotAgainstVel(name)
    tab.add(char("Error in " + name),char("d"+name),...
        zeros(size(tab.get(name))) ...
    );
    figure()
    hold on
    tab.errorAvgAtplot('Veloc', name, char("d" + name), ETable.within(tab.Ang, 0.12, 5), 'Veloc', 5,10,15,20,25);
    tab.errorAvgAtplot('Veloc', name, char("d" + name), ETable.within(tab.Ang, 0.12, 10), 'Veloc', 5,10,15,20,25);
    tab.errorAvgAtplot('Veloc', name, char("d" + name), ETable.within(tab.Ang, 0.12, 20), 'Veloc', 5,10,15,20,25);
    tab.errorAvgAtplot('Veloc', name, char("d" + name), ETable.within(tab.Ang, 0.12, 30), 'Veloc', 5,10,15,20,25);
    tab.errorAvgAtplot('Veloc', name, char("d" + name), ETable.inrange(tab.Ang, -0.1, 0.1), 'Veloc', 5,10,15,20,25);
    legend({'$$\theta = 5^{\circ}$$','$$\theta = 10^{\circ}$$','$$\theta = 20^{\circ}$$','$$\theta = 30^{\circ}$$','$$\theta = 0^{\circ}$$'}, 'Location', 'NorthWest', 'Interpreter', 'latex');
    hold off
end
%tab.caption({'Errors computed using std-dev of', 'all values measured at each V'});
end