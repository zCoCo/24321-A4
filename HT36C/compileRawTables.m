function compileRawTables()
    experiment = "A";
    % Create a Table with Columns: run,NTubes,L,FHot,FCold,Thi,Tho,Tci,Tco,x1,T1,...x10,T10], at 1
    % row per run.
    output = zeros(5, 3+2*10);

    for run = 1:5
        T = ETable(char("A4_HT36C_"+experiment+"_"+run+".xlsx"), ["NTubes", "T"+(1:10), "pumpHotSett", "FHot", "valveColdSett", "FCold", "pumpDir","flowDir", "NHot", "THot", "NCold", "TCold", "x"]);
        output(run, 1) = run;
        output(run, 2) = T.NTubes(1);
        output(run, 3) = max(T.x);
        output(run, 4) = T.FHot(1);
        output(run, 5) = T.FCold(1);
        
        for r = 1:numel(T.NHot) % loop through each row of the leftmost temperature
            probeHot = str2double(regexp(string(T.NHot(r)), '\d*', 'match'));
            probeCold = str2double(regexp(string(T.NCold(r)), '\d*', 'match'));
            
            if(T.x(r) == 0) % row indicates inlet temps
                output(run,6) = T.THot(r);
                output(run,8) = T.TCold(r);
            elseif(T.x(r) == max(T.x)) % row indicates outlet temps
                output(run,7) = T.THot(r);
                output(run,9) = T.TCold(r);
            end
            output(run, (probeHot-1)*2 + 10) = T.x(r);
            output(run, (probeHot-1)*2 + 11) = T.THot(r);
            output(run, (probeCold-1)*2 + 10) = T.x(r);
            output(run, (probeCold-1)*2 + 11) = T.TCold(r);
        end
    end
    
    tab = array2table(output);
    strs(1:2:2*10) = "x"+(1:10); % Create interleaved header strings
    strs(2:2:2*10+1) = "T"+(1:10);
    tab.Properties.VariableNames = cellstr(["run","NTubes","L", "FHot","FCold", "Thi","Tho", "Tci","Tco", strs]);
    writetable(tab, char("Comp-A4_HT36C_"+experiment+".xlsx"));
end