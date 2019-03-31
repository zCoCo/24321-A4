function parta()
    % Scaling Table:
    Ts = ETable('origins.xlsx', ["fig","size","x","y","h","w"]);
    T = ETable('streamlineLoc.xlsx', ["cyl", "cyl3D", "rect", "A4", "A5", "A6", "A7"]);
    
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20; % mm, Size of Squares
    
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
    
    % Figure 3:
    figure();
    hold on
        plot(ys(1:9-1)/2/R, Vs(1:9-1));
        plot(ys(9:end)/2/R, Vs(9:end));
        ETable.vline(ys(9-1)/2/R,'Above Cylinder');
        ETable.vline(ys(9)/2/R,'Below Cylinder');
    hold off
    
    ths = 0:0.01:2*pi;
    psi = [-1:0.1:-0.3 0.3:0.1:1]; % Streamline Constants
    
    colors = ['r', 'b', 'k', 'g']; % Plot Colors for Each Set of Streamlines
    
    figure, polaraxes
    hold on
        for c = psi % ...Plot a set of streamlines
%             ur = Uinf .* cos(ths) .* (1 - R^2/rs 
            rs = (c - sign(c) .* (c.^2 + 4.*Uinf^2.*R^2.*sin(ths).^2).^(1/2))./(2.*Uinf.*sin(ths))
            polarplot(ths, rs, 'r'); % ...all with the same color
        end
    hold off
    %U = ((U^2*(R^4 - 2*cos(2*th)*R^2*r^2 + r^4))/r^4)^(1/2);
end