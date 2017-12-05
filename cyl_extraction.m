clc

path='/home/jcl/Matlab2017b/DE_cylinder_modelling';
holes_dir=dir([path '/*.pcd']);
holes=size(holes_dir,1);
fprintf(1,'\n Holes found: %i \n',holes);

%Plot each hole cloud
for i=1:holes
    
cloudfile=strcat('roi', num2str(i));
cloudfile=strcat(cloudfile, '.pcd');

nube = pcread(cloudfile);
pcshow(nube, 'MarkerSize', 25)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on  
maxDistance = 0.010;
[model,inlierIndices] = pcfitcylinder(nube,maxDistance);
model
plot(model)
center=model.Parameters(1:3);
vector=model.Orientation;
avg=ev(nube,vector,center,model.Radius);

fprintf(1,'\n Estimated axis vector by the GL filter (u v w): [ %f, %f, %f', vector(1), vector(2), vector(3));
fprintf(1,'\n Estimated Radius by the GL filter %f\n',model.Radius);
fprintf(1,'\n Average distance: %f \n',avg);
end

% for i=1:holes
%     
% cloudfile=strcat('hole', num2str(i));
% cloudfile=strcat(cloudfile, '.pcd');
% 
% nube = pcread(cloudfile);
% maxDistance = 0.010;
% roi = [inf,inf,-inf,inf,inf,inf];
% sampleIndices = findPointsInROI(nube,roi);
% referenceVector = [0,0,1];
% %[model,inlierIndices] = pcfitcylinder(nube,maxDistance,referenceVector,'SampleIndices',sampleIndices);
% [model,inlierIndices] = pcfitcylinder(nube,maxDistance);
% model
% k = waitforbuttonpress;
% plot(model)
% end

