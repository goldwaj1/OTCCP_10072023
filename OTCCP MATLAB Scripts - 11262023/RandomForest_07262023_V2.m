function RandomForest_07262023_V2(celllines_color, celllines, dir, root, progress)
%Code for the Data Analysis and Classification of Cell Lines Based on
%Object Parameters. This is general code that will be extended to specific
%cases later on

%Last Edited: 06/07/2021

clc
close all
savepath
warning('off','MATLAB:table:ModifiedVarnames') 

%~~PART 0: INITIALIZATION AND ALLOCATION OF GLOBAL VARIABLES~~
save_dir = [dir 'MATLAB Data'];
save_filename = [root '_ImportedIMARISData.mat'];

%~~PART 1: LOADING DATASET AND VARIABLES~~
progressbar(progress, 0.33, 0, 0, 0); cancelcheck


oldcd = cd(save_dir);
imported = load(save_filename);
cd(oldcd); 

X = imported.X;
X_labels = imported.X_labels;
T_labels = imported.T_labels;
cellX_labels = imported.cellX_labels;
param_labels = imported.param_labels;
objectID = imported.objectID;
dpg_data = imported.dpg_data;
cell_list = imported.cell_list;
errorfile_list = imported.errorfile_list;

save_dir = [dir 'MATLAB Data'];
figure_dir = [dir 'Figures'];

figure_filename = [root '_Figure_'];
workspace_filename = [root '_Workspace.mat'];

%~~PART 2 - DEFINE PARAMETER SUBSETS~~
progressbar('MainScript', root, 'Classification','Defining Param', ''); cancelcheck
progressbar(progress, 0.33, .05, 0, 0) 

%OPG Subset
param_opg = ["Area", "BB AA X","BB AA Y","BB AA Z",'BB OO X','BB OO Y', 'BB OO Z',...
    'CI', 'Oblate','Prolate', 'BI AA', 'BI OO','Sphericity','Triangles','Volume', 'Voxels'];
param_idx_opg = find(contains(param_labels, param_opg));
X_opg = X(:,param_idx_opg);
param_labels_opg = param_labels(param_idx_opg);
progressbar(progress, 0.33, .05, .15, 0); cancelcheck

%NPG Subset
param_npg = ["Dist Origin", 'Position X', 'Position Y', 'Position Z', 'Dist Surface', 'Polarity'];
param_idx_npg = find(contains(param_labels, param_npg));
X_npg = X(:,param_idx_npg);
param_labels_npg = param_labels(param_idx_npg);
progressbar(progress, 0.33, .05, .3, 0); cancelcheck

%DPG Subset
param_dpg = ["Min Dist" 'Max Dist' 'Mean Dist' 'Median Dist' 'Std Dist' 'Sum Dist' 'Skewness Dist' ...
    'Kurtosis Dist' 'Sum/Vol Dist' 'Sum/Pos Z Dist' 'Sum*Vol Dist' 'Sum*Pos Z Dist'];
param_idx_dpg = find(contains(param_labels, param_dpg));
X_dpg = X(:,param_idx_dpg);
param_labels_dpg = param_labels(param_idx_dpg);
progressbar(progress, 0.33, .05, .45, 0); cancelcheck

%OPG + NPG Subset
param_opgnpg = [param_opg param_npg];
param_idx_opgnpg = find(contains(param_labels, param_opgnpg));
X_opgnpg = X(:,param_idx_opgnpg);
param_labels_opgnpg = param_labels(param_idx_opgnpg);
progressbar(progress, 0.33, .05, .6, 0); cancelcheck

%OPG + DPG Subset
param_opgdpg = [param_opg param_dpg];
param_idx_opgdpg = find(contains(param_labels,param_opgdpg));
X_opgdpg = X(:,param_idx_opgdpg);
param_labels_opgdpg = param_labels(param_idx_opgdpg);
progressbar(progress, 0.33, .05, .75, 0); cancelcheck

%NPG + DPG Subset
param_npgdpg = [param_npg param_dpg];
param_idx_npgdpg = find(contains(param_labels,param_npgdpg));
X_npgdpg = X(:,param_idx_npgdpg);
param_labels_npgdpg = param_labels(param_idx_npgdpg);


%~~PART 3: RANDOM FOREST CLASSIFICATION AND CONFUSION MATRIX PLOT~~
progressbar('MainScript', root, 'Classification', 'RF Training & Accuracy Assessment', ''); cancelcheck
progressbar(progress, 0.33, .3, 0, 0); cancelcheck
    [forest, forestCVClass, forestCVScore, forestCVErri, forestCVErr_dist] = cellline_randomforest(X, X_labels, param_labels, 'RF ~ All Param', 0); 
progressbar([], [], .3, .2, 0); cancelcheck
    [forest_opg, forestCVClass_opg, forestCVScore_opg, forestCVErri_opg, forestCVErr_dist_opg] = cellline_randomforest(X_opg, X_labels, param_labels_opg, 'RF ~ OPG', 0);
progressbar([], [], .3, .35, 0); cancelcheck
    [forest_npg, forestCVClass_npg, forestCVScore_npg, forestCVErri_npg, forestCVErr_dist_npg]  = cellline_randomforest(X_npg, X_labels, param_labels_npg, 'RF ~ NPG', 0);
progressbar([], [], .3, .50, 0); cancelcheck
    [forest_dpg, forestCVClass_dpg, forestCVScore_dpg, forestCVErri_dpg, forestCVErr_dist_dpg] = cellline_randomforest(X_dpg, X_labels, param_labels_dpg, 'RF ~ DPG', 0);
progressbar([], [], .3, .65, 0); cancelcheck
    [forest_opgnpg, forestCVClass_opgnpg, forestCVScore_opgnpg, forestCVErri_opgnpg, forestCVErr_dist_opgnpg] = cellline_randomforest(X_opgnpg, X_labels, param_labels_opgnpg, 'RF ~ OPG + NPG', 0);
progressbar([], [], .3, .80, 0); cancelcheck
    [forest_opgdpg, forestCVClass_opgdpg, forestCVScore_opgdpg, forestCVErri_opgdpg, forestCVErr_dist_opgdpg] = cellline_randomforest(X_opgdpg, X_labels, param_labels_opgdpg, 'RF ~ OPG + DPG', 0);
progressbar([], [], .3, .95, 0); cancelcheck
    [forest_npgdpg, forestCVClass_npgdpg, forestCVScore_npgdpg, forestCVErri_npgdpg, forestCVErr_dist_npgdpg] = cellline_randomforest(X_npgdpg, X_labels, param_labels_npgdpg, 'RF ~ NPG + DPG', 0);

%~~PART 4: RANDOM FOREST ROC CURVE~~
progressbar('MainScript', root, 'Classification', 'ROC Assessment', '')
%{
Note: rocmetrics does not work with 
progressbar(progress, 0.33, .6, 0, 0); cancelcheck
    cellline_auc = cellline_roc(X_labels, forestCVClass, forestCVScore, 'ROC ~ All Param');  
progressbar([], [], .6, .2, 0); cancelcheck
    cellline_auc_opg = cellline_roc(X_labels, forestCVClass_opg, forestCVScore_opg, 'ROC ~ OPG');
progressbar([], [], .6, .2, 0); cancelcheck
    cellline_auc_npg = cellline_roc(X_labels, forestCVClass_npg, forestCVScore_npg, 'ROC ~ NPG');
progressbar([], [], .6, .35, 0); cancelcheck
    cellline_auc_dpg = cellline_roc(X_labels, forestCVClass_dpg, forestCVScore_dpg, 'ROC ~ DPG');
progressbar([], [], .6, .5 , 0); cancelcheck
    cellline_auc_opgnpg = cellline_roc(X_labels, forestCVClass_opgnpg, forestCVScore_opgnpg, 'ROC ~ OPG + NPG');
progressbar([], [], .6, .65, 0); cancelcheck
    cellline_auc_opgdpg = cellline_roc(X_labels, forestCVClass_opgdpg, forestCVScore_opgdpg, 'ROC ~ OPG + DPG');     
progressbar([], [], .6, .80, 0); cancelcheck
    cellline_auc_npgdpg = cellline_roc(X_labels, forestCVClass_npgdpg, forestCVScore_npgdpg, 'ROC ~ NPG + DPG');
%}

%~~PART 5: RELATIVE PREDICTOR IMPORTANCE CALCULATION~~
progressbar('MainScript', root, 'Classification', 'Predictor Importance', '')

progressbar(progress, 0.33, .8, 0, 0); cancelcheck
    imp = cellline_predictorimportance(forest, param_labels, 'Predictor Importance ~ All Param', 1);
progressbar([], [], .8, .1, 0); cancelcheck
    imp_opg = cellline_predictorimportance(forest_opg, param_labels_opg, 'Predictor Importance ~ OPG',1);
progressbar([], [], .8, .25, 0); cancelcheck
    imp_npg = cellline_predictorimportance(forest_npg, param_labels_npg, 'Predictor Importance ~ NPG',1);
progressbar([], [], .8, .4, 0); cancelcheck
    imp_dpg = cellline_predictorimportance(forest_dpg, param_labels_dpg, 'Predictor Importance ~ DPG',1);
progressbar([], [], .8, .55, 0); cancelcheck
    imp_opgnpg = cellline_predictorimportance(forest_opgnpg, param_labels_opgnpg, 'Predictor Importance ~ OPG + NPG', 1);
progressbar([], [], .8, .70, 0); cancelcheck 
    imp_opgdpg = cellline_predictorimportance(forest_opgdpg, param_labels_opgdpg, 'Predictor Importance ~ OPG + DPG', 1);
progressbar([], [], .8, .85, 0); cancelcheck
    imp_npgdpg = cellline_predictorimportance(forest_npgdpg, param_labels_npgdpg, 'Predictor Importance ~ NPG + DPG',1);


%~~PART 6A: SAVING FIGURES AS IMAGES~~
progressbar('MainScript', root, 'Classification', 'Saving Figures', '')
progressbar(progress, 0.33, .90, 0, 0); cancelcheck
oldcd = cd(figure_dir);
cellline_savefigures();
cd(oldcd); 

%~~PART 6B: EXPORT WORKSPACE~~
progressbar('MainScript', root, 'Classification', 'Exporting Workspace', '')
progressbar(progress, 0.33, .95, 0, 0); cancelcheck
oldcd = cd(save_dir);
save(workspace_filename);
cd(oldcd); 

%~~FUNCTION DEFINITIONS~~
function [forest, forestCVClass, forestCVScore, forestCVErr_i, forestCVErr_dist] = cellline_randomforest(X, X_labels, param_labels, fig_title, skipconfusion)
    progressbar([], [], [], [], 0); cancelcheck
    
    
    tic %tic and toc are statements that allow for time tracking
    rng('default');  %Setting the rng ensures reproducibility
    
    t = templateTree('Reproducible', true, 'Prune', 'off', 'PruneCriterion', 'error', 'SplitCriterion', 'gdi'); 
    forest = fitcensemble(X, X_labels, 'Method', 'Bag', 'Learners', t,...
        'PredictorNames', param_labels); %Random Forest Algorithm
    
    progressbar([], [], [], [], .2); cancelcheck
    forestCV = crossval(forest); %10-Fold Cross Validation

    progressbar([], [], [], [], .5); cancelcheck
    forestCVErr = kfoldLoss(forestCV); %Random Forest Algorithm Validation Error
    forestCVErr_i= kfoldLoss(forestCV, 'Mode', 'individual');
    [forestCVClass, forestCVScore] = kfoldPredict(forestCV); %Random Forest Algorithm Validation Prediction
    
    time = toc; %record the elapsed time
    progressbar([], [], [], [], .7); cancelcheck
        

    forestCVErr_dist = [];
    for i = 1:10 % x10
        forestCV_alt = crossval(forest, 'KFold', 2); %2-Fold Cross Validation
        forestCVErr_dist = [forestCVErr_dist; kfoldLoss(forestCV_alt, 'Mode', 'individual')];
    end

    if skipconfusion == 0 %the confusion matrix could be skipped if desired
        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
        
        cm = confusionchart(cellstr(X_labels), forestCVClass); %confusion matrix of validation data
        title([fig_title, newline, 'CV Accuracy: ', num2str(100-(forestCVErr*100)),... 
            '%', newline, append('Time: ', num2str(time), 'sec')])
        cm.FontName = 'Calibri';
        cm.FontSize = 15;
        cm.GridVisible = 'off';
        cm.DiagonalColor = "#266C26";
    end
end
function auc_data = cellline_roc(X_labels, forestCVClass, forestCVScore, fig_title)
    progressbar([], [], [], [], 0); cancelcheck
    

    rocObj = rocmetrics(X_labels, forestCVScore, sort(celllines));

    progressbar([], [], [], [], .5); cancelcheck
    figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
    rocplot = plot(rocObj, "AverageROCType","macro", "ShowModelOperatingPoint",false);
    title(fig_title, "FontName", "Calibri", "FontSize", 15)
    xlabel('False Positive Rate', "FontName", "Calibri", "FontSize", 15)
    ylabel('True Positive Rate', "FontName", "Calibri", "FontSize", 15)

    for i = 1:length(unique(X_labels))
        rocplot(i).LineWidth = 3;
        rocplot(i).Color =  '#c8e6c9';
    end

    rocplot(i+1).LineWidth = 4;
    rocplot(i+1).Color =  "#266C26";

    auc_data = rocObj.AUC;                                                                                                                                                                                                                                                                                                                           
end

function imp = cellline_predictorimportance(forest, param_labels, fig_title, skipfigure)
    progressbar([], [], [], [], 0); cancelcheck
    %This statement enables parallel computing which can speed up this
    %segment of the code
    options = statset('UseParallel',true); 
    
    %The predictor importance is determine through Out-of-Bag Permuted
    %Predicter Importance, a process that allows for relatively accurate
    %analysis of predictor importance. This algorithm also works well if
    %one of the variables were to theorectically not be continous in the future 
    imp = oobPermutedPredictorImportance(forest,'Options',options);
    
    %the bar graph can be skipped if desired
    if skipfigure == 0
        %The statements below plot the predictor importance results on a
        %bar graph
        progressbar([], [], [], [], .5); cancelcheck 

        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.8 0.6]); 
        barbar = bar(categorical(param_labels), imp);
        title(fig_title,"FontName", "Calibri", "FontSize", 15);
        ylabel('Estimates', "FontName", "Calibri", "FontSize", 15);
        xlabel('Predictors', "FontName", "Calibri", "FontSize", 15);
        barbar.FaceColor = "#266C26";
        barbar.EdgeAlpha = 0;
    end
end 

    function pvalues = cellline_ttest(combErr_dist, fig_title)
        figure('Name', fig_title, 'NumberTitle', ...
                'off', 'Units', 'Normalized', 'OuterPosition', [0.3 0.2 0.4 0.6]);
        box = boxplot((1 - combErr_dist), 'Notch', 'on', 'Labels', ...
            {'All', 'OPG', 'NPG', 'DPG', 'ONPG', 'ODPG', 'NDPG'}, ...
            'Colors', [.21 .59 .21]);
        yt = get(gca, 'YTick');
        axis([xlim    0  ceil(max(yt)*1.2)])
        xt = get(gca, 'XTick');
        hold on
        plot(xt([2 3]), [1 1]*max(yt)*1.1, '-k',  mean(xt([2 3])), max(yt)*1.15, '*k')
        hold off
        
  

    end
function cellline_savefigures()
    
    %this array contains all the figures currently present at this point in
    %the code. This will allows these to be saved
    allfigures = findobj( 'Type', 'Figure');
    
    %for all the figures
    for i = 1:length(allfigures)
        current_fig = allfigures(i);
        %the 'Name' of the figure correlates to the naming at the top of
        %the window
        fig_name = current_fig.Name;

        progressbar([], [], [], (i-1)/length(allfigures), 0); 
        
        %Note that we do not want to save progress bars. These have no
        %title, so these can be accounted for by the statement below
        if (strcmp(fig_name, '') || contains(fig_name, '%'))
            continue;
        end
        
        %We use the title of the figure to alter the filename of the figure
        %once saved
        adjusted_name = strrep(fig_name,'~', '-');
        adjusted_name = strrep(adjusted_name ,' ', '');
        
        %Save the figure as a .m file and 
        saveas(current_fig, [figure_filename adjusted_name], 'png') 
    end
end
end

