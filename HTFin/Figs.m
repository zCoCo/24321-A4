function Figs()
tab = A4_TF_data();

freeConvFig = figure();
title("Free Convection");

forcedConvFig = figure();
title("Forced Convection");

freeConvRun = [1,1,2,2];
%{
Red: Brass
Green: Copper
Blue: Stainless Steel
Magenta: Aluminum

Solid: Thermocouple 1 (closest to base)
Dashed: Thermocouple 2
Dotted: Thermocouple 3
Dash-Dot: Thermocouple 4
Bold: Thermocouple 5 (at tip)
%}
for r = 1:2
    syms = ["B","C","S","A"];
    for j = 1:4
        colors = ["r","g","b","m","c"];
        colorsFull = ["red","green","blue","magenta","cyan"];
        lines = [repmat("-.",1,5),"-","--",":","-."];
        if r == freeConvRun(j)
            figure(freeConvFig);
        else
            figure(forcedConvFig);
        end
        hold on
        sym = syms(j);
        for i=1:5
            name = char("T" + sym + "_" + i);
            errname = char("dT" + sym + "_" + i);
            if i > 4
                ph = tab.errorplot('tAbs',name,errname,75,tab.run==r, char(colors(j)));
                ph.Marker = '*';
                ph.MarkerSize = 1;
                ph.MarkerEdgeColor = char(colorsFull(j));
                ph.MarkerFaceColor = char(colorsFull(j));
            else
                tab.errorplot('tAbs',name, errname,75,tab.run==r,char(lines(i)+colors(j)));
            end
            ylabel('Temperature [K]','Interpreter','latex');
        end
        hold off
    end
    
    saveas(freeConvFig, 'Figure 1.png', 'png');
    saveas(forcedConvFig, 'Figure 2.png', 'png');
    
end
