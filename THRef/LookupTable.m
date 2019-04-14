classdef LookupTable
    properties(GetAccess=public, SetAccess=immutable)
        file_address,
        image
    end
    properties(GetAccess=public, SetAccess=private)
        pts = struct(...
            'x',[],...
            'y',[]...
        );
    end
    methods
        function obj = LookupTable(addr,scale)
            obj.file_address = addr;
            obj.image = imread(addr);
            for 
        end
    end
end