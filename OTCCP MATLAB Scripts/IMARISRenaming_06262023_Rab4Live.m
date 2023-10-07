clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

location = append(cd,'\');
dir(location)

ds1 = spreadsheetDatastore(location);
files = ds1.Files;
modifiedfiles = erase(files, location);

temp = contains(modifiedfiles, '.xls');
modifiedfiles = modifiedfiles(temp);

lastCL = '';
defaultcount = 1;
ignorefilename = 0;
for i = 1:length(modifiedfiles)
    oldname = modifiedfiles{i};

    %For Pampa's Live 5CL Data
    type = '';
    oldname_split = split(oldname);

    oldname_split2 = split(oldname_split{5}, '_');
    if contains(oldname_split2{1}, 'ko')
        type = 'KO';
    elseif contains(oldname_split2{1}, 'wt')
        type = 'WT';
    end
    CL = strcat(upper(oldname_split2{3}), type); 
    CL = erase(CL, '-'); %CL = <extracted cellline>
    
    if ~contains(lastCL, CL)
        lastCL = CL;
        defaultcount = 1;
        ignorefilename = 0;
    end
   
    if ignorefilename
        ignorefilename = 1;
        CellNum = defaultcount;
        defaultcount = defaultcount + 1;
    end

    %For Rab4 Data
    %oldname_split = split(oldname);
    %CL = oldname_split{4}; %CL = <extracted cellline>
    %CellNum = sscanf(oldname_split{2},'CELL%d'); %CellNum = <extract cell number>

    %For Mets Data
    %oldname_split = split(oldname, '_');
    %CL = oldname_split{1}; %CL = <extracted cellline>
    %CellNum = sscanf(oldname_split{2},'Cell %d'); %CellNum = <extract cell number>

    %FINAL FORMAT: CELLLINE cell# ...
    newname = append(CL, ' cell', num2str(CellNum), ' IMARISDataset.xls');
    movefile(strcat(location,oldname), strcat(location,newname));
end

%Put these new parameters in the dataset
save("RenameWrkspace.mat")