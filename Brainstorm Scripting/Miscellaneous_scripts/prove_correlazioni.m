cd('/Users/giorgioarcara/Desktop/')

load('RES_COR.mat')
load('RES_PVAL.mat')


 % Initialize output structure
    sOutput = db_template('statmat');
    sOutput.pmap         = RES_PVAL;
    sOutput.tmap         = RES_COR;
    sOutput.df           = length(group_merged)/2;
    sOutput.Correction   = 'no';
    sOutput.Type         = 'presults';
    sOutput.ChannelFlag  = ref_info.GoodChannels;
    sOutput.Time         = ref_info.Time;
    sOutput.ColormapType = 'stat2';
    sOutput.DisplayUnits = 'r';
    sOutput.nComponents  = [];
    sOutput.GridAtlas    = [];
    sOutput.Freqs        = [];
    sOutput.TFmask       = [];