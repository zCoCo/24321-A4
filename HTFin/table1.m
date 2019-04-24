function table1()
    tab = A4_TF_data();
    
    % Therm. Phys. Prop.:
    g = 9.81;
    Pr_a = 0.707; % SI base
    k_a = 26.2e-3; % SI base
    nu_a = 15.81e-6; % SI base
    
    % Measurements:
    Tinf = 22.8 + 273.15; % K
    x = flip([1.50 77.78 154.15 230.43 303.39]*1e-3); % X-Positions of Each P
    L = 306.36e-3;
    ks = [14.9,167,116, 401]; % SS, Al, B, Cu
    D = 12.7e-3;
    
    Uforced = 4.77; %m/s
    dUforced = 1.73; %m/s
    Ufree = 0.113; %m/s
    dUfree = 0.023; %m/s

    results = []; % Cols: he, k, qfin, Re, Gr, Nu0, h0, Te, hrad
    
    
    freeConvFig = figure();
    freeConvLabels = [];

    forcedConvFig = figure();
    forcedConvLabels = [];
    
freeConvRun = [2,2,1,1];
names = ["Stainless Steel", "Aluminum", "Brass", "Copper"];
syms = ["S","A","B","C"];
colors = ["r","g","b","m","c"];
count = 1;
for r = 1:2
    for j = 1:4
        hold on
        sym = syms(j);
        
        Te = [];
        dTe = [];
        for i=1:5
            Ts = tab.get(char("T" + sym + "_" + i));
            dTs = tab.get(char("dT" + sym + "_" + i));
            Ts = Ts(tab.run == r);
            dTs = dTs(tab.run == r);
            Te(i) = Ts(end);
            dTe(i) = dTs(end);
        end
        
        Gr = g * (mean(Te)-Tinf)*D^3 / Tinf / (nu_a^2);
        
        if r == freeConvRun(j)
            Ra = Gr*Pr_a;
            Re = Ufree * D / nu_a;
            Nu0 = (0.60 + (0.387*Ra^(1/6)) / ((1 + (0.559/Pr_a)^(9/16))^(8/27)))^2;
            h0 = (k_a/D)*Nu0;
        else
            Re = Uforced * D / nu_a;
            Nu0 = (0.3 + ((0.62*sqrt(Re)*Pr_a^(1/3)) / ((1+(0.4/Pr_a)^(2/3))^(1/4))) * (1 + (Re/282000)^(5/8))^(4/5));
            h0 = (k_a/D)*Nu0;
        end
        
        k = ks(j);
        thb = Te(end) - Tinf;
        Li = sqrt(4/k/D)*L;
        Ai = @(x) Li - sqrt(4/k/D)*x;
        m = @(h) sqrt(4*h/k/D);
        B = @(h) h / k / m(h);
        T = @(h,x) Tinf + thb*((cosh(m(h)*(L-x)) + B(h)*sinh(m(h)*(L-x))))/(cosh(m(h)*L) + B(h)*sinh(m(h)*L));
        he = lsqcurvefit(T,h0, x,Te, [], [], optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt', 'MaxIterations', 1000));
 
        if r == freeConvRun(j)
            figure(freeConvFig);
            freeConvLabels = [freeConvLabels, names(j) + " Experimental Data", names(j) + " Computed Data"];
        else
            figure(forcedConvFig);
            forcedConvLabels = [forcedConvLabels, names(j) + " Experimental Data", names(j) + " Computed Data"];
            if strcmp(sym, "S")
            end
        end
        
        hold on
            errorbar(x,Te, dTe, char("o"+colors(j)));
            fplot(@(x) T(he,x), [min(x),max(x)], char("-"+colors(j)));
        hold off
        
        %{
        figure();
        hold on
            plot(x,Te, 'o');
            fplot(@(x) T(he,x), [min(x),max(x)]);
        hold off
        title(char(names(j) + " Tube - Run " + r), 'Interpreter', 'latex');
        xlabel('Position Along Fin [m]', 'Interpreter', 'latex');
        ylabel('Temperature [K]', 'Interpreter', 'latex');
        legend({'Raw Data', char("Fitted Curve with $h="+floor(he)+"$")}, 'Interpreter', 'latex');
        %}
        
        %he = gradDescentH(Te,x,ks(j),D,L, h0, h0/1000, 5000, 5*(2*0.5)^2);
        results(count,1) = he;
        results(count,2) = ks(j);
        results(count,4) = Re;
        results(count,5) = Gr;
        results(count,6) = Nu0;
        results(count,7) = h0;
        results(count,8) = mean(Te);
        results(count,9) = 0.78*(5.67e-8)*(mean(Te)-Tinf)*(mean(Te)^2-Tinf^2);
        results(count,10) = thb;
        count = count+1;
    end
end


    figure(freeConvFig);
    xlabel('Position Along Fin [m]', 'Interpreter', 'latex');
    ylabel('Temperature [K]', 'Interpreter', 'latex');
    legend(cellstr(freeConvLabels), 'Interpreter', 'latex');
    saveas(freeConvFig, 'Figure 3.png', 'png');
    
    figure(forcedConvFig);
    xlabel('Position Along Fin [m]', 'Interpreter', 'latex');
    ylabel('Temperature [K]', 'Interpreter', 'latex');
    legend(cellstr(forcedConvLabels), 'Interpreter', 'latex');
    ETable.caption({'Note: \textit{By coincidence, $T_2$ for Brass} ','\textit{and Stainless-Steel are nearly overlapping.}'});
    saveas(forcedConvFig, 'Figure 4.png', 'png');
    
    
    h = results(:,1);
    k = results(:,2);
    thb = results(:,10);
    Li = sqrt(4./k./D)*L;
    m = sqrt(4*h./k./D);
    B = h ./ k ./ m;
    qfin = sqrt(pi^2 .* h .* k .* D^3 ./ 4) .* thb .* (sinh(m*L) + B.*cosh(m*L)) ./ (cosh(m*L)+B.*sinh(m*L));
    results(:,3) = qfin;
    
    disp(results);
    
    tabout = array2table(results);
    tabout.Properties.VariableNames = cellstr(["h","k","qfin","Re","Gr","Nu0","h0","Tf","hrad","thb"]);
    writetable(tabout, 'Table 1 Calc Data.xlsx');
    
    % Uses Gradient Descent to Determine the Value of H which Best Fits the
    % Measured Data.
    function he = gradDescentH(Te,x,k,D,L, h0, stepSize, maxIter, tol)
        h = h0;% Seed with good initial guess.
        thb = Te(end) - Tinf;
        
        n = 1;
        F = Inf; % Squared Error, Starts at Inf to kick off algorithm
        dFdh = 0;
        first_run = 1;
        while(n<maxIter && (first_run || F(n-1)>tol)) % Iterate until convergence
            first_run = 0;
            for i = 1:numel(Te) % For each entry in Te
                Li = sqrt(4/k/D)*L;
                Ai = Li - sqrt(4/k/D)*x(i);
                B = sqrt(D/4/k);
                Ci = Tinf - Te(i);

                F(n) = 0;
                dFdh2(n) = 0;
                
                % Compute Squared Error Function:
                thb = Te(1) - Tinf;
                Li = sqrt(4/k/D)*L;
                Ai = @(x) Li - sqrt(4/k/D)*x;
                B = @(h) h / k / sqrt(4*h/k/D);
                T = @(h,x) Tinf + (thb*(cosh(Ai(x)*(h)^(1/2)) + B(h)*sinh(Ai(x)*(h)^(1/2))))/(cosh((h)^(1/2)*Li) + B(h)*sinh((h)^(1/2)*Li));
                Ff = @(h) (T(h,x(i))-Te(i))^2;
                F(n) = F(n) + Ff(h(n));
                % Compute Local Derivative of Squared Error:
                dFdh2(n) = dFdh2(n) + (Ff(h(n)+stepSize)-Ff(h(n)-stepSize)) / (2*stepSize);
                %dFdh(n) = dFdh(n) + 2*(Ci + (thb*(cosh(Ai*h(n)^(1/2)) + B*sinh(Ai*h(n)^(1/2))))/(cosh(h(n)^(1/2)*Li) + B*sinh(h(n)^(1/2)*Li)))*((Ai*thb*(sinh(Ai*h(n)^(1/2)) + B*cosh(Ai*h(n)^(1/2))))/(h(n)^(1/2)*(2*cosh(h(n)^(1/2)*Li) + 2*B*sinh(h(n)^(1/2)*Li))) - (Li*thb*(cosh(Ai*h(n)^(1/2)) + B*sinh(Ai*h(n)^(1/2)))*(sinh(h(n)^(1/2)*Li) + B*cosh(h(n)^(1/2)*Li)))/(2*h(n)^(1/2)*(cosh(h(n)^(1/2)*Li) + B*sinh(h(n)^(1/2)*Li))^2));
            end
            
            % Perform Gradient Descent Decrement on h and Compute Current dh:
            h(n+1) = h(n) - stepSize*dFdh2(n);
            
        n = n+1;
        end
        
        % Grab Final Results:
        he = h(end);
        
        % Plot Process to Verify Convergence:
        figure();
        hold on
            plot(1:n, h);
            ylabel('Heat Transfer Coefficient [$^W/_{m^2 K}$]', 'Interpreter', 'latex');
            yyaxis right;
            plot(1:n-1,F);
            %plot(1:n-1,dFdh);
            plot(1:n-1,dFdh2);
        hold off
        title('Gradient Descent Convergence for Heat Transfer Coefficient', 'Interpreter', 'latex');
        xlabel('Iteration', 'Interpreter', 'latex');
        legend({'Heat Transfer Coefficient', 'Squared Error', 'Squared Error Slope dh'}, 'Interpreter', 'latex');
    end

end
