%% Allow Intra, CR and Inter Mode
% This part doesn't work correctly yet

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
       
    for nframe = 1:length(V) % loop over all frames, comparison between two frames: -1
        nframe
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        
        % loop over all 16x16 blocks
        for nrow = 1:M
            for ncol =1:N
                
                % Get rates and add another bit for mode indication
                R_intra = blocks{quantStep,nframe}{nrow,ncol}.RIntra + 1/16^2;
                R_copy = 2/16^2;
                
                Rres_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{nrow,ncol}.resDCTquant, ...
                    codebooks_res, quantStep, 'coef');
                Roffset_inter = 2/16^2;
                Rpos_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{nrow,ncol}.pos, ...
                    codebooks_mot, quantStep, 'motion')/16^2;
                R_inter = Rres_inter + Roffset_inter + Rpos_inter;
                
                Dist_intra = blocks{quantStep,nframe}{nrow,ncol}.MSEIntra;               
                %Dist_inter = blocks{quantStep,nframe}{ii,jj}.MSEInter;

                
                if nframe==1
                    % the first frame has to be transmitted in intra mode
                    J_copy = inf;
                    J_inter= inf;
                    
                    % Calculations for Inter Mode
                    % get residual and motion vector
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVecAll,...
                     blocks{quantStep,nframe}{nrow,ncol}.residualAll ] = ...
                        jzlk_findMotionVec(V{nframe}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                    
                    % Apply DCT transform and quantize
                    [blocks{quantStep,nframe}{nrow,ncol}.resDCTAll,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSEresAll ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residualAll, ...
                        delta(quantStep));
                    
                else
                    % Calculate the distortion between the previously sent
                    % coefficients and the UNquantized DCT coefficients of the
                    % current frame
                    framePrevSent = Vreceived_blk{quantStep,nframe-1}{nrow,ncol};
                    frameCur = blocks{quantStep,nframe}{nrow,ncol}.imgData;
                    Dist_copy = sum(abs(framePrevSent(:)-frameCur(:)).^2)/16^2;
                    
                    % Calculations for Inter Mode
                    % get residual and motion vector
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVecAll,...
                     blocks{quantStep,nframe}{nrow,ncol}.residualAll ] = ...
                        jzlk_findMotionVec(Vreceived{quantStep,nframe-1}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                    
                    % Apply DCT transform and quantize
                    [blocks{quantStep,nframe}{nrow,ncol}.resDCTAll,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSEresAll ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residualAll, ...
                        delta(quantStep));
                    
                     %reconstruct image from residual and motion vector
                     resimg = decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll);
                     prevPos = blocks{quantStep,nframe}{nrow,ncol}.pos + ...
                         blocks{quantStep,nframe}{nrow,ncol}.motionVecAll;
                     previmgpart = Vreceived{quantStep,nframe-1}...
                         (prevPos(1):prevPos(1)+15, prevPos(2):prevPos(2)+15);

                     reconstructedImg = previmgpart + resimg;
                     
                     % To be tested
                     Dist_inter = sum(abs(reconstructedImg(:)-...
                     Vblk16{nframe}{nrow,ncol}(:)).^2)/(M*N);
                    
                    
                    % calculate cost functions
                    J_copy = Dist_copy + lambda*R_copy;
                    J_inter = Dist_inter + lambda*R_inter;
                end
                
                J_intra = Dist_intra + lambda*R_intra;
                
                minIdx = find(min([J_intra J_copy J_inter]));
                minIdx = minIdx(1);
                
                % compare cost functions and decide on mode
                if minIdx == 1 % intra mode
                    blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll = DCTCoef;
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 1;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_intra; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_intra;
                    Vreceived{quantStep,nframe}{nrow,ncol} = ...
                        decode_intraframe2(DCTCoef);
                elseif minIdx == 2 % copy mode
                    blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll = ...
                        blocks{quantStep,nframe-1}{nrow,ncol}.receivedDCTAll;
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 2;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_copy; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_copy;
                    Vreceived{quantStep,nframe}{nrow,ncol} = ...
                    decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll);
                elseif minIdx == 3 % inter mode
                    blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll = ...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll;
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 3;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_inter; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_inter;
                    Vreceived{quantStep,nframe}{nrow,ncol} = reconstructedImg;
                end
                
                % it already contains 2 bit for decision
%                 blocks{quantStep,nframe}{ii,jj}.RIntra = R_intra;
%                 blocks{quantStep,nframe}{ii,jj}.RCopy = R_copy;
%                 blocks{quantStep,nframe}{ii,jj}.RInter = R_inter;
                

                
            end
        end
        Vreceived_blk{quantStep,nframe} = Vreceived{quantStep,nframe};
        Vreceived{quantStep,nframe} = cell2mat(Vreceived{quantStep,nframe});
    end
end


