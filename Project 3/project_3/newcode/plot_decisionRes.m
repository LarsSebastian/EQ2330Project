function [ output_args ] = plot_decisionRes( frameintra_for,framecopy_for, framemotion_for, frameintra_mot, framecopy_mot, framemotion_mot, quant )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

figure;
plot(frameintra_for, 'o-','LineWidth', 2);
hold on;
plot(framecopy_for ,'rx-.', 'LineWidth', 2);
plot(framemotion_for, 'k--', 'LineWidth', 2);
grid on;
xlabel('frame');
ylabel('#');
title(['decisions for video foreman\_qcif.yuv, quantization level: ', num2str(quant)]);


legend('intra mode', 'copy mode', 'motion compensation');
hold off;

figure;
plot(frameintra_mot, 'o-','LineWidth', 2);
hold on;
plot(framecopy_mot ,'rx-.', 'LineWidth', 2);
plot(framemotion_mot, 'k--', 'LineWidth', 2);
grid on;
xlabel('frame');
ylabel('#');
title(['decisions for video mother-daugher\_qcif.yuv, quantization level: ', num2str(quant)]);

legend('intra mode', 'copy mode', 'motion compensation');  

hold off;

end

