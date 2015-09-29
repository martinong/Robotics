%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 1
%
% Team number: put your team number here (e.g. 1)
% Team leader: e.g. Jane Smith (js1234)
% Team members: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% main function
function  hw1_team_11(serPort)

% Variable Declaration
Initial_Distance = DistanceSensorRoomba(serPort);   % Get the Initial Distance
Total_Distance = 0;                                 % Initialize Total Distance
hasBeenBumped = false;
displacement = [0,0];
a = 0;

while sqrt(displacement(1)^2 + displacement(2)^2) > 0.25 || Total_Distance < 1
    display(sqrt(displacement(1)^2 + displacement(2)^2));
    display(Total_Distance);
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    WallSensor = WallSensorReadRoomba(serPort);        % Read Wall Sensor, Requires WallsSensorReadRoomba file

    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;
    
    if(~hasBeenBumped)
        if (isCurrentlyBumped)
            DistanceSensorRoomba(serPort);
            AngleSensorRoomba(serPort);
            hasBeenBumped = true;
        else
            SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        end
    elseif(isCurrentlyBumped)
        hasBeenBumped = true;
        turnAngle(serPort, 0.2, 5);
        [a, displacement, Total_Distance] = ...
            update(a, displacement, Total_Distance, serPort);
    elseif (~isCurrentlyBumped && WallSensor)
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        [a, displacement, Total_Distance] = ...
            update(a, displacement, Total_Distance, serPort);
    elseif (~WallSensor && hasBeenBumped)
        SetFwdVelRadiusRoomba(serPort, 0.2, -0.2);
        [a, displacement, Total_Distance] = ...
            update(a, displacement, Total_Distance, serPort);
    end
    pause(0.1);
end

SetFwdVelRadiusRoomba(serPort, 0, 2);                                       % Stop the Robot

end


function [a, displacement, Total_Distance] = update(a, displacement, Total_Distance, serPort)
    d = DistanceSensorRoomba(serPort);
    a = a + AngleSensorRoomba(serPort);
    displacement = displacement + [d*cos(a), d*sin(a)];
    Total_Distance = Total_Distance + d;
end
