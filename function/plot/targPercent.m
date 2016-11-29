function store_means = targPercent(allOrders,varargin)

params = struct(...
    'jitterAmount',.008, ...
    'addPoints',0 ...
    );

params = structInpParse(params,varargin);

% -- calculate percent

fixedOrd = allOrders(~isnan(allOrders(:,1)),:);

posPerc = nan(size(fixedOrd,1),size(fixedOrd,2));
negPerc = nan(size(fixedOrd,1),size(fixedOrd,2));

for i = 1:size(fixedOrd,1);
    oneRow = fixedOrd(i,:);
    oneRow(isnan(oneRow)) = [];
    
    posN = 4;
    negN = 4;

    intP = 1;
    intN = 1;
    
    for j = 1:length(oneRow)            
        
        if oneRow(j) == 1;
            posPerc(i,j) = intP/posN;
            intP = intP+1;
        elseif oneRow(j) == 0;
            negPerc(i,j) = intN/negN;
            intN = intN+1;
        end
    end
end

% -- get means and sem

posMeans = nan(1,size(posPerc,2));
negMeans = nan(1,size(posPerc,2));
negSems = nan(1,size(posPerc,2));
posSems = nan(1,size(posPerc,2));

posVar = nan(1,size(posPerc,2));
negVar = nan(1,size(posPerc,2));

for k = 1:size(posPerc,2);
    posMeans(1,k) = nanmean(posPerc(:,k));
    posSems(1,k) = nanSEM(posPerc(:,k));
    
    posVar(1,k) = nanstd(posPerc(:,k)).^2;
    
    negMeans(1,k) = nanmean(negPerc(:,k));
    negSems(1,k) = nanSEM(negPerc(:,k));  
    
    negVar(1,k) = nanstd(negPerc(:,k)).^2;
end

% -- plot percents

posAddSem(1,:) = posMeans + posSems;
posAddSem(2,:) = posMeans - posSems;
negAddSem(1,:) = negMeans + negSems;
negAddSem(2,:) = negMeans - negSems;

xCoords = 1:length(posMeans);

hold on;

plot(xCoords,posMeans,'b');
plot(xCoords,posAddSem(1,:),'b');
plot(xCoords,posAddSem(2,:),'b');

% plot([xCoords; xCoords],posAddSem,'b');

plot(xCoords,negMeans,'r');
plot(xCoords,negAddSem(1,:),'r');
plot(xCoords,negAddSem(2,:),'r');

% plot([xCoords; xCoords],negAddSem,'r');
posVect = posPerc(~isnan(posPerc));
negVect = negPerc(~isnan(negPerc));
[h,p,ks2stat]=kstest2(negVect,posVect,'Tail','unequal');
h
p
ks2stat

store_means.pos(1,:) = posMeans;
store_means.pos(2:3,:) = posAddSem;
store_means.posVar = posVar;
store_means.neg(1,:) = negMeans;
store_means.neg(2:3,:) = negAddSem;
store_means.negVar = negVar;

% -- make actual data points bigger

if ~params.addPoints

plot(xCoords,posMeans,'b*','markers',1.5);
plot(xCoords,negMeans,'r*','markers',1.5);

end

% -- add optionally add raw data and jitter

if params.addPoints
    
for i = 1:size(posPerc,2);
    extr = posPerc(:,i);
    extr = extr(~isnan(extr));
    
    extrNeg = negPerc(:,i);
    extrNeg = extrNeg(~isnan(extrNeg));
    
    newX = repmat(i,length(extr),1);
    newXNeg = repmat(i,length(extrNeg),1);
    
    for j = 1:2;
        stp = 1;
        if j == 1;
            for k = 1:length(newX);
                if rand < .5
                    newX(k) = newX(k) - jitterAmount*stp;
                else
                    newX(k) = newX(k) + jitterAmount*stp;
                end
                stp = stp+1;
            end
        elseif j == 2;
            for k = 1:length(newXNeg);
                if rand < .5
                    newXNeg(k) = newXNeg(k) - jitterAmount*stp;
                else
                    newXNeg(k) = newXNeg(k) + jitterAmount*stp;
                end
                stp = stp+1;
            end
        end
    end     
    
    plot(newX,extr,'b*','markers',.8); %pos
    plot(newXNeg,extrNeg,'r*','markers',.8);
    
    store_perc(i).pos = extr;
    store_perc(i).neg = extrNeg;

end

end

% -- labels and limits

xlabel('Choice Number','FontSize', 12);
ylabel('Cumulative Proportion of Specific Choices','FontSize', 12);
legend('neg','pos','Location','southeast');

ylim([0 1]);
xlim([1 8]);



% end
    
    
            
        
    
    
    



