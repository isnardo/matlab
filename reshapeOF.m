
E = [];
k = 1;

for xy = 1:6
    for z = 1:6
        for b = 1:6
            E(z,xy,b) = err(k);
            k = k+1;
        end
    end
end