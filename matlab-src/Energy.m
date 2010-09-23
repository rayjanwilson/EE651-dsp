function energy = Energy(signal)
energy = 0;
for k=1:length(signal),
    energy = energy + abs(signal(k))^2;
end