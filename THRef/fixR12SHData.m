function fixR12SHData()
    Ts = [];
    Ps = [];
    Vs = [];
    Hs = [];
    Ss = [];
    
    Ps_src = [10:10:100, 101.325, 110:10:400, 425:25:750, 800:50:1000, 1100:100:2000, 2200:200:4000];
    for i = 1:4:numel(Ps_src)
        % Determine Source File:
        P0 = Ps_src(i);
        Pf = Ps_src(i+3);
        file = char("Table R12SH_"+P0+"-"+Pf);
        
        % Fix Source File:
        fID = fopen(file, 'r');
        str = fscanf(fID, '%c');
        
        % Find the beginning and end of each row (where two +ve temPs_src are
        % smashed together) and separate them:
        for T = -200:5:200
            smash = char(" "+num2str(T)+num2str(T+5)+" ");
            unsmash = char(" "+num2str(T)+" "+num2str(T+5)+" ");
            str = strrep(str, smash,unsmash);
        end
        fclose(fID);
        
        % Overwrite Source File:
        fID = fopen(file, 'w');
        fprintf(fID, str);
        fclose(fID);

        % Extract Source File Data:
        src = ETable.loadFromLineFile(file, 14, ...
        ["Temperature", "Spec. Vol. 1", "Enthalpy 1", "Entropy 1", "Spec. Vol. 2", "Enthalpy 2", "Entropy 2", "Spec. Vol. 3", "Enthalpy 3", "Entropy 3", "Spec. Vol. 4", "Enthalpy 4", "Entropy 4", "Temperature2 (ignore me)"],...
        ["T", "v1","h1","s1", "v2","h2","s2", "v3","h3","s3", "v4","h4","s4", "T2"]);
        vec = ones(size(src.T));
        Ts = [Ts; src.T; src.T; src.T; src.T];
        Ps = [Ps; Ps_src(i)*vec; Ps_src(i+1)*vec; Ps_src(i+2)*vec; Ps_src(i+3)*vec];
        Vs = [Vs; src.v1; src.v2; src.v3; src.v4];
        Hs = [Hs; src.h1; src.h2; src.h3; src.h4];
        Ss = [Ss; src.s1; src.s2; src.s3; src.s4];
    end
    tab = array2table([Ts Ps Vs Hs Ss]);
    tab.Properties.VariableNames = cellstr(["Temperature_C", "Pressure_kPa", "SpecificVolume_m3_kg", "SpecificEnthalpy_kJ_kg", "SpecificEntropy_kJ_kgK"]);
    writetable(tab, 'Table R12SH.xlsx');
end
    
    