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

for i = 1:length(modifiedfiles)
    oldname = modifiedfiles{i};
    %For Jonathan's Live 5CL Data
    %oldname_split = split(oldname);
    %CL = strcat(oldname_split{1}, upper(oldname_split{3})); %CL = <extracted cellline>
    %CellNum = sscanf(oldname_split{2},'cell%d'); %CellNum = <extract cell number>
    
    %For Rab4 Data
    oldname_split = split(oldname);
    CL = oldname_split{4}; %CL = <extracted cellline>
    CellNum = sscanf(oldname_split{2},'CELL%d'); %CellNum = <extract cell number>

    %For Mets Data
    %oldname_split = split(oldname, '_');
    %CL = oldname_split{1}; %CL = <extracted cellline>
    %CellNum = sscanf(oldname_split{2},'Cell %d'); %CellNum = <extract cell number>

    %FINAL FORMAT: CELLLINE cell# ...
    newname = append(CL, ' cell', num2str(CellNum), ' IMARISDataset.xls');
    movefile(strcat(location,oldname), strcat(location,newname));
end