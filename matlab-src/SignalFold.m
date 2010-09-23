function [y,n] = SignalFold(x,n)
% implements y(n) = x(-n)
% [y,n] = SignalFold(x,n)
y = fliplr(x); n = -fliplr(n);
