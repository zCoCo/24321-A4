function contraction()
    % Scaling Table:
    Ts = ETable('origins.xlsx', ["fig","size","x","y","h","w"]);
    T = ETable('streamlineLoc.xlsx', ["cyl", "cyl3D", "rect", "A4", "A5", "A6", "A7", "S11i", "S11o"]);
    
    Uinf = 85.9; % mm/s, Free Stream Velocity
    R = 30.3; % mm, Radius of Cylinder
    sq = 20.1; % mm, Size of Squares
    sdye = 9.68; % mm, Spacing between Dye Injectors
    Dpsic = 831; % mm^2/s, Ideal
    
%% Velocity Fields:
    field = Ts.fig==10;
    inlet = T.S11i;
    outlet = T.S11o(1:12);
    yi = (Ts.y(field) - inlet) .* (sq/Ts.size(field));
    yo = (Ts.y(field) - outlet) .* (sq/Ts.size(field));
    
    Dyi = yi(1:end-1) - yi(2:end);
    Dyo = yo(1:end-1) - yo(2:end);
    
    Usi = Dpsic ./ Dyi;
    Uso = Dpsic ./ Dyo;
    ysi = yi(1:end-1) - Dyi(1:end)./2;
    yso = yo(1:end-1) - Dyo(1:end)./2;
    
    figure();
    hold on
        plot(ysi,Usi);
        plot(yso,Uso);
    hold off
    legend({'Flow at Inlet', 'Flow at Outlet'}, 'Interpreter', 'latex');
    xlabel('Y-Position Relative to Centerline [mm]', 'Interpreter', 'latex');
    ylabel('Average Flow Velocity between Adjacent Streamlines [$\frac{mm}{s}$]', 'Interpreter', 'latex');
    saveas(gcf, 'Figure 11.png', 'png');
    saveas(gcf, 'Figure 11.fig', 'fig');
end