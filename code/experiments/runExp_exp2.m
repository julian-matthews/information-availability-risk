%% EXPERIMENT CODE: STAKED BANDIT TASK
% Created 2019-03: Julian Matthews & Patrick Cooper
%
% Modified bandit task with single slot machine and an "accept" or "reject"
% button and variable information
%
% Manipulations include stake (10:10:50) and information (0:1:5)
%
% Initial 6 trials per condition (@ 30 conditions): 180 total trials

function runExp_exp2

% Define internal settings for debugging/etc
USE_debug = 0; % 1 = subscreen on laptop monitor else full screen
USE_synctest = 0; % 0 = skips psychtoolbox sync test

% Variations
USE_training = 1; % 0= skips training and heads straight to trials
USE_screenshots = 0; % 1= takes PTB screenshots for posters/presentations
USE_neutral = 0; % 1= 'broken' windows replaced by neutral faces
USE_reveal = 0; % 1= can invoke extra cost to 'see' true win/loss faces
USE_winnings = 0; % 1= balance displayed at end of trial
USE_announcement = 0; % 1= stake announced via audio only
USE_reject_wait = 1; % 1= neutral faces appear

break_num = 2; % Number of breaks during exp

% Define proportion of trials that will win (50% in original studies)
% This will be counterbalanced for an equal proportion of wins and losses
% for each of the stake/info conditions
win_proportion = 0.5;

% Will auto-adjust number of repetitions to balance win proportion amongst
% conditions (specifying new reps) but will flag if surpasses 15 reps (540 trials)

dbstop if error

%% EXPERIMENT STARTS HERE
% Add supporting functions to path
addpath('addons');

% Collect participant details
if ~USE_debug
    subj.initials = input('Subject''s initials:\n','s');
    subj.ID = input('Subject number (01 to 99):\n','s');
    subj.age = input('Age:\n','s');
    
    while 1
        subj.gender = ...
            input('Gender (f)emale, (m)ale, (n)on-binary:\n','s');
        switch subj.gender
            case {'f','m','n'}
                break
            otherwise
                continue
        end
    end
    
    while 1
        subj.hand = ...
            input('Handedness (r)ight, (l)eft, (a)mbidextrous:\n','s');
        switch subj.hand
            case {'r','l','a'}
                break
            otherwise
                continue
        end
    end
    
else
    subj.initials = 'JM'; subj.ID = '999'; subj.age = '32';
    subj.gender = 'm'; subj.hand = 'r';
end

% Add digits to build full ID as per Patrick's script
subj.partID = ['00' subj.ID];
subj.win_proportion = win_proportion;

% Load Psychtoolbox parameters and OpenWindow
[audio_samples,cfg] = parameters(USE_debug,USE_synctest);

% Raw data save location
data_save = '../../data/';

% Crash protection, skip setup if trials already created
if ~exist([data_save subj.ID '_' subj.initials '/' subj.ID subj.initials '_settings.mat'],'file')
    
    % Creates trials
    [TR,subj] = assign_trials_exp2(subj,cfg);
    
end

%% Present instructions

% Determine window size
[y,i] = min(cfg.win_rect(3:4));
instruct_window = [0 0 y y];
if i == 2
    instruct_window = instruct_window + (cfg.width-y)/2*[1 0 1 0];
elseif i == 1
    instruct_window = instruct_window + (cfg.height-y)/2*[0 1 0 1];
end

% Colour screen black
Screen('FillRect', cfg.win_ptr, cfg.black);
Screen('DrawTexture',cfg.win_ptr,cfg.instruct.gamble, ...
    [],instruct_window);
Screen('Flip', cfg.win_ptr);

WaitSecs(1);

% Look for the internal laptop keyboard
clear PsychHID
devices = PsychHID('Devices');
for device = 1:length(devices)
    if strcmp(devices(device).usageName,'Keyboard') ...
            && contains(devices(device).product,'Internal')
        device_num = device;
        break
    elseif device == length(devices)
        device_num = [];
    end
end

KbStrokeWait(device_num);

WaitSecs(2);

%% Cycle trials

% Determine when/if break happen
breaks = round(length(TR)/(break_num+1));
break_trials = (1:break_num).*breaks;

% Create machine configurations from Patrick's code
% Leaving off arm for the moment because people might select 'accept' to
% see animation rather than on the basis of the stake. Need to match visual
% presentation of each option
width = cfg.width*.33;
height = 155;
machine = createMachine(cfg,1,width, height,'centre');
windows = createWindows(cfg,5,width/6, height*.8,'centre');
wB = createWindowBreaks(windows);

% Value used to adjust proximinty of decision boxes
narrowing = 40;

% Computes size of emoji needed to fit into window
face_dim = diff(windows.allRects([1 3],1))*.7;

% Decide on reveal and reject sounds
reveal_sound = audio_samples.neutSound;
reject_sound = audio_samples.reject;

if ~USE_neutral
    face_options = {cfg.emoji.positive cfg.emoji.negative}; %#ok<*USENS>
end

% Start clock to measure total experiment time
whole_experiment = tic;

%% RUN TRAINING
% 20 practice trials. First 5 are untimed decisions and hardcoded to
% reveal a few interesting combinations of information/stake/outcomes

if USE_training

    run_training_exp2(subj,cfg,windows,wB,machine,narrowing,...
        audio_samples,reveal_sound,reject_sound,device_num,USE_winnings)

end

% Intermission screen
Screen('FillRect', cfg.win_ptr, cfg.black);

Screen('TextFont', cfg.win_ptr, cfg.instruct_font);
Screen('TextSize', cfg.win_ptr, cfg.minor_text);

start_tex = sprintf(['You''re now ready to start the experiment\n\n'...
    'Each set of trials will take ~10 minutes to complete']);

DrawFormattedText(cfg.win_ptr, start_tex, ...
        'center','center', cfg.white);

Screen('Flip', cfg.win_ptr);

trial_file = [subj.ID '_' subj.initials '_trials'];
save([subj.save_location trial_file '.mat'],'TR')

WaitSecs(1);

KbStrokeWait(device_num);

summary_tex = sprintf(['Remember:\n\n'...
    '1. The chance of winning is 50%% on EVERY trial\n\n'...
    '2. Consider INFORMATION and STAKE when choosing to play or not']);

DrawFormattedText(cfg.win_ptr, summary_tex, ...
        'center','center', cfg.white);

Screen('Flip', cfg.win_ptr);

WaitSecs(3);

KbStrokeWait(device_num);

Screen('TextSize', cfg.win_ptr, cfg.text_size);
Screen('TextFont', cfg.win_ptr, cfg.standard_font);

for dot = 1:3
    
    dot_string = repmat('.',1,dot);
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    DrawFormattedText(cfg.win_ptr, 'Preparing real trials', ...
        'center','center', cfg.white);
    DrawFormattedText(cfg.win_ptr, dot_string, ...
        'center',cfg.yCentre + cfg.height * 0.2, cfg.white);
    Screen('Flip', cfg.win_ptr);
    
    WaitSecs(1);
    
end

%% START EXPERIMENT
for tr = 1:length(TR)
    %% TAKE A BREAK YET?
    if ~isempty(find(break_trials==tr,1))
        
        % Flag to experimenter
        disp('?_? ~participant has reached a break');
        
        % Intermission screen
        Screen('FillRect', cfg.win_ptr, cfg.black);
        Screen('DrawTexture',cfg.win_ptr,cfg.instruct.intermission);
        Screen('Flip', cfg.win_ptr);
        
        trial_file = [subj.ID '_' subj.initials '_trials'];
        save([subj.save_location trial_file '.mat'],'TR')
        
        WaitSecs(2);
        
        KbStrokeWait(device_num);
                
        % Display % complete so far
        talk_tex{1} = sprintf('??? %0.0f%% of experiment completed',...
            tr/length(TR)*100);
        
        talk_tex{2} = sprintf('?_? %0.0f%% of experiment completed',...
            tr/length(TR)*100);
        
        for dot = 1:8
            
            tmp = mod(dot,2)+1;
            DrawFormattedText(cfg.win_ptr, talk_tex{tmp}, ...
                'center','center', cfg.white);
            Screen('Flip', cfg.win_ptr);
            
            WaitSecs(0.5);
            
        end
        
    end
    
    %% ANNOUNCE THE STAKE
    
    switch TR(tr).stake_level
        case '10 cents'
            staked = audio_samples.stake10;
        case '20 cents'
            staked = audio_samples.stake20;
        case '30 cents'
            staked = audio_samples.stake30;
        case '40 cents'
            staked = audio_samples.stake40;
        case '50 cents'
            staked = audio_samples.stake50;
    end
    
    stop(staked); play(staked);

    %% WHAT HAPPENED ON PREVIOUS TRIAL?
    
    if tr > 1
        TR(tr).reward_to_date = sum([TR(1:tr).reward],'omitnan');
        if strcmp(TR(tr-1).stake_decision,'accept')
            TR(tr).outcome_previous = [TR(tr-1).outcome ': ' TR(tr-1).stake_level];
        else
            TR(tr).outcome_previous = 'reject';
        end
    end
    
    %% DRAW THE MACHINE
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    
    if ~USE_announcement
        % Display stake visually
        DrawFormattedText(cfg.win_ptr, TR(tr).stake_level, 'center',...
            cfg.yCentre + cfg.height * -0.2, cfg.white);
    end
    
    % Draw the machine and windows to the screen
    Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
        (windows.allRects), 6);
    Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
    
    % Display broken screen(s) for this trial (cross or grey)
    if USE_neutral
        if ~isempty(find(TR(tr).info_arrangement==0,1))
            for w_i = find(TR(tr).info_arrangement==0)
                Screen('DrawLine', cfg.win_ptr, wB.colour, ...
                    wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i),6);
                Screen('DrawLine', cfg.win_ptr, wB.colour, ...
                    wB.xEnd(w_i),wB.yStart(w_i),wB.xStart(w_i),wB.yEnd(w_i),6);
            end
        end
    else
        if ~isempty(find(TR(tr).info_arrangement==0,1))
            for w_i = find(TR(tr).info_arrangement==0)
                Screen('FillRect', cfg.win_ptr, wB.colour, ...
                    [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
            end
        end
    end
    
    % Display ACCEPT and REJECT options depending on subj.selection_side
    if strcmp(subj.selection_side{1},'ACCEPT')
        [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
            machine.allRects(1)+ narrowing, ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
            machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        
        Screen('FrameRect',cfg.win_ptr, wB.colour, ...
            [accept_box + 10*[-1 -1 1 1]; ...
            reject_box + 10*[-1 -1 1 1]]',4);
    else
        [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
            machine.allRects(1) + narrowing, ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
            machine.allRects(3) - cfg.accept_bounds(3) - narrowing, ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        
        Screen('FrameRect',cfg.win_ptr, wB.colour, ...
            [accept_box + 10*[-1 -1 1 1]; ...
            reject_box + 10*[-1 -1 1 1]]',4);
    end
    
    % if USE_winnings
    %     kitty_num = sum([TR(1:tr).reward],'omitnan')/100;
    %     if kitty_num < 0
    %         kitty = sprintf('-$%0.2f',abs(kitty_num));
    %     else
    %         kitty = sprintf('$%0.2f',kitty_num);
    %     end
    %     DrawFormattedText(cfg.win_ptr,kitty,'left',50);
    % end
    
    Screen('Flip',cfg.win_ptr);
    
    if USE_screenshots
        capture_count = capture_count + 1; %#ok<*UNRCH>
        imageArray = Screen('GetImage', cfg.win_ptr);
        imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
    end
    
    start_timer = GetSecs;
    time_elapsed = tic;
    while 1
        
        % Machine and stake appears for timed interval about whether to
        % accept or reject stake on basis of info
        
        [is_pressed, this_time, is_key]=KbCheck(device_num);
        
        if is_pressed && (this_time-start_timer)>cfg.input_minimum
            if xor(is_key(cfg.leftKey),is_key(cfg.rightKey))
                if is_key(cfg.leftKey)
                    response_side = 0;
                elseif is_key(cfg.rightKey)
                    response_side = 1;
                end
                
                Screen('FillRect', cfg.win_ptr, cfg.black);
                
                % Display machine (stake not presented visually)
                % DrawFormattedText(cfg.win_ptr, TR(tr).stake_level, 'center',...
                %   cfg.yCentre + cfg.height * -0.2, cfg.white);
                Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
                    (windows.allRects), 6);
                Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
                
                % Display broken screen(s) for this trial (cross or grey)
                if USE_neutral
                    if ~isempty(find(TR(tr).info_arrangement==0,1))
                        for w_i = find(TR(tr).info_arrangement==0)
                            Screen('DrawLine', cfg.win_ptr, wB.colour, ...
                                wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i),6);
                            Screen('DrawLine', cfg.win_ptr, wB.colour, ...
                                wB.xEnd(w_i),wB.yStart(w_i),wB.xStart(w_i),wB.yEnd(w_i),6);
                        end
                    end
                else
                    if ~isempty(find(TR(tr).info_arrangement==0,1))
                        for w_i = find(TR(tr).info_arrangement==0)
                            Screen('FillRect', cfg.win_ptr, wB.colour, ...
                                [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                        end
                    end
                end
                
                % Highlight text
                if response_side == 0 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    TR(tr).stake_decision = 'accept';
                    
                    stop(staked);
                    stop(audio_samples.accept)
                    play(audio_samples.accept)
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    TR(tr).stake_decision = 'reject';
                    
                    stop(staked);
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    
                elseif response_side == 0 && strcmp(subj.selection_side{1},'REJECT')
                    
                    TR(tr).stake_decision = 'reject';
                    
                    stop(staked);
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(3) - cfg.accept_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'REJECT')
                    
                    TR(tr).stake_decision = 'accept';
                    
                    stop(staked);
                    stop(audio_samples.accept)
                    play(audio_samples.accept)
                    
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(3) - cfg.accept_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    
                end
                
                Screen('FrameRect',cfg.win_ptr, wB.colour, ...
                    [accept_box + 10*[-1 -1 1 1]; ...
                    reject_box + 10*[-1 -1 1 1]]',4);
                
                Screen('Flip', cfg.win_ptr);
                
                if USE_screenshots
                    capture_count = capture_count + 1; %#ok<*UNRCH>
                    imageArray = Screen('GetImage', cfg.win_ptr);
                    imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
                end
                
                WaitSecs(0.8);
                
                TR(tr).reward = 0;
                TR(tr).stake_decision_RT = this_time - start_timer;
                break
            end
        end
        
        if (toc(time_elapsed)-cfg.stake_decision) > 0
            TR(tr).stake_decision = NaN;
            TR(tr).stake_decision_RT = cfg.stake_decision;
            
            WaitSecs(0.8);
            
            break
        end
    end
    
    outcome_timer = tic;
    
    %% ACCEPTED or REJECTED?
    if strcmp(TR(tr).stake_decision,'accept')
        % Participant has accepted stake: view the dynamic machine
        
        % Determine random index for non-instrumental faces
        if ~USE_neutral
            indx = randi(2,1,length(TR(tr).info_arrangement));
        end
        
        for window = 1:length(TR(tr).info_arrangement)
            
            emoji_stream = TR(tr).info_arrangement(1:window);
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            if ~USE_neutral
                % Display broken screen(s) for this trial (cross or grey)
                if ~isempty(find(TR(tr).info_arrangement==0,1))
                    for w_i = find(TR(tr).info_arrangement==0)
                        Screen('FillRect', cfg.win_ptr, wB.colour, ...
                            [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                    end
                end
            end
            
            for slot = 1:length(emoji_stream)
                
                switch emoji_stream(slot)
                    case 0
                        if USE_neutral
                            this_face = cfg.emoji.neutral;
                        else
                            this_face = face_options{indx(slot)}; %#ok<*NODEF>
                        end
                    case 1
                        if TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'win')
                            this_face = cfg.emoji.positive;
                        elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'win')
                            this_face = cfg.emoji.negative;
                        elseif TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'loss')
                            this_face = cfg.emoji.negative;
                        elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'loss')
                            this_face = cfg.emoji.positive;
                        end
                end
                
                % Display face
                Screen('DrawTexture',cfg.win_ptr, this_face,[],...
                    CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
                
            end
            
            % Display window
            Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
                (windows.allRects), 6);
            
            Screen('Flip',cfg.win_ptr);
            stop(reveal_sound);
            play(reveal_sound);
            
            WaitSecs(cfg.window_reveal);
            
            if USE_screenshots
                capture_count = capture_count + 1; %#ok<*UNRCH>
                imageArray = Screen('GetImage', cfg.win_ptr);
                imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
            end
            
        end
        
        %% Present the WIN or LOSS
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
        
        if ~USE_neutral && ~USE_reveal
            if ~isempty(find(TR(tr).info_arrangement==0,1))
                for w_i = find(TR(tr).info_arrangement==0)
                    Screen('FillRect', cfg.win_ptr, wB.colour, ...
                        [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                end
            end
        end
        
        for slot = 1:length(emoji_stream)
            
            switch emoji_stream(slot)
                case 0
                    if USE_neutral
                        this_face = cfg.emoji.neutral;
                    else
                        if ~USE_reveal
                            this_face = face_options{indx(slot)};
                        else
                            if TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'win')
                                this_face = cfg.emoji.positive;
                            elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'win')
                                this_face = cfg.emoji.negative;
                            elseif TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'loss')
                                this_face = cfg.emoji.negative;
                            elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'loss')
                                this_face = cfg.emoji.positive;
                            end
                        end
                    end
                case 1
                    if TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'win')
                        this_face = cfg.emoji.positive;
                    elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'win')
                        this_face = cfg.emoji.negative;
                    elseif TR(tr).majo_arrangement(slot) == 1 && strcmp(TR(tr).outcome,'loss')
                        this_face = cfg.emoji.negative;
                    elseif TR(tr).majo_arrangement(slot) == -1 && strcmp(TR(tr).outcome,'loss')
                        this_face = cfg.emoji.positive;
                    end
            end
            
            Screen('DrawTexture',cfg.win_ptr, this_face,[],...
                CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
            
        end
        
        Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
            (windows.allRects), 6);
        
        if strcmp(TR(tr).outcome,'win')
            outcome_string = ['You win ' TR(tr).stake_level];
            audio = audio_samples.winSound;
        else
            outcome_string = ['You lose ' TR(tr).stake_level];
            audio = audio_samples.loseSound;
        end
        
        DrawFormattedText(cfg.win_ptr, outcome_string, 'center', ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        
        Screen('Flip',cfg.win_ptr);
        stop(audio);
        play(audio);
        
        if USE_screenshots
            capture_count = capture_count + 1; %#ok<*UNRCH>
            imageArray = Screen('GetImage', cfg.win_ptr);
            imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
        end
        
        % Find where the blank space separating the reward from 'cents'
        num_find = strfind(TR(tr).stake_level,' ');
        if strcmp(TR(tr).outcome,'win')
            TR(tr).reward = str2double(TR(tr).stake_level(1:num_find-1));
        else
            TR(tr).reward = -str2double(TR(tr).stake_level(1:num_find-1));
        end
        
        WaitSecs(cfg.outcome_reveal);
        
        if USE_winnings
            
            increments = TR(tr).reward/10;
            kitty_num = sum([TR(1:tr-1).reward],'omitnan')/100;
            
            for inc = 1:abs(increments)
                
                Screen('FillRect', cfg.win_ptr, cfg.black);
                
                if increments > 0
                    new_kitty = kitty_num + 0.1*inc;
                else
                    new_kitty = kitty_num - 0.1*inc;
                end
                
                if new_kitty < 0
                    kitty = sprintf('-$%0.2f',abs(new_kitty));
                else
                    kitty = sprintf('$%0.2f',new_kitty);
                end
                
                DrawFormattedText(cfg.win_ptr,kitty,'center','center');
                
                if inc == 1
                    feedback_sound = audio_samples.brokSound;
                elseif inc > 1
                    if TR(tr).reward > 0
                        feedback_sound = audio_samples.broku(inc-1);
                    else
                        feedback_sound = audio_samples.brokd(inc-1);
                    end
                end
                
                stop(feedback_sound); play(feedback_sound);
                Screen('Flip',cfg.win_ptr);
                
                WaitSecs(1/6);
                
                Screen('Flip',cfg.win_ptr);
                
                WaitSecs(1/12);
                
            end
        end
        
    else
        % Participant has rejected stake or failed to select an item
        if isnan(TR(tr).stake_decision)
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            wait_string = 'Too slow! Please wait until next stake is prepared.';
            DrawFormattedText(cfg.win_ptr, wait_string, 'center', ...
                'center', cfg.white);
            Screen('Flip',cfg.win_ptr);
            stop(audio_samples.loseSound);
            play(audio_samples.loseSound);
            
            WaitSecs(cfg.too_slow);
            
        elseif strcmp(TR(tr).stake_decision,'reject') && USE_reject_wait
            % Play out the trial but with neutral faces
            
            for window = 1:length(TR(tr).info_arrangement)
                
                Screen('FillRect', cfg.win_ptr, cfg.black);
                Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
                
                if ~USE_neutral
                    % Display broken screen(s) for this trial (cross or grey)
                    if ~isempty(find(TR(tr).info_arrangement==0,1))
                        for w_i = find(TR(tr).info_arrangement==0)
                            Screen('FillRect', cfg.win_ptr, wB.colour, ...
                                [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                        end
                    end
                end
                
                for slot = 1:window
                    
                    % Display neutral face
                    Screen('DrawTexture',cfg.win_ptr, cfg.emoji.neutral,[],...
                        CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
                    
                end
                
                % Display window
                Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
                    (windows.allRects), 6);
                
                Screen('Flip',cfg.win_ptr);
                stop(reveal_sound);
                play(reveal_sound);
                
                if USE_screenshots
                    capture_count = capture_count + 1; %#ok<*UNRCH>
                    imageArray = Screen('GetImage', cfg.win_ptr);
                    imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
                end
                
                WaitSecs(cfg.window_reveal);
                
            end
            
            %% Present the WIN or LOSS
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            if ~USE_neutral && ~USE_reveal
                if ~isempty(find(TR(tr).info_arrangement==0,1))
                    for w_i = find(TR(tr).info_arrangement==0)
                        Screen('FillRect', cfg.win_ptr, wB.colour, ...
                            [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                    end
                end
            end
            
            for slot = 1:length(TR(tr).info_arrangement)
                
                Screen('DrawTexture',cfg.win_ptr, cfg.emoji.neutral,[],...
                    CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
                
            end
            
            Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
                (windows.allRects), 6);
            
            outcome_string = 'Stake rejected on this trial';
            
            DrawFormattedText(cfg.win_ptr, outcome_string, 'center', ...
                cfg.yCentre + cfg.height * 0.22, cfg.white);
            
            Screen('Flip',cfg.win_ptr);
            stop(reject_sound);
            play(reject_sound);
            
            if USE_screenshots
                capture_count = capture_count + 1; %#ok<*UNRCH>
                imageArray = Screen('GetImage', cfg.win_ptr);
                imwrite(imageArray, ['screenshot_' num2str(capture_count) '.png'])
            end
            
            WaitSecs(cfg.outcome_reveal);
            
            if USE_winnings
                
                num_find = strfind(TR(tr).stake_level,' ');
                sound_match = str2double(TR(tr).stake_level(1:num_find-1));
                
                increments = sound_match/10;
                kitty_num = sum([TR(1:tr-1).reward],'omitnan')/100;
                
                for inc = 1:abs(increments)
                    
                    Screen('FillRect', cfg.win_ptr, cfg.black);
                    
                    if kitty_num < 0
                        kitty = sprintf('-$%0.2f',abs(kitty_num));
                    else
                        kitty = sprintf('$%0.2f',kitty_num);
                    end
                    
                    DrawFormattedText(cfg.win_ptr,kitty,'center','center');
                    
                    feedback_sound = audio_samples.brokSound;
                    
                    stop(feedback_sound); play(feedback_sound);
                    Screen('Flip',cfg.win_ptr);
                    
                    WaitSecs(1/6);
                    
                    Screen('Flip',cfg.win_ptr);
                    
                    WaitSecs(1/12);
                    
                end
            end
        end
    end
    
    %% SAVE TEMP FILE
    % Saved data up to the latest trial of the current block
    trial_file = [subj.ID '_' subj.initials '_temp'];
    save([subj.save_location trial_file '.mat'],'TR')
    
    %% INTERTRIAL SCREEN
    time_elapsed = tic;
    while (toc(time_elapsed)-cfg.intertrial_time) < 0
        Screen('FillRect', cfg.win_ptr, cfg.window_colour);
        Screen('Flip', cfg.win_ptr);
    end
    
    TR(tr).outcome_time = toc(outcome_timer);
    
    % Display percentage of trials completed
    fprintf('trials complete: %0.2f%%\n',tr/length(TR)*100);
    
end

%% SAVE TRIALS AND SETTINGS

subj.end_time = datestr(now);
subj.task_time = toc(whole_experiment);
subj.exp_duration = datevec(datenum(subj.end_time,0)-datenum(subj.start_time,0));

trial_file = [subj.ID '_' subj.initials '_trials'];
save([subj.save_location trial_file '.mat'],'TR')

settings_file = [subj.ID '_' subj.initials '_settings'];
save([subj.save_location settings_file '.mat'],'subj','cfg')

sca;

final_take = sum([TR(:).reward],'omitnan')/100;
if final_take < 0
    fin_tex = sprintf('\nThe final take was: -$%0.2f\n',abs(final_take));
else
    fin_tex = sprintf('\nThe final take was: $%0.2f\n',final_take);
end
disp(fin_tex)
    

end
