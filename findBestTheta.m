function [i1, i2, xsec] = findBestTheta(thetaList_rad, rhoList, center_xy)

posThetaIdx = (thetaList_rad > 0);
negThetaIdx = (thetaList_rad <= 0);

posTheta = thetaList_rad(posThetaIdx); kp = length(posTheta);
posRho = rhoList(posThetaIdx);
negTheta = thetaList_rad(negThetaIdx); kn = length(negTheta);
negRho = rhoList(negThetaIdx);

if(kp == 0 || kn == 0)
    error('expect at least one theta to be negative and positive!')
end

scoreMatrix = zeros(kn , kp);

bestPair = zeros(length(negTheta),1);
bestDiff = bestPair;
for i = 1:kn
    nt = negTheta(i);
    nr = negRho(i);
    nl = projLine(nt, nr);
    for j = 1:kp
        pt = posTheta(j);
        pr = posRho(j);
        pl = projLine(pt, pr);
        xsec = intersection(nl, pl);
        scoreMatrix(i,j) = abs(nt + pt)*180 + 1*distance2center(xsec, center_xy);
    end
    [bestDiff(i), bestPair(i)] = min(scoreMatrix(i,:));
end

[~, bestOfThemAll] = min(bestDiff);

i1 = bestOfThemAll;
i2 = bestPair(bestOfThemAll);
%need to convert to the initial array
i1 = find(negThetaIdx, i1); i1 = i1(end);
i2 = find(posThetaIdx, i2); i2 = i2(end);

l1 = projLine(thetaList_rad(i1), rhoList(i1));
l2 = projLine(thetaList_rad(i2), rhoList(i2));
xsec = intersection(l1,l2);

end


function l = projLine(theta, rho)
    l = [cos(theta), sin(theta), -rho]';
end

function xy = intersection(l1, l2)
    xy = cross(l1, l2);
    x = xy(1)/xy(end);
    y = xy(2)/xy(end);
    xy = [x, y];
end

function d = distance2center(xy, center_xy)
    %d = norm(xy - center_xy);
    if xy(1) < 0 || xy(1) > 1400 || xy(2) < 0 || xy(2) > 900
        d = Inf;
    else
        d = abs(xy(1) - center_xy(1));
        d = max(d, 0);
    end
end