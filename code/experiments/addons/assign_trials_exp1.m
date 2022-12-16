function [TR,subj] = assign_trials_exp1( subj,cfg )
%% BUILDS TRIALS FOR STAKED BANDIT TASK
% Prepares trials with 6 information levels

% Builds directory for data ie. stake-bandit/data/raw/99_JM/
% If folder does not exist we assume this participant needs their task
% order assigned and trials created
if ~exist(['../../data/' subj.ID '_' subj.initials],'dir')
    mkdir('../../data/', [subj.ID '_' subj.initials]);
end

subj.save_location = ['../../data/' subj.ID '_' subj.initials '/'];

% Reset random number generator by the clock time & save
t = clock;
subj.RNG_seed = t(3)*t(4)*t(5);
rng(subj.RNG_seed,'twister')

% Calculate when trials were created, this is resolved at end of experiment
subj.version = 'Experiment 1';
subj.start_time = datestr(now);
subj.end_time = [];
subj.exp_duration = [];
subj.task_time = [];

%% ASSIGN SELECTION ORIENTATION
% If the subj ID is an odd number, ACCEPT on LEFT and REJECT on RIGHT
% If the subj ID is an even number, ACCEPT on RIGHT and REJECT on LEFT

if mod(str2double(subj.ID),2)==1
    subj.selection_side = {'ACCEPT','REJECT'};
else
    subj.selection_side = {'REJECT','ACCEPT'};
end

%% DETERMINE STAKE/INFO CONDITIONS + WIN/LOSS RATIO
% Present 6 trials at each of 5 stake levels and 6 information levels
% Can adjust win proportion (ie, 50% win, 50% loss in standard version)

trial_repetitions = 2; % Total of 180 trials counterbalanced 6x30 conditions

% Determine whether an 
if floor(trial_repetitions*subj.win_proportion)~= (trial_repetitions*subj.win_proportion)
    
    sub_text = ['Cannot substitute ' num2str(trial_repetitions) ' reps into 108 conditions '...
        'with a win_ratio of ' num2str(subj.win_proportion)];
    disp(sub_text);
    disp('Rounding up to the next appropriate repetition number');
    
    while 1
        trial_repetitions = trial_repetitions+1;
        if floor(trial_repetitions*subj.win_proportion) == ...
                (trial_repetitions*subj.win_proportion)
            disp(['The new trial rep is ' num2str(trial_repetitions)]);
            break
        elseif trial_repetitions > 6
            disp('The win_ratio requires an inordinate number of reps for perfect counterbalancing (600+ trials)');
            disp('Please change win_ratio or hard-code repetitions');
            return
        end
    end
end

% Determine proportion of trials that result in win
win_reps = round(trial_repetitions*subj.win_proportion);
loss_reps = trial_repetitions - win_reps;

% Counterbalance 5 stake levels (changed to 50 later) and 6 info levels (0:1:5)
stake_labels = {'10','20','30','40','50'}';
info_labels = {'0','1','2','3','4','5'}';

% Determine whether win or loss is by 3:1:5 slots
majority_labels = {'3','4','5'};

stake_conditions = length(stake_labels);
info_conditions = length(info_labels);
majority_conditions = length(majority_labels);

win_order = repmat(randperm(stake_conditions * info_conditions * majority_conditions),...
    1,win_reps);

loss_order = repmat(randperm(stake_conditions * info_conditions * majority_conditions),...
    1,loss_reps);

% Build condition labels balanced by stake & info conditions
condition_labels = cell(stake_conditions * info_conditions * majority_conditions,3);

count = 0;
for stake = 1:stake_conditions
    for info = 1:info_conditions
        for majo = 1:majority_conditions
            count = count+1;
            condition_labels{count,1} = stake_labels{stake};
            condition_labels{count,2} = info_labels{info};
            condition_labels{count,3} = majority_labels{majo};
        end
    end
end

% Substitute conditions into wins and losses and add 'win'/'loss' label
win_conditions = horzcat(condition_labels(win_order,:), ...
    repmat({'win'},length(win_order),1));
loss_conditions = horzcat(condition_labels(loss_order,:), ...
    repmat({'loss'},length(loss_order),1));

% Shuffle over all trials (retaining rows)
stake_info = Shuffle(vertcat(win_conditions,loss_conditions),2);

clear stake info majo

%% DETERMINE SLOT APPEARANCE
% Sampling all possible info arrangements (particularly in the case of 3
% or 2 windows) would require an inordinate number of trials not to mention 
% the window majority condition)
% To account for this I try to roughly balance between-subjects by cycling
% through all arrangements on a trial by trial basis and shuffling each
% time the list of arrangements is exhausted. This should result in at
% least 1 trial per arrangement while still balancing overall information
% levels and win/loss majorities

% All possible info conditions (32 total)

info.open5 = [1 1 1 1 1];

info.open4 = Shuffle([...
    1 1	1 1	0;...
    1 1 1 0 1;...
    1 1	0 1	1;...
    1 0	1 1	1;...
    0 1	1 1	1],2);

info.open3 = Shuffle([...
    1 1 1 0 0;...
    1 1 0 1 0;...
    1 1	0 0	1;...
    1 0	1 1	0;...
    1 0	1 0	1;...
    1 0	0 1	1;...
    0 1	1 1	0;...
    0 1	1 0	1;...
    0 1	0 1	1;...
    0 0	1 1	1],2);


info.open2 = Shuffle([...
    1 1	0 0	0;...
    1 0	1 0	0;...
    1 0	0 1	0;...
    1 0	0 0	1;...
    0 0	1 1	0;...
    0 0	1 0	1;...
    0 1	1 0	0;...
    0 1	0 1	0;...
    0 1	0 0	1;...
    0 0	0 1	1],2);

info.open1 = Shuffle([...
    1 0	0 0	0;...
    0 1	0 0	0;...
    0 0	1 0	0;...
    0 0	0 1	0;...
    0 0	0 0	1],2);

info.open0 = [0 0 0 0 0];

% Majority window conditions

% Arrangement for 3 window majority
majo.windows3 = Shuffle([...
    1 1 1 0 0;...
    1 1 0 0 1;...
    1 0 0 1 1;...
    0 0 1 1 1;...
    0 1 1 1 0;...
    0 1 0 1 1;...
    1 1 0 1 0;...
    1 0 1 1 0;...
    1 0 1 0 1;...
    0 1 1 0 1],2);

majo.windows4 = Shuffle([...
    1 1 1 1 0;...
    1 1 1 0 1;...
    1 1 0 1 1;...
    1 0 1 1 1;...
    0 1 1 1 1],2);

majo.windows5 = [1 1 1 1 1];

% For each trial, select a window & majority state and cycle to next
% arrangement. When list exhausted, randomise order and cycle again.
% Majority and info condition determined by condition labels above

info_state = [];
majo_state = [];

info_counter1 = 0;
info_counter2 = 0;
info_counter3 = 0;
info_counter4 = 0;

majo_counter3 = 0;
majo_counter4 = 0;

for tr = 1:size(stake_info,1)
    
    switch stake_info{tr,2}
        case '0'
            info_state = info.open0;
        case '5'
            info_state = info.open5;
        case '1'
            info_counter1 = info_counter1+1;
            if info_counter1 > size(info.open1,1)
                info_counter1 = 1;
                Shuffle(info.open1,2);
            end
            info_state = info.open1(info_counter1,:);
        case '2'
            info_counter2 = info_counter2+1;
            if info_counter2 > size(info.open2,1)
                info_counter2 = 1;
                Shuffle(info.open2,2);
            end
            info_state = info.open2(info_counter2,:);
        case '3'
            info_counter3 = info_counter3+1;
            if info_counter3 > size(info.open3,1)
                info_counter3 = 1;
                Shuffle(info.open3,2);
            end
            info_state = info.open3(info_counter3,:);
        case '4'
            info_counter4 = info_counter4+1;
            if info_counter4 > size(info.open4,1)
                info_counter4 = 1;
                Shuffle(info.open4,2);
            end
            info_state = info.open4(info_counter4,:);
    end
    
    switch stake_info{tr,3}
        case '3'
            majo_counter3 = majo_counter3+1;
            if majo_counter3 > size(majo.windows3,1)
                majo_counter3 = 1;
                Shuffle(majo.windows3,2);
            end
            majo_state = majo.windows3(majo_counter3,:);
        case '4'
            majo_counter4 = majo_counter4+1;
            if majo_counter4 > size(majo.windows4,1)
                majo_counter4 = 1;
                Shuffle(majo.windows4,2);
            end
            majo_state = majo.windows4(majo_counter4,:);
        case '5'
            majo_state = majo.windows5;
    end
    
    for point = 1:length(majo_state)
        if majo_state(point) == 0
            majo_state(point) = -1; 
        end
    end
    
    TR(tr).info_arrangement = info_state;
    TR(tr).majo_arrangement = majo_state; 
    
end

%% WHEN WAS OUTCOME DETERMINED OR REVEALED TO BE INDETERMINATE?
% This is currently hard-coded for a 5-slot decision space with 1 to 5
% broken windows and an outcome determined by the appearance of 3 of the
% same category. Indeterminacy assumes that participant is able to reflect
% upon decision space and knows that not enough visible slots are available
% to determine an outcome: 
% [01x1x] is indeterminate @ slot 2
% [x001x] is indeterminate @ slot 4
% [x10x0] is indeterminate @ slot 3
% [x1010] is indeterminate @ slot 5
% Examples 1 & 3 are interesting because they require this form of
% reflection for a participant to be certain of indeterminacy before the
% final visible slot is revealed. People should not be willing to expend
% effort or cost for further information at this point if they have this
% knowledge and only value instrumental information

for tr = 1:size(stake_info,1)
   
    if sum(TR(tr).info_arrangement) < 3
        TR(tr).outcome_known = 'indeterminate from beginning';
        continue
    end
    
    outcome_vector = TR(tr).info_arrangement.*TR(tr).majo_arrangement;
    
    windex = [];
    for slot = 1:length(outcome_vector)
        if isequal(outcome_vector(slot),1)
            windex(slot) = 1; %#ok<*AGROW>
        else
            windex(slot) = 0;
        end
    end
    
    if sum(windex) < 3
        if sum(TR(tr).info_arrangement) == 3
            
            % Indeterminate when both conditions have appeared
            win_flag = 0;
            lose_flag = 0;
            for slot = 1:length(outcome_vector)
                if outcome_vector(slot) == 1
                    win_flag = 1;
                elseif outcome_vector(slot) == -1
                    lose_flag = 1;
                end
                
                if (win_flag+lose_flag) == 2
                    TR(tr).outcome_known = ...
                        ['indeterminate at slot: ' num2str(slot)];
                    break
                end
            end
            
        elseif sum(TR(tr).info_arrangement) == 4
            
            % Final visible slot signals indeterminacy
            for slot = 1:length(TR(tr).info_arrangement)
                if isequal(TR(tr).info_arrangement(slot),1)
                    TR(tr).outcome_known = ...
                        ['indeterminate at slot: ' num2str(slot)];
                end
            end
        end 
    end
    
    informativeness = 0;
    for slot = 1:length(windex)
        informativeness = informativeness + windex(slot);
        if informativeness == 3
            TR(tr).outcome_known = ['determined at slot: ' num2str(slot)];
            break
        end
    end
end

%% BUILD THOSE TRIALS
for tr = 1:size(stake_info,1)
    
    % Find the reward and effort conditions
    % TR(tr).stake_level = [stake_info{tr,1} ' cents'];
    TR(tr).stake_level = '50 cents'; % Retroactively fix @ 50cents
    TR(tr).info_level = ['slots visible: ' stake_info{tr,2}];
    TR(tr).majo_level = [stake_info{tr,3} ' slot majority'];
    
    % Outcome of gamble
    TR(tr).outcome = stake_info{tr,4};
    
    % ACCEPT or REJECT response (order determined by subj.selection_side)
    TR(tr).stake_decision = []; % 'accept' or 'reject'
    TR(tr).stake_decision_RT = [];
    
    % Reward or loss on this trial (assuming 'accept' decision NaN otherwise)
    TR(tr).reward = [];
    
    TR(tr).reward_to_date = NaN;
    TR(tr).outcome_previous = NaN;
    
    % How long did it take to view trial outcome: this will be longest for
    % 50 cent stakes and very short for 'Reject' decisions
    TR(tr).outcome_time = []; 
    
    % Anything else I require here
    
end

%% SAVE TRIALS AND SETTINGS

trial_file = [subj.ID '_' subj.initials '_trials'];
save([subj.save_location trial_file '.mat'],'TR')

settings_file = [subj.ID '_' subj.initials '_settings'];
save([subj.save_location settings_file '.mat'],'subj','cfg')

end