function [y,n] = SignalShift(x,m,n0)
% implements y(n) = x(n-n0)
% [y,n] = SignalShift(x,m,n0)
n = m+n0; y = x;