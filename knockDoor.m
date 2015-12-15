function knockDoor(serPort)

hLow = .45;
hHigh = .85;
sLow =.15;
sHigh = .55;
vLow = .25;
vHigh = .65;

count = 0;

while true
    img = imread('http://192.168.0.100/img/snapshot.cgi?');
%     imshow(img);
    img_width = size(img, 2);
    hsv = rgb2hsv(img);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    hMask = (h >= hLow) & (h <= hHigh);
%     imshow(hMask);
    sMask = (s >= sLow) & (s <= sHigh);
%     imshow(sMask);
    vMask = (v >= vLow) & (v <= vHigh);
%     imshow(vMask);
    objMask = uint8(hMask & sMask & vMask);
    imshow(objMask);
    props = regionprops(bwlabel(objMask), 'area');
    maxArea = max([props.Area])
    minObjArea = maxArea - 1;
    % Look for door
    if (size(props, 1) == 0) || (maxArea < 25000)
        if(count < 6)
           turnAngle(serPort, 0.2, 57); % Should be 60 degrees, compensated for our robot's broken wheel
           count = count + 1;
           continue;
        else
            count = 0;
            SetFwdVelRadiusRoomba(serPort, 0.2, Inf);
            pause(5);
            SetFwdVelRadiusRoomba(serPort, 0, Inf);
            continue;
        end
    end
    objMask = uint8(bwareaopen(objMask, minObjArea));
    str_el = strel('disk', 25);
    objMask = imclose(objMask, str_el);
%     imshow(objMask, []);
%     hold on;
    props = regionprops(bwlabel(objMask), 'Centroid');
    centroid = props.Centroid;
    obj_x = centroid(1);
    plot(centroid(1), centroid(2), 'r*');
%     pause(.1);
    center_dist = obj_x - img_width/2;
    if (abs(center_dist) > 50)
        turnAngle(serPort, 0.1, -center_dist/10);
    else
        break;
    end

end

% Go forward until bump
% BumpRight = nan;
% BumpLeft = nan;
% BumpFront = nan;
[ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
while isnan(BumpRight) || isnan(BumpLeft) || isnan(BumpFront)
    [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
end
bumped = BumpRight || BumpLeft || BumpFront;
while (~bumped)
    [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    while isnan(BumpRight) || isnan(BumpLeft) || isnan(BumpFront)
        [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    end
    bumped = BumpRight || BumpLeft || BumpFront;
    if(bumped)
        SetFwdVelRadiusRoomba(serPort, -0.2, inf);
        pause(1);
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        pause(1.1);
        SetFwdVelRadiusRoomba(serPort, -0.2, inf);
        pause(1);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
%         BeepRoomba(serPort);
        
        % PLAY SONG
        f4 = 65;
        aes4 = 68;
        a4 = 69;
        c5 = 72;
        e5 = 76;
        f5 = 77;
        
        MEASURE = 80;
        HALF = MEASURE/2;
        Q = MEASURE/4;
        Ed = MEASURE*3/16;
        S = MEASURE/16;
        
        MEASURE_TIME = MEASURE/64;
        
        fwrite(serPort, [140, 0, 9, a4,Q, a4,Q, a4,Q, f4,Ed, c5,S, a4,Q, f4,Ed, c5,S, a4,HALF]);
        fwrite(serPort, [140, 1, 9, e5,Q, e5,Q, e5,Q, f5,Ed, c5,S, aes4,Q, f4,Ed, c5,S, a4,HALF]);
        fwrite(serPort, [141, 0]);
        pause(MEASURE_TIME*2.01);
        fwrite(serPort, [141, 1]);
        pause(MEASURE_TIME*2.01);
        % END PLAY SONG
        
        pause(4);
    end
    SetFwdVelRadiusRoomba(serPort, 0.2, inf);
    pause(0.05);
end
pause(4);
SetFwdVelRadiusRoomba(serPort, 0, 2);
end
