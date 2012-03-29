function [Lh,Lv] = create4connected_L1(m,n,mask);
mn = m*n;
a = ones(mn,1);
rng = m:m:mn-1;

A = spdiags(a,-1,mn,mn);
A(rng,rng+1) = 0;
Lv = -speye(mn) + A;

B = spdiags(a,-m,mn,mn);
B(rng+1,rng) = 0;
Lh = -speye(mn) + B;

% remove boundary pixels
for i=m:m:mn
  Lv(i,i) = 0;
end

for i=m*(n-1)+1:mn
  Lh(i,i) = 0;
end

% do the same along the mask
if exist('mask','var') && any(mask(:)==0)
  for i=1:size(mask,2)
    ind1 = find(mask(:,i)==1);
    ind0 = find(mask(:,i)==0);

    % crossings from 0 to 1 and 1 to 0
    ind_01 = intersect(ind0+1,ind1);
    %ind_10 = intersect(ind0-1,ind1);
    % remove crossings that have only a width of one and collect them into
    % singles
    %singles = intersect(ind_10, ind_01);
    %ind_10 = setdiff(ind_10, ind_01);

    indexOffset = ind_01 + (i-1)*m;

    % handle the mask borders where the gradient does not lie completely inside
    Lv(indexOffset, indexOffset) = 0;

    % remove weights on single pixel
    %Lv(singles + (i-1)*m, singles + (i-1)*m) = 0;
  end

  for i=1:size(mask,1)
    ind1 = find(mask(i,:)==1);
    ind0 = find(mask(i,:)==0);

    % crossings from 0 to 1 and 1 to 0
    ind_01 = intersect(ind0+1,ind1);
    %ind_10 = intersect(ind0-1,ind1);
    % remove crossings that have only a width of one and collect them into
    % singles
    %singles = intersect(ind_10, ind_01);
    %ind_10 = setdiff(ind_10, ind_01);

    indexOffset = (ind_01-1)*m + i;

    % handle the mask borders where the gradient does not lie completely inside
    Lh(indexOffset, indexOffset) = 0;

    % remove weights on single pixel
    %Lh(singles + (i-1)*m, singles + (i-1)*m) = 0;
  end

  maskInd = find(mask(:)~=0);
  Lh = Lh(maskInd,maskInd);
  Lv = Lv(maskInd,maskInd);
end

assert(issparse(Lh));
assert(issparse(Lv));
