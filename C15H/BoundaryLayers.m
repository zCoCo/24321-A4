function BoundaryLayers()
    tab = A4_C15H_data();

    % Output Table of Points Used in Figures:
    table3 = [];
    for f = [tab.SMOOTH, tab.ROUGH, tab.OBSTACLE]
        for i = 1:2
            v = 5^i;
            for pos = [tab.UPSTREAM, tab.CENTERSTREAM, tab.DOWNSTREAM]
                entry = tab.Fin == f & tab.Vset == v & tab.Pos == pos;
                ys = tab.Y(entry);
                Vs = tab.Vcalc(entry);
                
                n = numel(ys);
                x = mean(tab.X(entry & tab.Y ~= 0));
                Rex = mean(tab.Rex(entry & tab.Y ~= 0));
                dRex = mean(tab.dRex(entry & tab.Y ~= 0));
                Vinf = max(Vs);%mean(tab.Vinf(entry & tab.Y ~= 0));
                ym = mean(ys);
                
                syms symd
                % Laminar:
                if(Rex~=0)
                    d_Re_lam = 5*x / Rex^(1/5) ;
                else
                    d_Re_lam = 0;
                end

                A = sum(ys.^6); B = sum(ys.^4); C = sum(Vs.*ys.^3);
                D = B; E = sum(ys.^2); F = sum(ys.*Vs);
                denom = (A*E - B*D);
                a = (C*E - F*B) / denom;
                b = (A*F - C*D) / denom;

                V = @(y) a*y.^3 + b*y;
                SE = sqrt(sum((V(ys) - ym).^2) / (n-2));

                d = double(solve(a*symd^3 + b*symd == 0.95.*Vinf, symd));
                d_lam = d(d>0); d_lam = d_lam(1); % Select First Positive Solution
                dd_lam = 1.96 * SE;
                
                % Turbulent:
                if(Rex~=0)
                    if(f == tab.OBSTACLE)
                        d_Re_turb = x * (0.381/Rex^(1/5)) * (Rex~=0);
                    else
                        d_Re_turb = x * (0.381/Rex^(1/5) - 10.256/Rex) * (Rex~=0);
                    end
                else 
                    d_Re_turb = 0;
                end
                c = sum(Vs.*ys.^(1/7)) ./ sum(ys.^(2/7));

                V = @(y) c*y.^(1/7);
                SE = sqrt(sum((V(ys) - ym).^2) / (n-2));

                d = double(solve(c*symd^(1/7) == 0.95.* Vinf));
                d_turb = d(d>0); d_turb = d_turb(1); % Select First Positive Solution
                dd_turb = 1.96 * SE;
                    
                if f == tab.OBSTACLE || f == tab.ROUGH % Choose best fitting curve
                    if dd_turb < dd_lam
                        d_Re = d_Re_turb;
                        d = d_turb;
                        dd = dd_turb;
                    else
                        d_Re = d_Re_lam;
                        d = d_lam;
                        dd = dd_lam;
                    end
                elseif Rex > 5e5
                    d_Re = d_Re_turb;
                    d = d_turb;
                    dd = dd_turb;
                else
                    d_Re = d_Re_lam;
                    d = d_lam;
                    dd = dd_lam;
                end
                
                % Add Entry to Table:
                if imag(d)
                    dnote = "**";
                else
                    dnote = "";
                end
                table3 = [table3; string(f) string(v) string(pos) string(sprintf('%d',round(Rex)) + " � " + sprintf('%d',round(dRex))) string(sprintf('%0.3f', d_Re)) string(dnote + sprintf('%0.3f',real(d)) + " � " + sprintf('%0.3f',dd))];
                
                % Plot Regression to Visually Confirm Shape:
                if 1
                    figure('Visible', 'off');
                    hold on
                        plot(ys,Vs, ':o');
                        fplot(V, [min(ys) max(ys)]);
                        ETable.hline(Vinf, 'Measured Free Stream Velocity', 'left', 'bottom');
                        ETable.hline(0.95*Vinf, '95\% of Free Stream Velocity', 'left', 'top');
                        ETable.vline(d_Re, 'Theoretical Boundary Layer Thickness', 'auto', 'bottom', [0.2 0.9 0.2]);
                        ETable.vline(d, 'Calculated Boundary Layer Thickness', 'auto', 'top', [0.2 0.2 0.9]);
                    hold off
                    fins = ["Smooth Plate", "Rough Plate", "Obstacle + Smooth Plate"];
                    poss = ["Upstream", "Centerstream", "Downstream"];
                    xlabel('Y Position Perpendicular to Plate [mm]', 'Interpreter', 'latex');
                    ylabel('Flow Velocity[$^m/_s$]', 'Interpreter', 'latex');
                    legend({'Raw Data', 'Regression'}, 'Location', 'SouthEast', 'Interpreter', 'latex');
                    figID = char("f" + f + "-v" + v + "-p" + pos);
                    title(char("Fig. A-" + figID + " - " + poss(pos) + " of " + fins(f) + " at " +  "Velocity: "+v+", Position: "+pos), 'Interpreter', 'latex');
                    saveas(gcf, char("Boundary Layer - " + figID + ".png"), 'png');
                    disp(figID);
                end
            end
        end
    end
    tableO = array2table(table3);
    writetable(tableO, char("Table 3_raw.xlsx"));
end