function table1()
    tab = A4_TF_data();
    
    % Therm. Phys. Prop.:
    g = 9.81;
    Pr_a = 0.707; % SI base
    k_a = 26.2e-3; % SI base
    nu_a = 15.81e-6; % SI base
    
    x = [1.50 77.78 154.15 230.43 303.39]*1e-3; % X-Positions of Each P
    L = 306.36;
    ks = [116, 401, 14.9, 167]; % B, Cu, SS, Al
    D = 12.7e-3;
    
    % Setup Parameters:
    U = 4.77; %m/s
    dU = 1.73; %m/s
    Re = U * D / nu_a;
    Ra = 

    % Uses Gradient Descent to Determine the Value of H which Best Fits the
    % Measured Data.
    function [he,dhe] = gradDescentH(Te,x,k, stepSize, maxIter, tol)
        Tb = Te(1);
        h = zeros(size(Te));
        h(1) = % TODO: Seed with good initial guess.
        
        n = 1;
        F = 0; % Squared Error
        while(n<maxIter && F>tol) % Iterate until convergence
            F = 0;
            dFdh = 0;
            for i = 1:numel(Te) % For each entry in Te
                Li = sqrt(4/k/D)*L;
                Ai = Li - sqrt(4/k/D)*x(i);
                B = sqrt(D/4/k);
                Ci = Tinf - Te(i);

                % Compute Squared Error:
                F = F + (Ci + (thb*(cosh(Ai*(h(i))^(1/2)) + B*sinh(Ai*(h(i))^(1/2))))/(cosh((h(i))^(1/2)*Li) + B*sinh((h(i))^(1/2)*Li)))^2;
                % Compute Local Derivative of Squared Error:
                dFdh = dFdh + 2*(Ci + (thb*(cosh(Ai*h(i)^(1/2)) + B*sinh(Ai*h(i)^(1/2))))/(cosh(h(i)^(1/2)*Li) + B*sinh(h(i)^(1/2)*Li)))*((Ai*thb*(sinh(Ai*h(i)^(1/2)) + B*cosh(Ai*h(i)^(1/2))))/(h(i)^(1/2)*(2*cosh(h(i)^(1/2)*Li) + 2*B*sinh(h(i)^(1/2)*Li))) - (Li*thb*(cosh(Ai*h(i)^(1/2)) + B*sinh(Ai*h(i)^(1/2)))*(sinh(h(i)^(1/2)*Li) + B*cosh(h(i)^(1/2)*Li)))/(2*h(i)^(1/2)*(cosh(h(i)^(1/2)*Li) + B*sinh(h(i)^(1/2)*Li))^2));
            end
            
            % Perform Gradient Descent Decrement on h and Compute Current dh:
            h(n+1) = h(n) - stepSize*dFdh;
            
        i = i+1;
        end
        
        % Grab Final Results:
        he = h(end);
        
        % Plot Process to Verify Convergence:
        figure();
        errorbars(1:i, h, dh);
        title('Gradient Descent Convergence for Heat Transfer Coefficient', 'Interpreter', 'latex');
        xlabel('Iteration', 'Interpreter', 'latex');
        ylabel('Heat Transfer Coefficient [$^W/_{m^2 K}$]', 'Interpreter', 'latex');
    end

end
