%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 1
%
% Team number: 11
% Team leader: Martin Ong (mo2454)
% Team members: Phillip Godzin (pgg2105), Alice Chang (avc2120)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% main function
function  hw3_team_11(serPort)
    global time; time = tic;                                      % time since last update
    global keySet; keySet =   {};
    global valueSet; valueSet = [];
    global map; map = containers.Map(keySet,valueSet)
    global displacement; displacement = [0,0];                               % x and y displacement from first wall bump
    global a; a = 0;                                              % angle change since first wall bump
    global Total_Distance; Total_Distance = 0;
    %spiral until hit
    
    spiral(serPort);
    while(toc(time) < 300)
        if(isKey(map, [x,y]) && map([x,y]) == 2)
            randomBounce(serPort);
        end
        if(~isKey(map, [x,y]))
            wallFollow(serPort);
        end
    end
%     rect(map);
end

function spiral(serPort)

    bumped = false;
    radius = 0.05;
    while (~bumped)
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        SetFwdVelRadiusRoomba(serPort, 0.2, radius);
        pause(0.05);
        bumped = BumpRight || BumpLeft || BumpFront;
        radius = min(radius + 0.005, 2);  
        update(serPort);
        if(~isKey(map, [x,y]))
            map = updateMap(1);
        end
    end
    pause(0.1);

end

function WallFollow(serPort)
% Variable Declaration
hasBeenBumped = false;                              % Has the robot hit a wall yet or still looking for the first

% fig = figure();                                   % Figure for plotting path
% hold on;

% Continue until the robot is sufficiently close to where it initially hit the wall and has travelled far enough
while sqrt(displacement(1)^2 + displacement(2)^2) > 0.25 || Total_Distance < 1
%     plot(displacement(1), displacement(2), 'bo');             % Plots path
    [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
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
        update(serPort);
    elseif (WallSensor)
        % If it is against a wall and not being bumped, continue moving forward.
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        update(serPort);
    else
        % If there is no wall to the right, make a half-circle turn (round the corner) to the right looking
        % for another wall.
        SetFwdVelRadiusRoomba(serPort, 0.1, -0.2);
        update(serPort);
    end
    pause(0.05);
    updateMap(2);
end

SetFwdVelRadiusRoomba(serPort, 0, 2);                                       % Stop the Robot

end


function randomBounce(serPort)
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;
    
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;
    if (isCurrentlyBumped)
        randomAngle = rand * 180 + 90;
        turnAngle(serPort, 0.4, randomAngle);
    else
        SetFwdVelRadiusRoomba(serPort, 0.4, inf);
    end
    pause(0.05);
    update(serPort);
    if(~isKey(map, [x,y]))
        updateMap(1);
    end

end
% Update the total distance travelled and displacement.
function update(serPort)
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    [dr,dc] = size(d);
    [ar,ac] = size(a);
    if (dr && dc && ar && ac)
        displacement = displacement + [d*cos(a), d*sin(a)];
    end
    Total_Distance = Total_Distance + d;
end

function rect(m)
figure();
for i=1:size(m, 1)
    for j = 1:size(m, 2)
        if (m(i, j) == 0)
            rectangle('position',[i * 0.4 j * .4 (i+1) * 0.4 (j+1)*.4],'facecolor','black');
        elseif (m(i, j) == 1)
            rectangle('position',[i * 0.4 j * .4 (i+1) * 0.4 (j+1)*.4],'facecolor','y');
        else
            rectangle('position',[i * 0.4 j * .4 (i+1) * 0.4 (j+1)*.4],'facecolor','r');
        end
    end
end
end

function updateMap(val)
    diameter = 0.4;
    x = ceil(displacement(1)/diameter);
    y = ceil(displacement(2)/diameter);
    if(~isKey(map, [x,y]) || map([x,y]) ~= val)
    	time = tic;
    end
    map([x,y]) = val;
end