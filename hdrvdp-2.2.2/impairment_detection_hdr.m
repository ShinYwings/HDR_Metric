% This example demonstrates how HDR-VDP can be used to detect impairments
% in HDR images. 
%
% Note that the predicted visibility of introduced distortions may not
% match the visibility of those seen on the screen. The HDR images are scaled in
% absolute photometric units and parts of the image are much darker than
% shown in tone-mapped images, making distortions less visible.

imgs = dir('./img/laval_hdr_mantiuk/*.hdr');
refimgs = dir('./img/val_hdrs/*.hdr');

if ~exist( 'hdrvdp3', 'file' )
        addpath( fullfile( pwd, '..') );
end

pu21 = pu21_encoder();

psnr = [];
ssim = [];
qscore = [];

for i = 1:numel(imgs)
    ref_path= append("./img/val_hdrs/", refimgs(i).name);
    pred_path = append("./img/laval_hdr_mantiuk/", imgs(i).name);
    disp(ref_path)
    disp(pred_path)
    
    P_ref = hdrread( ref_path );
    P_pred = hdrread( pred_path );
    
    % my way
    PSNR_me = pu21_metric( P_pred, P_ref, 'PSNR', min(P_ref(:)), max(P_ref(:)));
    SSIM_me = pu21_metric( P_pred, P_ref, 'SSIM', min(P_ref(:)), max(P_ref(:)));
    
    % singleHDR way
    I_pred = pre_hdr_p3(P_pred);
    I_ref = pre_hdr_p3(P_ref);
    
    % original way
    %P_ref = P_ref/max(P_ref(:)) * 10000;
    %P_pred = P_pred/max(P_ref(:)) * 10000;
    %PSNR_me = pu21_metric( P_pred, P_ref, 'PSNR', 0, 10000);
    %SSIM_me = pu21_metric( P_pred, P_ref, 'SSIM', 0, 10000);
    
    % Find the angular resolution in pixels per visual degree:
    % 30" 4K monitor seen from 0.5 meters
    %ppd = hdrvdp_pix_per_deg( 30, [3840 2160], 0.5 );
    
    %res_pred = hdrvdp( I_pred, I_ref, 'rgb-native', ppd, {} );
    res_pred = hdrvdp( I_pred, I_ref, 'rgb-bt.709', 30 );
    
    % context image to show in the visualization
    %I_context = get_luminance( I_ref );

    % Visualize images assuming 200 cd/m^2 display
    % This size is not going to be correct because we are using subplot
    
    %gamma = 2.2;
    %L_peak = 200;
    
    %clf
    %subplot( 4, 1, 1 );
    %imshow( (I_ref/L_peak).^(1/gamma) );
    %title( 'reference image after pu21-encoding' );

    %subplot( 4, 1, 2 );
    %imshow( (P_pred/L_peak).^(1/gamma) );
    %title( 'predition image' );

    %subplot( 4, 1, 3 );
    %imshow( (I_pred/L_peak).^(1/gamma) );
    %title( 'predition image after pu21-encoding' );

    %subplot( 4, 1, 4 );
    %imshow( hdrvdp_visualize( (res_pred.P_map), I_context ) );
    %title( 'Detection of pred' );
    
    txt = sprintf('PSNR = %g dB,   SSIM = %g,   Qscore = %g\n', PSNR_me, SSIM_me, res_pred.Q);
    disp(txt);
    %text(-30,45,txt);
    
    psnr(end+1) = PSNR_me;
    ssim(end+1) = SSIM_me;
    qscore(end+1) = res_pred.Q;
    %fprintf( 1, 'Evaluation: PSNR = %g dB, SSIM = %g, Q_Score = %g\n', PSNR_me, SSIM_me, res_pred.Q );
    
    %savepath = sprintf('./output/%d.png', i);
    %saveas(gcf,savepath);

end

psnr_clean  =  psnr(~isinf(psnr));
ssim_clean  =  ssim(~isinf(ssim));
qscore_clean  =  qscore(~isinf(qscore));
res = sprintf('[MEAN] PSNR = %g dB,   SSIM = %g,   Qscore = %g\n', mean(psnr_clean,'omitnan'), mean(ssim,'omitnan'), mean(qscore,'omitnan'));

disp(res);
%mean_psnr = length(pnsr);

figure
subplot(1,3,1);
boxplot(psnr);
title( 'PSNR' );

subplot(1,3,2);
boxplot(ssim);
title( 'SSIM' );

subplot(1,3,3);
boxplot(qscore);
title( 'Q Score' );

% Reference: https://github.com/alex04072000/SingleHDR/issues/4
function hdr = pre_hdr_p3(hdr)
    eps = 1e-8;
    s = size(hdr(:), 1);
    k = int64(s*1e-3);
    a = mink(hdr(:), k);
    a = a(end);
    b = maxk(hdr(:), k);
    b = b(end);
    c = 1.0;
    d = 999.0;
    hdr = (hdr - a).*(d - c)./(b - a + eps) + c;
    hdr(hdr < 0) = 0;
end
