function  Homework1(serPort)

% Variable Declaration
tStart= tic;                                        % Time limit marker
maxDuration = 60;                                   % 20 seconds of max duration time
Initial_Distance = DistanceSensorRoomba(serPort);   % Get the Initial Distance
Total_Distance = 0;                                 % Initialize Total Distance
hasBeenBumped = false;
while toc(tStart) < maxDuration
    [ BumpRight, BumpLeft, WheelDropRight, WheelDropLeft, WheelDropCastor, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort); % Read Bumpers
    %       display(BumpLeft)                                % Display Left Bumper Value
    %       display(BumpRight)                               % Display Right Bumper Value
    %       display(BumpFront)                               % Display Front Bumper Value
    WallSensor = WallSensorReadRoomba(serPort);        % Read Wall Sensor, Requires WallsSensorReadRoomba file
    %       display(WallSensor)                              % Display WallSensor Value
    isCurrentlyBumped = BumpRight || BumpLeft || BumpFront;
    
    if(~hasBeenBumped)
        if (isCurrentlyBumped)
            hasBeenBumped = true;
        else
            SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        end
        display('1');
    elseif(isCurrentlyBumped)
        hasBeenBumped = true;
        turnAngle(serPort, 0.2, 10);
        display('2a');
    elseif (~isCurrentlyBumped && WallSensor)
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        display('2b');
    elseif (~WallSensor && hasBeenBumped)
        SetFwdVelRadiusRoomba(serPort, 0.2, -0.2);
    else
        display('now what');
    end
    pause(0.05);
    
    
    
    
    
    
    

%     if (isCurentlyBumped && WallSensor && hasBeenBumped)
%         % No Wall 
%         SetFwdVelAngVelCreate(serPort, 0.1, -0.3);
%         pause(0.005);
%         turnAngle(serPort, 0.1, -45);                 % Turn Left 90 degrees
%         display('no wall');
%     elseif (WallSensor && hasBeenBumped)           % Else the iRobot hasn't bumped into anything
%         SetFwdVelRadiusRoomba(serPort, 0.25, inf);       % Move Forward
%         %       Total_Distance = Total_Distance + DistanceSensorRoomba(serPort);    % Update the Total_Distance covered so far
%         display('straight');
%     elseif ( && WallSensor)     % If the iRobot Create Bumped on the Right
%         SetFwdVelRadiusRoomba(serPort, 0.1, inf);
%         hasBeenBumped = 1;
%     elseif (isCurentlyBumped && ~WallSensor)
%         turnAngle(serPort, 0.1, -5);
%         
%         hasBeenBumped = 1;
%         display('bumped');
%     else
%         SetFwdVelRadiusRoomba(serPort, 0.1, inf);
%         pause(0.5);
%     end
%     pause(0.1);
end
SetFwdVelRadiusRoomba(serPort, 0, 2);                                       % Stop the Robot

end