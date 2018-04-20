clc
clear
% Nubes para obtener scanmatching
nube1 = pcread('scanm1.pcd');    
nube2 = pcread('scanm2.pcd');

%Nubes para fusionar
nube3 = pcread('roi1.pcd');    
nube4 = pcread('roi2.pcd');

%Plot
figure(1)
pcshow(nube1)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on 
pcshow(nube2)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on 
title('Scan matching clouds')

%Filtrado y conversión nubes
scan_new=cloudfilter(nube1);
scan_ant=cloudfilter(nube2);
hole_new=cloudfilter(nube1);
hole_ant=cloudfilter(nube2);

%ICP scan matching
[TR, TT, dataOut] = icp(scan_ant,scan_new);   % dataOut=TR*nube_new+TT

pts=size(hole_new,2);
for i=1:1:pts
    point=hole_new(:,i);
    new_points(:,i)=TR*point+TT;
end    


figure(2)
plot3(hole_ant(1,:),hole_ant(2,:),hole_ant(3,:),'r.',new_points(1,:),new_points(2,:),new_points(3,:),'g.'), hold on, axis equal
 plot3([1 1 0],[0 1 1],[0 0 0],'r-',[1 1],[1 1],[0 1],'r-','LineWidth',2)
title('Transformed data points (green) and model points (red)')

