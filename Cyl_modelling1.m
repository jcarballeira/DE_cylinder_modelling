function [Solution]=Cyl_modelling1

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
end


NP=input('\ \n Introduce population number: \n');
if isempty(NP)
    NP=100;   
    fprintf(1,'\n \t Population 100 by default. \n');
end

NP=round(NP);
fprintf(1,'\n Population size: %i \n',NP);

% Genetic algorithm upper iterations limit
iter_max=input('\ \n Introduzce the maximum number of iterations: \ \');
iter_max=round(iter_max);
if isempty(iter_max)
    iter_max= 40;   
    fprintf(1,'\n \t The default iterations are %d \n',iter_max);
end

%--------------------------------------------------------------------------
% Different options for the GL algorithm can be selected via keyboard:
%  - DE Core Options:
%    1) Random Mutation, with Thresholding and Discarding (Default). 
%    2) Basic version, Random Mutation, without Thresholding, Discarding.
%    3) Mutation from Best candidate, with Thresholding and Discarding.
%    4) Random Mutation, with Thresholding and Discarding, NP is
%    drastically reduced (tracking) after convergence.
version_de=input('\ \n Introduce the DE version that you want to apply: \n 1) Random Mutation, with Thresholding and Discarding. \n 2) Basic version, Random Mutation, without Thresholding, Discarding. \n 3) Mutation from Best candidate, with Thresholding and Discarding. \n 4) Random Mutation, with Thresholding and Discarding, NP reduced (tracking) after convergence. \n');
if isempty(version_de)
    version_de=1;   
    fprintf(1,'\n \t Option 1 by default. \n');
end

centers=csvread('centers.csv');

%Evaluate each hole cloud
for i=1:holes
    
center=centers(i,:);

cloudfile=strcat('roi', num2str(i));
cloudfile=strcat(cloudfile, '.pcd')

nube = pcread(cloudfile);    
Points=nube.Count;

if Points > 15

   

fprintf(1,'\n Hole points considered: %i \n',Points);    
xyz=nube.Location;
xyz=reshape(xyz, [1 size(xyz,1)*size(xyz,2)]);
xyz(isnan(xyz))=[];
sz=size(xyz,2);
   
for j=1:1:sz/3
       x=xyz(j);
       y=xyz(j+sz/3);
       z=xyz(j+2*sz/3);
       mat(ceil(j),:) = [x y z];
end


ptCloud=pointCloud(mat);

%--------------------------------------------------------------------------
%Initialization parameters:
D=4;                        % DE Number of Chromosomes. 
F=0.8;                     % Differential variations factor (mutation)
CR=0.5;                     % Crossover constant

% Population parameter boundaries,[x,y,z,u,v,w]: xyz center point, uvw axis vector
%vector_min=[-1 -1 -1];
vector_min=[-0.4 -0.4 0.6];
%vector_max=[1 1 1 ];
vector_max=[0.4 0.4 1];
min=[vector_min(1), vector_min(2), vector_min(3),0.003]; %minimum an maximum
max=[vector_max(1), vector_max(2), vector_max(3),0.03];

N_SIMULATIONS=1;
Solution.best_estimate=zeros(N_SIMULATIONS,D);
Solution.error=zeros(N_SIMULATIONS,1);

for simul=1:N_SIMULATIONS
    
% The initial population is randomly generated.
population=initiate_pop(min,max,NP,D);

%--------------------------------------------------------------------------

% The robot motion simulation starts. In a single step, the robot tries to
% locate itself. After convergence, robot motion is allowed until an 'f'
% is introduced in dir_disp. In this case, the GL module ends its
% execution.
        
fprintf(1,'\n Simulation: %d/%d ',simul,N_SIMULATIONS);
tic
% The DE-based GL filter is called
[bestmem,error,population]=alg_genet1(ptCloud,version_de,population,iter_max,max,min,NP,D,F,CR,center);
toc
fprintf(1,'\n Estimated axis vector by the GL filter (u v w) %f %f %f %f\n',bestmem(2),bestmem(3),bestmem(4));
fprintf(1,'\n Estimated Radius by the GL filter %f\n',bestmem(5));

% The best solution and the error are returned.
Solution.best_estimate(simul,:)=bestmem(2:(D+1));
Solution.error(simul)=error;



end

%--------------------------------------------------------------------------
% Representation of results
height=ptCloud.ZLimits(2)-ptCloud.ZLimits(1);
params=[center(1),center(2),center(3),center(1)+height*Solution.best_estimate(1),center(2)+height*Solution.best_estimate(2),center(3)+height*Solution.best_estimate(3),Solution.best_estimate(4)];
model = cylinderModel(params);
%quiver3(Solution.best_estimate(2),Solution.best_estimate(3),Solution.best_estimate(4),Solution.best_estimate(5),Solution.best_estimate(6),Solution.best_estimate(7))
plot(model)
else 
fprintf(1,'\n More points needed to analyze the hole');    
end
end
end