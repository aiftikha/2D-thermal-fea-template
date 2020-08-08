clf;
clear;
tlist=[2,10,15,25,60];
%----------------------------------------------------------------------
% Steps
%----------------------------------------------------------------------
% 1. Create transient PDE model
% 2. Create geometry and import into model
% 3. Define thermal properties
% 4. Define ICs and BCs
% 5. Generate Mesh
% 6. Solve the PDE
% 7. Plot the PDE 
%----------------------------------------------------------------------


% Create transient pde model
% Source: https://www.mathworks.com/help/pde/ug/pde.thermalmodel.html
model1=createpde(1);
thermalmodel=createpde('thermal','transient');
%----------------------------------------------------------------------


% Create rectangular geometry
% Source: https://www.mathworks.com/help/pde/ug/create-geometry-at-the-command-line.html
rect1=[3 4 0 0.1 0.1 0 0 0 -0.35 -0.35]';
%----------------------------------------------------------------------


% Import geomtry to thermal model, and plotting geometry for edge reference
% Source: https://www.mathworks.com/help/pde/ug/pde.pdemodel.geometryfromedges.html
ns=char('rect1');
ns=ns';
sf='rect1';
g=decsg(rect1,sf,ns);
pg=geometryFromEdges(thermalmodel,g);
figure (1)
pdegplot(thermalmodel,'Edgelabels','on');
axis equal
%----------------------------------------------------------------------


% Defining alpha (Thermal diffusivity) as ThermalConductivity/(MassDensity X SpecificHeat)
% Function source: https://www.mathworks.com/help/pde/ug/pde.thermalmodel.thermalproperties.html
thermalProperties(thermalmodel,'ThermalConductivity',0.0001,'MassDensity',1','SpecificHeat',1);
%----------------------------------------------------------------------


% Defining boundary conditions
% Source: https://www.mathworks.com/help/pde/ug/pde.thermalmodel.thermalbc.html#bvhtzlo-RegionType
thermalBC(thermalmodel,'Edge',1,'Temperature',100);
thermalBC(thermalmodel,'Edge',2,'Temperature',40);
thermalBC(thermalmodel,'Edge',3,'Temperature',10);
thermalBC(thermalmodel,'Edge',4,'Temperature',20);
%----------------------------------------------------------------------


% Defining initial condition, generating mesh, and plotting
% Source: https://www.mathworks.com/help/pde/ug/pde.thermalmodel.thermalic.html#bvhtznb-RegionType
thermalIC(thermalmodel,0);
generateMesh(thermalmodel);

for n=1:length(tlist)
    % Create a matrix of solutions for each time from tlist
    result(n)=solve(thermalmodel,0:0.1:tlist(n)); 
    
        % Plot only for the first 4 times as required by the question 
        if n<5 
            figure (n+1)
            pdeplot(thermalmodel,'XYData',result(n).Temperature(:,end))
            tstring = ['Temperature at time = ', num2str(tlist(n)),' s'];
            title(tstring)
            axis equal
 end
end
%---------------------------------------------------------------------


% Repeat the above steps for a steady state model
% Error involved as steady state solution depends only on ThermalConductivity 
% which was assumed to be same as ThermalDiffusivity
% Sources: Same as transient state
model2=createpde(1);
thermalmodel2=createpde('thermal','steadystate');
pg2=geometryFromEdges(thermalmodel2,g);
thermalProperties(thermalmodel2,'ThermalConductivity',0.0001);
thermalBC(thermalmodel2,'Edge',1,'Temperature',100);
thermalBC(thermalmodel2,'Edge',2,'Temperature',40);
thermalBC(thermalmodel2,'Edge',3,'Temperature',10);
thermalBC(thermalmodel2,'Edge',4,'Temperature',20);
generateMesh(thermalmodel2);
result2=solve(thermalmodel2);
figure(6)
pdeplot(thermalmodel2,'XYData',result2.Temperature(:,end))
tstring2 = ['Temperature at steady state'];
title(tstring2)
axis equal
%----------------------------------------------------------------------


% Interpolate Temperature at specific X,Y, and t
% Source for interpolation function: 
% https://www.mathworks.com/help/pde/ug/pde.steadystatethermalresults.interpolatetemperature.html
X = [0.04 0.06 0.07 0.09];
Y = [-0.3 -0.25 -0.2 -0.15];
t = [15 60];
l=1;
diary infal.dat
fprintf('   X       Y       t      T\n');
for i=1:1:length(X)
    for j=1:2   
    Tintrp1(l) = interpolateTemperature(result(5),X(i),Y(i),t(j));
    fprintf('%0.2f   %0.2f   %0.2f   %0.2f\n',[X(i) Y(i) t(j) Tintrp1(l)]);
    q=l+1;
    l=q;
    end
end
diary off
%---------------------------------------------------------------------

