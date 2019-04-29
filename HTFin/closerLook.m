function closerLook()
tab2 = A4_TF_data();
figure()

    for i=1:5
        if tab2.run==1
        tab2.plot('tAbs',char("TA_" + i));
        hold on;
        end
    end
    hold off;
end