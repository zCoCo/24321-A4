function compileRawTables()
    experiments = ["A" "B" "C" "D"];
    trials = [5 2 2 4];
    for i = 1:numel(experiments)
        experiment = experiments(i);
        % Create a Table with Columns:
        % run,NTubes,L,FHot,FCold,Thi,Tho,Tci,Tco,x1,T1,...x10,T10],flowDir
        % at 1 row per run.
        output = num2cell(zeros(trials(i), 10+2*10));
        xtable = num2cell(zeros(0, 6)); % Columns: NTubes, flowDir, L, x, THot, TCold

        for run = 1:trials(i)
            T = ETable(char("A4_HT36C_"+experiment+"_"+run+".xlsx"), ["NTubes", "T"+(1:10), "pumpHotSett", "FHot", "valveColdSett", "FCold", "pumpDir","flowDir", "NHot", "THot", "NCold", "TCold", "x"]);
            output{run, 1} = run;
            output{run, 2} = T.NTubes(1);
            output{run, 3} = max(T.x);
            output{run, 4} = T.FHot(1);
            output{run, 5} = T.FCold(1);
            output{run,6} = max(T.THot);
            output{run,7} = min(T.THot);
            output{run,8} = min(T.TCold);
            output{run,9} = max(T.TCold);
            output{run, 9+20+1} = T.flowDir(1);

            for r = 1:numel(T.NHot) % loop through each row of the leftmost temperature
                probeHot = str2double(regexp(string(T.NHot(r)), '\d*', 'match'));
                probeCold = str2double(regexp(string(T.NCold(r)), '\d*', 'match'));

                output{run, (probeHot-1)*2 + 10} = T.x(r);
                output{run, (probeHot-1)*2 + 11} = T.THot(r);
                output{run, (probeCold-1)*2 + 10} = T.x(r);
                output{run, (probeCold-1)*2 + 11} = T.TCold(r);
            end
            
            nx = numel(T.x);
            a = size(xtable,1) + 1;
            b = a + nx - 1;
            xtable(a:b, 1) = num2cell(T.NTubes(1));
            xtable(a:b, 2) = num2cell(T.flowDir(1));
            xtable(a:b, 3) = num2cell(max(T.x));
            xtable(a:b, 4) = num2cell(T.x);
            xtable(a:b, 5) = num2cell(T.THot);
            xtable(a:b, 6) = num2cell(T.TCold);
        end

        tab = cell2table(output);
        strs(1:2:2*10) = "x"+(1:10); % Create interleaved header strings
        strs(2:2:2*10+1) = "T"+(1:10);
        tab.Properties.VariableNames = cellstr(["run","NTubes","L", "FHot","FCold", "Thi","Tho", "Tci","Tco", strs, "flowDir"]);
        writetable(tab, char("Comp-A4_HT36C_"+experiment+".xlsx"));
        
        xtab = cell2table(xtable);
        xtab.Properties.VariableNames = cellstr(["NTubes", "flowDir", "L", "x", "THot", "TCold"]);
        writetable(xtab, char("XTable-A4_HT36C_"+experiment+".xlsx"));
    end
end