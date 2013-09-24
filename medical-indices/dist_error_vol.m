function [ASD Dmax pdv] = dist_error_vol( CA, CB, rad, res, max_dis)
% **********************************************************************
% IMPORTANT: This function use multicore matlab processing, if you want 
% to improve the performance start matlabpool (matlabpool open) before
% execute this function.
% **********************************************************************
%
% This function compute the Averange Symetric Distance (ASD), Maximum Distance (Dmax) and Percentage of % Distances (pdv) Greather than a given value (max_dis), between two binary contours (CA and CB).
%
% INPUT:
%
% CA  	 : binary contour A
% CB  	 : binary contour B
% rad 	 : radius to search around of each voxel [x,y,z]
% res 	 : voxel resolution in millimeters [x,y,z]
% max_dis : maximum distance (in millimiters) to compute pvd
%
% OUTPUT:
%
% ASD  : Averange Simetric Distance
% Dmax : Maximum Distance
% pvd  : Percentage of distances greather than max_dis
%
% - Isnardo Reducindo (isnardo.rr@gmail.com)
% - Released: 1.0.0   Date: 2013/07/17
% - Revision: 1.1.0   Date: 2013/09/24 

% Cast to logical
CA = logical( CA );
CB = logical( CB );

% Volumes Size
size_CA = size( CA );
size_CB = size( CB );
size_m  = size_CA;

% Check the volumes sizes
if size_CA(1) == size_CB(1) && size_CA(2) == size_CB(2) && size_CA(3) == size_CB(3)
    cA = CA;
    cB = CB;
else
    for i = 1 : length( size_m )
        if size_CB(i) > size_CA(i)
            size_m(i) = size_CB(i);
        end
    end
    cA = zeros( size_m );
    cB = zeros( size_m );
    
    cA( 1:size_CA(1),1:size_CA(2),1:size_CA(3) ) = CA;
    cB( 1:size_CB(1),1:size_CB(2),1:size_CB(3) ) = CB;
end

% Points in the contours
pA = find( cA );
pB = find( cB );

% Obtain the cardinality of the contours
card_CA = length( pA );
card_CB = length( pB );

% Create Sub-Volumen to compute the distances
size_sub = rad*2 + 1;
M = zeros( size_sub );
c = rad + 1; 
M( c(1),c(2),c(3) ) = 1;
D = bwdistX( M, res );

% Start Multicore Processing with MATLAB
% matlabpool open

% Find the minimun distances of each point in contour pA with respect to
% contour CB
dist_pA_CB = zeros( card_CA,1 );

parfor i = 1 : card_CA
    
    % Obtain 3D point index
    [ a b c ] = ind2sub( size_m, pA(i) );
    ind = [a b c];
    
    % Obtain subvolume index
    ind_in = ind - rad;
    ind_fi = ind + rad;
    ind_be = [1,1,1];
    ind_en = size_sub;
    
    % Check that subvolume index exist inside of the volume
    for k = 1:3
        if ind_in(k) < 1
            ind_be(k) = 2 - ind_in(k);
            ind_in(k) = 1;
        end
        if ind_fi(k) > size_m(k)
            ind_en(k) = size_sub(k) - ( ind_fi(k) - size_m(k) );
            ind_fi(k) = size_m(k);
        end
    end
    
    % Obtain the subvolume
    S = zeros( size_sub );
    S( ind_be(1):ind_en(1),ind_be(2):ind_en(2),ind_be(3):ind_en(3) ) = cB( ind_in(1):ind_fi(1),ind_in(2):ind_fi(2),ind_in(3):ind_fi(3) );
    S = logical(S);
    
    % find the minimum distance of pA to CB
    if any( S(:) )
        dist_pA_CB(i) = min( D( find(S) ) );
    else
        dist_pA_CB(i) = max( max(max(D)) );
    end
        
end


% Find the minimun distances of each point in contour pB with respect to
% contour CA
dist_pB_CA = zeros( card_CB,1 );

parfor i = 1 : card_CB
    
    % Obtain 3D point index
    [ a b c ] = ind2sub( size_m, pB(i) );
    ind = [a b c];
    
    % Obtain subvolume index
    ind_in = ind - rad;
    ind_fi = ind + rad;
    ind_be = [1,1,1];
    ind_en = size_sub;
    
    % Check that subvolume index exist inside of the volume
    for k = 1:3
        if ind_in(k) < 1
            ind_be(k) = 2 - ind_in(k);
            ind_in(k) = 1;
        end
        if ind_fi(k) > size_m(k)
            ind_en(k) = size_sub(k) - ( ind_fi(k) - size_m(k) );
            ind_fi(k) = size_m(k);
        end
    end
    
    % Obtain the subvolume
    S = zeros( size_sub );
    S( ind_be(1):ind_en(1),ind_be(2):ind_en(2),ind_be(3):ind_en(3) ) = cA( ind_in(1):ind_fi(1),ind_in(2):ind_fi(2),ind_in(3):ind_fi(3) );
    S = logical(S);
    
    % find the minimum distance of pB to CA
    if any( S(:) )
        dist_pB_CA(i) = min( D( find(S) ) );
    else
        dist_pB_CA(i) = max( max(max(D)) );
    end
end

% matlabpool close

% Compute the ASD
ASD = ( sum(dist_pA_CB) + sum(dist_pB_CA) ) / ( card_CA + card_CB );

% Compute Dmax
Dmax = max( [ max(dist_pA_CB) max(dist_pB_CA) ] );

% Compute
pdv = sum( dist_pA_CB > max_dis ) + sum( dist_pB_CA > max_dis );
pdv = pdv / ( card_CA + card_CB ) * 100;
