% Script that Tests Ploting of Funf
function potentialPrimitives()
%% Setup 
Uinf = 1; % Free-Stream Velocity
a = 1; % Radius of Any Cylinder
K = 2*pi*Uinf*a^2 / 10; % Strength of Any Sink/Source

rs = {... % Solutions to Streamline Functions as Polar Functions, Radius of Theta
    @(th,c) - K .* sin(th) ./ 2 ./ pi ./ c ... % Doublet
    @(th,c) (c - sign(c) .* (c.^2 + 4.*Uinf^2.*a^2.*sin(th).^2).^(1/2))./(2.*Uinf.*sin(th))... % Uniform Flow around Cylinder
    @(th,c) sqrt(c * (1/1000) ./ sin(th) ./ cos(th)) % Flow around Sharp Bend
    };

%% Plot 
    th = 0:0.01:2*pi;
    psi = [-1:0.1:-0.3 0.3:0.1:1]; % Streamline Constants
    
    colors = ['r', 'b', 'k', 'g']; % Plot Colors for Each Set of Streamlines
    
    figure, polaraxes
    hold on
        for i = 1:numel(rs) % For each streamline function
            f_r = rs{i};
            for c = psi % ...Plot a set of streamlines
                r = f_r(th,c);
                polarplot(th, r, colors(i)); % ...all with the same color
            end
        end
    hold off
      
end