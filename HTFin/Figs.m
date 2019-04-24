function Figs()
tab = A4_TF_data();

freeConvFig = figure();
title("Free Convection");

forcedConvFig = figure();
title("Forced Convection");

freeConvRun = [1,1,2,2];
for r = 1:2
    syms = ["B","C","S","A"];
    for j = 1:4
        colors = ["r","g","b","m","c"];
        lines = ["-","--",":","-."];
        if r == freeConvRun(j)
            figure(freeConvFig);
        else
            figure(forcedConvFig);
        end
        hold on
        sym = syms(j);
        for i=1:4
            name = char("T" + sym + "_" + i);
            errname = char("dT" + sym + "_" + i);
            tab.errorplot('tAbs',name, errname,75,tab.run==r,char(lines(i)+colors(j)));
            ylabel('Temperature (K)','Interpreter','latex');
        end
        if i > 4
            tab.errorplot('tAbs',name,errname,75,tab.run==r,'Marker','>','MarkerIndices',100)
        end
        hold off
    end
    
    
end
