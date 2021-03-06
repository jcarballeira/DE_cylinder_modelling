function [error]=fitness1(ptCloud,trial,center)
%--------------------------------------------------------------------------
%   Function: fitness
% -> Description: fitness function that is optimized by the DE-based Global
% localization filter. 
%--------------------------------------------------------------------------
% -> Inputs:
%       -ptCloud: Hole point cloud.
% -> Output: 
%       -error: fitness value.
%--------------------------------------------------------------------------
sum_desv=0;
size=ptCloud.Count;
dists=zeros(1,size);


    for j=1:size
        x=ptCloud.Location(j);
        y=ptCloud.Location(size+j);
        z=ptCloud.Location(2*size+j);

        Sx=x-center(1);
        Sy=y-center(2);
        Sz=z-center(3);

        mod_qpxu=sqrt((Sy*trial(3)-Sz*trial(2))^2+(Sz*trial(1)-Sx*trial(3))^2+(Sx*trial(2)-Sy*trial(1))^2);
        mod_u=sqrt(trial(1)^2+trial(2)^2+trial(3)^2);
        dist_rect=mod_qpxu/mod_u;
        dists(j)=dist_rect-trial(4);
     end

   

    for j=1:size
        desv=dists(j)^2;
        sum_desv=sum_desv + desv;
    end

    desvest=sqrt(sum_desv/size);
    error=desvest;
end

