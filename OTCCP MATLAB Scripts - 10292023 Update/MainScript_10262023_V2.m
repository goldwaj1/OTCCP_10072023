clear
clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 
global canceled


cancelcheck
script_dir = cd;
celllines_color = ''; 
progressbar('MainScript', '', '', '', '')

%UI Runs
%dialog box code running
[celllines, dir, root, mode] = DatasetDirSelection(script_dir);
if isequal(mode, 'DEBUG')
    %INSERT DEBUG CODE TO BE RAN HERE
else
    CompleteRFScript(celllines_color, celllines, dir, root, script_dir, mode, 0.15, [])
end

function [celllines, direc, root, mode] = DatasetDirSelection(script_dir)
        %Import App Information
        AppData = load('UIInputValues.mat');
        delete UIInputValues.mat

        imp_dir = AppData.imp_dir;
        exp_dir = AppData.exp_dir;
        root = AppData.root_name;
        mode = AppData.mode;
        
        if ~isequal(mode, 'DEBUG')
            mkdir(strcat(exp_dir, '\IMARIS Data'))
            mkdir(strcat(exp_dir, '\MATLAB Data'))
            mkdir(strcat(exp_dir, '\Figures'))
        
            cd(imp_dir)
            directory_instance = dir('*.xls');
            file_names = {directory_instance.name};

            %remove all elements after and including "cell" and common variants
            temp = eraseBetween(file_names, 'cell', strlength(file_names), 'Boundaries', 'inclusive');
            temp = eraseBetween(temp, 'Cell', strlength(temp), 'Boundaries', 'inclusive');
            temp = eraseBetween(temp, 'CEll', strlength(temp), 'Boundaries', 'inclusive');
            temp = eraseBetween(temp, 'CELL', strlength(temp), 'Boundaries', 'inclusive');

            %remove all special charatcers and white space left over
            CL_list = regexprep(temp,'[^a-zA-Z0-9]','');

            celllines = string(unique(CL_list));

            cd(imp_dir)
            [status, message] = copyfile('*.xls', strcat(exp_dir, '\IMARIS Data'));


            cd(script_dir)

            
            save("ImpWrkspace.mat")
            
        end

        direc = append(exp_dir,'\');



end
function CompleteRFScript(celllines_color, celllines, dir, root, script_dir, specialcase, progress, tp, type)
    import = 1; rf = 1; export = 1; pool = 0;
    if contains(specialcase, 'noimport')
        import = 0;
    elseif contains(specialcase, 'exportonly')
        import = 0; rf = 0;
    elseif contains(specialcase, 'importonly')
        rf = 0; export = 0;
    end

    if contains(specialcase, 'Live')
        type = 'Live';
        if contains(specialcase, 'pool')
            pool = 1;
        end
        if contains(specialcase, 'nonpool')
            pool = 0;
        end
    elseif contains(specialcase, 'Track')
        type = 'Track';
    else
        type = 'Fixed';
    end

    progressbar('MainScript', root, 'Importing', '', '')
   
    if (import == 1)
        IMARISDataImport_10262023_V2(celllines_color, celllines, dir, root, type, tp, pool, progress); cd(script_dir); 
    end

    progressbar('MainScript', root, 'Classification', '', '')
    
    if (rf == 1)
        RandomForest_07262023_V2(celllines_color, celllines, dir, root, progress); cd(script_dir);
    end

    progressbar('MainScript', root, 'Exporting', '', '')
    if (export == 1)
        MATLABDataExport_07262023_V2(dir, root, type, progress); cd(script_dir);
    end
    
end
