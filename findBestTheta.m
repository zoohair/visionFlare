function [i1, i2] = findBestTheta(thetaList)

posThetaIdx = (thetaList > 0);
negThetaIdx = (thetaList <= 0);

posTheta = thetaList(posThetaIdx); kp = length(posTheta);
negTheta = thetaList(negThetaIdx); kn = length(negTheta);

if(kp == 0 || kn == 0)
    error('expect at least one theta to be negative and positive!')
end

diffMatrix = zeros(kn , kp);

bestPair = zeros(length(negTheta),1);
bestDiff = bestPair;
for i = 1:kn
    nt = negTheta(i);
    for j = 1:kp
        pt = posTheta(j);
        diffMatrix(i,j) = abs(nt + pt);
    end
    [bestDiff(i), bestPair(i)] = min(diffMatrix(i,:));
end

[~, bestOfThemAll] = min(bestDiff);

i1 = bestOfThemAll;
i2 = bestPair(bestOfThemAll);
%need to convert to the initial array
i1 = find(negThetaIdx, i1); i1 = i1(end);
i2 = find(posThetaIdx, i2); i2 = i2(end);

end