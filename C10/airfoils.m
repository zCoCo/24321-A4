function airfoils()
    % Scaling Table:
    Ts = ETable('origins.xlsx', ["fig","size","x","y","h","w"]);
    T = ETable('streamlineLoc.xlsx', ["cyl", "cyl3D", "rect", "A4", "A5", "A6", "A7", "S11i", "S11o"]);
    
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20; % mm, Size of Squares
    sdye = 9.68; % mm, Spacing between Dye Injectors
    Dpsic = 831; % mm^2/s, Ideal
    
%% Velocity Fields:
    for i = 4:7
        foil = Ts.fig==i;
        raw = T.get(char("A"+num2str(i)));
        y = (Ts.y(foil) - raw) * (sq/Ts.size(foil)); % r values of streamlines in mm
        Dy = y(1:end-1) - y(2:end);
        Us = Dpsic ./ Dy;
        ys = y(1:end-1) - Dy(1:end)./2;
        disp(char("FOIL " + num2str(i)));
        mean(Us)
        max(Us)
        figure, plot(ys,Us);
    end
    
    % Plots the Grid used in the Experiment at a specified scale
    function plotGrid(scale)
        if(nargin < 1)
            scale = 1;
        end
        xSize = 16;
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