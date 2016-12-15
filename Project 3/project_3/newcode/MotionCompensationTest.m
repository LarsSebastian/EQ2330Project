%% Test jzlk_entropy2
B = [ 1 87 2 9 4 5 2 1 1 9 4 2];

% The expected result are
% pdf = [ 1/4 1/4 1/6 1/ 12 1/6 1/12]
% entropy = 2.4591
entropy = jzlk_entropy2(B);


%% Test jzlk_findMotionVec 

A = [   1 5 4 3 8 2; ...
        9 2 0 7 4 3; ...
        1 2 8 3 4 6; ...
        9 8 7 6 3 4; ...
        1 7 4 9 2 6; ...
        0 1 6 2 8 4 ]

% expected result: motionVec=[0 1], residual = zeros, only 1 in bottom
% right corner
block = [ 4 3 8; 0 7 4; 8 3 3]
pos = [1 2]
[motionVec, residual] = jzlk_findMotionVec(A, block, pos)
