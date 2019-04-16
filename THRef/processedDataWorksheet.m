function T = processedDataWorksheet()
    % Load Raw Data:
    T = ETable('A4_ThRef.xlsx', 12, ["Pc","CP", "Pe","Ve","Ie", "Vm","Im","Fm", "wm", "wc", "Flow_r","Flow_m", "T1","T2","T3","T4","T5","T6","T7","T8"]);
    
    % Convert Units to SI Base Units:
    % C -> K
    for i = 1:8
        T.edit(char("T"+(i)), T.T + 273.15); % C -> K
    end
    
    % kPa -> Pa
    T.edit('Pc', T.Pc * 1e3);
    T.edit('Pe', T.Pe * 1e3);
    
    % rpm -> rad/s
    T.edit('wm', T.wm * 2*pi/60);
    T.edit('wc', T.wc * 2*pi/60);
    
    % g/s to kg/s
    T.edit('Flow_r', T.Flow_r / 1000);
    T.edit('Flow_w', T.Flow_w / 1000);
end