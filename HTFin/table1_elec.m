function table1_elec()
    T = ETable('table1 raw.xlsx', ["Exp","Run" "T"+string(1:5), "h", "V", "I", "R", "qe", "qfin"]);
    
    dV = T.V*0.0019/100;
    dR = T.R*0.0060/100;
    T.add('dQelec', 'dqe', sqrt((2*T.V./T.R).^2 .* dV.^2 + (T.V.^2./T.R.^2).^2 .* dR.^2));
    T.add('Conv. Eff.', 'e', 100*T.qfin ./ T.qe);

    writetable(T.data, 't1 touch.xlsx');
end