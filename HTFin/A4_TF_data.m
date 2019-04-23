% Function that simply returns a standard set of processed data from HT11C
% Part A for use in solving specific problems.
function T = A4_TF_data()
    % Load in Data from Excel file (converted from .xls to .xlsx by doing a
    % "save-as" in Excel. Must be in same directory as folder.
    %T = ETable('A4_TF.xlsx', ["run","t", "TB_" + string(1:5), "TC_" + string(1:5), "TS_" + string(1:5), "TA_" + string(1:5)]);
    %save 'A4_TF_data.proc' T
    load A4_TF_data.mat T
    
    T.unitsList = ["","sec",repmat("K",1,20)];
   
    %% Convert Units:
    for sym = ["B","C","S","A"]
        for i=1:5
            name = char("T" + sym + "_" + i);
            T.edit(name,T.get(name)+273.15);
            T.add(char("Uncertainty in"+T.cosmeticFullName(name)),char("d"+name),max(0.0075*abs(T.get(name)-295.95),1));
        end
    end
    
    %% Calculated Columns:
    T.add(char("Time Elapsed[sec]"),char("tAbs"),(T.t-min(T.t(T.run==1))).*(T.run==1) + (T.t-min(T.t(T.run==2))).*(T.run==2));
    
    T.edit('run', T.run.*(T.tAbs<3500));
end