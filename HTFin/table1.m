function table1()
    % Setup Parameters:
    L = 1;
    k = 1;
    D = 1;
    x = (1:5)/10;


    % Uses Gradient Descent to Determine the Value of H which Best Fits the
    % Measured Data.
    function [he,dhe] = gradDescentH(Te,x, stepSize, maxIter, tol)
        h = zeros(size(Te));
        h(1) = % TODO: Seed with good initial guess.
        dh = zeros(size(Te)); % Initial Value doesn't matter, it will be replaced.
        
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
            dh(n+1) = 1.96*F / (numel(Te) - 2); % 1.96*Standard Error of Regression -> 95% Confidence Interval
            
        i = i+1;
        end
        
        % Grab Final Results:
        he = h(end);
        dhe = dh(end);
        
        % Plot Process to Verify Convergence:
        figure();
        errorbars(1:i, h, dh);
        title('Gradient Descent Convergence for Heat Transfer Coefficient', 'Interpreter', 'latex');
        xlabel('Iteration', 'Interpreter', 'latex');
        ylabel('Heat Transfer Coefficient [$^W/_{m^2 K}$]', 'Interpreter', 'latex');
    end

end
