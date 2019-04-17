function figure4()
    T = PDW2();
    
    figure();
    T.plot('RR','COP');
    hold on
    h = plot(T.RR(1:end-4), T.COP(1:end-4), '-o');
    h(2) = plot(T.RR(end-3:end), T.COP(end-3:end), '-o');
    hold off
    ETable.vline(T.RR(end-4), '$\leftarrow$ Decreasing Refrigeration Load $\quad$', 'right', 'top');
    ETable.vline(T.RR(end-4), '$\quad$ Increasing Refrigeration Load $\rightarrow$', 'left', 'top');
    legend(h, {'Decreasing Refrigeration Load', 'Increasing Refrigeration Load'}, 'Interpreter', 'latex');
    saveas(gcf, 'figure4.png', 'png');
    saveas(gcf, 'figure4.fig', 'fig');
end