function z = theta2z(thetaPair_rad)
k1 = tan(pi/2 - thetaPair_rad(1));
k2 = tan(pi/2 - thetaPair_rad(2));

z = - k1*k2 / (k2 - k1) * 70;
end