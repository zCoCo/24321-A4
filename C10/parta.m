function parta()
    % Scaling Table:
    Ts = ETable('origins.xlsx', ["fig","size","x","y","h","w"]);
    T = ETable('streamlineLoc.xlsx', ["cyl", "cyl3D", "rect", "A4", "A5", "A6", "A7", "S11i", "S11o"]);
    
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20; % mm, Size of Squares
    sdye = 9.68; % mm, Spacing between Dye Injectors
    
%% Velocity Fields:
    cylinder = Ts.fig==1;
    r = (Ts.y(cylinder) - T.cyl) * (sq/Ts.size(cylinder)) % r values of streamlines in mm
    psi = Uinf.*sin(pi/2).*(r-R^2./r) .* (r>0) + Uinf.*sin(-pi/2).*(r-R^2./r) .* (r<0) % mm^2/s
    Dpsi_upper = psi(1:9-1) - psi(2:9)
    Dpsi_lower = -(psi(10:end-1) - psi(11:end))
    Dpsi = [Dpsi_upper; Dpsi_lower]
    Dy = [r(1:9-1) - r(2:9); r(10:end-1) - r(11:end)];
    Vs = Dpsi ./ Dy;
    ys = [r(1:9-1) - Dy(1:9-1)./2; r(10:end-1) - Dy(9:end)./2];
    
    y3D = (Ts.y(cylinder) - T.cyl3D) * (sq/Ts.size(cylinder)) % r values of streamlines in mm
    x3D = -3*2*R;
    r3D = sqrt(y3D.^2 + x3D.^2);
    th3D = atan2(y3D,x3D);
    psi3D = Uinf.*sin(th3D).*(r3D-R^2./r3D) % mm^2/s
    Dpsi3D = psi3D(1:end-1) - psi3D(2:end)
    Dy3D = y3D(1:end-1) - y3D(2:end);
    Vs3D = abs(Dpsi3D ./ Dy3D);
    ys3D = [y3D(1:end-1) - Dy3D(1:end)./2];
    
    % Figure 1:
    [x,y] = meshgrid(-16*sq:1:16*sq,-12*sq:1:12*sq);
    u = (Uinf*(- R.^2.*x.^2 + R.^2.*y.^2 + x.^4 + 2.*x.^2.*y.^2 + y.^4))./(x.^2 + y.^2).^2;
    v = -(2.*R.^2.*Uinf.*x.*y)./(x.^2 + y.^2).^2;
    
    figure();
    plotGrid();
    hold on
        starty = (-9:9)*sdye;
        startx = -16*sq*ones(size(starty));
        streamline(x,y,u,v,startx,starty);
        fill(R*cos(0:0.1:2*pi), R*sin(0:0.1:2*pi), 'k');
    hold off
    xlabel('X-Position (Cylinder Diameters)', 'Interpreter', 'latex');
    ylabel('Y-Position (Cylinder Diameters)', 'Interpreter', 'latex');
    ax = gca;
    ax.TickLabelInterpreter = 'latex';
    xticks(2*R*(-6:6));
    xticklabels(cellstr((-6:6) + "D"));
    yticks(2*R*(-4:4));
    yticklabels(cellstr((-4:4) + "D"));
    axis equal
    xlim([-9*sq,9*sq]);
    ylim([-6.1*sq,6.1*sq]);
    ETable.caption({'\textbf{Note:} \textit{Gridlines in plot have same}','\textit{positioning as in image}'}); 
    saveas(gcf, 'Figure 1.png', 'png');
    saveas(gcf, 'Figure 1.fig', 'fig');
    
    % Figure 3:
    Urect = Uinf * (12/(12-2)); % TODO: Fix me.
    
    figure();
    hold on
        plot(ys(1:9-1)/2/R, Vs(1:9-1), 'bo-');
        plot(ys(9:end)/2/R, Vs(9:end), 'bo-', 'HandleVisibility','off');
        plot(ys3D/2/R, Vs3D, 'go-');
        plot(ys_rect(1:6)/2/(2*sq), Us_rect(1:6), 'ro-');
        plot(ys_rect(7:end)/2/(2*sq), Us_rect(7:end), 'ro-', 'HandleVisibility','off');
        plot(ys3L/2/(2*sq), Usr3L, 'mo-');
        ETable.vline(0.5,'Above Cylinder');
        ETable.vline(-0.5,'Below Cylinder', 'right');
        legend({'Flow around Cylinder at Centerline', 'Flow 3 Diameters Upstream of Cylinder', 'Flow around Rectangle at Centerline', 'Flow 3 Lengths Upstream of Rectangle'}, 'Interpreter', 'latex');
        
    hold off
    xlabel('Y-Position (Characteristic Lengths, ie. Diameter/Width)', 'Interpreter', 'latex');
    ylabel('Flow Velocity ($\frac{mm}{s}$)', 'Interpreter', 'latex');
    ax = gca;
    ax.TickLabelInterpreter = 'latex';
    xticks((-6:6));
    xticklabels(cellstr((-6:6) + "$L_{c}$"));
    xlim([-2.1 2.1]);
    
    
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