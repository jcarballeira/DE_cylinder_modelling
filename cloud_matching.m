clc
clear

path='/home/jcl/Matlab2017b/DE_cylinder_modelling';
holes_dir=dir([path '/*.pcd']);
holes=size(holes_dir,1)/6
TRs=[];
TTs=[];

% Dibujar nubes para obtener scanmatching
for i=1:holes
    
cloudfileroi=strcat('rest', num2str(i));
cloudfileroi=strcat(cloudfileroi, '.pcd');

figure(10)
nube = pcread(cloudfileroi);
pcshow(nube, 'MarkerSize', 25)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on 
title('Scan matching clouds')
end

nubescan = pcread('rest1.pcd');
nubehole = pcread('roi1.pcd');
scanref=cloudfilter(nubescan);
holeref=cloudfilter(nubehole);
result=holeref';

for i=2:holes
 
%Filtrado y conversión nubes    
cloudfileroi=strcat('rest', num2str(i));
cloudfileroi=strcat(cloudfileroi, '.pcd');
nubescan = pcread(cloudfileroi);
scan=cloudfilter(nubescan);

cloudfilehole=strcat('roi', num2str(i));
cloudfilehole=strcat(cloudfilehole, '.pcd');
nubehole = pcread(cloudfilehole);
hole=cloudfilter(nubehole);

%ICP scan matching
[TR, TT, dataOut] = icp(scanref,scan);   % dataOut=TR*nube_new+TT
%TS(i)=[TR TT];
TRs=[TRs;TR]
TTs=[TTs TT]
tfs=size(TTs,2);

%Drawing scan matching
figure(2)
clf
plot3(scanref(1,:),scanref(2,:),scanref(3,:),'r.',dataOut(1,:),dataOut(2,:),dataOut(3,:),'g.'), hold on, axis equal
plot3([1 1 0],[0 1 1],[0 0 0],'r-',[1 1],[1 1],[0 1],'r-','LineWidth',2)
titulo=strcat('Transformed data points', num2str(i));
titulo=strcat(titulo, '(green) and model points (red)');
title(titulo)

scanref=scan;
holeref=hole;


%TR and TT application
pts=size(hole,2);
for j=1:1:pts
    point=hole(:,j);
    for t=1:1:tfs
       point=TRs(3*(tfs-t+1)-2:3*(tfs-t+1),:)*point+TTs(:,tfs-t+1); 
    end    
    new_points(:,j)=point;
end

result=[result;new_points'];
%Plot conversion
mergedcloud = pointCloud(result);
k = waitforbuttonpress

end

figure(3)
title('Merged Holes')
pcshow(mergedcloud)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on 

[Cilindro]=modelling(mergedcloud);