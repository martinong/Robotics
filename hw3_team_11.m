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
    global keySet; keySet =   {'0,0'};
    global valueSet; valueSet = 1;
    global map; map = containers.Map(keySet,valueSet);
    global displacement; displacement = [0,0];                               % x and y displacement from first wall bump
    global a; a = 0;                                              % angle change since first wall bump
    global Total_Distance; Total_Distance = 0;
    
    global fh_pos; fh_pos = figure();                             % Figure for plotting path
    hold on;
    global fh_rect; fh_rect = figure();
    
    %spiral until hit
    spiral(serPort);
    
    while(toc(time) < 10) % Stop if map doesn't get updated within 30 sec.
        if(isKey(map, toChar(displacement(1),displacement(2))) && ...
                 map(toChar(displacement(1),displacement(2))) == 2)
            display('BOUNCE BOUNCE BOUNCE BOUNCE BOUNCE BOUNCE BOUNCE BOUNCE BOUNCE!');
            randomBounce(serPort);
            display('END RANDOM BOUNCE');
        elseif(~isKey(map, toChar(displacement(1),displacement(2))))
            display('START WALL FOLLOW');
            WallFollow(serPort);
            display('END WALL FOLLOW');
            randomBounce(serPort)
            display('END RANDOM BOUNCE AFTER WALL FOLLOW');
        end
        
%         pause(0.05);
    end
    SetFwdVelRadiusRoomba(serPort, 0, 2);
    
    rect();
end

%% Spiral
function spiral(serPort)
    disp('SPIRAL');
    global map displacement;
    bumped = false;
    radius = 0.1;
    while (~bumped)
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        SetFwdVelRadiusRoomba(serPort, 0.2, radius);
        pause(0.05);
        bumped = BumpRight || BumpLeft || BumpFront;
        radius = min(radius + 0.005, 2);  
        update(serPort);
        if(~isKey(map, toChar(displacement(1),displacement(2))))
            updateMap(1);
        end
    end
end

%% Wall Follow
function WallFollow(serPort)
    % Variable Declaration
    global displacement Total_Distance;
    Wall_Follow_Starting_Displacement = displacement;
    Wall_Follow_Starting_Distance = Total_Distance;

    % Continue until the robot is sufficiently close to where it initially hit the wall and has travelled far enough
    while sqrt((displacement(1) - Wall_Follow_Starting_Displacement(1))^2 + ...
            (displacement(2) - Wall_Follow_Starting_Displacement(2))^2) > 0.25 ...
            || Total_Distance - Wall_Follow_Starting_Distance < 0.3
        
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
        pause(0.05);
        update(serPort);
        updateMap(2);
    end

    
    randomAngle = rand * 90 + 45;
    turnAngle(serPort, 0.1, randomAngle);
    pause(0.1);

end

%% Bounce
function randomBounce(serPort)
%     randomAngle = rand * 180 + 90;
%     turnAngle(serPort, 0.1, randomAngle);
    
    % Go forward until bump
    bumped = false;
    while (~bumped)
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        pause(0.05);
        bumped = BumpRight || BumpLeft || BumpFront;
        update(serPort);
        updateMap(1);
    end
end

%% Update the total distance travelled and displacement.
function update(serPort)
    global displacement a Total_Distance fh_pos;
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    [dr,dc] = size(d);
    [ar,ac] = size(a);
    if (dr && dc && ar && ac)
        displacement = displacement + [d*cos(a), d*sin(a)];
    end
    Total_Distance = Total_Distance + d;
    
    figure(fh_pos);
    plot(displacement(1), displacement(2), 'bo');             % Plots path
    
    rect();
end

%% Plotting on map
function rect()
global map fh_rect;
figure(fh_rect);
diameter = 0.4;
keyset = keys(map);
points = zeros(length(keyset), 2);
for i=1:length(keyset)
   points(i, :) = toXY(keyset{i}); 
end
% minX = min(points(:, 1));
% minY = min(points(:, 2));
% maxX = max(points(:, 1));
% maxX = max(points(:, 2));
% width = maxX - minX;
% height = maxY - minY;
for i=1:size(points,1)
    x = points(i, 1);
    y = points(i, 2);
    if (map(toChar(x, y)) == 1)
        rectangle('position',[x*diameter, y*diameter, diameter, diameter],'facecolor','y');
    elseif (map(toChar(x, y)) == 2)
        rectangle('position',[x*diameter, y*diameter, diameter, diameter],'facecolor','r');
    end
end
end


%% Helper functions
function updateMap(val)
    global time map displacement;
    diameter = 0.4;
    x = round(displacement(1)/diameter);
    y = round(displacement(2)/diameter);
    % Add to map if robot reaches a point for the first time
    % or is replacing an observed point with a wall.
    if(~isKey(map, toChar(x,y)) || map(toChar(x,y)) == 1)
        map(toChar(x,y)) = val;
    	time = tic;
    end
end


function str = toChar(x, y)
str = strcat(num2str(x), ',', num2str(y));
end

function xy =  toXY(str)
p = strsplit(str, ',');
x = str2double(p{1});
y = str2double(p{2});
xy = [x y];
end