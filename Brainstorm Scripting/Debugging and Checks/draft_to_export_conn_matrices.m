

% Input files
sFiles = {...
    'CT/CT_ArcaraMapping_20160127_03_band/timefreq_connectn_corr_170310_0919.mat'};

my_conn=in_bst_data(sFiles{1});

R = bst_memory('GetConnectMatrix', my_conn);

% Channel correspondence can be get from index
% e.g.,  my_conn.RowNames(2) is the second row and the second column.

