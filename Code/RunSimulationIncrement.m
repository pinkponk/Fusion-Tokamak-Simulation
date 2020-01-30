function [  ] = RunSimulationIncrement( simData ,plotTypeString)
%RUNSIMULATION Summary of this function goes here
%   Detailed explanation goes here

%% Equilibrium magnetic field components 
mu0 = 4*pi*10e-7;                                       %[N/A^2]
plas_curr_A = simData.plas_curr*1000;                   %[A]
Bpoloidal = mu0*plas_curr_A/(2*pi*simData.aminor);      %From Ampare's law, ?I=circleIntegral(B_vec dot product dl_vec)
% Bpoloidal = mu0*plas_curr_A/(2*pi*simData.Rmajor);      %From Ampare's law, ?I=circleIntegral(B_vec dot product dl_vec)
Bpoloidal = Bpoloidal*1000;                             %Convert to mT

% Bpoliodal = 9.152293387657957e+02;

%% Creating dummy sensor dimensions
b = zeros(4,32);
b(1,:) = simData.brad_A;
b(2,:) = simData.brad_B;
b(3,:) = -simData.brad_A;
b(4,:) = -simData.brad_B;

%% Fast furier transform
% B = zeros(size(b));
B = fftshift(fft2(b(:,:)));
B(:,17) = 0;  %Cancel out the static displacement
ftoroidal = -16:15;  % 0-centered frequency range, n-modes
fpoloidal = [-2,-1,0,1]; %m-modes

% B(:,1) = 0;
% B(:,:) = (fft2(b(:,:)));
% ftoroidal = 0:15;
% temp = [-16:-1];
% ftoroidal(1,(end+1):(end+length(temp))) = temp;



switch plotTypeString
    case 'FreqModesMesh'
        [az,el] = view;
        [X,Y] = meshgrid(ftoroidal,fpoloidal); % 0-centered 2D frequency range
        

         
        mesh(X,Y,abs(B))
        axis([-16 15 -2 1 0 30])
        view([az,el]);
        
    case 'FreqModesImgCol'
                imagesc(ftoroidal,fpoloidal,abs(B))
        colorbar
        xlabel('X mode number/ frequency')
        ylabel('y mode number/ frequency')
         axis([-16 15 -2 1])
        
    case {'ColumnShape','ColumnShapeMesh','ColumnShapeRed','CrossSection'}
        %% Going from Cmn (magnetic field) to Smn (magetic fieldlines displacment)

        Bsize = size(B);
        Smn = zeros(Bsize);

        Btoroidal = simData.btor_tfc;      %[mT]
%         Btoroidal = -9.627087041735649;
        
        mIndex = 0;
        for m = fpoloidal
            mIndex = mIndex +1;
            nIndex = 0;
            for n = ftoroidal
                nIndex = nIndex + 1;
                if n ~= 0 || m ~= 0
                    %when both modes are 0 this gives inf for Smn, not good, ask why it is like this? remember:  Smn(mIndex,nIndex,tStep) = B(mIndex,nIndex,N)/(1j*(m*BpoloidalN/r+n*BtoroidalN/R));
%                     mIndex = m-fpoloidal(1)+1;
%                     nIndex = n-ftoroidal(1)+1;

                    Smn(mIndex,nIndex) = B(mIndex,nIndex)/(1j*(m*Bpoloidal/simData.aminor+n*Btoroidal/simData.Rmajor));
                end
             end
        end


        %% Going from Smn (magetic fieldlines displacment) to r (Plasma displacement)
        
        % simData.theta_res is a number which can be a fraction and
        % therefor needs to be rounded to prevent inconsistencies in the plot.
        thetaRes = -pi:(2*pi/round(simData.theta_res)):(pi-(2*pi/round(simData.theta_res)));
        phiRes = -pi:(2*pi/round(simData.phi_res)):(pi-(2*pi/round(simData.phi_res)));
        
        r = zeros(length(thetaRes),length(phiRes));

        SmnR = real(Smn);
        SmnIm = imag(Smn);
        
%         %test
%          Am = 2*abs(Smn);
%          alpha = atan2(SmnIm,SmnR);
%          ftoroidal2 = 0:15;

        row = 0;
        for theta = thetaRes
            row = row + 1;
             col = 0;
            for phi = phiRes
                col = col + 1;
                mIndex = 0;
                for m = fpoloidal
                    mIndex = mIndex +1;
                    nIndex = 0;
                    for n = ftoroidal
                            nIndex = nIndex +1;
                        
%                             mIndex = m-fpoloidal(1)+1;
%                             nIndex = n-ftoroidal(1)+1;

                            temp = m*theta+n*phi;
                            EulerR = cos(temp);
                            EulerIm = sin(temp);
                            
                            %test
%                            r(row,col) = r(row,col)+Am(4,nIndex)*cos(alpha(4,nIndex)+temp);
                            

                            r(row,col) = r(row,col) + SmnR(mIndex,nIndex)*EulerR-SmnIm(mIndex,nIndex)*EulerIm;

                            %+(SmnR(mIndex,nIndex)*EulerIm+SmnIm(mIndex,nIndex)*EulerR)*1j;
                            %im part
%                             (SmnR*EulerIm+SmnIm*EulerR);
                        
                     end
                end
            end
        end

        %% Animation
        
        % simData.theta_res is a number which can be a fraction and
        % therefor needs to be rounded to prevent inconsistencies in the plot.
        thetaRes = -pi:(2*pi/round(simData.theta_res)):pi;
        phiRes = -pi:(2*pi/round(simData.phi_res)):pi;
    
        %Close the 2D-loop for animation
        rSize = size(r)+[1 1];                    
        rClosed = zeros(rSize);
        rClosed(1:(end-1),1:(end-1)) = r;                
        rClosed(1:(end-1),end) = r(:,1);
        rClosed(end,(1:(end-1))) = r(1,:);

        %Boost amp to see disturbances better
        rClosed = rClosed*simData.amp_boost;
        
        x = zeros(size(r(:,:)));
        y = zeros(size(x));
        z = zeros(size(x));

        %unvectorized verison
        row = 0;
        for theta = thetaRes
            row = row + 1;
             col = 0;
            for phi = phiRes
                col = col + 1;

                x(row,col) = (simData.Rmajor + (simData.aminor + rClosed(row,col)/1000) *cos(theta)) * cos(phi);
                y(row,col) = (simData.Rmajor + (simData.aminor + rClosed(row,col)/1000) * cos(theta)) * sin(phi);
                z(row,col) = (simData.aminor + rClosed(row,col)/1000)* sin(theta);

            end

        end
            if strcmp(plotTypeString,'CrossSection')
%                 [az,el] = view;
%                 plot(x(:,1), z(:,1));
        thetaRes2 = -pi:(2*pi/round(simData.theta_res)):(pi-(2*pi/round(simData.theta_res)));
        temp = (r(:,30)*simData.amp_boost/1000+simData.aminor);
%         temp = ones(length(thetaRes2),1)*0.2;
           x = cos(thetaRes2)'.*temp;
           y = sin(thetaRes2)'.*temp;
                plot(x,y)
%                 axis([-.8 .8 -.8 .8])
                axis equal
%                 view([az,el]);
                drawnow
                
            elseif strcmp(plotTypeString,'ColumnShapeRed')
                [az,el] = view;
                surf(x, y, z, r(:,:),'FaceColor','red','EdgeColor','none');
                camlight left;
                lighting phong
                axis([-1.8 1.8 -1.8 1.8 -.8 .8])
                view([az,el]);
                drawnow
                
            elseif strcmp(plotTypeString,'ColumnShapeMesh')
                [az,el] = view;
                mesh(x, y, z);
                axis([-1.8 1.8 -1.8 1.8 -.8 .8])
                view([az,el]);
                drawnow
                
            else
                [az,el] = view;
                surf(x, y, z, r(:,:));
                axis([-1.8 1.8 -1.8 1.8 -.8 .8])
                view([az,el]);
                drawnow
              
            end
            

end

end

