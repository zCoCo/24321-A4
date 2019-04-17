function figure3()
    T = PDW2();
    
    figure();
    T.plot('T5','RR');
    ETable.caption({'*\textit{Curve follows increasing refrigeration load}', '\textit{from bottom left to top right}'});
    saveas(gcf, 'figure3.png', 'png');
    saveas(gcf, 'figure3.fig', 'fig');
end