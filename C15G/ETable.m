classdef ETable < dynamicprops & matlab.mixin.SetGet
    properties
        data; % Core Data Table
        shortNames; % Short Names for Each Valid Column
        unitsList; % Cosmetically Styled Units for Each Short Name (using latex)
    end
    methods
        % Instantiates table from the given spreadsheet (make sure to
        % upgrade xls to xlsx) with the given short names for columns
        function obj = ETable(file, shortNames)
            % Creates a New ETable with the same contents as the given ETable
            % if only one argument is given and that argument is the 
            % ETable
            if nargin < 2
                other = file; 
                obj.data = other.data;
                obj.shortNames = other.shortNames;
                obj.unitsList = other.unitsList;
                
                % Copy all custom properties over
                for name = other.shortNames
                    obj.addprop(char(name));
                    obj.set(char(name), other.get(char(name)));
                end
            else
                obj.data = readtable(file, 'ReadVariableNames',false);

                obj.shortNames = shortNames;

                % Prune Columns that are Empty or Contain NaN from Table:
                w = width(obj.data);
                c = 1;
                while c<=w
                    if (...
                        ~iscell(obj.data{:,c}) && ~prod(~isnan(obj.data{:,c})) || ... % contains NaN
                        isequal(obj.data{2,c}, {''}) && isempty(strtrim(strjoin(cellstr(obj.data{2:end,c})))) ... %is empty
                    )
                        obj.data(:,c) = [];
                        w = w - 1; % Readjust width
                    else
                        c = c+1;
                    end
                end

                % Scoop up Unaltered Full Names into Variable Descriptions, for
                % plotting labels:
                obj.data.Properties.VariableDescriptions = obj.data{1,:};
                % Dump them into Variable Names as well, for command-line #head
                % display:
                obj.data.Properties.VariableNames = matlab.lang.makeValidName(obj.data{1,:});
                % Remove Header Row from Data:
                obj.data(1,:) = [];

                % Prune Any Rows which are All Empty (eg. due to equations in
                % excel which returned '').
                r = 1;
                h = height(obj.data);
                while r<=h
                    row = strtrim(join(obj.data{r,:}));
                    if isequal(row, {''})
                        obj.data(r,:) = [];
                        h = h-1;
                    else
                        r = r+1;
                    end
                end

                for c = 1:width(obj.data)
                    % Convert Strings to Numbers i/a:
                    nums = str2double(obj.data{:,c});
                    if prod(~isnan(nums)) % nums is NaN free
                        obj.data{:,c} = num2cell(nums);
                    end

                    % Create Object Properties Based on Short Name:
                    try
                        obj.addprop(char(shortNames(c)));
                        obj.set(char(shortNames(c)), cell2mat(obj.data{:,c}));
                    catch e
                        warning('Likely Wrong Number of Short Names Supplied');
                    end
                end
            end
        end % ctor
        
        % Helper Function which Returns the Full Variable Name, as a Valid 
        % Variable Name, Associated with the Given shortName:
        function vfn = validFullName(obj, shortName)
            vfn = obj.data.Properties.VariableNames{obj.shortNames == shortName};
        end
        % Helper Function which Returns the Cosmetic (user-facing) Full 
        % Variable Name, Associated with the Given shortName:
        function cfn = cosmeticFullName(obj, shortName)
            cfn = obj.data.Properties.VariableDescriptions{obj.shortNames == shortName};
        end
        
        % Adds a Column with the Given Name, ShortName, and Values:
        function add(obj, n, sn, vs)
            % Add Parameter:
            obj.addprop(sn);
            obj.set(char(sn), vs);
            obj.shortNames(end+1) = sn;
            % Add to Core Data Table:
            obj.data{:, end+1} = num2cell(vs); % use full name for table headers
            obj.rename(sn, n); % Set all names
        end
        
        % Edits the Given Column with the Given Short Name by replacing its
        % values with the given new values:
        function edit(obj, sn, newVals)
            % Update Parameter:
            obj.set(char(sn), newVals);
            % Update Core Data Table:
            obj.data{:, obj.validFullName(sn)} = num2cell(newVals);
        end
        
        % Set the value of the first given variable to its average across 
        % alls rows where the second given variable has one of the given
        % values for each of the given values.
        % Rows where varB is not (within 5% of) any of the given values
        % remain unchanged.
        %{
        ex.: table.bin('A', 'B', 10,20)
        A | B            A | B
        1 | 10           2 | 10
        2 | 10           2 | 10
        3 | 10           2 | 10
        3 | 13     ->    3 | 13
        4 | 20           5 | 20
        5 | 20           5 | 20
        6 | 20           5 | 20
        %}
        function bin(obj, varA, varB, varargin)
            As = obj.get(char(varA));
            Bs = obj.get(char(varB));
            binned = As;
            for i=1:numel(varargin)
                cond = ETable.is(Bs,varargin{i});
                binned = binned.*~cond + mean(As(cond)).*cond;
            end
            obj.edit(varA,binned);
        end
        
        % Edits the Full Name Associated with the Given Short Name:
        function rename(obj, sn, newFullName)
            % Set Name:
            idx = obj.shortNames == sn;
            obj.data.Properties.VariableNames{idx} = matlab.lang.makeValidName(newFullName);
            obj.data.Properties.VariableDescriptions{idx} = newFullName;
            
            % Try to Extract Units from Name:
            units = regexp(newFullName, '(?<=\[).*(?=\])', 'match');
            if ~isempty(units)
                obj.unitsList(idx) = units(1);
            end
        end
        
        % Sets the Cosmetic Units Associated with the Given ShortName
        function setUnits(obj, sn, us)
            obj.unitsList(obj.shortNames == char(sn)) = us;
        end
        
        % Returns the Units Associated with the Given Short Name
        function u = units(obj, sn)
            u = obj.unitsList(obj.shortNames == char(sn));
        end
        
        % Prints the Top of the Table in the Command Line:
        function head(obj)
            disp(head(obj.data,5));
        end
        
        % Returns a copy of this object as a new ETable
        function copy = copy(this)
            copy = ETable(this);
        end
        
        % Returns subsection of the current ETable as a Table containing 
        % all the columns between the columns with short names: colA, colB. 
        % If only colA is needed, just use table.get(col)
        function sub = cols(obj, colA, colB)
            idxA = find(obj.shortNames == colA, 1);
            idxB = find(obj.shortNames == colB, 1);
            sub = obj.data{:, idxA:idxB};
        end
        
        % Returns subsection of the current ETable as a Table containing 
        % the columns with the given indicies in the desired order
        function sub = selectColumns(obj, varargin)
            sz = size(obj.get(char(varargin{1})));
            sz(2) = length(varargin);
            sub = zeros(sz);
            for i = 1:numel(varargin)
                sub(:,i)= obj.get(char(varargin{i}));
            end
        end
        
        % Returns a ETable which is a subtable of the given table where
        % each row is the average of all values that meet the conditions
        % given by each element of varargin, where varargin is a list of
        % conditional vectors obtained by performing, say,
        % ETable.is(table.parameterA, parameterValue) & table.parameterB>5
        function ST = subtable(obj, varargin)
            ST = obj.copy();
            % Summarize Data for Each Range:
            subdata = zeros(length(varargin), length(obj.shortNames));
            for c = 1:width(obj.data)
                col = obj.get(char(obj.shortNames(c))); % Fetch Column Data
                for r = 1:length(varargin)
                    subdata(r,c) = mean(col([varargin{r}]));
                    ST.set(char(obj.shortNames(c)), subdata(r,c));
                end
            end
            sub = array2table(subdata);
            sub.Properties.VariableNames = obj.data.Properties.VariableNames;
            sub.Properties.VariableDescriptions = obj.data.Properties.VariableDescriptions;
            ST.data = sub;
        end
        
        % Function Summary, displays and returns a summary table of the 
        % mean values of all variables in each of the given ranges.
        function STd = summary(obj, varargin)
            ST = obj.subtable(varargin{:});
            STd = ST.data;
            % TODO: Transfer over each dynamicprop (.get, .set)
            disp('Summary Table:');
            disp(STd);
        end
        
        % Produces a Stylized Plot of the Two Variables with the Given
        % Short Names Subject to the Given Range. Returns the plot handle.
        function ph = plot(obj, nameX, nameY, range)
            % Obtain Data:
            xs = obj.get(char(nameX));
            ys = obj.get(char(nameY));
            
            % Determine Range:
            if nargin < 4
                range = true(size(xs));
            end
            
            % Plot Data:
            ph = plot(xs(range), ys(range), 'o-');
            obj.label(nameX, nameY);
        end
        
        % Produces a Stylized Plot of the Two Variables with the Given
        % Short Names Subject to the Given Range with Vertical Error Bars 
        % from the Variable with the Short Name nameE. Errorbars will only 
        % show up every n datapoints. Returns the plot handle.
        function eph = errorplot(obj, nameX, nameY, nameE, n, range)
            % Obtain Data:
            xs = obj.get(char(nameX));
            ys = obj.get(char(nameY));
            es = obj.get(char(nameE));
            
            ebars = NaN(size(es));
            ebars(1:n:length(es)) = es(1:n:length(es));
            
            % Determine Range:
            if nargin < 6
                range = true(size(xs));
            end
            
            % Plot Data:
            eph = errorbar(xs(range), ys(range), ebars(range), 'o-');
            
            obj.label(nameX, nameY);
        end
        
        % Creates a Plot with Error Bars for the Given X and Y Data Subject
        % to the Given Conditionals Range. Only plots points which are the 
        % average X and Y data for each value of varargin for the given 
        % variable, var.
        % Ex.
        % errorAvgAtplot('X','Y','dqc', ETable.is(V,9), 'u', 1,2,3);
        % Plots a one point with errorbars for each value of u (1,2,3) on a 
        % graph of Y vs X where V is 9.
        function eph = errorAvgAtplot(obj, nameX, nameY, nameE, range, var, varargin)
            % Obtain Data:
            xs = obj.get(char(nameX));
            ys = obj.get(char(nameY));
            es = obj.get(char(nameE));
            
            xs = xs(range);
            ys = ys(range);
            es = es(range);
            
            % Compute Points:
            vals = [varargin{:}];
            xps = zeros(size(vals));
            yps = zeros(size(vals));
            eps = zeros(size(vals));
            for i=1:length(vals)
                rawVals = obj.get(char(var));
                cond = ETable.is(rawVals(range), vals(i));
                xps(i) = mean(xs(cond));
                yps(i) = mean(ys(cond));
                eps(i) = mean(es(cond));
            end

            % Plot Data:
            eph = errorbar(xps, yps, eps, 'o-');
            
            obj.label(nameX, nameY);
        end
        
        % Helper Function which labels a plot, given the short names of the
        % x and y axes
        function label(obj, nameX, nameY)
            fullNameX = obj.cosmeticFullName(nameX); % Fetch full names
            fullNameY = obj.cosmeticFullName(nameY);
            fullNameX(regexp(fullNameX,'[\n\r]')) = []; % Remove linebreaks
            fullNameY(regexp(fullNameY,'[\n\r]')) = [];
            xlabel(fullNameX, 'Interpreter', 'latex');
            ylabel(fullNameY, 'Interpreter', 'latex');
        end
        
        % Convenience function that marks the last data point meeting the
        % where the variables in the varargin list are within 5% of their
        % associated values in the current plot of nameY vs nameX. Each 
        % datapoint is labeled with the conditionals then the coordinates 
        % of the point. The arrow to each datapoint has length l, angle a 
        % in radians, and horizontal alignment given by horizAlign
        % Lengths are referenced in terms of x-axis units.
        % Ex:
        % ETable.mark('t','T', 35,pi/2, 'V',9, 'Ua',1)
        % This will mark the last datapoint where V is 9, and Ua is 1 with
        % something like: {'9V, 1m/s', '10min, 300K'} with an arrow that is
        % 35minutes long (if units of 't' are minutes) at an angle of pi/2.
        function m = mark(obj, nameX,nameY, l,a, horizAlign, varargin)
            if ~mod(length(varargin),2) % ensure length of varargin is even
                cond = true(size(obj.data{:,1})); % select all datapoints
                label =  {'', ''};
                
                if length(varargin) > 1
                    vars = string(varargin(1:2:end));
                    args = [varargin{2:2:end}];
                    for i = 1:length(vars)
                        cond = cond & ETable.is(obj.get(char(vars(i))), args(i));
                        if i>1
                            label{1} = strcat(label{1}, {', '});
                        end
                        label{1} = strcat(label{1}, string(args(i)), obj.units(vars(i)));
                    end
                end
                
                xs = obj.get(char(nameX)); xs = xs(cond); 
                ys = obj.get(char(nameY)); ys = ys(cond);
                
                % Prune Outliers
                out = isoutlier(xs);
                xs(out) = []; ys(out) = [];
                
                if ~isempty(xs)
                    x = xs(end); y = ys(end);
                    label{2} = strcat(string(floor(x)), obj.units(nameX), {', '}, string(floor(y)), obj.units(nameY));
                    m = ETable.arrow(x,y, l,a, label, 'HorizontalAlignment', horizAlign);
                end
            else
                error('#ETable::mark requires an even number of pairs of variables and values');
            end
        end
        
        % Convenience function that puts an annotation (arrow pointing to) 
        % the final point that meets a given conditionals list in the  
        % current plot of nameY vs nameX.
        % l is the length of the arrow, a is angle, and t is the text, 
        % along with a vararginlist of parameters.
        % Lengths are referenced in terms of x-axis units.
        function a = annotate(obj, nameX,nameY, cond, l,a, t, varargin)
            xs = obj.get(char(nameX)); xs = xs(cond); 
            ys = obj.get(char(nameY)); ys = ys(cond);
            if ~isempty(xs)
                x = xs(end); y = ys(end);
                a = ETable.arrow(x,y, l,a, t,varargin);
            end
        end
    end
    
    methods(Static)
        % Convenience function that adds the given text as a caption to the
        % figure.
        function c = caption(t)
            dim = [0.1, 0.07, 0, 0];
            c = annotation('textbox', dim, 'String', t, 'FitBoxToText', 'on', 'LineStyle', 'none', 'Interpreter', 'latex');
        end
        
        % Draws a grey verical dashed line at the given X-axis value on the
        % current plot, with a label of the given text at the bottom.
        % side: 'left','right','center'
        function vline(x, txt, side)
            if nargin < 3
                side = 'left';
            end
            hold on
                grey = [0.5 0.4 0.4];
                plot([x x], ylim, ':', 'Color', grey);
                size = ylim;
                text(x, 0.05*diff(size) + size(1), txt, 'Color', grey, 'HorizontalAlignment', side, 'Interpreter', 'latex');
            hold off
        end
        
        % Convenience function that draws an arrow to point x,y with length
        % l, angle a, and optional text, t along with a list of parameters.
        % Lengths are referenced in terms of x-axis units.
        function a = arrow(x,y, l,a, t, varargin)
            p = [x,y];

            axs = gca; % Get current axes
            sx = diff(axs.XLim); % Get size of each axis
            sy = diff(axs.YLim);
            o = p - l * [cos(a), sin(a)*sy/sx];

            d = p-o;
            a = quiver(o(1),o(2), d(1),d(2), 0, 'MaxHeadSize', 0.05*sx/norm(l * [cos(a), sin(a)*sy/sx]), 'HandleVisibility','off'); % don't show in legend
            if nargin > 4
                args = [varargin, {'Interpreter','latex'}];
                text(o(1),o(2),t, args{:});
            end
        end
        
        % Convenience function that returns whether the given value is 
        % within the given fractional range of the given target:
        function w = within(val, range, target)
            w = val < (target + range.*target) & val > (target - range.*target);
        end
        % Convenience function that returns whether the given value is
        % within 5% of the given value:
        function i = is(val, target)
            if target ~= 0
                i = ETable.within(val, 0.12, target);
            else
                i = ETable.inrange(val, -0.1, 0.1);
            end
        end
        % Convenience Function that returns whether the given value is 
        % within the given range:
        function w = inrange(val, lb,ub)
            w = val <= ub & val >= lb;
        end
    end
end