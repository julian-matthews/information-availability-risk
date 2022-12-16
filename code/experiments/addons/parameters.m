function [audio,cfg] = parameters( USE_debug, USE_synctest )
% `parameters.m` loads the parameters required to run the STAKED BANDIT exp
% so it can be displayed on the current screen. It also initiates
% PsychToolBox and opens a window for the experiment to take place.

%% INITIALISE SCREEN

% Window size
cfg.window_size = [];

% Select screen
cfg.screens = Screen('Screens');

if size(cfg.screens,2) == 1
    % Subsets window on main screen for single-monitor setups
    cfg.window_size = [10 10 1150 750];
end

cfg.computer = Screen('Computer');
cfg.version = Screen('Version');

% Screen setup using Psychtoolbox is notoriously clunky in Windows,
% particularly for dual-monitors. This relates to the way Windows handles
% multiple screens (it defines a 'primary display' independent of
% traditional numbering) and numbers screens in the reverse order to
% Linux/Mac.

% The 'isunix' function should account for the reverse numbering but if
% you're using a second monitor you will need to define a 'primary display'
% using the Display app in your Windows Control Panel. See the psychtoolbox
% system reqs for more info: http://psychtoolbox.org/requirements/#windows

if isunix
    if USE_debug
        cfg.screen_num = max(cfg.screens);
    else
        cfg.screen_num = min(cfg.screens); % Attached monitor
        % cfg.screen_num = max(cfg.screens); % Main display (eg, laptop)
    end
else
    if USE_debug
        cfg.screen_num = min(cfg.screens);
    else
        cfg.screen_num = max(cfg.screens);
        % cfg.screen_num = min(cfg.screens);
    end
end

% Define colours
cfg.white = WhiteIndex(cfg.screen_num);
cfg.black = BlackIndex(cfg.screen_num);
cfg.gray = round((cfg.white + cfg.black)/2);
cfg.highlight = [255 255 0]; % Yellow RGB

% Fix for unexpected contrast settings
if round(cfg.gray) == cfg.white
    cfg.gray = cfg.black;
end

cfg.window_colour = cfg.black;

% Used to debug syncerrors
if ~USE_synctest
    Screen('Preference', 'SkipSyncTests', 1);
end

%('OpenWin', WinPtr, WinColour, WinRect, PixelSize, AuxBuffers, Stereo)
[cfg.win_ptr, cfg.win_rect] = Screen('OpenWindow', ...
    cfg.screen_num, cfg.window_colour, cfg.window_size, [], 2, 0);

% Find window size
[cfg.width, cfg.height] = Screen('WindowSize', cfg.win_ptr);

% Define center X & Y
[cfg.xCentre , cfg.yCentre] = RectCenter(cfg.win_rect);

% Font
cfg.standard_font = 'Courier';
cfg.instruct_font = 'Arial';
Screen('TextFont', cfg.win_ptr, cfg.standard_font);

% Text size
cfg.text_size = 40;
cfg.minor_text = 30;
Screen('TextSize', cfg.win_ptr, cfg.text_size);

cfg.frame_rate = Screen('NominalFrameRate', cfg.win_ptr,1);

% Estimate of monitor flip interval for specified window
[cfg.flip_interval, cfg.flip_samples, cfg.flip_stddev]...
    = Screen('GetFlipInterval', cfg.win_ptr);

%% CORE PRESENTATION INTERVALS

% Time to make A/R decision
cfg.stake_decision = 5;

% Dynamic reveal timing
if USE_debug
    % cfg.window_reveal = .1;
    cfg.window_reveal = 1;
else
    cfg.window_reveal = 1;
end

% Time to view outcome
if USE_debug
    % cfg.outcome_reveal = .5;
    cfg.outcome_reveal = 1.5;
else
    cfg.outcome_reveal = 1.5;
end

% Interval to wait upon REJECT decision (dynamic reveals + outcome timing)
cfg.reject_wait = (cfg.window_reveal*5)+cfg.outcome_reveal;

% Minimum amount of time to wait before decision response can be recorded
% In seconds (currently set to 10ms)
cfg.input_minimum = 0.001;

% Interval to wait for a 'Too Slow' response
cfg.too_slow = 2;

% Intertrial interval
cfg.intertrial_time = 0.6;

%% RESPONSE KEYBOARD SETTINGS

KbName('UnifyKeyNames')

% Can change this to response box or whatever keys
cfg.leftKey = KbName('LeftArrow');
cfg.rightKey = KbName('RightArrow');
cfg.fatigueKey = KbName('LeftControl');

%% MEASURES DEGREES VISUAL ANGLE
[x,y] = Screen('DisplaySize',cfg.win_ptr);
cfg.xDimCm = x/10;
cfg.yDimCm = y/10;

% Expect participant to be sitting 60cm from screen (visual angle test)
cfg.distanceCm = 60;

% Calculate visual angle
% Unintutitive order of operations but have confirmed #ok
cfg.visualAngleDegX = atan(cfg.xDimCm/(2*cfg.distanceCm))/pi*180*2;
cfg.visualAngleDegY = atan(cfg.yDimCm/(2*cfg.distanceCm))/pi*180*2;

% Calculate visual angle per degree
cfg.visualAnglePixelPerDegX = cfg.width/cfg.visualAngleDegX;
cfg.visualAnglePixelPerDegY = cfg.height/cfg.visualAngleDegY;

% Usually mean pixels per degree is reported in papers
cfg.pixelsPerDegree = mean([cfg.visualAnglePixelPerDegX,...
    cfg.visualAnglePixelPerDegY]);

%% Determine size of texboxes

[~,~,cfg.accept_bounds] = DrawFormattedText(cfg.win_ptr, 'YES');

[~,~,cfg.reject_bounds] = DrawFormattedText(cfg.win_ptr, 'NO');

%% LOAD INSTRUCTION IMAGES & MAKE TEXTURES

image_location = 'addons/instructions/';

instruct_gamble = imread([image_location 'instructions_gamble.png']);
cfg.instruct.gamble = Screen('MakeTexture',cfg.win_ptr,...
    instruct_gamble);

intermission = imread([image_location 'intermission.png']);
cfg.instruct.intermission = Screen('MakeTexture',cfg.win_ptr,...
    intermission);

%% LOAD EMOJIS & MAKE TEXTURES
% Not the most efficient method but it's effective

emoji_location = 'addons/emojis/';

emoji_img.positive = imread([emoji_location 'positive.png']);
emoji_img.negative = imread([emoji_location 'negative.png']);
emoji_img.neutral = imread([emoji_location 'neutral.png']);

cfg.emoji.positive= Screen('MakeTexture',cfg.win_ptr,...
    emoji_img.positive);
cfg.emoji.negative = Screen('MakeTexture',cfg.win_ptr,...
    emoji_img.negative);

cfg.emoji.neutral = Screen('MakeTexture',cfg.win_ptr,...
    emoji_img.neutral);

%% LOAD SOUNDS into AUDIOPLAYER

audio_location = 'addons/audio/';

[winY,winFS] = ...
    audioread([audio_location 'register_hires.wav']);
audio.winSound = audioplayer(winY,winFS);

[loseY,loseFS] = ...
    audioread([audio_location 'tooslow.wav']);
audio.loseSound = audioplayer(loseY,loseFS);

[neutY,neutFS] = ...
    audioread([audio_location 'reveal.wav']);
audio.neutSound = audioplayer(neutY,neutFS);

[coinY,coinFS] = ...
    audioread([audio_location 'accept.wav']);
audio.accept = audioplayer(coinY,coinFS);

[nopeY,nopeFS] = ...
    audioread([audio_location 'reject.wav']);
audio.reject = audioplayer(nopeY,nopeFS);

[s10Y,s10FS] = ...
    audioread([audio_location '10_cents.wav']);
audio.stake10 = audioplayer(s10Y,s10FS);

[s20Y,s20FS] = ...
    audioread([audio_location '20_cents.wav']);
audio.stake20 = audioplayer(s20Y,s20FS);

[s30Y,s30FS] = ...
    audioread([audio_location '30_cents.wav']);
audio.stake30 = audioplayer(s30Y,s30FS);

[s40Y,s40FS] = ...
    audioread([audio_location '40_cents.wav']);
audio.stake40 = audioplayer(s40Y,s40FS);

[s50Y,s50FS] = ...
    audioread([audio_location '50_cents.wav']);
audio.stake50 = audioplayer(s50Y,s50FS);

[neuY,neuFS] = ...
    audioread([audio_location 'neutral_outcome.wav']);
audio.neut_outcome = audioplayer(neuY,neuFS);

[brokY,brokFS] = ...
    audioread([audio_location 'broken_0.wav']);
audio.brokSound = audioplayer(brokY,brokFS);

[coiY,coiFS] = ...
    audioread([audio_location 'load_coin.wav']);
audio.load_coin = audioplayer(coiY,coiFS);

[goingY,goingFS] = ...
    audioread([audio_location 'win.wav']);
audio.go_time = audioplayer(goingY,goingFS);

for brokens = 1:4
    % temp = sprintf('brok%g',brokens);
    [brokY,brokFS] = ...
        audioread([audio_location ['broken_d' num2str(brokens) '.wav']]);
    audio = setfield(audio,'brokd',{brokens},audioplayer(brokY,brokFS)); %#ok<*TNMLP>
    
    [brokY,brokFS] = ...
        audioread([audio_location ['broken_u' num2str(brokens) '.wav']]);
    audio = setfield(audio,'broku',{brokens},audioplayer(brokY,brokFS));
end

end