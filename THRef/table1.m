function table1()
    R12 = tableR12();
    T = processedDataWorksheet();
    
    %% Add All State Data:
    %P,T,s,h
    T.interp('Entropy for State 3', 's3', R12, 'T','sf', 'T3');
    T.interp('Enthalpy for State 3', 'h3', R12, 'T','hf', 'T3');
    T.interp('Pressure for State 3', 'P3', R12, 'T','P', 'T3');
    
    T.interp('Entropy for State 6', 's6', R12, 'T','sg', 'T6');
    T.interp('Enthalpy for State 6', 'h6', R12, 'T','hg', 'T6');
    T.interp('Pressure for State 6', 'P6', R12, 'T','P', 'T6');
    
    
end