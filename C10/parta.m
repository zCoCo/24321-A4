function parta()
    % Scaling Table:
    Ts = ETable('origins.xlsx', ["fig","size","x","y","h","w"]);
    T = ETable('streamlineLoc.xlsx', ["cyl", "cyl3D", "rect", "A4", "A5", "A6", "A7"]);
    
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20; % mm, Size of Squares
    
%% Predicted Streamlines:
    cylinder = Ts.fig==1;
    r = (Ts.y(cylinder) - T.cyl) * (sq/Ts.size(cylinder)) % r values of streamlines in mm
    psi = Uinf.*sin(pi/2).*(r-R^2./r) .* (r>0) + Uinf.*sin(-pi/2).*(r-R^2./r) .* (r<0) % mm^2/s
    Dpsi_upper = psi(1:9-1) - psi(2:9)
    Dpsi_lower = psi(10:end-1) - psi(11:end)
    
    %psi = Uinf*sin(pi/2)*(n*sq-R^2/(2*R))
    
    %U = ((U^2*(R^4 - 2*cos(2*th)*R^2*r^2 + r^4))/r^4)^(1/2);
end