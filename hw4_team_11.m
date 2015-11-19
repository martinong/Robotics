%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 4
%
% Team number: 11
% Team leader: Martin Ong (mo2454)
% Team members: Phillip Godzin (pgg2105), Alice Chang (avc2120)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% main function
function  hw4_team_11(serPort)
    global position;                                % Position of robot
    global a;                                       % Angle change
    global Total_Distance; Total_Distance = 0;      % Total distance traveled
    global diameter; diameter = 0.35;    
%     global fh_pos; fh_pos = figure(); hold on;      % Figure for plotting position

    % IMPORTANT: Set this to the file containing the path points
    file_of_path = strcat(pwd,'/path.txt');

    % Read paths from file
    path = readtable(file_of_path,'Delimiter',' ','ReadVariableNames',false);
    path = table2array(path);
    
    % Set initial position and direction (facing positive y)
    position = path(1,:);
    a = pi/2;
    
    % Go to each position in the path
    for i = 2:size(path,1)
        goTo(serPort, path(i,:));
    end
    
    % Stop
    SetFwdVelRadiusRoomba(serPort, 0, 2);
    
end

%% Go to a destination in a straight line
function goTo(serPort, destination)
    global position a;
    % Initialize direction to arbitrary value whose norm is > 0.05
    direction = [1 0];
   
    while norm(direction) > 0.05
           
        % Find the straight line path to destination
        direction = destination - position;
        % Find angle to destination
        angle = atan2(direction(2),direction(1));

        % Turn to within 10 degree
        while mod(abs(angle - a),2*pi) > (10/180*pi)
            angleTurnd = (angle-a)/pi*180;
            turnAngle(serPort, 0.15, angleTurnd);
            pause(0.1);
            update(serPort);
        end

        % Move forward until close to destination
        SetFwdVelRadiusRoomba(serPort, 0.15, Inf);
        pause(0.1);
        update(serPort);
        
        % If wall hit, then use part of Bug2 algorithm to go around obstacle
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
        if (BumpRight || BumpLeft || BumpFront)
            WallFollow(serPort, direction);
        end
        
    end
    
    % Stop
    SetFwdVelRadiusRoomba(serPort, 0, 2);
end

%% Wall Follow until reaches m-line of direction
function WallFollow(serPort, direction)
    % Variable Declaration
    global position Total_Distance;
    WF_Start_Pos = position;
    WF_Start_Dist = Total_Distance;

    % Continue until the robot reaches m-line and has travelled far enough
    while distBtwLinePoint(position-WF_Start_Pos, direction) > 0.25 ...
            || Total_Distance - WF_Start_Dist < 0.5
        
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
        WallSensor = WallSensorReadRoomba(serPort);                 % Read Wall Sensor, Requires WallsSensorReadRoomba file

        isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;     % Check if the robot is in a bumped state

        if(isCurrentlyBumped)
            % While the robot is being bumped, turn left until it is no longer being bumped.
            turnAngle(serPort, 0.1, 20);
        elseif (WallSensor)
            % If it is against a wall and not being bumped, continue moving forward.
            SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        else
            % If there is no wall to the right, make a half-circle turn (round the corner) to the right looking
            % for another wall.
            SetFwdVelRadiusRoomba(serPort, 0.1, -0.2);
        end
        
        update(serPort);
        pause(0.05);
    end
    
    SetFwdVelRadiusRoomba(serPort, 0, 2);
    
end

%% Distance between line and point
function d = distBtwLinePoint(point, line)
    % line is a vector from 0,0
    % point is the vector from 0,0 to that point
    d = norm(cross([line,0],[point,0]))/norm([line,0]);
end

%% Update the total distance travelled and position.
function update(serPort)
    global position a Total_Distance;
%     global fh_pos;
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    [dr,dc] = size(d);
    [ar,ac] = size(a);
    if (dr && dc && ar && ac)
        position = position + [d*cos(a), d*sin(a)];
%         figure(fh_pos);
%         plot(position(1), position(2), 'bo');
    end
    Total_Distance = Total_Distance + d;
end