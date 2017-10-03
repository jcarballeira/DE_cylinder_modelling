function [Solution]=Cyl_modelling

clc 

nube = pcread('hole1.pcd');
pcshow(nube, 'MarkerSize', 25)
  xlabel('X')
  ylabel('Y')
  zlabel('Z')



xyz=nube.Location;
xyz(isnan(xyz))=[]
sz=size(xyz,2);
        for j=1:sz 
            x=nube.Location(j);
            y=nube.Location(sz+j);
            z=nube.Location(2*sz+j);
            mat(j,:) = [x y z];
      
        end

ptCloud=pointCloud(mat);

%--------------------------------------------------------------------------
%Initialization parameters:
D=6;                        % DE Number of Chromosomes. 
F=0.8;                     % Differential variations factor (mutation)
CR=0.5;                     % Crossover constant

% Population parameter boundaries,[x,y,z,u,v,w]: xyz center point, uvw axis vector

min=[ptCloud.XLimits(1), ptCloud.YLimits(1), ptCloud.ZLimits(1), -0.15, -0.15, 0.8] %minimum an maximum
max=[ptCloud.XLimits(2), ptCloud.YLimits(2), ptCloud.ZLimits(2), 0.15, 0.15, 1]

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
    
%--------------------------------------------------------------------------
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

end

%--------------------------------------------------------------------------
% Representation of results



end