function MATLABDataExport_05072023_V2(dir, root, type, progress)

clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames')

progressbar('MainScript', root, 'Exporting', '', '')
progressbar(progress, 0.67, 0, 0, 0) 

workspace_dir = [dir 'MATLAB Data'];
workspace_filename = [root '_Workspace.mat'];

oldcd = cd(workspace_dir);
M = load(workspace_filename);

%~~PART 6A: EXPORTING MAIN DATA TO EXCEL~~
%Main Data Exportation
progressbar('MainScript', root, 'Exporting', 'Main Data Exportation', '')
progressbar(progress, 0.67, .1, 0, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X, M.X_labels, M.T_labels, M.param_labels, M.objectID, M.celllines, ...
    M.forestCVErri, M.forestCVErr_dist, M.imp, M.forestCVScore, 0, [root ' Full']);
progressbar([], [], [], .2, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_opg, M.X_labels, M.T_labels, M.param_labels_opg, M.objectID, M.celllines, ...
    M.forestCVErri_opg, M.forestCVErr_dist_opg, M.imp_opg, M.forestCVScore_opg, 0, [root ' OPG']);
progressbar([], [], [], .35, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_npg, M.X_labels, M.T_labels, M.param_labels_npg, M.objectID, M.celllines, ...
    M.forestCVErri_npg, M.forestCVErr_dist_npg, M.imp_npg, M.forestCVScore_npg, 0, [root ' NPG']);
progressbar([], [], [], .5, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_dpg, M.X_labels, M.T_labels, M.param_labels_dpg, M.objectID, M.celllines, ...
    M.forestCVErri_dpg, M.forestCVErr_dist_dpg,  M.imp_dpg, M.forestCVScore_dpg, 0, [root ' DPG']);
progressbar([], [], [], .65, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_opgnpg, M.X_labels, M.T_labels, M.param_labels_opgnpg, M.objectID, M.celllines, ...
    M.forestCVErri_opgnpg,  M.forestCVErr_dist_opgnpg, M.imp_opgnpg, M.forestCVScore_opgnpg, 0, [root ' OPGNPG']);
progressbar([], [], [], .8, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_opgdpg, M.X_labels, M.T_labels, M.param_labels_opgdpg, M.objectID, M.celllines, ...
    M.forestCVErri_opgdpg, M.forestCVErr_dist_opgdpg, M.imp_opgdpg, M.forestCVScore_opgdpg, 0, [root ' OPGDPG']);
progressbar([], [], [], .95, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_completedataexport(M.X_npgdpg, M.X_labels, M.T_labels, M.param_labels_npgdpg, M.objectID, M.celllines, ...
    M.forestCVErri_npgdpg, M.forestCVErr_dist_npgdpg, M.imp_npgdpg, M.forestCVScore_npgdpg, 0, [root ' NPGDPG']);

progressbar('MainScript', root, 'Exporting', 'DPG Data Exportation', '')
progressbar(progress, 0.67, .5, 0, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_dpgexport(M.X, M.X_labels, M.T_labels, M.dpg_data, M.celllines, M.cell_list, [root ' Full/DPGCalcData']);
cd(workspace_dir)

progressbar('MainScript', root, 'Exporting', 'Alt Data Exportation', '')
progressbar(progress, 0.67, .8, 0, 0); cd(oldcd); cancelcheck; cd(workspace_dir); 
cellline_altdataexport(M.X, M.X_labels, M.T_labels, M.objectID, M.param_labels, M.dpg_data, M.celllines, M.cell_list, [root ' Full/Alt']);

progressbar(1)

%cellline_dataexport: exporting desired data to an outside Excel form for further analysis.
function cellline_completedataexport(X, X_labels, T_labels, param_labels, objectID, celllines, ...
    forestCVErri, forestCVErri_alt, imp, forestCVScore, cellline_auc , filename)
    
    
    progressbar([], [], [], [], 0);
    mkdir(filename)
    cd(filename)

    progressbar([], [], [], [], .2);
    if contains(type, "Live")
        T1 = cell2table([cellstr(X_labels) num2cell(T_labels) num2cell(objectID) num2cell(X)]);
        T1.Properties.VariableNames = cellstr(['Cellline' 'Timepoint' 'Object ID #' param_labels]);
    else
        T1 = cell2table([cellstr(X_labels) num2cell(objectID) num2cell(X)]);
        T1.Properties.VariableNames = cellstr(['Cellline' 'Object ID #' param_labels]);
    end
    writetable(T1, 'Dataset.csv')
    
    progressbar([], [], [], [], .4); 
    T2 = cell2table([num2cell([1:10].') num2cell((1-forestCVErri)*100)]);
    T2.Properties.VariableNames = cellstr(['kFold' "Accuracy"]);
    writetable(T2, 'kFoldAccuracy.csv')

    progressbar([], [], [], [], .45); 
    T2 = cell2table([num2cell([1:20].') num2cell((1-forestCVErri_alt)*100)]);
    T2.Properties.VariableNames = cellstr(['kFold' "Accuracy"]);
    writetable(T2, 'AltkFoldAccuracy.csv')
    
    progressbar([], [], [], [], .5); 
    T3 = cell2table([cellstr(param_labels.') num2cell(imp.') num2cell(normalize(imp, 'range').')]);
    T3.Properties.VariableNames = cellstr(['Parameter' "Relative Predictor Importance" "Normalized Predictor Importance"]);
    writetable(T3, 'PredictorImp.csv')
    
    %{
    progressbar([], [], [], [], .7); 
    if contains(type, "Live")
        T5 = cell2table([cellstr(X_labels) num2cell(T_labels) num2cell(objectID) num2cell(forestCVScore)]);
        T5.Properties.VariableNames = cellstr(['True Label' 'Timepoint' 'Object ID #' celllines]);
    else
         T5 = cell2table([cellstr(X_labels) num2cell(objectID) num2cell(forestCVScore)]);
    T5.Properties.VariableNames = cellstr(['True Label' 'Object ID #' celllines]);
    end
    writetable(T5, 'ROCData.csv')

    progressbar([], [], [], [], .9); 
    T6 = cell2table(num2cell(cellline_auc));
    T6.Properties.VariableNames = cellstr(celllines);
    writetable(T6, 'ROCData_AUC.csv')
    %}
    cd ../
end

function cellline_altdataexport(X, X_labels, T_labels, objectID, param_labels, dpg_data, celllines, cell_list, filename)
    param_labels_sheetname = strrep(param_labels, '/', ' Divided By ');
    param_labels_sheetname = strrep(param_labels_sheetname, '*', ' x ');
    
    progressbar([], [], [], [], 0);
    
    mkdir(filename)
    cd(filename)

    if size(celllines, 1) > 1
        celllines = celllines.';
    end
    
    %Slide 2 - 34 Parameters Organized by Cell Lines
    for i = 1:length(celllines)
        progressbar([], [], [], [], 1/8*(i/length(celllines)))
        cl_range = contains(X_labels, celllines(i));
        
        if contains(type, "Live")
            A1 = cell2table([cellstr(X_labels(cl_range)) num2cell(T_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(X(cl_range,:))]);
            A1.Properties.VariableNames = cellstr(['Cellline' 'Time Points' 'Object ID #' param_labels]);
        else
            A1 = cell2table([cellstr(X_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(X(cl_range,:))]);
            A1.Properties.VariableNames = cellstr(['Cellline' 'Object ID #' param_labels]);
        end

        writetable(A1, strcat(celllines(i), '_Data.csv'))
    end

    %Slide 3 - Mean and Sum Per Cell and Parameter
    progressbar([], [], [], [], 1/8);
    mkdir("Param Data")
    cd("Param Data")
    [X_labels_mean, X_mean] = cellline_meancelldata(X, X_labels, dpg_data, cell_list, celllines);
    [X_labels_sum, X_sum] = cellline_sumcelldata(X, X_labels, dpg_data, cell_list, celllines);
    
    cell_list_num = cell_list;
    for j = 1:length(celllines)
        cell_list_num = erase(cell_list_num, append(celllines(j), ' cell'));
    end
    cell_list_num = str2double(cell_list_num);
    maxcellnum = max(cell_list_num);
    
    for i = 1:length(param_labels)
        progressbar([], [], [], [], 1/8 + 3/8*(i/length(param_labels))); 
        reorg_meandata = [];
        reorg_sumdata = [];
        w = 0;
        start = 1;
        for j = 1:length(celllines)
            %extract cell numbers for that cellline
            cl_cell_list = cell_list(contains(cell_list, celllines(j)));
            cl_cell_num = erase(cl_cell_list, append(celllines(j), ' cell'));
            cl_cell_num = str2double(cl_cell_num);
            
            temp_meandata = [];
            temp_sumdata = [];
            
            for k = 1:maxcellnum
                if any(cl_cell_num == k)
                    idx = start + find(cl_cell_num == k) - 1;
                    temp_meandata = [temp_meandata; X_mean(idx, i)];
                    temp_sumdata = [temp_sumdata; X_sum(idx, i)];
                    w = w + 1;
                else
                    temp_meandata = [temp_meandata; NaN];
                    temp_sumdata = [temp_sumdata; NaN];
                end
            end
            
            start = start + length(cl_cell_num);
            reorg_meandata = [reorg_meandata temp_meandata];
            reorg_sumdata = [reorg_sumdata temp_sumdata];
        end
        
        A2 = cell2table([cellstr(sortedcelllist(maxcellnum)) num2cell(reorg_meandata)]);
        A2.Properties.VariableNames = cellstr([' ' sort(celllines)]);
        writetable(A2, strcat(param_labels_sheetname(i), '_MeanData.csv'))

        A3 = cell2table([cellstr(sortedcelllist(maxcellnum)) num2cell(reorg_sumdata)]);
        A3.Properties.VariableNames = cellstr([' ' sort(celllines)]);
        writetable(A3, strcat(param_labels_sheetname(i), '_SumData.csv'))
    end
    cd ../

    %Slide 4 - Normalized Mean Data
    meansheet_data = [];

    w = 0;
    start = 1;

    for i = 1:length(celllines)
        progressbar([], [], [], [], 1/2 + 2/8*(i/length(celllines))); 
        norm_data = normalize(X_mean,'range');
        cl_cell_list = cell_list(contains(cell_list, celllines(i)));
        cl_cell_num = erase(cl_cell_list, append(celllines(i), ' cell'));
        cl_cell_num = str2double(cl_cell_num);
        
        temp_normdata = [];
        
        for k = 1:maxcellnum
                if any(cl_cell_num == k)
                    idx = start + find(cl_cell_num == k) - 1;
                    temp_normdata = [temp_normdata; norm_data(idx,:)];
                    w = w + 1;
                else
                    temp_normdata = [temp_normdata; NaN(1, size(norm_data, 2))];
                end
        end
    
        A5 = cell2table([cellstr(param_labels.') num2cell(temp_normdata).' num2cell(mean(temp_normdata, 1)).']);
        A5.Properties.VariableNames = cellstr([' ' sortedcelllist(maxcellnum).' 'Average']);
        writetable(A5,  strcat(celllines(i), '_NormData.csv'))
        
        start = start + length(cl_cell_num);
        meansheet_data = [meansheet_data mean(temp_normdata,1).'];
    end
    A5 = cell2table([cellstr(param_labels.') num2cell(meansheet_data)]);
    A5.Properties.VariableNames = cellstr(["Parameters" sort(celllines)]);
    writetable(A5,  strcat('NormMeanData.csv'))
    
    %Slide 5 - LN of Data
    for i = 1:length(celllines)
        progressbar([], [], [], [], 6/8 + 1/8*(i/length(celllines))); 
        cl_range = contains(X_labels, celllines(i));
        
        if contains(type, "Live")
            A6 = cell2table([cellstr(X_labels(cl_range)) num2cell(T_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(log(X(cl_range,:)))]);
            A6.Properties.VariableNames = cellstr([" " 'Timepoint' 'Object ID #' param_labels]);
        else
            A6 = cell2table([cellstr(X_labels(cl_range)) num2cell(objectID(cl_range)) num2cell(log(X(cl_range,:)))]);
            A6.Properties.VariableNames = cellstr([" " 'Object ID #' param_labels]);
        end

        writetable(A6,  strcat(celllines(i), '_LNData.csv'))
    end

    %Slide 6 - Number of Objects Per Cell
    numobj_data = [];
    w = 0;
    start = 1;
    for i = 1:length(celllines)
        progressbar([], [], [], [], 7/8 + 1/8*(i/length(dpg_data))); 
        
        cl_cell_list = cell_list(contains(cell_list, celllines(i)));
        cl_cell_num = erase(cl_cell_list, append(celllines(i), ' cell'));
        cl_cell_num = str2double(cl_cell_num);
        temp_numdata = [];
        
        for k = 1:maxcellnum
                if any(cl_cell_num == k)
                    idx = start + find(cl_cell_num == k) - 1;
                    temp_numdata = [temp_numdata; length(cell2mat(dpg_data(idx)))];
                    w = w + 1;
                else
                    temp_numdata = [temp_numdata; NaN];
                end
        end

        start = start + length(cl_cell_num);
        numobj_data = [numobj_data temp_numdata];
    end
    A7 = cell2table([cellstr(sortedcelllist(maxcellnum)) num2cell(numobj_data)]);
    A7.Properties.VariableNames = cellstr([' ' sort(celllines)]);
    writetable(A7,  'NumofObjects.csv')
    cd ../

end
function cellline_dpgexport(X, X_labels, T_labels, dpg_data, celllines, cell_list, filename)
    cell_list_num = cell_list;

    if size(celllines, 1) > 1
        celllines = celllines.';
    end

    for j = 1:length(celllines)
        cell_list_num = erase(cell_list_num, append(celllines(j), ' cell'));
    end
    cell_list_num = str2double(cell_list_num);
    maxcellnum = max(cell_list_num);

    progressbar([], [], [], [], 0);
    mkdir(filename)
    cd(filename)
    
    %Slide 7: DPG Per Cell
    dpg_data1 = cell(1,length(dpg_data));
    for i = 1:length(dpg_data)
        progressbar([], [], [], [], 1/3 * (i/length(dpg_data)))

        current_dpg_data = cell2mat(dpg_data(i));
        dpg_reshaped = nonzeros(reshape(current_dpg_data, [], 1));
        dpg_data1(1,i) = {dpg_reshaped};
    end   
    %{
    [X_labels_mean, ~] = cellline_meancelldata(X, X_labels, dpg_data);
    start = 1;
    dpgcell = {};
    for j = 1:length(celllines)
        current_celline_data = dpg_data1(start:(start+cellnum-1));
        dpgdata_cell = {};
        label_cell = {};
        for i = 1:length(current_celline_data)
            current_col = cell2mat(current_celline_data(i));
            k = 1;
            while length(current_col) > (k)
                dpgdata_cell = [dpgdata_cell cell(1000000,1)];
                if k == 1
                    label_cell = [label_cell cellstr(X_labels_mean(i))];
                else
                    label_cell = [label_cell cellstr(' ')];
                end
                dpgdata_cell(1:min([length(current_col), k + 999999]), end) = num2cell(current_col);
                k = k + 1000000;
            end
        end  
        start = start + cellnum;
        D1 = cell2table(dpgdata_cell);
        D1.Properties.VariableNames = cellstr(label_cell);
        writetable(D1, strcat(celllines(j), 'Data Per Cell.csv'))
    end
    %}
    
    dpg_data2 = cell(1, length(celllines));
    for j = 1:length(celllines)
        progressbar([], [], [], [], 1/3 + 1/3 * (j/length(celllines)));
        cl_cell = contains(cell_list, celllines(j));

        temp_datacolumn = [];
        current_cellline_data = cell2mat(dpg_data1(cl_cell).');
        temp_datacolumn = [temp_datacolumn; current_cellline_data];

        dpg_data2(1, j) = {temp_datacolumn};
    end
    
    %Exports Binned DPG Data
    progressbar([], [], [], [], .6)
    bins = 0:2:60;
    bindata_cell = num2cell(bins(2:end).');
    percentbindata_cell = num2cell(bins(2:end).');
    for i = 1:length(dpg_data2)
        progressbar([], [], [], [], 2/3 + 1/3 * (i/length(dpg_data2)));

        current_col = cell2mat(dpg_data2(i));
        bin_col = histcounts(current_col, bins);
        bindata_cell = [bindata_cell num2cell(bin_col.')];
        percentbindata_cell = [percentbindata_cell num2cell(((bin_col/sum(bin_col)) * 100).')];
    end
    bindata_cell = [bindata_cell cell(length(bindata_cell),1) percentbindata_cell];
    D2 = cell2table(bindata_cell);
    D2.Properties.VariableNames = cellstr(['Bins' celllines " " 'Bins ' strcat(celllines, ' (%)')]);
    writetable(D2, 'BinnedDPGData.csv')
    
    cd ../
end

function [X_labels_meancell, X_meancell] = cellline_meancelldata(X, X_labels, dpg_data, cell_list, celllines)
    X_meancell = [];
    counter = 1;
    for i = 1:length(dpg_data)
         celllength = length(cell2mat(dpg_data(i)));
         mean_range = counter : counter + celllength - 1;
         X_meancell = [X_meancell; mean(X(mean_range,:))];
         counter = counter + celllength;
    end
    X_labels_meancell = cell_list;
end

function [X_labels_sumcell, X_sumcell] = cellline_sumcelldata(X, X_labels, dpg_data, cell_list, celllines)
    X_sumcell = [];
    counter = 1;
    for i = 1:length(dpg_data)
         celllength = length(cell2mat(dpg_data(i)));
         sum_range = counter : counter + celllength - 1;
         X_sumcell = [X_sumcell; sum(X(sum_range,:))];
         counter = counter + celllength;
    end
    X_labels_sumcell = cell_list;    
end

function celllist = sortedcelllist(maxcellnum)
        celllist = [];
       
            temp = [];
            for i = 1:maxcellnum
                temp = [temp; strcat('Cell', string(i))];
            end
            celllist = temp;
end
end