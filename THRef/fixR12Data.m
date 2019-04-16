function fixR12Data()
    % Load file as string:
    file = 'R12 - Saturated Freon 12 Temp Table';
    fID = fopen(file, 'r');
    str = fscanf(fID, '%c');

    % Find the beginning and end of each row (where two +ve temps are
    % smashed together) and separate them:
    for T = -110:110
        smash = char(" "+num2str(T)+num2str(T+1)+" ");
        unsmash = char(" "+num2str(T)+" "+num2str(T+1)+" ");
        str = strrep(str, smash,unsmash);
    end
    disp(str);
    fclose(fID);