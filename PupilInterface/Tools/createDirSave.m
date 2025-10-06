function path = createDirSave(path)
    fold = dir(path);
    fold = fold(3:end,1);
    fold = fold(cell2mat({fold.isdir})==1);
    
    if isempty(fold)
        mkdir(path, '000');
        path = [path filesep '000'];
    else
        num = str2num(fold(end).name);
        str = num2str(num+1, '%03d');
        mkdir(path, str);
        path = [path filesep str];
    end
end