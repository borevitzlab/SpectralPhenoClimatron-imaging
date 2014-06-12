function coordinates = fitUnitLattice ( unitLatCoor, realLatCoor )
    % Global to use them in minLatticeCorrespondance
    global unitLat realLat;

    % create temp coordinates
    [unitLat, realLat] = initWorkingLats ( unitLatCoor, realLatCoor );

    % Create the constrant matrix
    [A, b] = createConstraints ( unitLat, realLat );

    x0 = [0.00001; 0.000001; 0.000001; 0.99999];
    options = optimoptions('fmincon', 'Algorithm', 'interior-point');
    [coordinates,fval] = fmincon(@minLatticeCorrespondance,x0,A,b, ...
                                    [],[],[],[],[], options);

    % FIXME: Calc the init vector depending on the {unit,real}LatCoor vars
%    a = fminsearch(@minLatticeCorrespondance,[0,0,0,1]);
%
%    trans = [a(1) a(2)];o
%    theta = a(3);
%    scale = a(4);
%    fittedLat = getFittedLattice ( unitLatCoor, trans, theta, scale )

end

% Assume v = [x,y, theta, scale]. (x,y) is translation, theta is rotation
function [A, b] = createConstraints ( unitLat, realLat );

    % The max scale factor
    % FIXME, calculated it with width and height
    msf = 1.2;

    % max translation in x
    % FIXME, calculate it with the unitLat and realLat relation.
    mtx = 400;

    % max tranlation in y
    % FIXME, calculate it with the unitLat and realLat relation.
    mty = 400;

    % max angle change
    mac = pi/60;

    A = [  0  0  0 -1; ...
           0  0  0  1; ...
           0  0  1  0; ...
           0  0 -1  0; ...
           1  0  0  0; ...
           0  1  0  0; ...
          -1  0  0  0; ...
           0 -1  0  0 ];

    b = [ -1; msf; mac; -mac; mtx; mty; 0; 0 ];
end

function [unitLat, realLat] = initWorkingLats ( unitLatCoor, realLatCoor )

    % Create unit lattice
    x = [0 230 460 690 950 1210 1440 1670 1930 2190 ...
            2420 2650 2910 3170 3400 3630 3860];
    y = [0 230 460 690 920 1180 1440 1670 1900 2130 2360];

    unitLatCoor = [];
    for ( i=1:size(y,2) )
         unitLatCoor = vertcat(unitLatCoor, [x; ones(1,size(x,2))*y(i)]');
    end

    % Make unit lattice as big as real lattice
    rlW = abs(max(realLatCoor(:,1))-min(realLatCoor(:,1)));
    rlH = abs(max(realLatCoor(:,2))-min(realLatCoor(:,2)));
    unW = abs(max(unitLatCoor(:,1))-min(unitLatCoor(:,1)));
    unH = abs(max(unitLatCoor(:,2))-min(unitLatCoor(:,2)));
    ratW = rlW/unW;
    ratH = rlH/unH;
    unitLatCoor = unitLatCoor * min(ratW,ratH);

    % Center on gravitational center. Assume positive coords.
    c = [ round((max(realLatCoor(:,1))+min(realLatCoor(:,1)))/2) ...
          round((max(realLatCoor(:,2))+min(realLatCoor(:,2)))/2) ];
    rlCenterTrans = [1 0 0; 0 1 0; -c(1) -c(2) 1];
    realLatCoor(:,3)=1;
    realLat = realLatCoor*rlCenterTrans;

    c = [ round((max(unitLatCoor(:,1))+min(unitLatCoor(:,1)))/2) ...
          round((max(unitLatCoor(:,2))+min(unitLatCoor(:,2)))/2) ];
    ulCenterTrans = [1 0 0; 0 1 0; -c(1) -c(2) 1];
    unitLatCoor(:,3)=1;
    unitLat = unitLatCoor*ulCenterTrans;
end

function accumDist = minLatticeCorrespondance ( args )

    global unitLat;
    unitLat_ = unitLat;
    global realLat;
    realLat_ = realLat;

    trans(1) = args(1);
    trans(2) = args(2);
    theta = args(3);
    scale = args(4);

    % 1. Apply scaling
    unitLat_ = unitLat_ * scale;

    % 2. Apply translation
    ulAdjustT = [1,0,trans(1); 1,1,trans(2); 0,0,1];
    unitLat_ = unitLat_ * ulAdjustT;

    % 3. Apply rotation
    ulAdjustR = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1];
    unitLat_ = unitLat_ * ulAdjustR;

    % 4. Accumulate the distances.
    accumDist = sum( sqrt( (unitLat_(:,1)-realLat_(:,1)).^2 ...
                           + (unitLat_(:,2)-realLat_(:,2)).^2 ) );
end
