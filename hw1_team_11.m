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
function  hw1_team_11(serPort)

% Variable Declaration
Initial_Distance = DistanceSensorRoomba(serPort);   % Get the Initial Distance
Total_Distance = 0;                                 % Initialize Total Distance
hasBeenBumped = false;                              % Has the robot hit a wall yet or still looking for the first
displacement = [0,0];                               % x and y displacement from first wall bump
a = 0;                                              % angle change since first wall bump

% Continue until the robot is sufficiently close to where it initially hit the wall and has travelled far enough
while sqrt(displacement(1)^2 + displacement(2)^2) > 0.25 || Total_Distance < 1
    display(sqrt(displacement(1)^2 + displacement(2)^2));
    display(Total_Distance);
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);        % Read Wall Sensor, Requires WallsSensorReadRoomba file

    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;     % Check if the robot is in a bumped state
    
    if(~hasBeenBumped)
        % If the robot hasn't hit a wall yet, continue going straight.
        % Once it hits for the first time, start keeping track of the distance and displacement.
        if (isCurrentlyBumped)
            DistanceSensorRoomba(serPort);
            AngleSensorRoomba(serPort);
            hasBeenBumped = true;
        else
            SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        end
    elseif(isCurrentlyBumped)
        % While the robot is being bumped, turn left until it is no longer being bumped.
        hasBeenBumped = true;
        turnAngle(serPort, 0.2, 5);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    elseif (~isCurrentlyBumped && WallSensor)
        % If it is against a wall and not being bumped, continue moving forward.
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    elseif (~WallSensor && hasBeenBumped)
        % If there is no wall to the right, make a half-circle turn (round the corner) to the right looking
        % for another wall.
        SetFwdVelRadiusRoomba(serPort, 0.2, -0.2);
        [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort);
    end
    pause(0.1);
end

SetFwdVelRadiusRoomba(serPort, 0, 2);                                       % Stop the Robot

end

% Update the total distance travelled and displacement.
function [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort)
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    displacement = displacement + [d*cos(a), d*sin(a)];
    Total_Distance = Total_Distance + d;
end
