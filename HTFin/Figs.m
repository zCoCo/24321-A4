function Figs()
tab = A4_TF_data();

for sym = ["B","C","S","A"]
        for i=1:5
            name = char("T" + sym + "_" + i);
            tab.plot(t,name);
        end
    end
