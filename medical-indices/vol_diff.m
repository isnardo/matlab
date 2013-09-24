function [VolDiff VolDiff_P] = vol_diff(mA,mB,res)
% This function that computes the volume difference between two binary masks (3D)
%
% INPUT:
%
% mA  : Binary mask A
% mB  : Binary mask B
% res : voxel dimensions in millimeters [x,y,z]
%
% OTPUT:
%
% VolDiff    :  Volume difference in mm^3
% VolDiff_P  :  Volume difference in percentage (%)
%
% - Isnardo Reducindo (isnardo.rr@gmail.com)
% - Released: 1.0.0   Date: 2013/07/17
% - Revision: 1.1.0   Date: 2013/09/24 

    mA = cast(mA,'double');
    mB = cast(mB,'double');
    
    % Voxel Volume 
    vox = res(1)*res(2)*res(3);
    
    % Volumes Size
    size_mA = size( mA );
    size_mB = size( mB );
    size_m  = size_mA;

    % Check volumes sizes
    if size_mA(1) == size_mB(1) && size_mA(2) == size_mB(2) && size_mA(3) == size_mB(3)
        region1 = mA;
        region2 = mB;
    else
        for i = 1 : length( size_m )
            if size_mB(i) > size_mA(i)
                size_m(i) = size_mB(i);
            end
        end
        region1 = zeros( size_m );
        region2 = zeros( size_m );

        region1( 1:size_CA(1),1:size_CA(2),1:size_CA(3) ) = mA;
        region2( 1:size_CB(1),1:size_CB(2),1:size_CB(3) ) = mB;
    end

    imgRes = region1 + region2;
    imgRes( find( imgRes == 2 ) ) = 0;

    %Compute Volume Difference
    VolDiff = sum( sum(sum(imgRes)) )*vox;
    VolDiff_P = VolDiff/( sum( sum(sum(region1)) )*vox )*100;
