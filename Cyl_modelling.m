function [Solution]=Cyl_modelling

clc 
%hole1:
center=[-0.31 -0.45 1.50];
%hole2:
%center=[-0.67 -0.03 1.53];
%hole3:
%center=[0.45 -0.15 1.50];
%hole4:
%center=[0.11 -0.38 1.44];
%hole5:
%center=[0.33 -0.55 1.51];
%hole6:
%center=[-0.63 -0.53 1.56];
%hole7:
%center=[-0.05 -0.63 1.55];
%hole8:
%center=[0.63 -0.64 1.55];

nube = pcread('hole1.pcd');
pcshow(nube, 'MarkerSize', 25)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
hold on

Points=nube.Count;
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
D=6;                        % DE Number of Chromosomes. 
F=0.8;                     % Differential variations factor (mutation)
CR=0.5;                     % Crossover constant

% Population parameter boundaries,[x,y,z,u,v,w]: xyz center point, uvw axis vector
%vector_min=[-1 -1 -1];
vector_min=[-0.3 -0.3 0.6];
%vector_max=[1 1 1 ];
vector_max=[0.3 0.3 1];
min=[center(1)-0.05, center(2)-0.05, ptCloud.ZLimits(1)-0.01, vector_min(1), vector_min(2), vector_min(3)] %minimum an maximum
max=[center(1)+0.05, center(2)+0.05, ptCloud.ZLimits(1)+0.01, vector_max(1), vector_max(2), vector_max(3)]

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
if isempty(iter_max),
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
if isempty(version_de),
    version_de=1;   
    fprintf(1,'\n \t Option 1 by default. \n');
end

N_SIMULATIONS=1;
Solution.best_estimate=zeros(N_SIMULATIONS,D);
Solution.error=zeros(N_SIMULATIONS,1);

for simul=1:N_SIMULATIONS
    
%-----------------------------y a este señor quien le eligió para nada? demoque?---------------------------------------------
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
[bestmem,error,population]=alg_genet(ptCloud,version_de,population,iter_max,max,min,NP,D,F,CR);
toc
fprintf(1,'\n Estimated center by the GL filter (x y z) %f %f %f %f\n',bestmem(2),bestmem(3),bestmem(4));
fprintf(1,'\n Estimated axis vector by the GL filter (u v w) %f %f %f %f\n',bestmem(5),bestmem(6),bestmem(7));

% The best solution and the error are returned.
Solution.best_estimate(simul,:)=bestmem(2:(D+1));
Solution.error(simul)=error;

%Calculate radius from best candidate
sum=0;
fin=ptCloud.Count;
for j=1:fin
        x=ptCloud.Location(j);
        y=ptCloud.Location(fin+j);
        z=ptCloud.Location(2*fin+j);

        Sx=x-Solution.best_estimate(1);
        Sy=y-Solution.best_estimate(2);
        Sz=z-Solution.best_estimate(3);

        mod_qpxu=sqrt((Sy*Solution.best_estimate(6)-Sz*Solution.best_estimate(5))^2+(Sz*Solution.best_estimate(4)-Sx*Solution.best_estimate(6))^2+(Sx*Solution.best_estimate(5)-Sy*Solution.best_estimate(4))^2);
        mod_u=sqrt(Solution.best_estimate(4)^2+Solution.best_estimate(5)^2+Solution.best_estimate(6)^2);
        temp=mod_qpxu/mod_u;
        sum=sum+temp;
end
radio=sum/fin;

end

%--------------------------------------------------------------------------
% Representation of results
height=ptCloud.ZLimits(2)-ptCloud.ZLimits(1);
params=[Solution.best_estimate(1),Solution.best_estimate(2),Solution.best_estimate(3),Solution.best_estimate(1)+height*Solution.best_estimate(4),Solution.best_estimate(2)+height*Solution.best_estimate(5),Solution.best_estimate(3)+height*Solution.best_estimate(6),radio];
model = cylinderModel(params);
%quiver3(Solution.best_estimate(2),Solution.best_estimate(3),Solution.best_estimate(4),Solution.best_estimate(5),Solution.best_estimate(6),Solution.best_estimate(7))
plot(model)
end