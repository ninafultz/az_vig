%plotting az srtm3 comparisons 
    %usage: assess whether srtm3 can handle shorter time frames
    %nina fultz 2022

subj_control = ''
subj = ''

roi='raphe_nuclei'

%rois={'amygdala' 'cortex' 'ACC' 'cingulate'}
srtm2_types = {'SRTM3_15min', 'SRTM3_20min', 'SRTM3_30min'}

x = categorical({'control', 'vigilance'})
x = reordercats(x,{'control', 'vigilance'})

%% setting parent directory

path = ''
addpath(genpath(pwd)) %adding current path and subfolders

matrix_control = []
matrix_emotion = []

%% defining tac components for pet plot 
    % 8) Reference smoothed
%for a = 1:length(rois)
for i = 1:length(srtm2_types)
   srtm2_type = srtm2_types{i} 
   %srtm2_type = srtm{a}

% bpnd data control: subject at baseline

bp_data_control = load(fullfile(path, subj_control, '/pet/fastmap_outputs/', srtm2_type, '/bp_results/', [roi '.txt']))
bp_control = bp_data_control(:,5)
bp_all_control(:,i)=bp_control

bp_baseline_control(:,i) = bp_data_control(15,5)
bp_task_control(:,i) = bp_data_control(38,5)
percent_change_control(:,i) = ((bp_task_control-bp_baseline_control)/bp_baseline_control)*100

percent_change_control(:,i) = ((bp_task_control-bp_baseline_control)/bp_baseline_control)*100

%bpnd interventation -- emotion stimulus
bp_data = load(fullfile(path, subj, '/pet/fastmap_outputs/', srtm2_type, '/bp_results/', [roi '.txt']))
bpnd = bp_data(:,5)
bpnd_all(:,i)=bpnd

bpnd_task(:,i) = bp_data(38,5)
bpnd_baseline(:,i) = bp_data(15,5)
percent_change(:,i) = ((bpnd_task-bpnd_baseline)/bpnd_baseline)*100

end

%% 

%figure; hold on
for i=1:length(srtm2_types)
    srtm2_type = srtm2_types{i} 
    %hold on 
    subplot(4,1,i)
    plot([1 2], [percent_change_control(i) percent_change(i)], 'Color', [0.9100 0.4100 .1700]); hold on
    scatter([1 2], [percent_change_control(i) percent_change(i)], 'filled', 'MarkerFaceColor', [0.9290 0.6940 0.1250], 'MarkerEdgeColor', [0.9290 0.6940 0.1250])
    hold on
    
    title(['BPND of ' roi ' with ' srtm2_type], 'Interpreter', 'none'); hold on;
       %title((roi) 'BPND Percent Change');
   ax = gca;
   ax.XTick = [1,2];
   ax.XTickLabels = {'Control', 'Vigilance'}
   ylabel('% BPND Change')
   xlim([0.5, 2.5 ])
   %ylim([4, 12])
     set(gcf, 'color', 'w'); hold on

    subplot(4,1,4)
    plot([1 2], [percent_change_control(i) percent_change(i)]); hold on
    scatter([1 2], [percent_change_control(i) percent_change(i)], 'filled')
    %legend(srtm2_types)
    
    title(['BPND of ' roi ' with all SRTM time points'], 'Interpreter', 'none'); hold on;
    
   ax = gca;
   ax.XTick = [1,2];
   ax.XTickLabels = {'Control', 'Vigilance'}
   ylabel('% BPND Change')
   xlim([0.5, 2.5 ])
   %ylim([4, 12])
   set(gcf, 'color', 'w');
 

end
