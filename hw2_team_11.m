%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 2
%
% Team number: 11
% Team leader: Martin Ong (mo2454)
% Team members: Phillip Godzin (pgg2105), Alice Chang (avc2120)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% main function
function  hw2_team_11(serPort)

Total_Distance = 0;                                 % Initialize Total Distance
displacement = [0,0];                               % x and y displacement from first wall bump
a = 0;                                              % angle change since first wall bump
fig = figure();                                     % Figure for plotting path
hold on;

% Plot straight line path to target in green
x=0:4;
y = zeros(size(x));
plot(x, y, 'g');

% Loop until target is reached
while sqrt((displacement(1)-4)^2 + displacement(2)^2) > 0.3 || Total_Distance < 1
    [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;     % Check if the robot is in a bumped state
    
    % Go straight until wall bump
    if (~isCurrentlyBumped)
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        pause(0.05);
    else
        % Follow wall until m-line reached
        [displacement, a] = followWall(serPort, displacement, a, Total_Distance);
    end
    
end

display('Target Reached');
SetFwdVelRadiusRoomba(serPort, 0, 2);      % Stop the Robot

end

function [displacement, a] = followWall(serPort, displacement, a, Total_Distance)
Wall_Follow_Starting_Displacement = displacement;
Wall_Follow_Starting_Distance = Total_Distance;
hasBeenBumped = false;                              % Has the robot hit a wall yet or still looking for the first

% Continue until the robot is sufficiently close to where it initially hit the wall and has travelled far enough
while sqrt(displacement(1)^2 + displacement(2)^2) > 0.25 || Total_Distance < .2
        
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);                 % Read Wall Sensor, Requires WallsSensorReadRoomba file

    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;     % Check if the robot is in a bumped state
    
    if(~hasBeenBumped)
        % If the robot hasn't hit a wall yet, continue going straight.
        % Once it hits for the first time, start keeping track of the distance and displacement.
        if (isCurrentlyBumped)
            DistanceSensorRoomba(serPort);
            AngleSensorRoomba(serPort);
            hasBeenBumped = true;
        else
            SetFwdVelRadiusRoomba(serPort, 0.5, inf);
        end
    elseif(isCurrentlyBumped)
        % While the robot is being bumped, turn left until it is no longer being bumped.
        hasBeenBumped = true;
        turnAngle(serPort, 0.1, 20);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    elseif (WallSensor)
        % If it is against a wall and not being bumped, continue moving forward.
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    else
        % If there is no wall to the right, make a half-circle turn (round the corner) to the right looking
        % for another wall.
        SetFwdVelRadiusRoomba(serPort, 0.1, -0.2);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort); 
    end
    
    % Reaches m-line
    if (abs(displacement(2)) < 0.15 && ...
            (Total_Distance - Wall_Follow_Starting_Distance) > 0.2 && ...
            displacement(1) > 0)
        if (displacement(1) < 4)
            turnAngle(serPort, 0.1, (-a)./(pi/180));
            break;  % Stop wall following
        elseif (a > 0) % if robot is moving towards the left
            turnAngle(serPort, 0.1, (a)./(pi/180));
            break;  % Stop wall following
        end
        % if robot is moving towards the right, keep following the wall
        % (ie. do nothing)
    end
    
    pause(0.05);
end

if (sqrt((displacement(1)-Wall_Follow_Starting_Displacement(1))^2 + ...
        (displacement(2)-Wall_Follow_Starting_Displacement(2))^2) < 0.25 ...
        && Total_Distance > 0.25)
    SetFwdVelRadiusRoomba(serPort, 0, 2);                               % Stop the Robot
    display('I AM STUCK. (Target cannot be reached)');                  % Robot is stuck and can't reach target
end

end

% Update the total distance travelled and displacement.
function [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort)
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    [dr,dc] = size(d);
    [ar,ac] = size(a);
    if (dr && dc && ar && ac)
        displacement = displacement + [d*cos(a), d*sin(a)];
    end
    Total_Distance = Total_Distance + d;
    
    % Plots path
    plot(displacement(1), displacement(2), 'bo','MarkerSize', 20);
    line([displacement(1), displacement(1) + 1/20 * cos(a)], ...
        [displacement(2), displacement(2) + 1/20 * sin(a)], ...
        'LineWidth', 1, 'Color', [0, 0, 0]);
end
