function fig12()
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20; % mm, Size of Squares
    sdye = 9.68; % mm, Spacing between Dye Injectors
    c = Uinf / (-19*sq);
    
    % Figure 1:
    [x,y] = meshgrid(-19*sq:1:19*sq,-12*sq:1:12*sq);
    u = c*x;
    v = -c*y;
    
    figure();
    plotGrid();
    hold on
        starty = (-9:9)*sdye;
        startx = -19*sq*ones(size(starty));
        streamline(x,y,u,v,startx,starty);
        plot([-19*sq 0], [0 0], 'k');
        plot([0 0], [12*sq -12*sq], 'k');
    hold off
    xlabel('X-Position [mm]', 'Interpreter', 'latex');
    ylabel('Y-Position [mm]', 'Interpreter', 'latex');
    ax = gca;
    ax.TickLabelInterpreter = 'latex';
    axis equal
    xlim([-19*sq,19*sq]);
    ylim([-12.1*sq,12.1*sq]);
    ETable.caption({'\textbf{Note:} \textit{Gridlines in plot have same}','\textit{positioning as in image}'}); 
    saveas(gcf, 'Figure 12.png', 'png');
    saveas(gcf, 'Figure 12.fig', 'fig');
    
    % Plots the Grid used in the Experiment at a specified scale
    function plotGrid(scale)
        if(nargin < 1)
            scale = 1;
        end
        xSize = 19;
        ySize = 12;
        grey = [0.5 0.5 0.6];
        hold on
            for xx = sq*(-xSize:xSize)
                plot([xx xx]/scale, [-ySize ySize]*sq/scale, ':', 'Color', grey);
            end
            for yy = sq*(-ySize:ySize)
                plot([-xSize xSize]*sq/scale, [yy yy]/scale, ':', 'Color', grey);
            end
        hold off
    end
end