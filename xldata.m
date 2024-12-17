addpath('./tapas-master/HGF');
addpath("./matlab-json/bin/")
parentDir = input("Please enter the path for the parent directory(main directory where the data directories take place): ", "s");
prefix = input("Please enter the directory name which is common for every file you want to compare(e.g. JPAS_0152): ", "s");
dirInfo = dir(fullfile(parentDir, [prefix '*']));

numDirs = length(dirInfo);
expStruct = repmat(struct('name', [], 'choice', [], 'rew', [], 'sim', [], 'est', [], 'mean', []), 1, length(dirInfo));
ignoredDirs = ["  "];
k = 1;
for i = 1:length(dirInfo)
    if dirInfo(i).isdir
        %the full path to the current directory
        currentDir = fullfile(parentDir, dirInfo(i).name);
        % Check if metrics.json exists

        jsonFilePath = fullfile(currentDir, 'metrics.json');
        if exist(jsonFilePath, 'file')
            % Read and decode the JSON file
            str = fileread(jsonFilePath);  % Read the entire JSON file as a string
            jsonData = fromjson(str);
            if ~isfield(jsonData, "metrics") || ~isfield(jsonData, ("experiment data"))
                fprintf("Metrics format is different experiment data field cannot be found for %s, it will be ignored \n", currentdir);
                ignoredDirs(end+1) = currentDir;
                continue;
            end
            if length(jsonData.metrics.trials) > 385
                fprintf("*********The size is more than 385, so %s will be ignored.*********\n",currentDir)
                ignoredDirs(end+1) = currentDir;
                continue;
            end
            expStruct(k) = parseData(jsonData , currentDir);
            k = k + 1;
        else
            disp(['metrics.json not found in: ' currentDir]);
        end
    end
end 

for i = 1:length(expStruct)
    fprintf("-------Model is being applied %d / %d-------\n", i, length(expStruct))
    fprintf("-----------Model will be applied for %s-----------\n", expStruct(i).name)
    if isempty(expStruct(i).name)
        fprintf("There is an ignored directory, this index will not be processed since it is empty\n");
        continue;
    end
    expStruct(i).mean = calculation(expStruct(i));
    sharedFill(expStruct(i), i)
    close all;
end

if isempty(ignoredDirs)
    fprintf("There is no ignored directories\n");
else
    fprintf("Ignored directory list \n")
    for i = 2:length(ignoredDirs)
        fprintf("Ignored file %d : %s\n",i - 1, ignoredDirs(i))
    end
end
%------functions------
function result = parseDate(inputStr)
    spaceIdx = find(inputStr == ' ', 1);
    if ~isempty(spaceIdx)
        result = inputStr(1:spaceIdx-1);
    else
        result = inputStr;
    end
end

function expStruct = parseData(file, dir)
    if ~isfield(file, ("experiment data"))
        fprintf("Metrics format is different experiment data field cannot be found for %s \n", dir);
        return
    end
    date = parseDate(file.("experiment data").datetime); % date information is too long so the time part is removed 
    expStruct.name = [file.("experiment data").ID, '_', date];
    expStruct.rew = array_rew(file, expStruct.name);
    expStruct.choice= array_lr(file, expStruct.name);
    expStruct.mean = [];
    expStruct.sim = [];
    expStruct.est = [];
end

function arr_lr = array_lr(file, name)
    if ~isfield(file, "metrics")
        fprintf("Metrics format is different file.metrics.trials field cannot be found for %s \n", name);
        return
    end
    arr_lr = zeros(length(file.metrics.trials) - 1, 1);
    for i = 1:(length(file.metrics.trials) - 1)
        if isfield(file.metrics.trials{i,1}, 'choice') && strcmp(file.metrics.trials{i,1}.choice(1), 'r')
            arr_lr(i, 1) = 2;  
        elseif isfield(file.metrics.trials{i,1}, 'choice') && strcmp(file.metrics.trials{i,1}.choice(1), 'l')
            arr_lr(i, 1) = 1;
        else
            arr_lr(i, 1) = 0;
        end
    end
end

function arr_rew = array_rew(file,name)
    if ~isfield(file, "metrics")
        fprintf("metrics format is different file.metrics.trials field cannot be found for %s \n", name);
        return
    end
    arr_rew = zeros(length(file.metrics.trials) - 1, 1);  
    for i = 1:(length(file.metrics.trials) - 1)
        if isfield(file.metrics.trials{i,1}, 'rewarded') && file.metrics.trials{i,1}.rewarded(1) == 1
            arr_rew(i, 1) = 1;  
        else
            arr_rew(i, 1) = 0; 
        end
    end
end

function sharedFill(sesStruct, i)
    range = line_increment('A1', i);
    matRange = line_increment('B1', i);
    if (i == 1)
        titles = ["ID (mouse id + date)", "sim_responses Y_mean", "sim_responses Y_std. dev ", "sim_Learning Rate_mean", "sim_Learning Rate_std. dev", "sim_input U_mean", "sim_input U_std. dev",...
                "sim_perceptual state_mean", "sim_perceptual state_std. dev", "sim_mu_2_mean", "sim_mu_2_std. dev",  "sim_mu_3_mean", "sim_mu_3_std. dev", ...
                "est_input Y_mean", "est_input Y_std. dev",  "est_Learning Rate_mean", "est_Learning Rate_std. dev", ...
                "est_input U_mean", "est_input U_std. dev", "est_perceptual state_mean","est_perceptual state_std. dev", ...
                "est_mu_2_mean", "est_mu_2_std. dev", "est_mu_3_mean", "est_mu_3_std. dev", ...
                "est.traj.mu_1_mean", "est.traj.mu_2_mean", "est.traj.mu_3_mean","est.traj.mu_1_std. dev", "est.traj.mu_2_std. dev", "est.traj.mu_3_std. dev", ...
                "est.traj.sa_1_mean", "est.traj.sa_2_mean", "est.traj.sa_3_mean", "est.traj.sa_1_std. dev", "est.traj.sa_2_std. dev", "est.traj.sa_3_std. dev",...
                "est.traj.muhat_1_mean", "est.traj.muhat_2_mean", "est.traj.muhat_3_mean", "est.traj.muhat_1_std. dev", "est.traj.muhat_2_std. dev", "est.traj.muhat_3_std. dev" ...
                "est.traj.sahat_1_mean",  "est.traj.sahat_2_mean",  "est.traj.sahat_3_mean", "est.traj.sahat_1_std. dev",  "est.traj.sahat_2_std. dev",  "est.traj.sahat_3_std. dev"];
        writematrix(titles, 'comparisonData.xlsx', 'Range', 'A1') %title range
    end
    writematrix(sesStruct.name, 'comparisonData.xlsx','Range', range)	
    writematrix(sesStruct.mean, 'comparisonData.xlsx','Range', matRange)										
end

function ret = calculation(sesStruct)
    sesStruct.sim = tapas_simModel(sesStruct.rew,...
        'tapas_hgf_binary',...
        [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN -2.0 -6.0],... %-2.5 -6
        'tapas_unitsq_sgm',...
        5,...
        123456789);
    %sesStruct.sim.y = sesStruct.choice ; %activate it if you want to use your own y input instead of simulated one
    hgf_binary_config = tapas_hgf_binary_config(); % recovery of parameters 
    unitsq_sgm_config = tapas_unitsq_sgm_config();
    optim_config = tapas_quasinewton_optim_config();
    sesStruct.est = tapas_fitModel(sesStruct.sim.y, sesStruct.sim.u, hgf_binary_config, unitsq_sgm_config, optim_config); % average to calculate the recovery
    sesStruct.est.p_prc.om = [NaN -2.5447 -4.8456]; %changed for the model and parameters quality
    plotting(sesStruct)
    sesStruct.mean = write_data(sesStruct.name, sesStruct);
    sesStruct.mean = write_params(sesStruct);
    ret = sesStruct.mean;
end

function plotting(sesStruct)
    scrsz = get(0,'ScreenSize');
    outerpos = [0.2*scrsz(3),0.7*scrsz(4),0.8*scrsz(3),0.3*scrsz(4)];
    figure('OuterPosition', outerpos, 'Visible', 'off')
    plot(sesStruct.rew, '.', 'Color', [0 0.6 0], 'MarkerSize', 11)
    xlabel('Trial number')
    ylabel('rewarded/not rewarded')
    axis([1, 320, -0.1, 1.1])
    bopars = tapas_fitModel([],... %responses from the input, does response mean reward or the taken reaction, I am not sure about it ??
                                sesStruct.rew,... %input
                                'tapas_hgf_binary_config',... %type of the input 
                                'tapas_bayes_optimal_binary_config',... %perceptual model 
                                'tapas_quasinewton_optim_config'); %#ok<NASGU> %optimization algorithm , which is a variant of the Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm.
    
    
    tapas_hgf_binary_plotTraj(sesStruct.sim) % fig 2
    fig2 = gcf;
    set(fig2, 'Visible', 'off', 'Name', [sesStruct.name, ' Trajectory Simulation'], 'NumberTitle', 'off');
    imgName = sesStruct.name + "_Trajectory_Simulation.png";
    saveas(fig2, fullfile( './imgs/', imgName));

    
    tapas_hgf_binary_plotTraj(sesStruct.est) %fig 3   %%%parameter recovery figure
    fig3 = gcf;
    set(fig3, 'Visible', 'off' , 'Name', [sesStruct.name, ' Trajectory Estimation'], 'NumberTitle', 'off');
    imgName= sesStruct.name + "_Trajectory_Estimation.png";
    saveas(fig3, './imgs/'+ imgName);

    
    tapas_fit_plotCorr(sesStruct.est); % correlation fig 4
    fig4 = gcf;
    set(fig4, 'Visible', 'off' , 'Name', [sesStruct.name, ' Correlation Plot'], 'NumberTitle', 'off');
    imgName= sesStruct.name + "_Correlation_Plot.png";
    saveas(fig4, './imgs/' + imgName);

end

function ret = write_data(exp_name, sesStruct)
    title_range = 'A1'; %A letter is constant number changes
    matrix_range = 'B2'; %B letter is constant, number changes
    title = ["tapas_hgf_binary_plotTraj(sim)", "tapas_hgf_binary_plotTraj(est)"];
    figures = [];
    figures(1) = findall(0, 'Type', 'figure', 'Name', [sesStruct.name, ' Trajectory Simulation']);
    figures(2) = findall(0, 'Type', 'figure', 'Name', [sesStruct.name, ' Trajectory Estimation']);
    for k = 1:2
        yData = {};
        
        fig = figures(k);

        % Find all line objects in the figure
        plotHandles = findall(fig, 'Type', 'line');

        for i = 1:length(plotHandles) 
            currentYData = get(plotHandles(i), 'YData');
            if length(currentYData) > 1
                yData{end+1} = currentYData;
            end
        end
        maxLength = max(cellfun(@length, yData));
        yDataMatrix = cell(length(yData), maxLength);
        for i = 1:length(yData)
            yDataMatrix(i, 1:length(yData{i})) = num2cell(yData{i});
        end
        
        titles = { [exp_name, title(k)] ;"Input Y"; "Learning Rate"; "Input U"; "Posterior mu_2 (red line)"; "mu_2"; "mu_3"};
        writecell(titles, 'miceData.xlsx', 'Range', title_range, 'Sheet', sesStruct.name) %title range
        writecell(yDataMatrix, 'miceData.xlsx','Range', matrix_range, 'Sheet', sesStruct.name); %matrix name
        for i = 1:length(yData)
                sesStruct.mean(end + 1) = mean(yData{i});
                sesStruct.mean(end + 1) = std(yData{i});

        end
        title_range = (line_increment(title_range, 10));
        matrix_range = (line_increment(matrix_range, 10)); 
    end
    ret = sesStruct.mean;
end

function ret = line_increment(str, increment)
    str = char(str);
    letter = str(1);

    num = str2num(str(2));  % This only worked if the number was a single digit
    if (length(str) > 2)
        num = str2num(str(2:end));  % This condition was handled separately
    end
    new_num = num + increment;

    ret = [letter, num2str(new_num)];
end

function ret = write_params(sesStruct)
    param_range = 'B22'; %A letter is constant number changes
    title_range = 'A21'; %B letter is constant, number changes

    param_arr = {sesStruct.est.traj.mu; sesStruct.est.traj.sa; sesStruct.est.traj.muhat; sesStruct.est.traj.sahat};
    param_title = {"est.traj.mu_1"; "est.traj.mu_2"; "est.traj.mu_3"; "est.traj.sa_1";"est.traj.sa_2"; "est.traj.sa_3"; "est.traj.muhat_1"; "est.traj.muhat_2"; "est.traj.muhat_3"; "est.traj.sahat_1"; "est.traj.sahat_2"; "est.traj.sahat_3"};
    k = 1;
    for i = 1:length(param_arr)
        array_i = (param_arr{i});
        array_i = array_i';
        writecell([sesStruct.name; param_title(k:k+2)],'miceData.xlsx','Range', title_range, 'Sheet', sesStruct.name)
        writematrix(array_i, 'miceData.xlsx', "Range", param_range, 'Sheet', sesStruct.name)
        title_range = line_increment(title_range, 5);
        param_range = line_increment(param_range, 5);
        k = k +3;
    end
    sesStruct.mean = [sesStruct.mean, mean(sesStruct.est.traj.mu), std(sesStruct.est.traj.mu)];
    sesStruct.mean = [sesStruct.mean, mean(sesStruct.est.traj.sa), std(sesStruct.est.traj.sa)];
    sesStruct.mean = [sesStruct.mean, mean(sesStruct.est.traj.muhat), std(sesStruct.est.traj.muhat)];
    sesStruct.mean = [sesStruct.mean, mean(sesStruct.est.traj.sahat), std(sesStruct.est.traj.sahat)];
    ret = sesStruct.mean;
end
