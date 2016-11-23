load coeffs

x = [ 0 1 1 0 0.5 0.7 0 0.3 1 2 0 6 7 8 3 4 3 2 ];

y = jzlk_fwtDirect(x, haar);

xhat = jzlk_ifwtDirect(y,haar);

diff = x - xhat