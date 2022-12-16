function run_training_exp2( subj,cfg,windows,wB,machine,narrowing,audio_samples,reveal_sound,reject_sound,device_num,USE_winnings )
%  20 practice trials. First 5 are untimed decisions and hardcoded to
% reveal a few interesting combinations of information/stake/outcomes

face_dim = diff(windows.allRects([1 3],1))*.7;
face_options = {cfg.emoji.positive cfg.emoji.negative};

% Get ready for practice trials
for dot = 1:3
    
    dot_string = repmat('.',1,dot);
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    DrawFormattedText(cfg.win_ptr, 'Preparing introduction trials', ...
        'center','center', cfg.white);
    DrawFormattedText(cfg.win_ptr, dot_string, ...
        'center',cfg.yCentre + cfg.height * 0.2, cfg.white);
    Screen('Flip', cfg.win_ptr);
    
    WaitSecs(1);
    
end

%% INITIAL PRACTICE
% First 5 practice trials exhibiting a few interesting combos

training.info_arrangement = [...
    1 1 1 1 1;...
    1 1 1 1 1;...
    0 1 1 0 1;...
    1 1 1 0 0;...
    0 0 0 0 0];

% We'll hardcode this to 1=win_face, -1=lose_face, 0=neut_face
training.face_arrangement = [...
    1 -1 -1 1 1;... % Forced accept
    0 0 0 0 0;... % Forced reject
    1 -1 -1 1 1;... % demontrastion of non-informative, Forced accept decision
    1 -1 -1 1 -1;... % demonstration of that non-informative are truly random
    1 -1 1 -1 -1]; % demonstration of maximum number of non-informative

training.outcome = {...
    'win',...
    'lose',... % This will be rejected
    'lose',...
    'win',...
    'win'};

training.decision = {...
    'accept',...
    'reject',...
    'accept',...
    'accept',...
    'accept'};

training.stake_level = {...
    '30 cents',...
    '50 cents',...
    '20 cents',...
    '10 cents',...
    '50 cents'};

%% CYCLE INITIAL PRACTICE
for unti = 1:5
    
    % ANNOUNCE THE STAKE
    
    switch training.stake_level{unti}
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
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    
    % Display stake visually
    DrawFormattedText(cfg.win_ptr, training.stake_level{unti}, 'center',...
        cfg.yCentre + cfg.height * -0.2, cfg.white);
    
    % Draw the machine and windows to the screen
    Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
        (windows.allRects), 6);
    Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
    
    % Display broken screen(s) for this trial (cross or grey)
    if ~isempty(find(training.info_arrangement(unti,:)==0,1))
        for w_i = find(training.info_arrangement(unti,:)==0)
            Screen('FillRect', cfg.win_ptr, wB.colour, ...
                [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
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
    
    Screen('Flip',cfg.win_ptr);
    
    while 1
        
        % Machine and stake appears waiting for right decision
        
        [is_pressed, ~, is_key]=KbCheck(device_num);
        
        if is_pressed
            if xor(is_key(cfg.leftKey),is_key(cfg.rightKey))
                if is_key(cfg.leftKey)
                    if unti == 5
                        response_side = 0; %#ok<*NASGU>
                    elseif strcmp(subj.selection_side{1},'ACCEPT') && unti == 2
                        continue;
                    elseif strcmp(subj.selection_side{1},'REJECT') && unti ~= 2
                        continue;
                    end
                    response_side = 0;
                    
                elseif is_key(cfg.rightKey)
                    if unti == 5
                        response_side = 1;
                    elseif strcmp(subj.selection_side{2},'ACCEPT') && unti == 2
                        continue;
                    elseif strcmp(subj.selection_side{2},'REJECT') && unti ~= 2
                        continue;
                    end
                    response_side = 1;
                end
                
                Screen('FillRect', cfg.win_ptr, cfg.black);
                
                Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
                    (windows.allRects), 6);
                Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
                
                if ~isempty(find(training.info_arrangement(unti,:)==0,1))
                    for w_i = find(training.info_arrangement(unti,:)==0)
                        Screen('FillRect', cfg.win_ptr, wB.colour, ...
                            [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                    end
                end
                
                % Highlight text
                if response_side == 0 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    stop(audio_samples.accept)
                    play(audio_samples.accept)
                    
                    training.decision{unti} = 'accept';
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    training.decision{unti} = 'reject';
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    
                elseif response_side == 0 && strcmp(subj.selection_side{1},'REJECT')
                    
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    training.decision{unti} = 'reject';
                    
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(3) - cfg.accept_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'REJECT')
                    
                    stop(audio_samples.accept)
                    play(audio_samples.accept)
                    
                    training.decision{unti} = 'accept';
                    
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
                
                WaitSecs(0.8);
                
                break
            end
        end
    end
    
    if strcmp(training.decision{unti},'accept')
        % Participant has accepted stake: view the dynamic machine
        
        % Determine random index for non-instrumental faces
        for window = 1:length(training.info_arrangement(unti,:))
            
            emoji_stream = training.face_arrangement(unti,1:window);
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            % Display broken screen(s) for this trial (cross or grey)
            if ~isempty(find(training.info_arrangement(unti,:)==0,1))
                for w_i = find(training.info_arrangement(unti,:)==0)
                    Screen('FillRect', cfg.win_ptr, wB.colour, ...
                        [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                end
            end
            
            for slot = 1:length(emoji_stream)
                switch emoji_stream(slot)
                    case 0
                        this_face = cfg.emoji.neutral;
                    case 1
                        this_face = cfg.emoji.positive;
                    case -1
                        this_face = cfg.emoji.negative;
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
            
        end
        
        %% Present the WIN or LOSS
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
        
        if ~isempty(find(training.info_arrangement(unti,:)==0,1))
            for w_i = find(training.info_arrangement(unti,:)==0)
                Screen('FillRect', cfg.win_ptr, wB.colour, ...
                    [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
            end
        end
        
        for slot = 1:length(emoji_stream)
            
            switch emoji_stream(slot)
                case 0
                    this_face = cfg.emoji.neutral;
                case 1
                    this_face = cfg.emoji.positive;
                case -1
                    this_face = cfg.emoji.negative;
            end
            
            Screen('DrawTexture',cfg.win_ptr, this_face,[],...
                CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
            
        end
        
        Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
            (windows.allRects), 6);
        
        if strcmp(training.outcome{unti},'win')
            outcome_string = ['You win ' training.stake_level{unti}];
            audio = audio_samples.winSound;
        else
            outcome_string = ['You lose ' training.stake_level{unti}];
            audio = audio_samples.loseSound;
        end
        
        DrawFormattedText(cfg.win_ptr, outcome_string, 'center', ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        
        Screen('Flip',cfg.win_ptr);
        stop(audio);
        play(audio);
        
        WaitSecs(cfg.outcome_reveal);
        
        if unti > 2 && unti ~= 5
            % Pause at outcome so this trial can be explained
            KbStrokeWait(device_num);
            
            WaitSecs(1);
        end
        
        if USE_winnings
            
            % implement if of interest
            
            %             num_find = strfind(training.stake_level{unti},' ');
            %             sound_match = str2double(training.stake_level{unti}(1:num_find-1));
            %
            %             increments = sound_match/10;
            %
            %             % Need to specify a running win count
            %             kitty_num = sum([TR(1:tr-1).reward],'omitnan')/100;
            %
            %             for inc = 1:abs(increments)
            %
            %                 Screen('FillRect', cfg.win_ptr, cfg.black);
            %
            %                 if increments > 0
            %                     new_kitty = kitty_num + 0.1*inc;
            %                 else
            %                     new_kitty = kitty_num - 0.1*inc;
            %                 end
            %
            %                 if new_kitty < 0
            %                     kitty = sprintf('-$%0.2f',abs(new_kitty));
            %                 else
            %                     kitty = sprintf('$%0.2f',new_kitty);
            %                 end
            %
            %                 DrawFormattedText(cfg.win_ptr,kitty,'center','center');
            %
            %                 if inc == 1
            %                     feedback_sound = audio_samples.brokSound;
            %                 elseif inc > 1
            %                     if TR(tr).reward > 0
            %                         feedback_sound = audio_samples.broku(inc-1);
            %                     else
            %                         feedback_sound = audio_samples.brokd(inc-1);
            %                     end
            %                 end
            %
            %                 stop(feedback_sound); play(feedback_sound);
            %                 Screen('Flip',cfg.win_ptr);
            %
            %                 WaitSecs(1/6);
            %
            %                 Screen('Flip',cfg.win_ptr);
            %
            %                 WaitSecs(1/12);
            %
            %             end
        end
        
    else
        % Participant has rejected stake
        
        for window = 1:length(training.info_arrangement(unti,:))
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            % Display broken screen(s) for this trial (cross or grey)
            if ~isempty(find(training.info_arrangement(unti,:)==0,1))
                for w_i = find(training.info_arrangement(unti,:)==0)
                    Screen('FillRect', cfg.win_ptr, wB.colour, ...
                        [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
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
            
            WaitSecs(cfg.window_reveal);
            
        end
        
        %% Present the WIN or LOSS
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
        
        if ~isempty(find(training.info_arrangement(unti,:)==0,1))
            for w_i = find(training.info_arrangement(unti,:)==0)
                Screen('FillRect', cfg.win_ptr, wB.colour, ...
                    [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
            end
        end
        
        for slot = 1:length(training.info_arrangement(unti,:))
            
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
        
        WaitSecs(cfg.outcome_reveal);
        
        if USE_winnings
            
            % Implement below
            %                 num_find = strfind(TR(tr).stake_level,' ');
            %                 sound_match = str2double(TR(tr).stake_level(1:num_find-1));
            %
            %                 increments = sound_match/10;
            %                 kitty_num = sum([TR(1:tr-1).reward],'omitnan')/100;
            %
            %                 for inc = 1:abs(increments)
            %
            %                     Screen('FillRect', cfg.win_ptr, cfg.black);
            %
            %                     if kitty_num < 0
            %                         kitty = sprintf('-$%0.2f',abs(kitty_num));
            %                     else
            %                         kitty = sprintf('$%0.2f',kitty_num);
            %                     end
            %
            %                     DrawFormattedText(cfg.win_ptr,kitty,'center','center');
            %
            %                     feedback_sound = audio_samples.brokSound;
            %
            %                     stop(feedback_sound); play(feedback_sound);
            %                     Screen('Flip',cfg.win_ptr);
            %
            %                     WaitSecs(1/6);
            %
            %                     Screen('Flip',cfg.win_ptr);
            %
            %                     WaitSecs(1/12);
            %
            %                 end
        end
    end
    %% INTERTRIAL SCREEN
    time_elapsed = tic;
    while (toc(time_elapsed)-cfg.intertrial_time) < 0
        Screen('FillRect', cfg.win_ptr, cfg.window_colour);
        Screen('Flip', cfg.win_ptr);
    end
    
end

%% PREPARE PRACTICE 15 TRIALS

time_tex = sprintf(['We will now prepare a few randomly generated trials\n\n'...
    'You will have %g seconds to make decisions from here on\n\n'...
    ],cfg.stake_decision);

Screen('TextSize', cfg.win_ptr, cfg.minor_text);
Screen('TextFont', cfg.win_ptr, cfg.instruct_font);

DrawFormattedText(cfg.win_ptr, time_tex, ...
    'center','center', cfg.white);

Screen('Flip', cfg.win_ptr);

WaitSecs(2);

while (1)
    [~,~,buttons] = GetMouse(cfg.win_ptr);
    if buttons(1) || KbCheck(device_num)
        break;
    end
end

Screen('TextFont', cfg.win_ptr, cfg.standard_font);

% Get ready for practice trials
for dot = 1:3
    
    dot_string = repmat('.',1,dot);
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    
    Screen('TextSize', cfg.win_ptr, cfg.text_size);
    
    DrawFormattedText(cfg.win_ptr, 'Preparing practice trials', ...
        'center','center', cfg.white);
    DrawFormattedText(cfg.win_ptr, dot_string, ...
        'center',cfg.yCentre + cfg.height * 0.2, cfg.white);
    Screen('Flip', cfg.win_ptr);
    
    WaitSecs(1);
    
end

stake_labels = {'10','20','30','40','50'}';

for prac = 1:15
    TRAIN(prac).stake_level = [stake_labels{randi(5)} ' cents']; %#ok<*AGROW>
    TRAIN(prac).info_arrangement = randi(2,1,5)-1;
    temp = randi(2,1,5); temp(temp(:)==2)=-1;
    TRAIN(prac).majo_arrangement = temp;
    
    outcome = sum(TRAIN(prac).majo_arrangement(:)==-1);
    
    if outcome > 2
        TRAIN(prac).outcome = 'loss';
    else
        TRAIN(prac).outcome = 'win';
    end
end

for tr = 1:length(TRAIN)
    %% ANNOUNCE THE STAKE
    
    switch TRAIN(tr).stake_level
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
    
    %% DRAW THE MACHINE
    
    Screen('FillRect', cfg.win_ptr, cfg.black);
    
    % Display stake visually
    DrawFormattedText(cfg.win_ptr, TRAIN(tr).stake_level, 'center',...
        cfg.yCentre + cfg.height * -0.2, cfg.white);
    
    % Draw the machine and windows to the screen
    Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
        (windows.allRects), 6);
    Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
    
    % Display broken screen(s) for this trial (cross or grey)
    if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
        for w_i = find(TRAIN(tr).info_arrangement==0)
            Screen('FillRect', cfg.win_ptr, wB.colour, ...
                [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
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
    
    Screen('Flip',cfg.win_ptr);
    
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
                if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
                    for w_i = find(TRAIN(tr).info_arrangement==0)
                        Screen('FillRect', cfg.win_ptr, wB.colour, ...
                            [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                    end
                end
                
                % Highlight text
                if response_side == 0 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    TRAIN(tr).stake_decision = 'accept';
                    stop(audio_samples.accept)
                    play(audio_samples.accept)
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'ACCEPT')
                    
                    TRAIN(tr).stake_decision = 'reject';
                    
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(3) - cfg.reject_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    
                elseif response_side == 0 && strcmp(subj.selection_side{1},'REJECT')
                    
                    TRAIN(tr).stake_decision = 'reject';
                    
                    stop(audio_samples.reject)
                    play(audio_samples.reject)
                    
                    [~,~,reject_box]= DrawFormattedText(cfg.win_ptr, 'NO', ...
                        machine.allRects(1)+ narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.highlight);
                    [~,~,accept_box]= DrawFormattedText(cfg.win_ptr, 'YES', ...
                        machine.allRects(3) - cfg.accept_bounds(3) - narrowing, ...
                        cfg.yCentre + cfg.height * 0.22, cfg.white);
                    
                elseif response_side == 1 && strcmp(subj.selection_side{1},'REJECT')
                    
                    TRAIN(tr).stake_decision = 'accept';
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
                
                WaitSecs(0.8);
                
                TRAIN(tr).reward = 0;
                TRAIN(tr).stake_decision_RT = this_time - start_timer;
                break
            end
        end
        
        if (toc(time_elapsed)-cfg.stake_decision) > 0
            TRAIN(tr).stake_decision = NaN;
            TRAIN(tr).stake_decision_RT = cfg.stake_decision;
            
            WaitSecs(0.8);
            
            break
        end
    end
    
    %% ACCEPTED or REJECTED?
    if strcmp(TRAIN(tr).stake_decision,'accept')
        % Participant has accepted stake: view the dynamic machine
        
        % Determine random index for non-instrumental faces
        indx = randi(2,1,length(TRAIN(tr).info_arrangement));
        
        for window = 1:length(TRAIN(tr).info_arrangement)
            
            emoji_stream = TRAIN(tr).info_arrangement(1:window);
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            % Display broken screen(s) for this trial (cross or grey)
            if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
                for w_i = find(TRAIN(tr).info_arrangement==0)
                    Screen('FillRect', cfg.win_ptr, wB.colour, ...
                        [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                end
            end
            
            for slot = 1:length(emoji_stream)
                
                switch emoji_stream(slot)
                    case 0
                        this_face = face_options{indx(slot)}; %#ok<*NODEF>
                    case 1
                        if TRAIN(tr).majo_arrangement(slot) == 1
                            this_face = cfg.emoji.positive;
                        elseif TRAIN(tr).majo_arrangement(slot) == -1
                            this_face = cfg.emoji.negative;
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
            
        end
        
        %% Present the WIN or LOSS
        
        Screen('FillRect', cfg.win_ptr, cfg.black);
        Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
        
        if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
            for w_i = find(TRAIN(tr).info_arrangement==0)
                Screen('FillRect', cfg.win_ptr, wB.colour, ...
                    [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
            end
        end
        
        for slot = 1:length(emoji_stream)
            
            switch emoji_stream(slot)
                case 0
                    this_face = face_options{indx(slot)};
                case 1
                    if TRAIN(tr).majo_arrangement(slot) == 1
                        this_face = cfg.emoji.positive;
                    elseif TRAIN(tr).majo_arrangement(slot) == -1
                        this_face = cfg.emoji.negative;
                    end
            end
            
            Screen('DrawTexture',cfg.win_ptr, this_face,[],...
                CenterRect([0 0 face_dim face_dim],windows.allRects(:,slot)'));
            
        end
        
        Screen('FrameRect', cfg.win_ptr, windows.baseColours, ...
            (windows.allRects), 6);
        
        if strcmp(TRAIN(tr).outcome,'win')
            outcome_string = ['You win ' TRAIN(tr).stake_level];
            audio = audio_samples.winSound;
        else
            outcome_string = ['You lose ' TRAIN(tr).stake_level];
            audio = audio_samples.loseSound;
        end
        
        DrawFormattedText(cfg.win_ptr, outcome_string, 'center', ...
            cfg.yCentre + cfg.height * 0.22, cfg.white);
        
        Screen('Flip',cfg.win_ptr);
        stop(audio);
        play(audio);
        
        % Find where the blank space separating the reward from 'cents'
        num_find = strfind(TRAIN(tr).stake_level,' ');
        if strcmp(TRAIN(tr).outcome,'win')
            TRAIN(tr).reward = str2double(TRAIN(tr).stake_level(1:num_find-1));
        else
            TRAIN(tr).reward = -str2double(TRAIN(tr).stake_level(1:num_find-1));
        end
        
        WaitSecs(cfg.outcome_reveal);
        
        if USE_winnings
            
            increments = TRAIN(tr).reward/10;
            kitty_num = sum([TRAIN(1:tr-1).reward],'omitnan')/100;
            
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
                    if TRAIN(tr).reward > 0
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
        if isnan(TRAIN(tr).stake_decision)
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            wait_string = 'Too slow! Please wait until next stake is prepared.';
            DrawFormattedText(cfg.win_ptr, wait_string, 'center', ...
                'center', cfg.white);
            Screen('Flip',cfg.win_ptr);
            stop(audio_samples.loseSound);
            play(audio_samples.loseSound);
            
            WaitSecs(cfg.too_slow);
            
        elseif strcmp(TRAIN(tr).stake_decision,'reject')
            % Play out the trial but with neutral faces
            
            for window = 1:length(TRAIN(tr).info_arrangement)
                
                Screen('FillRect', cfg.win_ptr, cfg.black);
                Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
                
                % Display broken screen(s) for this trial (cross or grey)
                if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
                    for w_i = find(TRAIN(tr).info_arrangement==0)
                        Screen('FillRect', cfg.win_ptr, wB.colour, ...
                            [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
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
                
                WaitSecs(cfg.window_reveal);
                
            end
            
            %% Present the WIN or LOSS
            
            Screen('FillRect', cfg.win_ptr, cfg.black);
            Screen('FrameRect', cfg.win_ptr, machine.baseColours, machine.allRects, 4);
            
            if ~isempty(find(TRAIN(tr).info_arrangement==0,1))
                for w_i = find(TRAIN(tr).info_arrangement==0)
                    Screen('FillRect', cfg.win_ptr, wB.colour, ...
                        [wB.xStart(w_i),wB.yStart(w_i),wB.xEnd(w_i),wB.yEnd(w_i)]);
                end
            end
            
            for slot = 1:length(TRAIN(tr).info_arrangement)
                
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
            
            WaitSecs(cfg.outcome_reveal);
            
            if USE_winnings
                
                num_find = strfind(TRAIN(tr).stake_level,' ');
                sound_match = str2double(TRAIN(tr).stake_level(1:num_find-1));
                
                increments = sound_match/10;
                kitty_num = sum([TRAIN(1:tr-1).reward],'omitnan')/100;
                
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
    
    %% INTERTRIAL SCREEN
    time_elapsed = tic;
    while (toc(time_elapsed)-cfg.intertrial_time) < 0
        Screen('FillRect', cfg.win_ptr, cfg.window_colour);
        Screen('Flip', cfg.win_ptr);
    end
    
end

%% SAVE TEMP FILE
% Saved data up to the latest trial of the current block
trial_file = [subj.ID '_' subj.initials '_training'];
save([subj.save_location trial_file '.mat'],'TRAIN')

final_take = sum([TRAIN(:).reward],'omitnan')/100;
if final_take < 0
    fin_tex = sprintf('\nThe training take was: -$%0.2f\n',abs(final_take));
else
    fin_tex = sprintf('\nThe training take was: $%0.2f\n',final_take);
end
disp(fin_tex)

end