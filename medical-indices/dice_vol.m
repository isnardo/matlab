function DSC = dice_vol(mA,mB)
% This function computes dice similarity coefficient between two binary masks (3D)
%
% INPUT:
%
% mA  : Binary mask A
% mB  : Binary mask B
%
% OTPUT:
%
% DSC :  dice similarity coefficient
%
% - Isnardo Reducindo (isnardo.rr@gmail.com)
% - Released: 1.0.0   Date: 2013/07/17
% - Revision: 1.1.0   Date: 2013/09/24 

    mA = cast(mA,'double');
    mB = cast(mB,'double');
    
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

    regionSum = region1 + region2;

    imgRes = regionSum;
    imgRes( find( regionSum < 2 ) ) = 0;
    imgRes( find( regionSum == 2 ) ) = 1;

    %Compute Dice Similarity Coefficient ( DSC )
    DSC = 2*sum( sum(sum(imgRes)) )/( sum( sum(sum(region1)) ) + sum( sum(sum(region2)) ) );
