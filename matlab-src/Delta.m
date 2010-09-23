function [x,n] = Delta(n0,n1,n2)
% Generates x(n) = Delta(n-n0); n1<=n , n0<=n2
% [x,n] = Delta(n0,n1,n2)

if((n0<n1) | (n0 > n2) | (n1 > n2))
    error('arguments must satisy n1 <= n0 <= n2')
end

n=[n1:1:n2]; x=[(n-n0)==0];